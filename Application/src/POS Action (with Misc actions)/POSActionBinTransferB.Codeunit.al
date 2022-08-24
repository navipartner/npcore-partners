codeunit 6059837 "NPR POS Action: Bin Transfer B"
{
    Access = Internal;

    procedure TransferContentsToBin(POSSession: Codeunit "NPR POS Session"; FromBinNo: Code[10]; CheckpointEntryNo: Integer)
    var
        PaymentBinCheckpoint: Codeunit "NPR POS Payment Bin Checkpoint";
        WorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSSale: Codeunit "NPR POS Sale";
        PaymentBinCheckpointPage: Page "NPR POS Payment Bin Checkpoint";
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        PageAction: Action;
        SalePOS: Record "NPR POS Sale";
        POSPostEntries: Codeunit "NPR POS Post Entries";
        POSEntryToPost: Record "NPR POS Entry";
        EntryNo: Integer;
    begin
        WorkshiftCheckpoint.Get(CheckpointEntryNo);
        WorkshiftCheckpoint.Type := WorkshiftCheckpoint.Type::TRANSFER;
        WorkshiftCheckpoint.Modify();


        PaymentBinCheckpoint.CreatePosEntryBinCheckpoint(GetUnitNo(POSSession), FromBinNo, CheckpointEntryNo, POSPaymentBinCheckpoint.type::TRANSFER);
        Commit();

        // Confirm amounts counted and float/bank/safe transfer
        POSPaymentBinCheckpoint.Reset();
        POSPaymentBinCheckpoint.FilterGroup(2);
        POSPaymentBinCheckpoint.SetRange("Workshift Checkpoint Entry No.", CheckpointEntryNo);
        POSPaymentBinCheckpoint.FilterGroup(0);

        PaymentBinCheckpointPage.SetTableView(POSPaymentBinCheckpoint);
        PaymentBinCheckpointPage.LookupMode(true);
        PaymentBinCheckpointPage.SetTransferMode();
        PageAction := PaymentBinCheckpointPage.RunModal();
        Commit();

        if (PageAction = ACTION::LookupOK) then begin
            POSPaymentBinCheckpoint.Reset();
            POSPaymentBinCheckpoint.SetRange("Workshift Checkpoint Entry No.", CheckpointEntryNo);
            POSPaymentBinCheckpoint.SetRange(Status, POSPaymentBinCheckpoint.Status::READY);
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

    procedure PrintBinTransfer(CheckpointEntryNo: Integer)
    var
        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        RecRef: RecordRef;
    begin
        POSWorkshiftCheckpoint.SetRange("Entry No.", CheckpointEntryNo);
        POSWorkshiftCheckpoint.SetRange(Type, POSWorkshiftCheckpoint.Type::TRANSFER);
        if not POSWorkshiftCheckpoint.FindFirst() then
            exit;
        RecRef.GetTable(POSWorkshiftCheckpoint);
        RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Bin Transfer".AsInteger());
    end;

    procedure UserSelectBin(POSSession: Codeunit "NPR POS Session"): Code[10]
    var
        POSSetup: Codeunit "NPR POS Setup";
        POSUnit: Record "NPR POS Unit";
        POSUnittoBinRelation: Record "NPR POS Unit to Bin Relation";
        POSUnittoBinRelationPage: Page "NPR POS Unit to Bin Relation";
        PageAction: Action;
    begin

        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);

        POSUnittoBinRelation.SetRange("POS Unit No.", POSUnit."No.");
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

    local procedure GetUnitNo(POSSession: Codeunit "NPR POS Session"): Code[10]
    var
        POSSetup: Codeunit "NPR POS Setup";
        POSUnit: Record "NPR POS Unit";
    begin

        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);

        exit(POSUnit."No.");
    end;

    procedure GetDefaultUnitBin(POSSession: Codeunit "NPR POS Session"): Code[10]
    var
        POSSetup: Codeunit "NPR POS Setup";
        POSUnit: Record "NPR POS Unit";
    begin
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        POSUnit.TestField("Default POS Payment Bin");
        exit(POSUnit."Default POS Payment Bin");
    end;
}