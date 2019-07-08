codeunit 6150851 "POS Action - Bin Transfer"
{
    // 
    // NPR5.43/TSA /20180416 CASE 311964 Transfer content from one bin to another bin


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This action transfer funds from one bin to a different bin using the thPOS';

    local procedure ActionCode(): Text
    begin
        exit ('BIN_TRANSFER');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          ActionDescription,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)
        then begin

          Sender.RegisterWorkflowStep ('SELECTBIN', 'respond();');
          Sender.RegisterWorkflowStep ('TRANSFER', 'respond();');

          Sender.RegisterOptionParameter ('SourceBinSelection', 'PosUnitDefaultBin,UserSelection,FixedParameter', 'PosUnitDefaultBin');
          Sender.RegisterTextParameter ('SourceBin', '');
          Sender.RegisterWorkflow (false);

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
          exit;

        Handled := true;
        case WorkflowStep of
          'SELECTBIN': SelectSourceBin (Context, POSSession, FrontEnd);
          'TRANSFER' : TransferContentsToBin (Context, POSSession, FrontEnd);
        end;
    end;

    procedure TransferContentsToBin(Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        JSON: Codeunit "POS JSON Management";
        CheckpointEntryNo: Integer;
        PaymentBinCheckpoint: Codeunit "POS Payment Bin Checkpoint";
        POSWorkshiftCheckpoint: Codeunit "POS Workshift Checkpoint";
        WorkshiftCheckpoint: Record "POS Workshift Checkpoint";
        POSCreateEntry: Codeunit "POS Create Entry";
        PaymentBinCheckpointPage: Page "POS Payment Bin Checkpoint";
        POSPaymentBinCheckpoint: Record "POS Payment Bin Checkpoint";
        PageAction: Action;
        SalePOS: Record "Sale POS";
        POSSale: Codeunit "POS Sale";
        FromBinNo: Code[10];
        POSPostEntries: Codeunit "POS Post Entries";
        POSEntryToPost: Record "POS Entry";
        EntryNo: Integer;
    begin

        JSON.InitializeJObjectParser (Context, FrontEnd);
        FromBinNo := JSON.GetString ('FROM_BIN', true);

        //-NPR5.43 [310815]
        CheckpointEntryNo := POSWorkshiftCheckpoint.CreateEndWorkshiftCheckpoint_POSEntry (FromBinNo);

        //-NPR5.43 [311964]
        WorkshiftCheckpoint.Get (CheckpointEntryNo);
        WorkshiftCheckpoint.Type := WorkshiftCheckpoint.Type::TRANSFER;
        WorkshiftCheckpoint.Modify ();
        //+NPR5.43 [311964]

        PaymentBinCheckpoint.CreatePosEntryBinCheckpoint (GetUnitNo (POSSession), FromBinNo, CheckpointEntryNo);
        Commit;

        // Confirm amounts counted and float/bank/safe transfer
        POSPaymentBinCheckpoint.Reset ();
        POSPaymentBinCheckpoint.FilterGroup (2);
        POSPaymentBinCheckpoint.SetFilter ("Workshift Checkpoint Entry No.", '=%1', CheckpointEntryNo);
        POSPaymentBinCheckpoint.FilterGroup (0);

        PaymentBinCheckpointPage.SetTableView (POSPaymentBinCheckpoint);
        PaymentBinCheckpointPage.LookupMode (true);
        PaymentBinCheckpointPage.SetTransferMode();
        PageAction := PaymentBinCheckpointPage.RunModal();
        Commit;

        if (PageAction = ACTION::LookupOK) then begin
          POSPaymentBinCheckpoint.Reset ();
          POSPaymentBinCheckpoint.SetFilter ("Workshift Checkpoint Entry No.", '=%1', CheckpointEntryNo);
          POSPaymentBinCheckpoint.SetFilter (Status, '=%1' , POSPaymentBinCheckpoint.Status::READY);
          if (POSPaymentBinCheckpoint.FindFirst ()) then begin

            POSSession.GetSale (POSSale);
            POSSale.GetCurrentSale (SalePOS);

            EntryNo := POSCreateEntry.CreateBalancingEntryAndLines(SalePOS, false, CheckpointEntryNo);

            //-NPR5.43 [311964]
            // Posting
            POSEntryToPost.Get (EntryNo);
            POSEntryToPost.SetRecFilter();

            if (POSEntryToPost."Post Item Entry Status" < POSEntryToPost."Post Item Entry Status"::Posted) then
              POSPostEntries.SetPostItemEntries (false);

            if (POSEntryToPost."Post Entry Status" < POSEntryToPost."Post Entry Status"::Posted) then
              POSPostEntries.SetPostPOSEntries (true);

            POSPostEntries.SetStopOnError (true);
            POSPostEntries.SetPostCompressed (false);
            POSPostEntries.Run (POSEntryToPost);
            Commit;

            POSSession.ChangeViewLogin ();
            //+NPR5.43 [311964]

          end;
        end;
        //+NPR5.43 [310815]
    end;

    local procedure SelectSourceBin(Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        JSON: Codeunit "POS JSON Management";
        FromBinNo: Code[10];
        SourceBinSelection: Integer;
    begin

        JSON.InitializeJObjectParser (Context, FrontEnd);
        SourceBinSelection := JSON.GetIntegerParameter ('SourceBinSelection', true);
        case SourceBinSelection of
          1 : FromBinNo := UserSelectBin (POSSession);
          2 : FromBinNo := GetFixedBin (Context, POSSession, FrontEnd);
          else
            FromBinNo := GetDefaultUnitBin (POSSession);
        end;
        JSON.SetContext ('FROM_BIN', FromBinNo);
        FrontEnd.SetActionContext (ActionCode, JSON);
    end;

    local procedure UserSelectBin(POSSession: Codeunit "POS Session"): Code[10]
    var
        POSSetup: Codeunit "POS Setup";
        POSUnit: Record "POS Unit";
        POSUnittoBinRelation: Record "POS Unit to Bin Relation";
        POSUnittoBinRelationPage: Page "POS Unit to Bin Relation";
        PageAction: Action;
    begin

        POSSession.GetSetup (POSSetup);
        POSSetup.GetPOSUnit (POSUnit);

        POSUnittoBinRelation.SetFilter ("POS Unit No.", '=%1', POSUnit."No.");
        POSUnittoBinRelation.FilterGroup (2);
        POSUnittoBinRelationPage.SetTableView (POSUnittoBinRelation);
        POSUnittoBinRelation.FilterGroup (0);
        POSUnittoBinRelationPage.LookupMode (true);
        PageAction := POSUnittoBinRelationPage.RunModal ();
        if (PageAction <> ACTION::LookupOK) then
          Error  ('Bin selection aborted.');

        POSUnittoBinRelationPage.GetRecord (POSUnittoBinRelation);
        exit (POSUnittoBinRelation."POS Payment Bin No.");
    end;

    local procedure GetFixedBin(Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management"): Code[10]
    var
        JSON: Codeunit "POS JSON Management";
    begin

        JSON.InitializeJObjectParser (Context, FrontEnd);
        exit (JSON.GetStringParameter ('SourceBin', true));
    end;

    local procedure GetDefaultUnitBin(POSSession: Codeunit "POS Session"): Code[10]
    var
        POSSetup: Codeunit "POS Setup";
        POSUnit: Record "POS Unit";
    begin

        POSSession.GetSetup (POSSetup);
        POSSetup.GetPOSUnit (POSUnit);

        POSUnit.TestField ("Default POS Payment Bin");
        exit (POSUnit."Default POS Payment Bin");
    end;

    local procedure GetUnitNo(POSSession: Codeunit "POS Session"): Code[10]
    var
        POSSetup: Codeunit "POS Setup";
        POSUnit: Record "POS Unit";
    begin

        POSSession.GetSetup (POSSetup);
        POSSetup.GetPOSUnit (POSUnit);

        exit (POSUnit."No.");
    end;
}

