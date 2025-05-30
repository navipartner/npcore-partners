﻿codeunit 6150627 "NPR POS Workshift Checkpoint"
{
    Access = Internal;

    var
        MissingBin: Label 'No payment bin relation found for POS Unit %1.';

        POS_UNIT_SLAVE_STATUS: Label 'This POS manages other units for End-of-Day. The other units need to be in status closed, which is done with "Close Workshift" action. POS unit %1 has status %2.';
        EndOfDayUIOption: Option SUMMARY,BALANCING,"NONE";
        EodWorkshiftMode: Option XREPORT,ZREPORT,CLOSEWORKSHIFT;

    procedure EndWorkshift(Mode: Option; UnitNo: Code[10]; DimensionSetId: Integer) PosEntryNo: Integer
    begin
        // Main function to end the workshift
        PosEntryNo := CloseWorkshiftWorker(Mode, UnitNo, DimensionSetId);

        Commit();
        OnAfterEndWorkshift(Mode, UnitNo, (PosEntryNo <> 0), PosEntryNo);

        exit(PosEntryNo);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterEndWorkshift(Mode: Option; UnitNo: Code[10]; Successful: Boolean; PosEntryNo: Integer)
    begin
        // Mode:          XREPORT = 0, ZREPORT = 1, CLOSEWORKSHIFT = 2
        // Unit No.:      The POS Unit being balanced
        // Successful:    EOD posted successfully
        // Pos Entry No:  can be zero
    end;

    procedure BinTransfer(UsePosEntry: Boolean; WithPosting: Boolean; POSStoreCode: Code[10]; UnitNo: Code[10])
    var
        POSUnit: Record "NPR POS Unit";
        CheckPointEntryNo: Integer;
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        POSCheckpointMgr: Codeunit "NPR POS Workshift Checkpoint";
    begin
        if POSUnit.Get(UnitNo) then;
        CheckPointEntryNo := POSCheckpointMgr.CreateEndWorkshiftCheckpoint_POSEntry(POSStoreCode, UnitNo, POSUnit.Status);
        POSWorkshiftCheckpoint.Get(CheckPointEntryNo);
        Commit();

        CreateBinCheckpoint(CheckPointEntryNo, POSPaymentBinCheckpoint.Type::NA);
        Commit();
    end;

    procedure CreateBinCheckpoint(CheckPointEntryNo: Integer; PaymentBinCheckpointType: Option)
    var
        PaymentBinCheckpoint: Codeunit "NPR POS Payment Bin Checkpoint";
        UnittoBinRelation: Record "NPR POS Unit to Bin Relation";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSUnit: Record "NPR POS Unit";
    begin

        POSWorkshiftCheckpoint.Get(CheckPointEntryNo);

        POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.");

        if (POSUnit."Default POS Payment Bin" <> '') then
            PaymentBinCheckpoint.CreatePosEntryBinCheckpoint(POSUnit."No.", POSUnit."Default POS Payment Bin", CheckPointEntryNo, PaymentBinCheckpointType);

        UnittoBinRelation.SetFilter("POS Unit No.", '=%1', POSWorkshiftCheckpoint."POS Unit No.");
        if (UnittoBinRelation.FindSet()) then begin
            repeat
                PaymentBinCheckpoint.CreatePosEntryBinCheckpoint(UnittoBinRelation."POS Unit No.", UnittoBinRelation."POS Payment Bin No.", CheckPointEntryNo, PaymentBinCheckpointType);

            until (UnittoBinRelation.Next() = 0);
        end else begin
            if POSUnit."Default POS Payment Bin" = '' then
                Error(MissingBin, POSWorkshiftCheckpoint."POS Unit No.");

        end;

    end;

    procedure CloseWorkshift(UsePosEntry: Boolean; WithPosting: Boolean; UnitNo: Code[10]) PosEntryNo: Integer
    begin
        exit(CloseWorkshiftWithDimension(UsePosEntry, WithPosting, UnitNo, 0));
    end;

    procedure CloseWorkshiftWithDimension(UsePosEntry: Boolean; WithPosting: Boolean; UnitNo: Code[10]; DimensionSetId: Integer) PosEntryNo: Integer
    var
        Mode: Option;
    begin

        // THIS METHOD SHOULD BE DEPRECATED, but not yet deleted.
        case WithPosting of
            true:
                Mode := EodWorkshiftMode::ZREPORT;
            false:
                Mode := EodWorkshiftMode::XREPORT;
        end;

        exit(CloseWorkshiftWorker(Mode, UnitNo, DimensionSetId));

    end;

    local procedure CloseWorkshiftWorker(Mode: Option; UnitNo: Code[10]; DimensionSetId: Integer) PosEntryNo: Integer
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSUnit: Record "NPR POS Unit";
        CheckpointEntryNo: Integer;
        EoDConfirmed: Boolean;
    begin

        PosEntryNo := 0;
        POSUnit.Get(UnitNo);

        CheckpointEntryNo := CreateCheckpointWorker(Mode, UnitNo, POSUnit.Status);
        if (not POSWorkshiftCheckpoint.Get(CheckpointEntryNo)) then
            exit(0);

        EoDConfirmed := ShowEndOfDayUI(CheckpointEntryNo, Mode, UnitNo);

        // Create the balancing entries and post if z-report
        if (EoDConfirmed) then
            PosEntryNo := CreateBalancingEntry(Mode, UnitNo, CheckpointEntryNo, DimensionSetId);

    end;

    local procedure ShowEndOfDayUI(CheckpointEntryNo: Integer; Mode: Option; UnitNo: Code[20]) ConfirmEoD: Boolean
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        POSUnit: Record "NPR POS Unit";
        POSEndofDayProfile: Record "NPR POS End of Day Profile";
        PageAction: Action;
        POSWorkshiftCheckpointPage: Page "NPR POS Workshift Checkp. Card";
        PaymentBinCheckpointPage: Page "NPR POS Payment Bin Checkpoint";
        UIOption: Option;
        BlindCount: Boolean;
    begin

        // UI default response
        ConfirmEoD := false;
        POSWorkshiftCheckpoint.Get(CheckpointEntryNo);
        POSUnit.Get(UnitNo);

        // Select Default UI
        case Mode of
            EodWorkshiftMode::ZREPORT:
                UIOption := EndOfDayUIOption::SUMMARY;
            EodWorkshiftMode::XREPORT:
                UIOption := EndOfDayUIOption::SUMMARY;
            EodWorkshiftMode::CLOSEWORKSHIFT:
                UIOption := EndOfDayUIOption::NONE;
        end;
        BlindCount := false;

        // Select UI from Profile
        if (POSUnit."POS End of Day Profile" <> '') then begin
            POSEndofDayProfile.Get(POSUnit."POS End of Day Profile");
            BlindCount := POSEndofDayProfile."Force Blind Counting";

            case Mode of
                EodWorkshiftMode::ZREPORT:
                    case POSEndofDayProfile."Z-Report UI" of
                        POSEndofDayProfile."Z-Report UI"::SUMMARY_BALANCING:
                            UIOption := EndOfDayUIOption::SUMMARY;
                        POSEndofDayProfile."Z-Report UI"::BALANCING:
                            UIOption := EndOfDayUIOption::BALANCING;
                    end;

                EodWorkshiftMode::XREPORT:
                    case POSEndofDayProfile."X-Report UI" of
                        POSEndofDayProfile."X-Report UI"::SUMMARY_PRINT:
                            UIOption := EndOfDayUIOption::SUMMARY;
                        POSEndofDayProfile."X-Report UI"::PRINT:
                            UIOption := EndOfDayUIOption::NONE;
                    end;

                EodWorkshiftMode::CLOSEWORKSHIFT:
                    UIOption := EndOfDayUIOption::NONE;
            end;
        end;

        if (not GuiAllowed()) then
            UIOption := EndOfDayUIOption::NONE;

        // Show the summary page as initial EOD page
        if (UIOption = EndOfDayUIOption::SUMMARY) then begin
            POSPaymentBinCheckpoint.Reset();
            POSWorkshiftCheckpointPage.SetRecord(POSWorkshiftCheckpoint);
            if (not POSPaymentBinCheckpoint.IsEmpty()) then begin
                POSWorkshiftCheckpointPage.SetBlindCount(BlindCount);
                case Mode of
                    EodWorkshiftMode::XREPORT:
                        POSWorkshiftCheckpointPage.SetCheckpointMode(0);
                    EodWorkshiftMode::ZREPORT:
                        POSWorkshiftCheckpointPage.SetCheckpointMode(1);
                end;

                POSWorkshiftCheckpointPage.LookupMode(true);
                PageAction := POSWorkshiftCheckpointPage.RunModal();
                ConfirmEoD := (PageAction = ACTION::LookupOK);
            end else begin
                // Nothing to balance
                ConfirmEoD := true;
            end;
        end;

        // Show the balancing page as initial EOD page
        if (UIOption = EndOfDayUIOption::BALANCING) then begin
            POSPaymentBinCheckpoint.Reset();
            POSPaymentBinCheckpoint.SetCurrentKey("Workshift Checkpoint Entry No.");
            POSPaymentBinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', CheckpointEntryNo);
            if (not POSPaymentBinCheckpoint.IsEmpty()) then begin

                PaymentBinCheckpointPage.SetTableView(POSPaymentBinCheckpoint);


                PaymentBinCheckpointPage.SetBlindCount(BlindCount);
                case Mode of
                    EodWorkshiftMode::XREPORT:
                        PaymentBinCheckpointPage.SetCheckpointMode(0);
                    EodWorkshiftMode::ZREPORT:
                        PaymentBinCheckpointPage.SetCheckpointMode(1);
                end;

                PaymentBinCheckpointPage.LookupMode(true);
                PageAction := PaymentBinCheckpointPage.RunModal();
                ConfirmEoD := (PageAction = ACTION::LookupOK);

                if (not ConfirmEoD) and (Mode = EodWorkshiftMode::ZREPORT) then begin
                    POSPaymentBinCheckpoint.SetFilter("Include In Counting", '=%1', POSPaymentBinCheckpoint."Include In Counting"::YES);
                    if (POSPaymentBinCheckpoint.IsEmpty()) then begin
                        // When all lines are auto-counted, NAV disables the OK button, because page is not showing any lines.
                        POSPaymentBinCheckpoint.SetFilter("Include In Counting", '=%1', POSPaymentBinCheckpoint."Include In Counting"::VIRTUAL);
                        ConfirmEoD := not POSPaymentBinCheckpoint.IsEmpty();
                    end;
                end;
            end else begin
                // Nothing to show.
                ConfirmEoD := true;
            end;
        end;

        // No UI
        if (UIOption = EndOfDayUIOption::NONE) then begin
            // we need to set the state on the bin checkpoint
            // this would happen in the UI
            POSPaymentBinCheckpoint.Reset();
            POSPaymentBinCheckpoint.SetCurrentKey("Workshift Checkpoint Entry No.");
            POSPaymentBinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', CheckpointEntryNo);
            POSPaymentBinCheckpoint.ModifyAll(Status, POSPaymentBinCheckpoint.Status::READY);
            ConfirmEoD := true;
        end;

        Commit();
        exit(ConfirmEoD);
    end;

    internal procedure CreateCheckpointWorker(Mode: Option; UnitNo: Code[10]; xPOSUnitStatus: Option) CheckPointEntryNo: Integer
    var
        POSUnit: Record "NPR POS Unit";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        IsManager: Boolean;
        POSWebhooks: Codeunit "NPR POS Webhooks";
    begin

        POSUnit.Get(UnitNo);

        //Create checkpoints for managed POS Units
        IsManager := CreateCheckpointForManagedPosUnits(UnitNo, Mode);
        CheckPointEntryNo := CreateEndWorkshiftCheckpoint_POSEntry(POSUnit."POS Store Code", POSUnit."No.", xPOSUnitStatus);


        POSWorkshiftCheckpoint.Get(CheckPointEntryNo);
        case Mode of
            EodWorkshiftMode::ZREPORT:
                POSWorkshiftCheckpoint.Type := POSWorkshiftCheckpoint.Type::ZREPORT;
            EodWorkshiftMode::XREPORT:
                POSWorkshiftCheckpoint.Type := POSWorkshiftCheckpoint.Type::XREPORT;
            EodWorkshiftMode::CLOSEWORKSHIFT:
                POSWorkshiftCheckpoint.Type := POSWorkshiftCheckpoint.Type::XREPORT;
        end;
        POSWorkshiftCheckpoint.Modify();
        Commit();

        case Mode of
            EodWorkshiftMode::ZREPORT:
                POSPaymentBinCheckpoint.Type := POSPaymentBinCheckpoint.Type::ZREPORT;
            EodWorkshiftMode::XREPORT:
                POSPaymentBinCheckpoint.Type := POSPaymentBinCheckpoint.Type::XREPORT;
            EodWorkshiftMode::CLOSEWORKSHIFT:
                POSPaymentBinCheckpoint.Type := POSPaymentBinCheckpoint.Type::XREPORT;
        end;
        CreateBinCheckpoint(CheckPointEntryNo, POSPaymentBinCheckpoint.Type);

        if (IsManager) then
            AggregateWorkshifts(UnitNo, CheckPointEntryNo, Mode);

        Commit();

        POSWebhooks.InvokeUnitBalancedWebhook(POSWorkshiftCheckpoint.SystemId);

        exit(CheckPointEntryNo);

    end;

    local procedure CreateCheckpointForManagedPosUnits(UnitNo: Code[10]; Mode: Option): Boolean
    var
        MasterPosUnit: Record "NPR POS Unit";
        POSUnit: Record "NPR POS Unit";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        POSEndofDayProfile: Record "NPR POS End of Day Profile";
        PaymentBinCheckpoint: Codeunit "NPR POS Payment Bin Checkpoint";
        CheckPointEntryNo: Integer;
    begin

        POSUnit.Get(UnitNo);
        if (POSUnit."POS End of Day Profile" = '') then
            exit(false);

        if (not POSEndofDayProfile.Get(POSUnit."POS End of Day Profile")) then
            exit(false);

        if (POSEndofDayProfile."End of Day Type" <> POSEndofDayProfile."End of Day Type"::MASTER_SLAVE) then
            exit(false);

        if (POSUnit."No." <> POSEndofDayProfile."Master POS Unit No.") then
            exit(false); // Only EOD performed on master should verify the slaves

        // We are performing EOD on Master, verify all slaves are closed
        MasterPosUnit.Get(UnitNo);

        POSUnit.SetFilter("No.", '<>%1', UnitNo);
        POSUnit.SetFilter("POS End of Day Profile", '=%1', MasterPosUnit."POS End of Day Profile");

        // When Z-report, all slave units need to be status closed.
        if (Mode = EodWorkshiftMode::ZREPORT) then begin
            POSUnit.SetFilter(Status, '<>%1&<>%2', POSUnit.Status::CLOSED, POSUnit.Status::INACTIVE);
            if (POSUnit.FindFirst()) then
                Error(POS_UNIT_SLAVE_STATUS, POSUnit."No.", POSUnit.Status);

            POSUnit.SetFilter(Status, '=%1', POSUnit.Status::CLOSED);
        end;

        if (not POSUnit.FindSet()) then
            exit(false);

        // Create a Workshift checkpoint on all slaves
        repeat

            // POS Unit is closed - find the workshift
            POSWorkshiftCheckpoint.SetCurrentKey("POS Unit No.", Open, "Type");
            POSWorkshiftCheckpoint.SetFilter("POS Unit No.", '=%1', POSUnit."No.");
            POSWorkshiftCheckpoint.SetFilter(Type, '=%1', POSWorkshiftCheckpoint.Type::XREPORT);
            POSWorkshiftCheckpoint.SetFilter(Open, '=%1', true);
            if (not POSWorkshiftCheckpoint.FindLast()) then begin
                CheckPointEntryNo := CreateEndWorkshiftCheckpoint_POSEntry(POSUnit."POS Store Code", POSUnit."No.", POSUnit.Status);
                POSWorkshiftCheckpoint.Get(CheckPointEntryNo);
                POSWorkshiftCheckpoint.Type := POSWorkshiftCheckpoint.Type::XREPORT;
                POSWorkshiftCheckpoint.Modify();

                CreateBinCheckpoint(POSWorkshiftCheckpoint."Entry No.", POSPaymentBinCheckpoint.Type::XREPORT);

            end;

            // Slave bin contents to master bin
            PaymentBinCheckpoint.TransferToPaymentBin(POSWorkshiftCheckpoint."Entry No.", POSUnit."No.", MasterPosUnit."No.");

            // Create a new check point now with zero in the bins
            CheckPointEntryNo := CreateEndWorkshiftCheckpoint_POSEntry(POSUnit."POS Store Code", POSUnit."No.", POSUnit.Status);
            POSWorkshiftCheckpoint.Get(CheckPointEntryNo);
            POSWorkshiftCheckpoint.Type := POSWorkshiftCheckpoint.Type::WORKSHIFT_CLOSE;
            POSWorkshiftCheckpoint.Open := true;
            POSWorkshiftCheckpoint.Modify();

            CreateBinCheckpoint(CheckPointEntryNo, POSPaymentBinCheckpoint.Type::TRANSFER);

            POSWorkshiftCheckpoint.Reset();
            POSPaymentBinCheckpoint.SetCurrentKey("Workshift Checkpoint Entry No.");
            POSPaymentBinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', CheckPointEntryNo);
            POSPaymentBinCheckpoint.ModifyAll(Status, POSPaymentBinCheckpoint.Status::READY);
        until (POSUnit.Next() = 0);

        exit(true);

    end;

    local procedure AggregateWorkshifts(UnitNo: Code[10]; TargetWorkshiftCheckpointEntryNo: Integer; Mode: Option): Boolean
    var
        POSUnit: Record "NPR POS Unit";
        MasterPOSUnit: Record "NPR POS Unit";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSEndofDayProfile: Record "NPR POS End of Day Profile";
    begin

        POSUnit.Get(UnitNo);
        if (POSUnit."POS End of Day Profile" = '') then
            exit(false);

        if (not POSEndofDayProfile.Get(POSUnit."POS End of Day Profile")) then
            exit(false);

        if (POSEndofDayProfile."End of Day Type" <> POSEndofDayProfile."End of Day Type"::MASTER_SLAVE) then
            exit(false);

        if (POSUnit."No." <> POSEndofDayProfile."Master POS Unit No.") then
            exit(false); // Only EOD performed on master should verify the slaves

        // We are performing EOD on Master, verify all slaves are closed
        MasterPOSUnit.Get(UnitNo);

        POSUnit.SetFilter("No.", '<>%1', UnitNo);
        POSUnit.SetFilter("POS End of Day Profile", '=%1', MasterPOSUnit."POS End of Day Profile");

        // When Z-report, all slave units need to be status closed.
        if (Mode = EodWorkshiftMode::ZREPORT) then begin
            POSUnit.SetFilter(Status, '<>%1&<>%2', POSUnit.Status::CLOSED, POSUnit.Status::INACTIVE);
            if (POSUnit.FindFirst()) then
                Error(POS_UNIT_SLAVE_STATUS, POSUnit."No.", POSUnit.Status);

            POSUnit.SetFilter(Status, '=%1', POSUnit.Status::CLOSED);
        end;

        if (not POSUnit.FindSet()) then
            exit(false);

        // Add the workshift numbers together.
        repeat
            POSWorkshiftCheckpoint.SetCurrentKey("POS Unit No.");
            POSWorkshiftCheckpoint.SetFilter("POS Unit No.", '=%1', POSUnit."No.");
            if (POSWorkshiftCheckpoint.FindLast()) then begin

                // Verify last workshift checkpoint on pos unit is correct type
                if (POSWorkshiftCheckpoint.Type = POSWorkshiftCheckpoint.Type::WORKSHIFT_CLOSE) then begin

                    AddWorkshifts(POSWorkshiftCheckpoint."Entry No.", TargetWorkshiftCheckpointEntryNo);
                    AddTaxCheckpoints(POSWorkshiftCheckpoint."Entry No.", TargetWorkshiftCheckpointEntryNo);

                end else begin
                    // Blow up or skip ?
                    exit(false);
                end;

            end;
        until (POSUnit.Next() = 0);

        exit(true);
    end;

    internal procedure CreateBalancingEntry(Mode: Option; UnitNo: Code[10]; CheckPointEntryNo: Integer; DimensionSetId: Integer) EntryNo: Integer
    var
        POSUnit: Record "NPR POS Unit";
        POSEndofDayProfile: Record "NPR POS End of Day Profile";
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        SalePOS: Record "NPR POS Sale";
        POSAuditLog: Record "NPR POS Audit Log";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSEntryToPost: Record "NPR POS Entry";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        DenominationMgt: Codeunit "NPR Denomination Mgt.";
        DimMgt: Codeunit DimensionManagement;
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesManagement: Codeunit "No. Series";
#ELSE
        NoSeriesManagement: Codeunit NoSeriesManagement;
#ENDIF
        DuplicateReceiptNo: Label 'Duplicate Receipt Number: %1';
    begin

        POSUnit.Get(UnitNo);

        if (not POSEndofDayProfile.Get(POSUnit."POS End of Day Profile")) then
            POSEndofDayProfile.Init();

        POSPaymentBinCheckpoint.Reset();
        POSPaymentBinCheckpoint.SetCurrentKey("Workshift Checkpoint Entry No.");
        POSPaymentBinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', CheckPointEntryNo);
        POSPaymentBinCheckpoint.SetFilter(Status, '=%1', POSPaymentBinCheckpoint.Status::READY);
        if (POSPaymentBinCheckpoint.FindFirst()) then begin

            // A Sale POS record is needed when creating POS Entry
            SalePOS."Register No." := POSUnit."No.";
            SalePOS."POS Store Code" := POSUnit."POS Store Code";
            SalePOS.Date := Today();
            SalePOS."Sales Ticket No." := CopyStr(DelChr(Format(CurrentDateTime(), 0, 9), '<=>', DelChr(Format(CurrentDateTime(), 0, 9), '<=>', '01234567890')), 1, MaxStrLen(SalePOS."Sales Ticket No."));

            if (Mode = EodWorkshiftMode::ZREPORT) and (POSEndofDayProfile."Z-Report Number Series" <> '') then
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
                SalePOS."Sales Ticket No." := NoSeriesManagement.GetNextNo(POSEndofDayProfile."Z-Report Number Series", Today, false);
            if (Mode = EodWorkshiftMode::XREPORT) and (POSEndofDayProfile."X-Report Number Series" <> '') then
                SalePOS."Sales Ticket No." := NoSeriesManagement.GetNextNo(POSEndofDayProfile."X-Report Number Series", Today, false);
            if (Mode = EodWorkshiftMode::CLOSEWORKSHIFT) and (POSEndofDayProfile."X-Report Number Series" <> '') then
                SalePOS."Sales Ticket No." := NoSeriesManagement.GetNextNo(POSEndofDayProfile."X-Report Number Series", Today, false);
#ELSE
                SalePOS."Sales Ticket No." := NoSeriesManagement.GetNextNo(POSEndofDayProfile."Z-Report Number Series", Today, true);
            if (Mode = EodWorkshiftMode::XREPORT) and (POSEndofDayProfile."X-Report Number Series" <> '') then
                SalePOS."Sales Ticket No." := NoSeriesManagement.GetNextNo(POSEndofDayProfile."X-Report Number Series", Today, true);
            if (Mode = EodWorkshiftMode::CLOSEWORKSHIFT) and (POSEndofDayProfile."X-Report Number Series" <> '') then
                SalePOS."Sales Ticket No." := NoSeriesManagement.GetNextNo(POSEndofDayProfile."X-Report Number Series", Today, true);
#ENDIF

            if not POSCreateEntry.IsUniqueDocumentNo(SalePOS."Sales Ticket No.") then
                Error(DuplicateReceiptNo, SalePOS."Sales Ticket No.");

            SalePOS."Salesperson Code" := TryGetSalesperson();
            SalePOS."Start Time" := Time;
            SalePOS."Dimension Set ID" := DimensionSetId;
            DimMgt.UpdateGlobalDimFromDimSetID(SalePOS."Dimension Set ID", SalePOS."Shortcut Dimension 1 Code", SalePOS."Shortcut Dimension 2 Code");

            EntryNo := POSCreateEntry.CreateBalancingEntryAndLines(SalePOS, (Mode <> EodWorkshiftMode::ZREPORT), CheckPointEntryNo);
            if (EntryNo = 0) then
                exit(0);

            POSWorkshiftCheckpoint.Get(CheckPointEntryNo);
            DenominationMgt.StoreCountedDenominations(POSWorkshiftCheckpoint);

            if (Mode = EodWorkshiftMode::ZREPORT) then begin

                // Create running total statistics
                POSWorkshiftCheckpoint.SetCurrentKey("POS Unit No.", Open, "Type");
                POSWorkshiftCheckpoint.SetFilter("POS Unit No. Filter", '=%1', POSWorkshiftCheckpoint."POS Unit No.");
                POSWorkshiftCheckpoint.SetFilter("Type Filter", '=%1', POSWorkshiftCheckpoint.Type);
                POSWorkshiftCheckpoint.SetFilter("Open Filter", '=%1', false);

                POSWorkshiftCheckpoint.CalcFields("FF Total Dir. Item Sales (LCY)", "FF Total Dir. Item Return(LCY)", "FF Total Dir. Turnover (LCY)", "FF Total Dir. Neg. Turn. (LCY)", "FF Total Rounding Amt. (LCY)");
                POSWorkshiftCheckpoint."Perpetual Dir. Turnover (LCY)" := POSWorkshiftCheckpoint."FF Total Dir. Turnover (LCY)";
                POSWorkshiftCheckpoint."Perpetual Dir. Neg. Turn (LCY)" := POSWorkshiftCheckpoint."FF Total Dir. Neg. Turn. (LCY)";
                POSWorkshiftCheckpoint."Perpetual Rounding Amt. (LCY)" := POSWorkshiftCheckpoint."FF Total Rounding Amt. (LCY)";
                POSWorkshiftCheckpoint."Perpetual Dir. Item Sales(LCY)" := POSWorkshiftCheckpoint."FF Total Dir. Item Sales (LCY)";
                POSWorkshiftCheckpoint."Perpetual Dir. Item Ret. (LCY)" := POSWorkshiftCheckpoint."FF Total Dir. Item Return(LCY)";
                POSWorkshiftCheckpoint.Modify();

                POSEntryToPost.Get(EntryNo);
                POSEntryToPost.SetRecFilter();
                POSAuditLogMgt.CreateEntry(POSWorkshiftCheckpoint.RecordId, POSAuditLog."Action Type"::DRAWER_COUNT, POSEntryToPost."Entry No.", POSEntryToPost."Fiscal No.", POSEntryToPost."POS Unit No.");
                POSAuditLogMgt.CreateEntry(POSWorkshiftCheckpoint.RecordId, POSAuditLog."Action Type"::GRANDTOTAL, POSEntryToPost."Entry No.", POSEntryToPost."Fiscal No.", POSEntryToPost."POS Unit No.");
                POSAuditLogMgt.CreateEntry(POSWorkshiftCheckpoint.RecordId, POSAuditLog."Action Type"::WORKSHIFT_END, POSEntryToPost."Entry No.", POSEntryToPost."Fiscal No.", POSEntryToPost."POS Unit No.");

                OnAfterCreateBalancingEntry(POSWorkshiftCheckpoint);

                Commit();
            end;

        end else begin

            POSWorkshiftCheckpoint.Get(CheckPointEntryNo);
            if (POSWorkshiftCheckpoint.Type = POSWorkshiftCheckpoint.Type::ZREPORT) then begin

                POSPaymentBinCheckpoint.Reset();
                POSPaymentBinCheckpoint.SetCurrentKey("Workshift Checkpoint Entry No.");
                POSPaymentBinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', CheckPointEntryNo);
                if (POSPaymentBinCheckpoint.IsEmpty()) then begin

                    // When a forced Z-Report is set on Unit, and there are zero bin transactions to count,
                    // there will be no Payment Bin Checkpoints in status READY. So this will "reset" our counters to to current POS Entry position.
                    // TODO: This should go into the create entry POSCreateEntry.CreateBalancingEntryAndLines()
                    POSEntryToPost.SetFilter("POS Unit No.", POSWorkshiftCheckpoint."POS Unit No.");

                    if (POSEntryToPost.FindLast()) then begin
                        POSEntryToPost."Entry Type" := POSEntryToPost."Entry Type"::Balancing;
                        POSEntryToPost.Description := 'Nothing to balance.';
                        POSEntryToPost.Modify();

                        POSWorkshiftCheckpoint."POS Entry No." := POSEntryToPost."Entry No.";
                        EntryNo := POSEntryToPost."Entry No.";
                    end;

                    POSWorkshiftCheckpoint.Open := false;
                    POSWorkshiftCheckpoint.Modify();
                end;
            end;
        end;

        exit(EntryNo); // may be zero

    end;

    procedure CreateEndWorkshiftCheckpoint_POSEntry(POSStoreCode: Code[10]; POSUnitNo: Code[10]; xPOSUnitStatus: Option) CheckpointEntryNo: Integer
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin

        POSWorkshiftCheckpoint.Init();
        POSWorkshiftCheckpoint."Entry No." := 0;
        POSWorkshiftCheckpoint."POS Unit No." := POSUnitNo;
        POSWorkshiftCheckpoint."POS Unit Status Before Checkp." := xPOSUnitStatus;
        POSWorkshiftCheckpoint."Created At" := CurrentDateTime();
        POSWorkshiftCheckpoint.Open := true;
        POSWorkshiftCheckpoint.Insert();
        Commit();

        if (POSUnitNo <> '') then begin
            CalculateCheckpointStatistics(POSStoreCode, POSUnitNo, POSWorkshiftCheckpoint);
            UpdateWorkshiftCheckpoint(POSWorkshiftCheckpoint);
        end;
        POSWorkshiftCheckpoint.Modify();
        Commit();

        exit(POSWorkshiftCheckpoint."Entry No.");
    end;

    local procedure AddWorkshifts(WorkshiftEntryNo: Integer; TargetWorkshiftEntryNo: Integer)
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        TargetPOSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin

        if (not TargetPOSWorkshiftCheckpoint.Get(TargetWorkshiftEntryNo)) then
            exit;

        if (not POSWorkshiftCheckpoint.Get(WorkshiftEntryNo)) then
            exit;

        TargetPOSWorkshiftCheckpoint."Debtor Payment (LCY)" += POSWorkshiftCheckpoint."Debtor Payment (LCY)";
        TargetPOSWorkshiftCheckpoint."GL Payment (LCY)" += POSWorkshiftCheckpoint."GL Payment (LCY)";
        TargetPOSWorkshiftCheckpoint."Rounding (LCY)" += POSWorkshiftCheckpoint."Rounding (LCY)";
        TargetPOSWorkshiftCheckpoint."Credit Item Sales (LCY)" += POSWorkshiftCheckpoint."Credit Item Sales (LCY)";
        TargetPOSWorkshiftCheckpoint."Credit Item Quantity Sum" += POSWorkshiftCheckpoint."Credit Item Quantity Sum";
        TargetPOSWorkshiftCheckpoint."Credit Net Sales Amount (LCY)" += POSWorkshiftCheckpoint."Credit Net Sales Amount (LCY)";
        TargetPOSWorkshiftCheckpoint."Credit Sales Count" += POSWorkshiftCheckpoint."Credit Sales Count";
        TargetPOSWorkshiftCheckpoint."Credit Sales Amount (LCY)" += POSWorkshiftCheckpoint."Credit Sales Amount (LCY)";
        TargetPOSWorkshiftCheckpoint."Issued Vouchers (LCY)" += POSWorkshiftCheckpoint."Issued Vouchers (LCY)";
        TargetPOSWorkshiftCheckpoint."Redeemed Vouchers (LCY)" += POSWorkshiftCheckpoint."Redeemed Vouchers (LCY)";
        TargetPOSWorkshiftCheckpoint."Local Currency (LCY)" += POSWorkshiftCheckpoint."Local Currency (LCY)";
        TargetPOSWorkshiftCheckpoint."Foreign Currency (LCY)" += POSWorkshiftCheckpoint."Foreign Currency (LCY)";
        TargetPOSWorkshiftCheckpoint."EFT (LCY)" += POSWorkshiftCheckpoint."EFT (LCY)";

        TargetPOSWorkshiftCheckpoint."Manual Card (LCY)" += POSWorkshiftCheckpoint."Manual Card (LCY)";
        TargetPOSWorkshiftCheckpoint."Other Credit Card (LCY)" += POSWorkshiftCheckpoint."Other Credit Card (LCY)";
        TargetPOSWorkshiftCheckpoint."Cash Terminal (LCY)" += POSWorkshiftCheckpoint."Cash Terminal (LCY)";
        TargetPOSWorkshiftCheckpoint."Redeemed Credit Voucher (LCY)" += POSWorkshiftCheckpoint."Redeemed Credit Voucher (LCY)";
        TargetPOSWorkshiftCheckpoint."Created Credit Voucher (LCY)" += POSWorkshiftCheckpoint."Created Credit Voucher (LCY)";

        TargetPOSWorkshiftCheckpoint."Direct Item Sales (LCY)" += POSWorkshiftCheckpoint."Direct Item Sales (LCY)";
        TargetPOSWorkshiftCheckpoint."Direct Sales - Staff (LCY)" += POSWorkshiftCheckpoint."Direct Sales - Staff (LCY)";
        TargetPOSWorkshiftCheckpoint."Direct Item Net Sales (LCY)" += POSWorkshiftCheckpoint."Direct Item Net Sales (LCY)";
        TargetPOSWorkshiftCheckpoint."Direct Sales Count" += POSWorkshiftCheckpoint."Direct Sales Count";
        TargetPOSWorkshiftCheckpoint."Cancelled Sales Count" += POSWorkshiftCheckpoint."Cancelled Sales Count";
        TargetPOSWorkshiftCheckpoint."Net Turnover (LCY)" += POSWorkshiftCheckpoint."Net Turnover (LCY)";
        TargetPOSWorkshiftCheckpoint."Turnover (LCY)" += POSWorkshiftCheckpoint."Turnover (LCY)";
        TargetPOSWorkshiftCheckpoint."Direct Turnover (LCY)" += POSWorkshiftCheckpoint."Direct Turnover (LCY)";
        TargetPOSWorkshiftCheckpoint."Direct Negative Turnover (LCY)" += POSWorkshiftCheckpoint."Direct Negative Turnover (LCY)";
        TargetPOSWorkshiftCheckpoint."Direct Net Turnover (LCY)" += POSWorkshiftCheckpoint."Direct Net Turnover (LCY)";
        TargetPOSWorkshiftCheckpoint."Net Cost (LCY)" += POSWorkshiftCheckpoint."Net Cost (LCY)";
        TargetPOSWorkshiftCheckpoint."Profit Amount (LCY)" += POSWorkshiftCheckpoint."Profit Amount (LCY)";

        TargetPOSWorkshiftCheckpoint."Direct Item Returns (LCY)" += POSWorkshiftCheckpoint."Direct Item Returns (LCY)";
        TargetPOSWorkshiftCheckpoint."Direct Item Returns Line Count" += POSWorkshiftCheckpoint."Direct Item Returns Line Count";
        TargetPOSWorkshiftCheckpoint."Credit Real. Sale Amt. (LCY)" += POSWorkshiftCheckpoint."Credit Real. Sale Amt. (LCY)";
        TargetPOSWorkshiftCheckpoint."Credit Unreal. Sale Amt. (LCY)" += POSWorkshiftCheckpoint."Credit Unreal. Sale Amt. (LCY)";
        TargetPOSWorkshiftCheckpoint."Credit Real. Return Amt. (LCY)" += POSWorkshiftCheckpoint."Credit Real. Return Amt. (LCY)";
        TargetPOSWorkshiftCheckpoint."Credit Unreal. Ret. Amt. (LCY)" += POSWorkshiftCheckpoint."Credit Unreal. Ret. Amt. (LCY)";
        TargetPOSWorkshiftCheckpoint."Credit Turnover (LCY)" += POSWorkshiftCheckpoint."Credit Turnover (LCY)";
        TargetPOSWorkshiftCheckpoint."Credit Net Turnover (LCY)" += POSWorkshiftCheckpoint."Credit Net Turnover (LCY)";

        TargetPOSWorkshiftCheckpoint."Total Discount (LCY)" += POSWorkshiftCheckpoint."Total Discount (LCY)";
        TargetPOSWorkshiftCheckpoint."Total Net Discount (LCY)" += POSWorkshiftCheckpoint."Total Net Discount (LCY)";
        TargetPOSWorkshiftCheckpoint."Campaign Discount (LCY)" += POSWorkshiftCheckpoint."Campaign Discount (LCY)";
        TargetPOSWorkshiftCheckpoint."Mix Discount (LCY)" += POSWorkshiftCheckpoint."Mix Discount (LCY)";
        TargetPOSWorkshiftCheckpoint."Quantity Discount (LCY)" += POSWorkshiftCheckpoint."Quantity Discount (LCY)";
        TargetPOSWorkshiftCheckpoint."Custom Discount (LCY)" += POSWorkshiftCheckpoint."Custom Discount (LCY)";
        TargetPOSWorkshiftCheckpoint."BOM Discount (LCY)" += POSWorkshiftCheckpoint."BOM Discount (LCY)";
        TargetPOSWorkshiftCheckpoint."Customer Discount (LCY)" += POSWorkshiftCheckpoint."Customer Discount (LCY)";
        TargetPOSWorkshiftCheckpoint."Line Discount (LCY)" += POSWorkshiftCheckpoint."Line Discount (LCY)";
        TargetPOSWorkshiftCheckpoint."Calculated Diff (LCY)" += POSWorkshiftCheckpoint."Calculated Diff (LCY)";

        TargetPOSWorkshiftCheckpoint."Direct Item Quantity Sum" += POSWorkshiftCheckpoint."Direct Item Quantity Sum";
        TargetPOSWorkshiftCheckpoint."Direct Item Sales Line Count" += POSWorkshiftCheckpoint."Direct Item Sales Line Count";
        TargetPOSWorkshiftCheckpoint."Receipts Count" += POSWorkshiftCheckpoint."Receipts Count";
        TargetPOSWorkshiftCheckpoint."Cash Drawer Open Count" += POSWorkshiftCheckpoint."Cash Drawer Open Count";
        TargetPOSWorkshiftCheckpoint."Receipt Copies Count" += POSWorkshiftCheckpoint."Receipt Copies Count";
        TargetPOSWorkshiftCheckpoint."Receipt Copies Sales (LCY)" += POSWorkshiftCheckpoint."Receipt Copies Sales (LCY)";

        TargetPOSWorkshiftCheckpoint."Bin Transfer Out Amount (LCY)" += POSWorkshiftCheckpoint."Bin Transfer Out Amount (LCY)";
        TargetPOSWorkshiftCheckpoint."Bin Transfer In Amount (LCY)" += POSWorkshiftCheckpoint."Bin Transfer In Amount (LCY)";

        TargetPOSWorkshiftCheckpoint."Opening Cash (LCY)" += POSWorkshiftCheckpoint."Opening Cash (LCY)";
        POSWorkshiftCheckpoint."Consolidated With Entry No." := TargetWorkshiftEntryNo;
        POSWorkshiftCheckpoint.Modify();

        FinalizeCheckpoint(TargetPOSWorkshiftCheckpoint);

        TargetPOSWorkshiftCheckpoint.Modify();

    end;

    local procedure AddTaxCheckpoints(WorkshiftEntryNo: Integer; TargetWorkshiftEntryNo: Integer)
    var
        TargetWorkshiftTaxCheckpoint: Record "NPR POS Worksh. Tax Checkp.";
        POSWorkshiftTaxCheckpoint: Record "NPR POS Worksh. Tax Checkp.";
    begin

        POSWorkshiftTaxCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', WorkshiftEntryNo);
        POSWorkshiftTaxCheckpoint.SetFilter("Consolidated With Entry No.", '=%1', 0); // not yet consolidated.

        if (POSWorkshiftTaxCheckpoint.FindSet()) then begin

            repeat
                // consolidation key: "Workshift Checkpoint Entry No.","Tax Area Code","VAT Identifier","Tax Calculation Type"
                TargetWorkshiftTaxCheckpoint.SetCurrentKey("Workshift Checkpoint Entry No.", "Tax Area Code", "VAT Identifier", "Tax Calculation Type");
                TargetWorkshiftTaxCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', TargetWorkshiftEntryNo);
                TargetWorkshiftTaxCheckpoint.SetFilter("Tax Area Code", '=%1', POSWorkshiftTaxCheckpoint."Tax Area Code");
                TargetWorkshiftTaxCheckpoint.SetFilter("VAT Identifier", '=%1', POSWorkshiftTaxCheckpoint."VAT Identifier");
                TargetWorkshiftTaxCheckpoint.SetFilter("Tax Calculation Type", '=%1', POSWorkshiftTaxCheckpoint."Tax Calculation Type");
                TargetWorkshiftTaxCheckpoint.SetFilter("Tax Jurisdiction Code", '=%1', POSWorkshiftTaxCheckpoint."Tax Jurisdiction Code");
                TargetWorkshiftTaxCheckpoint.SetFilter("Tax Group Code", '=%1', POSWorkshiftTaxCheckpoint."Tax Group Code");

                if (TargetWorkshiftTaxCheckpoint.FindFirst()) then begin
                    TargetWorkshiftTaxCheckpoint."Tax Base Amount" += POSWorkshiftTaxCheckpoint."Tax Base Amount";
                    TargetWorkshiftTaxCheckpoint."Tax Amount" += POSWorkshiftTaxCheckpoint."Tax Amount";
                    TargetWorkshiftTaxCheckpoint."Amount Including Tax" += POSWorkshiftTaxCheckpoint."Amount Including Tax";
                    TargetWorkshiftTaxCheckpoint."Line Amount" += POSWorkshiftTaxCheckpoint."Line Amount";
                    TargetWorkshiftTaxCheckpoint.Modify();
                end else begin
                    TargetWorkshiftTaxCheckpoint.TransferFields(POSWorkshiftTaxCheckpoint, false);
                    TargetWorkshiftTaxCheckpoint."Entry No." := 0;
                    TargetWorkshiftTaxCheckpoint."Workshift Checkpoint Entry No." := TargetWorkshiftEntryNo;
                    TargetWorkshiftTaxCheckpoint.Insert();
                end;

                POSWorkshiftTaxCheckpoint."Consolidated With Entry No." := TargetWorkshiftTaxCheckpoint."Entry No.";
                POSWorkshiftTaxCheckpoint.Modify();

            until (POSWorkshiftTaxCheckpoint.Next() = 0);
        end;

    end;

    internal procedure FindPreviousCheckpointPOSEntryNo(POSUnitNo: Code[10]) EntryNo: Integer
    var
        PreviousUnitCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin
        EntryNo := 1;
        PreviousUnitCheckpoint.SetCurrentKey("POS Unit No.", Open, "Type");
        PreviousUnitCheckpoint.SetFilter("POS Unit No.", '=%1', POSUnitNo);
        PreviousUnitCheckpoint.SetFilter(Open, '=%1', false);
        PreviousUnitCheckpoint.SetFilter(Type, '=%1', PreviousUnitCheckpoint.Type::ZREPORT);
        if (PreviousUnitCheckpoint.FindLast()) then
            EntryNo := PreviousUnitCheckpoint."POS Entry No.";

        // When a managed POS is balanced, the workshift is marked as WORKSHIFT_CLOSED. Z-REPORT is posted, WORKSHIFT is not.
        PreviousUnitCheckpoint.SetFilter(Type, '=%1', PreviousUnitCheckpoint.Type::WORKSHIFT_CLOSE);
        PreviousUnitCheckpoint.SetFilter("Entry No.", '%1..', PreviousUnitCheckpoint."Entry No.");
        if (PreviousUnitCheckpoint.FindLast()) then begin
            PreviousUnitCheckpoint.Get(PreviousUnitCheckpoint."Consolidated With Entry No.");
            EntryNo := PreviousUnitCheckpoint."POS Entry No.";
        end;
    end;

    local procedure CalculateCheckpointStatistics(POSStoreCode: Code[10]; POSUnitNo: Code[10]; var POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        EntriesToBalance: Record "NPR POS Entry";
        FromEntryNo: Integer;
    begin
        FromEntryNo := FindPreviousCheckpointPOSEntryNo(POSUnitNo);

        EntriesToBalance.SetRange("POS Store Code", POSStoreCode);
        EntriesToBalance.SetFilter("Entry No.", '%1..', FromEntryNo);
        EntriesToBalance.SetFilter("System Entry", '=%1', false);
        EntriesToBalance.SetFilter("POS Unit No.", '=%1', POSUnitNo);
        if (EntriesToBalance.IsEmpty()) then
            exit;

        CalculateWorkshiftSummary(POSStoreCode, POSUnitNo, POSWorkshiftCheckpoint, FromEntryNo);
    end;

    local procedure CalculateWorkshiftSummary(POSStoreCode: Code[10]; POSUnitNo: Code[10]; var POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; FromPosEntryNo: Integer)
    var
        POSSalesLine: Record "NPR POS Entry Sales Line";
        POSPaymentLine: Record "NPR POS Entry Payment Line";
        POSEntry: Record "NPR POS Entry";
        GeneralLedgerSetup: Record "General Ledger Setup";
        WorkshiftCheckpointPublicAccess: Codeunit "NPR POS Worksh. Checkp. Public";
    begin
        SetGeneralStatistics(POSStoreCode, POSUnitNo, POSWorkshiftCheckpoint, FromPosEntryNo);
        GetTransferStatistics(POSWorkshiftCheckpoint, POSUnitNo, FromPosEntryNo);
        AggregateVat_PE(POSWorkshiftCheckpoint."Entry No.", POSStoreCode, POSUnitNo, FromPosEntryNo);
        SetRegisterStatistics(POSStoreCode, POSUnitNo, POSWorkshiftCheckpoint, FromPosEntryNo);

        POSSalesLine.SetFilter("POS Entry No.", '%1..', FromPosEntryNo);
        POSSalesLine.SetFilter("POS Unit No.", '=%1', POSUnitNo);
        POSSalesLine.SetFilter("Exclude from Posting", '=%1', false);
        if (POSSalesLine.FindSet()) then begin
            repeat
                POSEntry.Get(POSSalesLine."POS Entry No.");
                SetTurnoverAndProfit(POSWorkshiftCheckpoint, POSSalesLine, POSEntry);
                SetDiscounts(POSWorkshiftCheckpoint, POSSalesLine);
            until (POSSalesLine.Next() = 0);
        end;

        GeneralLedgerSetup.Get();
        POSPaymentLine.SetFilter("POS Entry No.", '%1..', FromPosEntryNo);
        POSPaymentLine.SetFilter("POS Unit No.", '=%1', POSUnitNo);
        if (POSPaymentLine.FindSet()) then begin
            repeat
                SetPayments(POSWorkshiftCheckpoint, POSPaymentLine, GeneralLedgerSetup."LCY Code");
            until (POSPaymentLine.Next() = 0);
        end;

        WorkshiftCheckpointPublicAccess.OnAfterCalculateWorkshiftSummaryOnBeforeFinalizeCheckpoint(POSWorkshiftCheckpoint, POSStoreCode, POSUnitNo, FromPosEntryNo);

        FinalizeCheckpoint(POSWorkshiftCheckpoint);
    end;

    local procedure SetGeneralStatistics(POSStoreCode: Code[10]; POSUnitNo: Code[10]; var POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; FromPosEntryNo: Integer)
    var
        POSEntry: Record "NPR POS Entry";
        DocDeleted: Boolean;
    begin
        POSEntry.SetCurrentKey("POS Store Code", "POS Unit No.");
        POSEntry.SetRange("POS Store Code", POSStoreCode);
        POSEntry.SetRange("POS Unit No.", POSUnitNo);
        POSEntry.SetFilter("Entry No.", '%1..', FromPosEntryNo);
        POSEntry.SetRange("System Entry", false);

        // Number of sales
        POSEntry.SetFilter("Entry Type", '=%1', POSEntry."Entry Type"::"Direct Sale");
        POSEntry.SetRange("Is Pay-in Pay-out", false);
        POSWorkshiftCheckpoint."Direct Sales Count" := POSEntry.Count();

        // Number of cancelled sales
        POSEntry.SetFilter("Entry Type", '=%1', POSEntry."Entry Type"::"Cancelled Sale");
        POSWorkshiftCheckpoint."Cancelled Sales Count" := POSEntry.Count();

        // Number of sales moved to ERP
        POSEntry.SetFilter("Entry Type", '=%1', POSEntry."Entry Type"::"Credit Sale");
        POSWorkshiftCheckpoint."Credit Sales Count" := 0;
        POSEntry.SetLoadFields("Sales Document Type", "Sales Document No.");
        if POSEntry.FindSet() then
            repeat
                CheckIsPosted(POSEntry."Sales Document Type", POSEntry."Sales Document No.", DocDeleted);
                if not DocDeleted then
                    POSWorkshiftCheckpoint."Credit Sales Count" += 1;
            until POSEntry.Next() = 0;
    end;

    local procedure CheckIsPosted(DocumentType: Enum "Sales Document Type"; DocmentNo: Code[20]; var DocDeleted: Boolean): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        DocDeleted := false;
        if SalesHeader.Get(DocumentType, DocmentNo) then
            exit(false);

        case DocumentType of
            SalesHeader."Document Type"::Order:
                begin
                    SalesInvHeader.SetCurrentKey("Order No.");
                    SalesInvHeader.SetRange("Order No.", DocmentNo);
                    if not SalesInvHeader.IsEmpty then
                        exit(true);
                end;

            SalesHeader."Document Type"::Invoice:
                begin
                    SalesInvHeader.SetCurrentKey("Pre-Assigned No.");
                    SalesInvHeader.SetRange("Pre-Assigned No.", DocmentNo);
                    if not SalesInvHeader.IsEmpty then
                        exit(true);
                end;

            SalesHeader."Document Type"::"Return Order":
                begin
                    SalesCrMemoHeader.SetCurrentKey("Return Order No.");
                    SalesCrMemoHeader.SetRange("Return Order No.", DocmentNo);
                    if not SalesCrMemoHeader.IsEmpty then
                        exit(true);
                end;

            SalesHeader."Document Type"::"Credit Memo":
                begin
                    SalesCrMemoHeader.SetCurrentKey("Pre-Assigned No.");
                    SalesCrMemoHeader.SetRange("Pre-Assigned No.", DocmentNo);
                    if not SalesCrMemoHeader.IsEmpty then
                        exit(true);
                end;
        end;

        DocDeleted := true;
        exit(false);

    end;

    local procedure GetTransferStatistics(var POSWorkshiftCheckpointOut: Record "NPR POS Workshift Checkpoint"; POSUnitNo: Code[10]; FromPosEntryNo: Integer)
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSBalancingLine: Record "NPR POS Balancing Line";
        POSBinEntry: Record "NPR POS Bin Entry";
    begin
        // Get intermediate end-of-day
        POSWorkshiftCheckpoint.SetCurrentKey("POS Entry No.");
        POSWorkshiftCheckpoint.SetFilter("POS Entry No.", '%1..', FromPosEntryNo);
        POSWorkshiftCheckpoint.SetRange("POS Unit No.", POSUnitNo);
        POSWorkshiftCheckpoint.SetFilter(Open, '=%1', true);
        if (POSWorkshiftCheckpoint.IsEmpty()) then
            exit;

        POSWorkshiftCheckpoint.FindSet();
        repeat
            // Find the balancing lines that specify bin transfer
            POSBalancingLine.SetFilter("POS Entry No.", '=%1', POSWorkshiftCheckpoint."POS Entry No.");
            POSBalancingLine.FilterGroup(-1);
            POSBalancingLine.SetFilter("Move-To Bin Code", '<>%1', '');
            POSBalancingLine.SetFilter("Deposit-To Bin Code", '<>%1', '');
            POSBalancingLine.FilterGroup(0);
            if POSBalancingLine.FindSet() then
                repeat
                    // Find the binentry to get LCY
                    POSBinEntry.SetCurrentKey("Bin Checkpoint Entry No.");
                    POSBinEntry.SetFilter("Bin Checkpoint Entry No.", '=%1', POSBalancingLine."POS Bin Checkpoint Entry No.");
                    POSBinEntry.SetFilter(Type, '%1|%2|%3..%4', POSBinEntry.Type::BANK_TRANSFER, POSBinEntry.Type::BIN_TRANSFER, POSBinEntry.Type::BANK_TRANSFER_OUT, POSBinEntry.Type::BIN_TRANSFER_IN);
                    if POSBalancingLine."Move-To Bin Code" <> '' then
                        AddToTransferStatistics(POSWorkshiftCheckpointOut, POSBinEntry, POSBalancingLine."Move-To Bin Code");
                    if POSBalancingLine."Deposit-To Bin Code" <> '' then
                        AddToTransferStatistics(POSWorkshiftCheckpointOut, POSBinEntry, POSBalancingLine."Deposit-To Bin Code");
                until POSBalancingLine.Next() = 0;
        until POSWorkshiftCheckpoint.Next() = 0;
    end;

    local procedure AddToTransferStatistics(var POSWorkshiftCheckpointOut: Record "NPR POS Workshift Checkpoint"; var POSBinEntry: Record "NPR POS Bin Entry"; BinCode: Code[10])
    var
        POSUnittoBinRelation: Record "NPR POS Unit to Bin Relation";
    begin
        POSBinEntry.SetRange("Payment Bin No.", BinCode);
        if not POSBinEntry.FindFirst() then
            exit;

        if POSUnittoBinRelation.Get(POSWorkshiftCheckpointOut."POS Unit No.", POSBinEntry."Payment Bin No.") then begin
            if POSBinEntry.Type in [POSBinEntry.Type::BANK_TRANSFER_IN, POSBinEntry.Type::BIN_TRANSFER_IN] then
                POSWorkshiftCheckpointOut."Bin Transfer In Amount (LCY)" -= POSBinEntry."Transaction Amount (LCY)"
            else
                POSWorkshiftCheckpointOut."Bin Transfer Out Amount (LCY)" += POSBinEntry."Transaction Amount (LCY)";
        end else begin
            if POSBinEntry.Type in [POSBinEntry.Type::BANK_TRANSFER_IN, POSBinEntry.Type::BIN_TRANSFER_IN] then
                POSWorkshiftCheckpointOut."Bin Transfer Out Amount (LCY)" += POSBinEntry."Transaction Amount (LCY)"
            else
                POSWorkshiftCheckpointOut."Bin Transfer In Amount (LCY)" -= POSBinEntry."Transaction Amount (LCY)";
        end;
    end;

    procedure SetTurnoverAndProfit(var POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; POSSalesLine: Record "NPR POS Entry Sales Line"; POSEntry: Record "NPR POS Entry")
    var
        DocDeleted: Boolean;
    begin

        //Total turnover must not include POS sales transfered to ERP as unposted.
        if (POSEntry."Entry Type" = POSEntry."Entry Type"::"Credit Sale") then begin

            if (CheckIsPosted(POSEntry."Sales Document Type", POSEntry."Sales Document No.", DocDeleted) and
                (POSSalesLine.Type <> POSSalesLine.Type::Voucher) and
                (POSSalesLine.Type <> POSSalesLine.Type::Payout) and
                (POSSalesLine.Type <> POSSalesLine.Type::"G/L Account")) then begin

                case (POSEntry."Sales Document Type") of
                    POSEntry."Sales Document Type"::Invoice:
                        POSWorkshiftCheckpoint."Credit Real. Sale Amt. (LCY)" += POSSalesLine."Amount Excl. VAT (LCY)";
                    POSEntry."Sales Document Type"::Order:
                        POSWorkshiftCheckpoint."Credit Real. Sale Amt. (LCY)" += POSSalesLine."Amount Excl. VAT (LCY)";
                    POSEntry."Sales Document Type"::"Credit Memo":
                        POSWorkshiftCheckpoint."Credit Real. Return Amt. (LCY)" += POSSalesLine."Amount Excl. VAT (LCY)";
                    POSEntry."Sales Document Type"::"Return Order":
                        POSWorkshiftCheckpoint."Credit Real. Return Amt. (LCY)" += POSSalesLine."Amount Excl. VAT (LCY)";
                end;

                POSWorkshiftCheckpoint."Turnover (LCY)" += POSSalesLine."Amount Incl. VAT (LCY)";
                POSWorkshiftCheckpoint."Net Turnover (LCY)" += POSSalesLine."Amount Excl. VAT (LCY)";
                POSWorkshiftCheckpoint."Credit Turnover (LCY)" += POSSalesLine."Amount Incl. VAT (LCY)";
                POSWorkshiftCheckpoint."Credit Net Turnover (LCY)" += POSSalesLine."Amount Excl. VAT (LCY)";
                POSWorkshiftCheckpoint."Net Cost (LCY)" += POSSalesLine."Unit Cost (LCY)" * POSSalesLine.Quantity;

            end else begin
                if not DocDeleted then
                    case (POSEntry."Sales Document Type") of
                        POSEntry."Sales Document Type"::Invoice:
                            POSWorkshiftCheckpoint."Credit Unreal. Sale Amt. (LCY)" += POSSalesLine."Amount Excl. VAT (LCY)";
                        POSEntry."Sales Document Type"::Order:
                            POSWorkshiftCheckpoint."Credit Unreal. Sale Amt. (LCY)" += POSSalesLine."Amount Excl. VAT (LCY)";
                        POSEntry."Sales Document Type"::"Credit Memo":
                            POSWorkshiftCheckpoint."Credit Unreal. Ret. Amt. (LCY)" += POSSalesLine."Amount Excl. VAT (LCY)";
                        POSEntry."Sales Document Type"::"Return Order":
                            POSWorkshiftCheckpoint."Credit Unreal. Ret. Amt. (LCY)" += POSSalesLine."Amount Excl. VAT (LCY)";
                    end;
            end;

            if not DocDeleted then begin
                POSWorkshiftCheckpoint."Credit Sales Amount (LCY)" += POSSalesLine."Amount Incl. VAT (LCY)";
                POSWorkshiftCheckpoint."Credit Net Sales Amount (LCY)" += POSSalesLine."Amount Excl. VAT (LCY)";
            end;
        end;


        if (POSEntry."Entry Type" <> POSEntry."Entry Type"::"Credit Sale") then begin
            if ((POSSalesLine.Type <> POSSalesLine.Type::Voucher) and
                (POSSalesLine.Type <> POSSalesLine.Type::Payout) and
                (POSSalesLine.Type <> POSSalesLine.Type::Customer) and
                (POSSalesLine.Type <> POSSalesLine.Type::"G/L Account")) then begin

                POSWorkshiftCheckpoint."Turnover (LCY)" += POSSalesLine."Amount Incl. VAT (LCY)";
                POSWorkshiftCheckpoint."Net Turnover (LCY)" += POSSalesLine."Amount Excl. VAT (LCY)";
                POSWorkshiftCheckpoint."Net Cost (LCY)" += POSSalesLine."Unit Cost (LCY)" * POSSalesLine.Quantity;
            end;
        end;

        if POSEntry."Entry Type" in [POSEntry."Entry Type"::"Direct Sale"] then begin
            if ((POSSalesLine.Type <> POSSalesLine.Type::Voucher) and
                (POSSalesLine.Type <> POSSalesLine.Type::Payout) and
                (POSSalesLine.Type <> POSSalesLine.Type::Customer) and
                (POSSalesLine.Type <> POSSalesLine.Type::"G/L Account")) then begin
                POSWorkshiftCheckpoint."Direct Net Turnover (LCY)" += POSSalesLine."Amount Excl. VAT (LCY)";
                POSWorkshiftCheckpoint."Direct Turnover (LCY)" += POSSalesLine."Amount Incl. VAT (LCY)";
                if POSSalesLine."Amount Incl. VAT (LCY)" < 0 then
                    POSWorkshiftCheckpoint."Direct Negative Turnover (LCY)" += POSSalesLine."Amount Incl. VAT (LCY)";
            end;
        end;

        case POSSalesLine.Type of
            POSSalesLine.Type::Item:
                begin
                    if (POSEntry."Entry Type" = POSEntry."Entry Type"::"Direct Sale") then begin
                        if (POSSalesLine.Quantity > 0) then begin
                            POSWorkshiftCheckpoint."Direct Item Sales (LCY)" += POSSalesLine."Amount Incl. VAT (LCY)";
                            POSWorkshiftCheckpoint."Direct Item Net Sales (LCY)" += POSSalesLine."Amount Excl. VAT (LCY)";
                            POSWorkshiftCheckpoint."Direct Item Sales Line Count" += 1;
                            POSWorkshiftCheckpoint."Direct Item Sales Quantity" += POSSalesLine.Quantity;
                        end;

                        if (POSSalesLine.Quantity < 0) then begin
                            POSWorkshiftCheckpoint."Direct Item Returns (LCY)" += POSSalesLine."Amount Incl. VAT (LCY)";
                            POSWorkshiftCheckpoint."Direct Item Returns Line Count" += 1;
                            POSWorkshiftCheckpoint."Direct Item Returns Quantity" += POSSalesLine.Quantity;
                        end;

                        POSWorkshiftCheckpoint."Direct Item Quantity Sum" += POSSalesLine.Quantity;
                    end;

                    if (POSEntry."Entry Type" = POSEntry."Entry Type"::"Credit Sale") then begin
                        POSWorkshiftCheckpoint."Credit Item Sales (LCY)" += POSSalesLine."Amount Incl. VAT (LCY)";
                        POSWorkshiftCheckpoint."Credit Item Quantity Sum" += POSSalesLine.Quantity;
                    end;
                end;

            POSSalesLine.Type::Customer:
                begin
                    POSWorkshiftCheckpoint."Debtor Payment (LCY)" += POSSalesLine."Amount Incl. VAT (LCY)";
                end;

            POSSalesLine.Type::"G/L Account":
                begin
                    POSWorkshiftCheckpoint."GL Payment (LCY)" += POSSalesLine."Amount Incl. VAT (LCY)";
                end;

            POSSalesLine.Type::Payout:
                begin
                    // Net value, a "Payin" has reversed sign
                    POSWorkshiftCheckpoint."GL Payment (LCY)" += POSSalesLine."Amount Incl. VAT (LCY)";
                end;

            POSSalesLine.Type::Rounding:
                begin
                    POSWorkshiftCheckpoint."Rounding (LCY)" += POSSalesLine."Amount Incl. VAT (LCY)";
                end;

            POSSalesLine.Type::Voucher:
                begin
                    POSWorkshiftCheckpoint."Issued Vouchers (LCY)" += POSSalesLine."Amount Incl. VAT (LCY)";
                end;

            else
                ;
        end;
    end;

    procedure SetDiscounts(var POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; POSSalesLine: Record "NPR POS Entry Sales Line")
    begin

        POSWorkshiftCheckpoint."Total Discount (LCY)" += POSSalesLine."Line Dsc. Amt. Incl. VAT (LCY)";
        POSWorkshiftCheckpoint."Total Net Discount (LCY)" += POSSalesLine."Line Dsc. Amt. Excl. VAT (LCY)";

        if POSSalesLine."Discount Type" <> POSSalesLine."Discount Type"::" " then
            POSWorkshiftCheckpoint."Discounts Count" += 1;

        case POSSalesLine."Discount Type" of
            POSSalesLine."Discount Type"::"BOM List":
                POSWorkshiftCheckpoint."BOM Discount (LCY)" += POSSalesLine."Line Dsc. Amt. Incl. VAT (LCY)";
            POSSalesLine."Discount Type"::Campaign:
                POSWorkshiftCheckpoint."Campaign Discount (LCY)" += POSSalesLine."Line Dsc. Amt. Incl. VAT (LCY)";
            POSSalesLine."Discount Type"::Customer:
                POSWorkshiftCheckpoint."Customer Discount (LCY)" += POSSalesLine."Line Dsc. Amt. Incl. VAT (LCY)";
            POSSalesLine."Discount Type"::Manual:
                POSWorkshiftCheckpoint."Custom Discount (LCY)" += POSSalesLine."Line Dsc. Amt. Incl. VAT (LCY)";
            POSSalesLine."Discount Type"::Mix:
                POSWorkshiftCheckpoint."Mix Discount (LCY)" += POSSalesLine."Line Dsc. Amt. Incl. VAT (LCY)";
            POSSalesLine."Discount Type"::Quantity:
                POSWorkshiftCheckpoint."Quantity Discount (LCY)" += POSSalesLine."Line Dsc. Amt. Incl. VAT (LCY)";
            else
                POSWorkshiftCheckpoint."Line Discount (LCY)" += POSSalesLine."Line Dsc. Amt. Incl. VAT (LCY)";
        end;
    end;

    procedure SetPayments(var POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; POSPaymentLine: Record "NPR POS Entry Payment Line"; LCYCode: Code[10])
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        IsLCY: Boolean;
    begin

        POSPaymentMethod.Get(POSPaymentLine."POS Payment Method Code");
        IsLCY := ((POSPaymentLine."Currency Code" = '') or (POSPaymentLine."Currency Code" = LCYCode));

        case POSPaymentMethod."Processing Type" of
            POSPaymentMethod."Processing Type"::CASH:
                begin
                    if (IsLCY) then POSWorkshiftCheckpoint."Local Currency (LCY)" += POSPaymentLine."Amount (LCY)";
                    if (not IsLCY) then POSWorkshiftCheckpoint."Foreign Currency (LCY)" += POSPaymentLine."Amount (LCY)";
                end;

            POSPaymentMethod."Processing Type"::CHECK:
                begin
                    if (IsLCY) then POSWorkshiftCheckpoint."Local Currency (LCY)" += POSPaymentLine."Amount (LCY)";
                    if (not IsLCY) then POSWorkshiftCheckpoint."Foreign Currency (LCY)" += POSPaymentLine."Amount (LCY)";
                end;

            POSPaymentMethod."Processing Type"::EFT:
                POSWorkshiftCheckpoint."EFT (LCY)" += POSPaymentLine."Amount (LCY)";
            POSPaymentMethod."Processing Type"::PAYOUT:
                ; // PAYOUT is recorded on Sales Line POSWorkshiftCheckpoint."GL Payment (LCY)" += "Amount (LCY)";
            POSPaymentMethod."Processing Type"::VOUCHER, POSPaymentMethod."Processing Type"::"FOREIGN VOUCHER":
                POSWorkshiftCheckpoint."Redeemed Vouchers (LCY)" += POSPaymentLine."Amount (LCY)";

        end;
    end;

    local procedure FinalizeCheckpoint(var POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    begin

        POSWorkshiftCheckpoint."Profit Amount (LCY)" := POSWorkshiftCheckpoint."Net Turnover (LCY)" - POSWorkshiftCheckpoint."Net Cost (LCY)";

        if (POSWorkshiftCheckpoint."Net Turnover (LCY)" <> 0) then
            POSWorkshiftCheckpoint."Profit %" := POSWorkshiftCheckpoint."Profit Amount (LCY)" * 100 / POSWorkshiftCheckpoint."Net Turnover (LCY)";

        if (POSWorkshiftCheckpoint."Profit Amount (LCY)" < 0) and (POSWorkshiftCheckpoint."Profit %" > 0) then
            POSWorkshiftCheckpoint."Profit %" := -POSWorkshiftCheckpoint."Profit %";

        POSWorkshiftCheckpoint."Calculated Diff (LCY)" := 0;

        if (POSWorkshiftCheckpoint."Turnover (LCY)" <> 0) then begin
            POSWorkshiftCheckpoint."Custom Discount %" := Round(POSWorkshiftCheckpoint."Custom Discount (LCY)" * 100 / POSWorkshiftCheckpoint."Turnover (LCY)", 0.01);
            POSWorkshiftCheckpoint."Quantity Discount %" := Round(POSWorkshiftCheckpoint."Quantity Discount (LCY)" * 100 / POSWorkshiftCheckpoint."Turnover (LCY)", 0.01);
            POSWorkshiftCheckpoint."Mix Discount %" := Round(POSWorkshiftCheckpoint."Mix Discount (LCY)" * 100 / POSWorkshiftCheckpoint."Turnover (LCY)", 0.01);
            POSWorkshiftCheckpoint."Campaign Discount %" := Round(POSWorkshiftCheckpoint."Campaign Discount (LCY)" * 100 / POSWorkshiftCheckpoint."Turnover (LCY)", 0.01);
            POSWorkshiftCheckpoint."Line Discount %" := Round(POSWorkshiftCheckpoint."Line Discount (LCY)" * 100 / POSWorkshiftCheckpoint."Turnover (LCY)", 0.01);
            POSWorkshiftCheckpoint."Total Discount %" := Round(POSWorkshiftCheckpoint."Total Discount (LCY)" * 100 / POSWorkshiftCheckpoint."Turnover (LCY)", 0.01);
            POSWorkshiftCheckpoint."BOM Discount %" := Round(POSWorkshiftCheckpoint."BOM Discount (LCY)" * 100 / POSWorkshiftCheckpoint."Turnover (LCY)", 0.01);
            POSWorkshiftCheckpoint."Customer Discount %" := Round(POSWorkshiftCheckpoint."Customer Discount (LCY)" * 100 / POSWorkshiftCheckpoint."Turnover (LCY)", 0.01);
        end;
    end;

    local procedure TryGetSalesperson(): Code[20]
    var
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSSetup: Codeunit "NPR POS Setup";
    begin

        if not POSSession.IsActiveSession(POSFrontEnd) then
            exit('');
        POSFrontEnd.GetSession(POSSession);
        POSSession.GetSetup(POSSetup);
        exit(POSSetup.Salesperson());

    end;

    procedure CreatePeriodCheckpoint(POSEntryNo: Integer; POSUnit: Code[10]; FromWorkshiftEntryNo: Integer; ToWorkshiftEntryNo: Integer; PeriodType: Code[20]) PeriodEntryNo: Integer
    var
        ZReportWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        PeriodWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSEntry: Record "NPR POS Entry";
        TmpTaxEntryNo: Integer;
        TempPeriodWorkshiftTaxCheckpoint: Record "NPR POS Worksh. Tax Checkp." temporary;
        PeriodWorkshiftTaxCheckpoint: Record "NPR POS Worksh. Tax Checkp.";
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        POSAuditLog: Record "NPR POS Audit Log";
    begin

        ZReportWorkshiftCheckpoint.SetCurrentKey("POS Unit No.", Open, "Type");
        ZReportWorkshiftCheckpoint.SetFilter("Entry No.", '>=%1&<=%2', FromWorkshiftEntryNo, ToWorkshiftEntryNo);
        ZReportWorkshiftCheckpoint.SetFilter("POS Unit No.", '=%1', POSUnit);
        ZReportWorkshiftCheckpoint.SetFilter(Open, '=%1', false);
        ZReportWorkshiftCheckpoint.SetFilter(Type, '=%1', ZReportWorkshiftCheckpoint.Type::ZREPORT);

        if (not ZReportWorkshiftCheckpoint.FindSet()) then
            exit(0);

        PeriodWorkshiftCheckpoint.Init();
        PeriodWorkshiftCheckpoint."Entry No." := 0;

        PeriodWorkshiftCheckpoint."POS Entry No." := POSEntryNo;
        PeriodWorkshiftCheckpoint."POS Unit No." := POSUnit;
        PeriodWorkshiftCheckpoint.TestField("POS Unit No.");
        PeriodWorkshiftCheckpoint."Created At" := CurrentDateTime();
        PeriodWorkshiftCheckpoint.Open := true;
        PeriodWorkshiftCheckpoint.Type := PeriodWorkshiftCheckpoint.Type::PREPORT;
        PeriodWorkshiftCheckpoint."Period Type" := PeriodType;
        PeriodWorkshiftCheckpoint.Insert();

        repeat
            PeriodWorkshiftCheckpoint."Debtor Payment (LCY)" += ZReportWorkshiftCheckpoint."Debtor Payment (LCY)";
            PeriodWorkshiftCheckpoint."GL Payment (LCY)" += ZReportWorkshiftCheckpoint."GL Payment (LCY)";
            PeriodWorkshiftCheckpoint."Rounding (LCY)" += ZReportWorkshiftCheckpoint."Rounding (LCY)";
            PeriodWorkshiftCheckpoint."Credit Item Sales (LCY)" += ZReportWorkshiftCheckpoint."Credit Item Sales (LCY)";
            PeriodWorkshiftCheckpoint."Credit Item Quantity Sum" += ZReportWorkshiftCheckpoint."Credit Item Quantity Sum";
            PeriodWorkshiftCheckpoint."Credit Net Sales Amount (LCY)" += ZReportWorkshiftCheckpoint."Credit Net Sales Amount (LCY)";
            PeriodWorkshiftCheckpoint."Credit Sales Count" += ZReportWorkshiftCheckpoint."Credit Sales Count";
            PeriodWorkshiftCheckpoint."Issued Vouchers (LCY)" += ZReportWorkshiftCheckpoint."Issued Vouchers (LCY)";
            PeriodWorkshiftCheckpoint."Redeemed Vouchers (LCY)" += ZReportWorkshiftCheckpoint."Redeemed Vouchers (LCY)";
            PeriodWorkshiftCheckpoint."Local Currency (LCY)" += ZReportWorkshiftCheckpoint."Local Currency (LCY)";
            PeriodWorkshiftCheckpoint."Foreign Currency (LCY)" += ZReportWorkshiftCheckpoint."Foreign Currency (LCY)";
            PeriodWorkshiftCheckpoint."EFT (LCY)" += ZReportWorkshiftCheckpoint."EFT (LCY)";
            PeriodWorkshiftCheckpoint."Manual Card (LCY)" += ZReportWorkshiftCheckpoint."Manual Card (LCY)";
            PeriodWorkshiftCheckpoint."Other Credit Card (LCY)" += ZReportWorkshiftCheckpoint."Other Credit Card (LCY)";
            PeriodWorkshiftCheckpoint."Cash Terminal (LCY)" += ZReportWorkshiftCheckpoint."Cash Terminal (LCY)";
            PeriodWorkshiftCheckpoint."Redeemed Credit Voucher (LCY)" += ZReportWorkshiftCheckpoint."Redeemed Credit Voucher (LCY)";
            PeriodWorkshiftCheckpoint."Created Credit Voucher (LCY)" += ZReportWorkshiftCheckpoint."Created Credit Voucher (LCY)";
            PeriodWorkshiftCheckpoint."Direct Item Sales (LCY)" += ZReportWorkshiftCheckpoint."Direct Item Sales (LCY)";
            PeriodWorkshiftCheckpoint."Direct Sales - Staff (LCY)" += ZReportWorkshiftCheckpoint."Direct Sales - Staff (LCY)";
            PeriodWorkshiftCheckpoint."Direct Sales Count" += ZReportWorkshiftCheckpoint."Direct Sales Count";
            PeriodWorkshiftCheckpoint."Cancelled Sales Count" += ZReportWorkshiftCheckpoint."Cancelled Sales Count";
            PeriodWorkshiftCheckpoint."Net Turnover (LCY)" += ZReportWorkshiftCheckpoint."Net Turnover (LCY)";
            PeriodWorkshiftCheckpoint."Turnover (LCY)" += ZReportWorkshiftCheckpoint."Turnover (LCY)";
            PeriodWorkshiftCheckpoint."Net Cost (LCY)" += ZReportWorkshiftCheckpoint."Net Cost (LCY)";
            PeriodWorkshiftCheckpoint."Profit Amount (LCY)" += ZReportWorkshiftCheckpoint."Profit Amount (LCY)";
            PeriodWorkshiftCheckpoint."Direct Item Returns (LCY)" += ZReportWorkshiftCheckpoint."Direct Item Returns (LCY)";
            PeriodWorkshiftCheckpoint."Direct Item Returns Line Count" += ZReportWorkshiftCheckpoint."Direct Item Returns Line Count";
            PeriodWorkshiftCheckpoint."Total Discount (LCY)" += ZReportWorkshiftCheckpoint."Total Discount (LCY)";
            PeriodWorkshiftCheckpoint."Campaign Discount (LCY)" += ZReportWorkshiftCheckpoint."Campaign Discount (LCY)";
            PeriodWorkshiftCheckpoint."Mix Discount (LCY)" += ZReportWorkshiftCheckpoint."Mix Discount (LCY)";
            PeriodWorkshiftCheckpoint."Quantity Discount (LCY)" += ZReportWorkshiftCheckpoint."Quantity Discount (LCY)";
            PeriodWorkshiftCheckpoint."Custom Discount (LCY)" += ZReportWorkshiftCheckpoint."Custom Discount (LCY)";
            PeriodWorkshiftCheckpoint."BOM Discount (LCY)" += ZReportWorkshiftCheckpoint."BOM Discount (LCY)";
            PeriodWorkshiftCheckpoint."Customer Discount (LCY)" += ZReportWorkshiftCheckpoint."Customer Discount (LCY)";
            PeriodWorkshiftCheckpoint."Line Discount (LCY)" += ZReportWorkshiftCheckpoint."Line Discount (LCY)";
            PeriodWorkshiftCheckpoint."Calculated Diff (LCY)" += ZReportWorkshiftCheckpoint."Calculated Diff (LCY)";
            PeriodWorkshiftCheckpoint."Direct Item Quantity Sum" += ZReportWorkshiftCheckpoint."Direct Item Quantity Sum";
            PeriodWorkshiftCheckpoint."Direct Item Sales Line Count" += ZReportWorkshiftCheckpoint."Direct Item Sales Line Count";
            PeriodWorkshiftCheckpoint."Receipts Count" += ZReportWorkshiftCheckpoint."Receipts Count";
            PeriodWorkshiftCheckpoint."Cash Drawer Open Count" += ZReportWorkshiftCheckpoint."Cash Drawer Open Count";
            PeriodWorkshiftCheckpoint."Receipt Copies Count" += ZReportWorkshiftCheckpoint."Receipt Copies Count";
            PeriodWorkshiftCheckpoint."Receipt Copies Sales (LCY)" += ZReportWorkshiftCheckpoint."Receipt Copies Sales (LCY)";
            PeriodWorkshiftCheckpoint."Bin Transfer Out Amount (LCY)" += ZReportWorkshiftCheckpoint."Bin Transfer Out Amount (LCY)";
            PeriodWorkshiftCheckpoint."Bin Transfer In Amount (LCY)" += ZReportWorkshiftCheckpoint."Bin Transfer In Amount (LCY)";
            PeriodWorkshiftCheckpoint."Opening Cash (LCY)" += ZReportWorkshiftCheckpoint."Opening Cash (LCY)";
            PeriodWorkshiftCheckpoint."Direct Negative Turnover (LCY)" += ZReportWorkshiftCheckpoint."Direct Negative Turnover (LCY)";
            PeriodWorkshiftCheckpoint."Direct Turnover (LCY)" += ZReportWorkshiftCheckpoint."Direct Turnover (LCY)";

            AggregateTaxCheckpoint(TempPeriodWorkshiftTaxCheckpoint, PeriodWorkshiftCheckpoint."Entry No.", ZReportWorkshiftCheckpoint."Entry No.", TmpTaxEntryNo);
        until (ZReportWorkshiftCheckpoint.Next() = 0);

        PeriodWorkshiftCheckpoint."Perpetual Dir. Item Sales(LCY)" := ZReportWorkshiftCheckpoint."Perpetual Dir. Item Sales(LCY)";
        PeriodWorkshiftCheckpoint."Perpetual Dir. Item Ret. (LCY)" := ZReportWorkshiftCheckpoint."Perpetual Dir. Item Ret. (LCY)";
        PeriodWorkshiftCheckpoint."Perpetual Dir. Turnover (LCY)" := ZReportWorkshiftCheckpoint."Perpetual Dir. Turnover (LCY)";
        PeriodWorkshiftCheckpoint."Perpetual Dir. Neg. Turn (LCY)" := ZReportWorkshiftCheckpoint."Perpetual Dir. Neg. Turn (LCY)";
        PeriodWorkshiftCheckpoint."Perpetual Rounding Amt. (LCY)" := ZReportWorkshiftCheckpoint."Perpetual Rounding Amt. (LCY)";

        FinalizeCheckpoint(PeriodWorkshiftCheckpoint);
        PeriodWorkshiftCheckpoint.Open := false;
        PeriodWorkshiftCheckpoint.Modify();

        TempPeriodWorkshiftTaxCheckpoint.Reset();
        if (TempPeriodWorkshiftTaxCheckpoint.FindSet()) then begin
            repeat
                PeriodWorkshiftTaxCheckpoint.TransferFields(TempPeriodWorkshiftTaxCheckpoint, false);
                PeriodWorkshiftTaxCheckpoint."Entry No." := 0;
                PeriodWorkshiftTaxCheckpoint.Insert();
            until (TempPeriodWorkshiftTaxCheckpoint.Next() = 0);
        end;

        if POSEntry.Get(PeriodWorkshiftCheckpoint."POS Entry No.") then;

        POSAuditLogMgt.CreateEntry(PeriodWorkshiftCheckpoint.RecordId, POSAuditLog."Action Type"::GRANDTOTAL, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.");
        POSAuditLogMgt.CreateEntry(PeriodWorkshiftCheckpoint.RecordId, POSAuditLog."Action Type"::WORKSHIFT_END, POSEntry."Entry No.", POSEntry."Fiscal No.", PeriodWorkshiftCheckpoint."POS Unit No.");

        exit(PeriodWorkshiftCheckpoint."Entry No.");
    end;

    local procedure AggregateTaxCheckpoint(var TmpPeriodTaxWorkshiftCheckpoint: Record "NPR POS Worksh. Tax Checkp." temporary; PeriodEntryNo: Integer; ZReportEntryNo: Integer; var TempEntryNo: Integer)
    var
        POSWorkshiftTaxCheckpoint: Record "NPR POS Worksh. Tax Checkp.";
    begin

        POSWorkshiftTaxCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', ZReportEntryNo);
        if (POSWorkshiftTaxCheckpoint.FindSet()) then begin
            repeat

                TmpPeriodTaxWorkshiftCheckpoint.Reset();
                TmpPeriodTaxWorkshiftCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', PeriodEntryNo);
                TmpPeriodTaxWorkshiftCheckpoint.SetFilter("Tax Area Code", '=%1', POSWorkshiftTaxCheckpoint."Tax Area Code");
                TmpPeriodTaxWorkshiftCheckpoint.SetFilter("Tax Calculation Type", '=%1', POSWorkshiftTaxCheckpoint."Tax Calculation Type");
                TmpPeriodTaxWorkshiftCheckpoint.SetFilter("VAT Identifier", '=%1', POSWorkshiftTaxCheckpoint."VAT Identifier");
                TmpPeriodTaxWorkshiftCheckpoint.SetFilter("Tax Jurisdiction Code", '=%1', POSWorkshiftTaxCheckpoint."Tax Jurisdiction Code");
                TmpPeriodTaxWorkshiftCheckpoint.SetFilter("Tax Group Code", '=%1', POSWorkshiftTaxCheckpoint."Tax Group Code");

                if (not TmpPeriodTaxWorkshiftCheckpoint.FindFirst()) then begin
                    TempEntryNo += 1;
                    TmpPeriodTaxWorkshiftCheckpoint."Entry No." := TempEntryNo;

                    TmpPeriodTaxWorkshiftCheckpoint.Init();
                    TmpPeriodTaxWorkshiftCheckpoint."Workshift Checkpoint Entry No." := PeriodEntryNo;

                    TmpPeriodTaxWorkshiftCheckpoint."Tax Calculation Type" := POSWorkshiftTaxCheckpoint."Tax Calculation Type";
                    TmpPeriodTaxWorkshiftCheckpoint."VAT Identifier" := POSWorkshiftTaxCheckpoint."VAT Identifier";
                    TmpPeriodTaxWorkshiftCheckpoint."Tax Area Code" := POSWorkshiftTaxCheckpoint."Tax Area Code";
                    TmpPeriodTaxWorkshiftCheckpoint."Tax Jurisdiction Code" := POSWorkshiftTaxCheckpoint."Tax Jurisdiction Code";
                    TmpPeriodTaxWorkshiftCheckpoint."Tax Group Code" := POSWorkshiftTaxCheckpoint."Tax Group Code";
                    TmpPeriodTaxWorkshiftCheckpoint."Tax %" := POSWorkshiftTaxCheckpoint."Tax %";
                    TmpPeriodTaxWorkshiftCheckpoint."Tax Type" := POSWorkshiftTaxCheckpoint."Tax Type";
                    TmpPeriodTaxWorkshiftCheckpoint.Insert();
                end;

                TmpPeriodTaxWorkshiftCheckpoint."Tax Base Amount" += POSWorkshiftTaxCheckpoint."Tax Base Amount";
                TmpPeriodTaxWorkshiftCheckpoint."Tax Amount" += POSWorkshiftTaxCheckpoint."Tax Amount";
                TmpPeriodTaxWorkshiftCheckpoint."Line Amount" += POSWorkshiftTaxCheckpoint."Line Amount";
                TmpPeriodTaxWorkshiftCheckpoint."Amount Including Tax" += POSWorkshiftTaxCheckpoint."Amount Including Tax";
                TmpPeriodTaxWorkshiftCheckpoint.Modify();
            until (POSWorkshiftTaxCheckpoint.Next() = 0);

        end;
    end;


    local procedure AggregateVat_PE(WorkshiftCheckpointEntryNo: Integer; POSStoreCode: Code[10]; POSUnitNo: Code[10]; FromPosEntryNo: Integer)
    var
        TempPOSWorkshiftTaxCheckpoint: Record "NPR POS Worksh. Tax Checkp." temporary;
        POSTaxAmountLine: Record "NPR POS Entry Tax Line";
        POSWorkshiftTaxCheckpoint: Record "NPR POS Worksh. Tax Checkp.";
        POSEntry: Record "NPR POS Entry";
        TempEntryNo: Integer;
    begin
        POSEntry.SetCurrentKey("POS Store Code", "POS Unit No.");
        POSEntry.SetRange("POS Store Code", POSStoreCode);
        POSEntry.SetRange("POS Unit No.", PosUnitNo);
        POSEntry.SetFilter("Entry No.", '%1..', FromPosEntryNo);
        POSEntry.SetFilter("Entry Type", '=%1', POSEntry."Entry Type"::"Direct Sale");
        if (POSEntry.IsEmpty()) then
            exit;

        POSEntry.SetLoadFields("Entry No.");
        POSEntry.FindSet();
        repeat
            POSTaxAmountLine.SetFilter("POS Entry No.", '=%1', POSEntry."Entry No.");
            if (POSTaxAmountLine.FindSet()) then begin
                repeat
                    TempPOSWorkshiftTaxCheckpoint.Reset();
                    TempPOSWorkshiftTaxCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', WorkshiftCheckpointEntryNo);
                    TempPOSWorkshiftTaxCheckpoint.SetFilter("Tax Area Code", '=%1', POSTaxAmountLine."Tax Area Code");
                    TempPOSWorkshiftTaxCheckpoint.SetFilter("Tax Calculation Type", '=%1', POSTaxAmountLine."Tax Calculation Type");
                    TempPOSWorkshiftTaxCheckpoint.SetFilter("VAT Identifier", '=%1', POSTaxAmountLine."VAT Identifier");
                    TempPOSWorkshiftTaxCheckpoint.SetFilter("Tax Jurisdiction Code", '=%1', POSTaxAmountLine."Tax Jurisdiction Code");
                    TempPOSWorkshiftTaxCheckpoint.SetFilter("Tax Group Code", '=%1', POSTaxAmountLine."Tax Group Code");

                    if (not TempPOSWorkshiftTaxCheckpoint.FindFirst()) then begin
                        TempEntryNo += 1;
                        TempPOSWorkshiftTaxCheckpoint."Entry No." := TempEntryNo;

                        TempPOSWorkshiftTaxCheckpoint.Init();
                        TempPOSWorkshiftTaxCheckpoint."Workshift Checkpoint Entry No." := WorkshiftCheckpointEntryNo;
                        TempPOSWorkshiftTaxCheckpoint."Tax Calculation Type" := POSTaxAmountLine."Tax Calculation Type";
                        TempPOSWorkshiftTaxCheckpoint."VAT Identifier" := POSTaxAmountLine."VAT Identifier";
                        TempPOSWorkshiftTaxCheckpoint."Tax Jurisdiction Code" := POSTaxAmountLine."Tax Jurisdiction Code";
                        TempPOSWorkshiftTaxCheckpoint."Tax Group Code" := POSTaxAmountLine."Tax Group Code";
                        TempPOSWorkshiftTaxCheckpoint."Tax Area Code" := POSTaxAmountLine."Tax Area Code";
                        TempPOSWorkshiftTaxCheckpoint."Tax %" := POSTaxAmountLine."Tax %";
                        TempPOSWorkshiftTaxCheckpoint.Insert();
                    end;

                    TempPOSWorkshiftTaxCheckpoint."Tax Base Amount" += POSTaxAmountLine."Tax Base Amount";
                    TempPOSWorkshiftTaxCheckpoint."Tax Amount" += POSTaxAmountLine."Tax Amount";
                    TempPOSWorkshiftTaxCheckpoint."Line Amount" += POSTaxAmountLine."Line Amount";
                    TempPOSWorkshiftTaxCheckpoint."Amount Including Tax" += POSTaxAmountLine."Amount Including Tax";
                    TempPOSWorkshiftTaxCheckpoint.Modify();
                until (POSTaxAmountLine.Next() = 0);
            end;
        until (POSEntry.Next() = 0);

        TempPOSWorkshiftTaxCheckpoint.Reset();
        if (TempPOSWorkshiftTaxCheckpoint.IsEmpty()) then
            exit;

        TempPOSWorkshiftTaxCheckpoint.FindSet();
        repeat
            POSWorkshiftTaxCheckpoint.TransferFields(TempPOSWorkshiftTaxCheckpoint, false);
            POSWorkshiftTaxCheckpoint."Entry No." := 0;
            POSWorkshiftTaxCheckpoint.Insert();
        until (TempPOSWorkshiftTaxCheckpoint.Next() = 0);
    end;

    local procedure SetRegisterStatistics(POSStoreCode: Code[10]; POSUnitNo: Code[10]; var POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; FromPosEntryNo: Integer)
    var
        POSEntry: Record "NPR POS Entry";
    begin
        if not POSEntry.Get(FromPosEntryNo) then
            exit;
        SetManualCashDrawerOpen(POSWorkshiftCheckpoint, POSEntry);
        SetReceiptCopyStatistics(POSWorkshiftCheckpoint, POSStoreCode, POSUnitNo, FromPosEntryNo);
    end;

    local procedure SetManualCashDrawerOpen(var POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; FirstPOSEntry: Record "NPR POS Entry")
    var
        POSAuditLog: Record "NPR POS Audit Log";
    begin
        POSAuditLog.SetCurrentKey("Acted on POS Unit No.", "Action Type");
        POSAuditLog.SetFilter(SystemCreatedAt, '%1..', FirstPOSEntry.SystemCreatedAt);
        POSAuditLog.SetRange("Active POS Unit No.", FirstPOSEntry."POS Unit No.");
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::MANUAL_DRAWER_OPEN);

        POSWorkshiftCheckpoint."Cash Drawer Open Count" := POSAuditLog.Count();
    end;

    local procedure SetReceiptCopyStatistics(var POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; POSStoreCode: Code[10]; POSUnitNo: Code[10]; FromPosEntryNo: Integer)
    var
        POSEntryReceiptCopies: Query "NPR POS Entry Receipt Copies";
    begin
        if not ReceiptCopyStatisticsEnabled(POSStoreCode, POSUnitNo) then
            exit;

        POSEntryReceiptCopies.SetRange(POSStoreCode, POSStoreCode);
        POSEntryReceiptCopies.SetRange(POSUnitNo, POSUnitNo);
        POSEntryReceiptCopies.SetFilter(POSEntryNo, '%1..', FromPosEntryNo);
        if not POSEntryReceiptCopies.Open() then
            exit;
        if POSEntryReceiptCopies.Read() then begin
            POSWorkshiftCheckpoint."Receipt Copies Count" := POSEntryReceiptCopies.NoOfReceiptCopies;
            POSWorkshiftCheckpoint."Receipt Copies Sales (LCY)" := POSEntryReceiptCopies.AmountInclTax;
        end;
        POSEntryReceiptCopies.Close();
    end;

    local procedure ReceiptCopyStatisticsEnabled(POSStoreCode: Code[10]; POSUnitNo: Code[10]): Boolean
    var
        POSUnit: Record "NPR POS Unit";
        POSAuditProfile: Record "NPR POS Audit Profile";
        Calculate: Boolean;
        Handled: Boolean;
    begin
        if not POSUnit.Get(POSUnitNo) then
            Clear(POSUnit);
        POSUnit.GetProfile(POSAuditProfile);

        OnDefineIfReceiptCopyStatisticsMustBeCalculated(POSStoreCode, POSUnitNo, POSAuditProfile."Audit Handler", Calculate, Handled);
        exit(Calculate);
    end;

    local procedure UpdateWorkshiftCheckpoint(var POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        POSPeriodRegister: Record "NPR POS Period Register";
    begin
        POSPeriodRegister.SetCurrentKey("POS Unit No.");
        POSPeriodRegister.SetRange("POS Unit No.", POSWorkshiftCheckpoint."POS Unit No.");
        if not POSPeriodRegister.FindLast() then
            exit;
        POSWorkshiftCheckpoint."POS Period Register No." := POSPeriodRegister."No.";
        POSWorkshiftCheckpoint."Salesperson Code" := TryGetSalesperson();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateBalancingEntry(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDefineIfReceiptCopyStatisticsMustBeCalculated(POSStoreCode: Code[10]; POSUnitNo: Code[10]; AuditHandler: Code[20]; var Calculate: Boolean; var Handled: Boolean)
    begin
    end;
}