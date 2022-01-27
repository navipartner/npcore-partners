codeunit 6150851 "NPR POS Action: Bin Transfer"
{
    Access = Internal;
    var
        ActionDescriptionLbl: Label 'This action transfer funds from one bin to a different bin using the thPOS';

    local procedure ActionCode(): Code[20]
    begin
        exit('BIN_TRANSFER');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          ActionDescriptionLbl,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)
        then begin

            Sender.RegisterWorkflowStep('SELECTBIN', 'respond();');
            Sender.RegisterWorkflowStep('TRANSFER', 'respond();');

            Sender.RegisterOptionParameter('SourceBinSelection', 'PosUnitDefaultBin,UserSelection,FixedParameter', 'PosUnitDefaultBin');
            Sender.RegisterTextParameter('SourceBin', '');
            Sender.RegisterWorkflow(false);

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;
        case WorkflowStep of
            'SELECTBIN':
                SelectSourceBin(Context, POSSession, FrontEnd);
            'TRANSFER':
                TransferContentsToBin(Context, POSSession, FrontEnd);
        end;
    end;

    procedure TransferContentsToBin(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        CheckpointEntryNo: Integer;
        PaymentBinCheckpoint: Codeunit "NPR POS Payment Bin Checkpoint";
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
        WorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        PaymentBinCheckpointPage: Page "NPR POS Payment Bin Checkpoint";
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        PageAction: Action;
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        FromBinNo: Code[10];
        POSPostEntries: Codeunit "NPR POS Post Entries";
        POSEntryToPost: Record "NPR POS Entry";
        EntryNo: Integer;
        ReadingErr: Label 'reading in TransferContentsToBin';
    begin

        JSON.InitializeJObjectParser(Context, FrontEnd);
        FromBinNo := CopyStr(JSON.GetStringOrFail('FROM_BIN', ReadingErr), 1, MaxStrLen(FromBinNo));

        CheckpointEntryNo := POSWorkshiftCheckpoint.CreateEndWorkshiftCheckpoint_POSEntry(FromBinNo);

        WorkshiftCheckpoint.Get(CheckpointEntryNo);
        WorkshiftCheckpoint.Type := WorkshiftCheckpoint.Type::TRANSFER;
        WorkshiftCheckpoint.Modify();

        PaymentBinCheckpoint.CreatePosEntryBinCheckpoint(GetUnitNo(POSSession), FromBinNo, CheckpointEntryNo);
        Commit();

        // Confirm amounts counted and float/bank/safe transfer
        POSPaymentBinCheckpoint.Reset();
        POSPaymentBinCheckpoint.FilterGroup(2);
        POSPaymentBinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', CheckpointEntryNo);
        POSPaymentBinCheckpoint.FilterGroup(0);

        PaymentBinCheckpointPage.SetTableView(POSPaymentBinCheckpoint);
        PaymentBinCheckpointPage.LookupMode(true);
        PaymentBinCheckpointPage.SetTransferMode();
        PageAction := PaymentBinCheckpointPage.RunModal();
        Commit();

        if (PageAction = ACTION::LookupOK) then begin
            POSPaymentBinCheckpoint.Reset();
            POSPaymentBinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', CheckpointEntryNo);
            POSPaymentBinCheckpoint.SetFilter(Status, '=%1', POSPaymentBinCheckpoint.Status::READY);
            if (POSPaymentBinCheckpoint.FindFirst()) then begin

                POSSession.GetSale(POSSale);
                POSSale.GetCurrentSale(SalePOS);

                EntryNo := POSCreateEntry.CreateBalancingEntryAndLines(SalePOS, false, CheckpointEntryNo);

                // Posting
                POSEntryToPost.Get(EntryNo);
                POSEntryToPost.SetRecFilter();

                if (POSEntryToPost."Post Item Entry Status" < POSEntryToPost."Post Item Entry Status"::Posted) then
                    POSPostEntries.SetPostItemEntries(false);

                if (POSEntryToPost."Post Entry Status" < POSEntryToPost."Post Entry Status"::Posted) then
                    POSPostEntries.SetPostPOSEntries(true);

                POSPostEntries.SetStopOnError(true);
                POSPostEntries.SetPostCompressed(false);
                POSPostEntries.Run(POSEntryToPost);
                Commit();

                POSSession.ChangeViewLogin();
            end;
        end;
    end;

    local procedure SelectSourceBin(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        FromBinNo: Code[10];
        SourceBinSelection: Integer;
    begin

        JSON.InitializeJObjectParser(Context, FrontEnd);
        SourceBinSelection := JSON.GetIntegerParameterOrFail('SourceBinSelection', ActionCode());
        case SourceBinSelection of
            1:
                FromBinNo := UserSelectBin(POSSession);
            2:
                FromBinNo := GetFixedBin(Context, FrontEnd);
            else
                FromBinNo := GetDefaultUnitBin(POSSession);
        end;
        JSON.SetContext('FROM_BIN', FromBinNo);
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure UserSelectBin(POSSession: Codeunit "NPR POS Session"): Code[10]
    var
        POSSetup: Codeunit "NPR POS Setup";
        POSUnit: Record "NPR POS Unit";
        POSUnittoBinRelation: Record "NPR POS Unit to Bin Relation";
        POSUnittoBinRelationPage: Page "NPR POS Unit to Bin Relation";
        PageAction: Action;
    begin

        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);

        POSUnittoBinRelation.SetFilter("POS Unit No.", '=%1', POSUnit."No.");
        POSUnittoBinRelation.FilterGroup(2);
        POSUnittoBinRelationPage.SetTableView(POSUnittoBinRelation);
        POSUnittoBinRelation.FilterGroup(0);
        POSUnittoBinRelationPage.LookupMode(true);
        PageAction := POSUnittoBinRelationPage.RunModal();
        if (PageAction <> ACTION::LookupOK) then
            Error('Bin selection aborted.');

        POSUnittoBinRelationPage.GetRecord(POSUnittoBinRelation);
        exit(POSUnittoBinRelation."POS Payment Bin No.");
    end;

    local procedure GetFixedBin(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management"): Code[10]
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin

        JSON.InitializeJObjectParser(Context, FrontEnd);
        exit(CopyStr(JSON.GetStringParameterOrFail('SourceBin', ActionCode()), 1, 10));
    end;

    local procedure GetDefaultUnitBin(POSSession: Codeunit "NPR POS Session"): Code[10]
    var
        POSSetup: Codeunit "NPR POS Setup";
        POSUnit: Record "NPR POS Unit";
    begin
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        POSUnit.TestField("Default POS Payment Bin");
        exit(POSUnit."Default POS Payment Bin");
    end;

    local procedure GetUnitNo(POSSession: Codeunit "NPR POS Session"): Code[10]
    var
        POSSetup: Codeunit "NPR POS Setup";
        POSUnit: Record "NPR POS Unit";
    begin

        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);

        exit(POSUnit."No.");
    end;
}

