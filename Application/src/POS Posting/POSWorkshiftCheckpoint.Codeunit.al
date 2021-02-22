codeunit 6150627 "NPR POS Workshift Checkpoint"
{
    var
        t030: Label 'Balancing';
        t031: Label 'Sales occur on this register after this balancing. Cancel and save countings.';
        MissingBin: Label 'No payment bin relation found for POS Unit %1.';

        POS_UNIT_SLAVE_STATUS: Label 'This POS manages other units for End-of-Day. The other units need to be in status closed, which is done with "Close Workshift" action. POS unit %1 has status %2.';
        EndOfDayUIOption: Option SUMMARY,BALANCING,"NONE";
        EodWorkshiftMode: Option XREPORT,ZREPORT,CLOSEWORKSHIFT;
        EntrySourceMethodOption: Option NA,AUDITROLL,BINENTRY;
        POSTING_ERROR: Label 'While posting end-of-day, the following error occured:\\%1';

    procedure EndWorkshift(Mode: Option; UnitNo: Code[20]; DimensionSetId: Integer) PosEntryNo: Integer
    begin
        // Main function to end the workshift
        PosEntryNo := CloseWorkshiftWorker(Mode, UnitNo, DimensionSetId);

        Commit;
        OnAfterEndWorkshift(Mode, UnitNo, (PosEntryNo <> 0), PosEntryNo);

        exit(PosEntryNo);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterEndWorkshift(Mode: Option; UnitNo: Code[20]; Successful: Boolean; PosEntryNo: Integer)
    begin
        // Mode:          XREPORT = 0, ZREPORT = 1, CLOSEWORKSHIFT = 2
        // Unit No.:      The POS Unit being balanced
        // Successful:    EOD posted successfully
        // Pos Entry No:  can be zero
    end;

    procedure BinTransfer(UsePosEntry: Boolean; WithPosting: Boolean; UnitNo: Code[20])
    var
        POSUnit: Record "NPR POS Unit";
        POSWorkshiftCheckpointPage: Page "NPR POS Workshift Checkp. Card";
        CheckPointEntryNo: Integer;
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSCheckpointMgr: Codeunit "NPR POS Workshift Checkpoint";
        PageAction: Action;
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        SalePOS: Record "NPR Sale POS";
        POSPostEntries: Codeunit "NPR POS Post Entries";
        POSEntryToPost: Record "NPR POS Entry";
        EntryNo: Integer;
    begin

        CheckPointEntryNo := POSCheckpointMgr.CreateEndWorkshiftCheckpoint_POSEntry(UnitNo);
        POSWorkshiftCheckpoint.Get(CheckPointEntryNo);
        Commit;

        CreateBinCheckpoint(CheckPointEntryNo);
        Commit;
    end;

    procedure CreateBinCheckpoint(CheckPointEntryNo: Integer)
    var
        PaymentBinCheckpoint: Codeunit "NPR POS Payment Bin Checkpoint";
        UnittoBinRelation: Record "NPR POS Unit to Bin Relation";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSUnit: Record "NPR POS Unit";
        POSPostingProfile: Record "NPR POS Posting Profile";
        EntrySourceMethod: Option;
    begin

        POSWorkshiftCheckpoint.Get(CheckPointEntryNo);

        POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.");
        POSUnit.GetProfile(POSPostingProfile);

        if (POSPostingProfile."POS Payment Bin" <> '') then
            PaymentBinCheckpoint.CreatePosEntryBinCheckpoint(POSUnit."No.", POSPostingProfile."POS Payment Bin", CheckPointEntryNo);

        UnittoBinRelation.SetFilter("POS Unit No.", '=%1', POSWorkshiftCheckpoint."POS Unit No.");
        if (UnittoBinRelation.FindSet()) then begin
            repeat
                PaymentBinCheckpoint.CreatePosEntryBinCheckpoint(UnittoBinRelation."POS Unit No.", UnittoBinRelation."POS Payment Bin No.", CheckPointEntryNo);

            until (UnittoBinRelation.Next() = 0);
        end else begin
            if (POSPostingProfile."POS Payment Bin" = '') then
                Error(MissingBin, POSWorkshiftCheckpoint."POS Unit No.");

        end;

    end;

    procedure CloseWorkshift(UsePosEntry: Boolean; WithPosting: Boolean; UnitNo: Code[20]) PosEntryNo: Integer
    var
        POSUnit: Record "NPR POS Unit";
        POSWorkshiftCheckpointPage: Page "NPR POS Workshift Checkp. Card";
        CheckPointEntryNo: Integer;
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSCheckpointMgr: Codeunit "NPR POS Workshift Checkpoint";
        PageAction: Action;
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        SalePOS: Record "NPR Sale POS";
        POSPostEntries: Codeunit "NPR POS Post Entries";
        POSEntryToPost: Record "NPR POS Entry";
        EntryNo: Integer;
    begin
        exit(CloseWorkshiftWithDimension(UsePosEntry, WithPosting, UnitNo, 0));
    end;

    procedure CloseWorkshiftWithDimension(UsePosEntry: Boolean; WithPosting: Boolean; UnitNo: Code[20]; DimensionSetId: Integer) PosEntryNo: Integer
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

    local procedure CloseWorkshiftWorker(Mode: Option; UnitNo: Code[20]; DimensionSetId: Integer) PosEntryNo: Integer
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSUnit: Record "NPR POS Unit";
        CheckpointEntryNo: Integer;
        EoDConfirmed: Boolean;
    begin

        PosEntryNo := 0;
        POSUnit.Get(UnitNo);

        CheckpointEntryNo := CreateCheckpointWorker(Mode, UnitNo);
        if (not POSWorkshiftCheckpoint.Get(CheckpointEntryNo)) then
            exit(0);

        EoDConfirmed := ShowEndOfDayUI(CheckpointEntryNo, Mode, UnitNo);

        // Create the balancing entries and post if z-report
        if (EoDConfirmed) then
            PosEntryNo := CreateBalancingEntryAndPost(Mode, UnitNo, CheckpointEntryNo, DimensionSetId);

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
                Commit;
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

                Commit;
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

        exit(ConfirmEoD);
    end;

    local procedure CreateCheckpointWorker(Mode: Option; UnitNo: Code[20]) CheckPointEntryNo: Integer
    var
        POSUnit: Record "NPR POS Unit";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        IsManager: Boolean;
    begin

        POSUnit.Get(UnitNo);

        //Create checkpoints for managed POS Units
        IsManager := CreateCheckpointForManagedPosUnits(UnitNo, Mode);
        CheckPointEntryNo := CreateEndWorkshiftCheckpoint_POSEntry(UnitNo);


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

        CreateBinCheckpoint(CheckPointEntryNo);
        POSPaymentBinCheckpoint.SetCurrentKey("Workshift Checkpoint Entry No.");
        POSPaymentBinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', CheckPointEntryNo);
        case Mode of
            EodWorkshiftMode::ZREPORT:
                POSPaymentBinCheckpoint.ModifyAll(Type, POSPaymentBinCheckpoint.Type::ZREPORT);
            EodWorkshiftMode::XREPORT:
                POSPaymentBinCheckpoint.ModifyAll(Type, POSPaymentBinCheckpoint.Type::XREPORT);
            EodWorkshiftMode::CLOSEWORKSHIFT:
                POSPaymentBinCheckpoint.ModifyAll(Type, POSPaymentBinCheckpoint.Type::XREPORT);
        end;

        if (IsManager) then
            AggregateWorkshifts(UnitNo, CheckPointEntryNo, Mode);

        Commit;

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
            POSUnit.SetFilter(Status, '<>%1', POSUnit.Status::CLOSED);
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
                CheckPointEntryNo := CreateEndWorkshiftCheckpoint_POSEntry(POSUnit."No.");
                POSWorkshiftCheckpoint.Get(CheckPointEntryNo);
                POSWorkshiftCheckpoint.Type := POSWorkshiftCheckpoint.Type::XREPORT;
                POSWorkshiftCheckpoint.Modify();

                CreateBinCheckpoint(POSWorkshiftCheckpoint."Entry No.");

                POSPaymentBinCheckpoint.SetCurrentKey("Workshift Checkpoint Entry No.");
                POSPaymentBinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', POSWorkshiftCheckpoint."Entry No.");
                POSPaymentBinCheckpoint.ModifyAll(Type, POSPaymentBinCheckpoint.Type::XREPORT);
            end;

            // Slave bin contents to master bin
            PaymentBinCheckpoint.TransferToPaymentBin(POSWorkshiftCheckpoint."Entry No.", POSUnit."No.", MasterPosUnit."No.");

            // Create a new check point now with zero in the bins
            CheckPointEntryNo := CreateEndWorkshiftCheckpoint_POSEntry(POSUnit."No.");
            POSWorkshiftCheckpoint.Get(CheckPointEntryNo);
            POSWorkshiftCheckpoint.Type := POSWorkshiftCheckpoint.Type::WORKSHIFT_CLOSE;
            POSWorkshiftCheckpoint.Open := true;
            POSWorkshiftCheckpoint.Modify();

            CreateBinCheckpoint(CheckPointEntryNo);

            POSWorkshiftCheckpoint.Reset();
            POSPaymentBinCheckpoint.SetCurrentKey("Workshift Checkpoint Entry No.");
            POSPaymentBinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', CheckPointEntryNo);
            POSPaymentBinCheckpoint.ModifyAll(Type, POSPaymentBinCheckpoint.Type::TRANSFER);
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
            POSUnit.SetFilter(Status, '<>%1', POSUnit.Status::CLOSED);
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

    local procedure CreateBalancingEntryAndPost(Mode: Option; UnitNo: Code[20]; CheckPointEntryNo: Integer; DimensionSetId: Integer) EntryNo: Integer
    var
        POSUnit: Record "NPR POS Unit";
        POSEndofDayProfile: Record "NPR POS End of Day Profile";
        POSEntry: Record "NPR POS Entry";
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        SalePOS: Record "NPR Sale POS";
        POSAuditLog: Record "NPR POS Audit Log";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSEntryToPost: Record "NPR POS Entry";
        POSCheckpointMgr: Codeunit "NPR POS Workshift Checkpoint";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSPostEntries: Codeunit "NPR POS Post Entries";
        DimMgt: Codeunit DimensionManagement;
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        PeriodEntryNo: Integer;
    begin

        POSUnit.Get(UnitNo);

        if (not POSEndofDayProfile.Get(POSUnit."POS End of Day Profile")) then
            POSEndofDayProfile.Init;

        POSPaymentBinCheckpoint.Reset();
        POSPaymentBinCheckpoint.SetCurrentKey("Workshift Checkpoint Entry No.");
        POSPaymentBinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', CheckPointEntryNo);
        POSPaymentBinCheckpoint.SetFilter(Status, '=%1', POSPaymentBinCheckpoint.Status::READY);
        if (POSPaymentBinCheckpoint.FindFirst()) then begin

            // A Sale POS record is needed when creating POS Entry
            SalePOS."Register No." := POSUnit."No.";
            SalePOS."POS Store Code" := POSUnit."POS Store Code";
            SalePOS.Date := Today;
            SalePOS."Sales Ticket No." := DelChr(Format(CurrentDateTime(), 0, 9), '<=>', DelChr(Format(CurrentDateTime(), 0, 9), '<=>', '01234567890'));

            if (Mode = EodWorkshiftMode::ZREPORT) and (POSEndofDayProfile."Z-Report Number Series" <> '') then
                SalePOS."Sales Ticket No." := NoSeriesManagement.GetNextNo(POSEndofDayProfile."Z-Report Number Series", Today, true);
            if (Mode = EodWorkshiftMode::XREPORT) and (POSEndofDayProfile."X-Report Number Series" <> '') then
                SalePOS."Sales Ticket No." := NoSeriesManagement.GetNextNo(POSEndofDayProfile."X-Report Number Series", Today, true);
            if (Mode = EodWorkshiftMode::CLOSEWORKSHIFT) and (POSEndofDayProfile."X-Report Number Series" <> '') then
                SalePOS."Sales Ticket No." := NoSeriesManagement.GetNextNo(POSEndofDayProfile."X-Report Number Series", Today, true);

            SalePOS."Salesperson Code" := TryGetSalesperson();
            SalePOS."Start Time" := Time;
            SalePOS."Dimension Set ID" := DimensionSetId;
            DimMgt.UpdateGlobalDimFromDimSetID(SalePOS."Dimension Set ID", SalePOS."Shortcut Dimension 1 Code", SalePOS."Shortcut Dimension 2 Code");

            EntryNo := POSCreateEntry.CreateBalancingEntryAndLines(SalePOS, (Mode <> EodWorkshiftMode::ZREPORT), CheckPointEntryNo);

            StoreCountedDenominations(UnitNo, CheckPointEntryNo);

            if (Mode = EodWorkshiftMode::ZREPORT) then begin

                // Create running total statistics
                POSWorkshiftCheckpoint.Get(CheckPointEntryNo);
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

                OnBeforePostWorkshift(POSWorkshiftCheckpoint);

                if (POSEntryToPost."Post Item Entry Status" < POSEntryToPost."Post Item Entry Status"::Posted) then
                    POSPostEntries.SetPostItemEntries(true);

                if (POSEntryToPost."Post Entry Status" < POSEntryToPost."Post Entry Status"::Posted) then
                    POSPostEntries.SetPostPOSEntries(true);

                POSPostEntries.SetStopOnError(true);
                POSPostEntries.SetPostCompressed(false);

                if (POSEndofDayProfile."Posting Error Handling" = POSEndofDayProfile."Posting Error Handling"::WITH_ERROR) then begin
                    POSPostEntries.Run(POSEntryToPost);
                end else begin
                    ClearLastError();
                    Commit;
                    if (not POSPostEntries.Run(POSEntryToPost)) then begin
                        POSEntryToPost.Get(EntryNo);
                        POSEntryToPost."POS Posting Log Entry No." := CreatePOSPostingLogEntry(POSEntryToPost, GetLastErrorText);
                        POSEntryToPost.Modify;
                        if (POSEndofDayProfile."Posting Error Handling" = POSEndofDayProfile."Posting Error Handling"::WITH_MESSAGE) then
                            Message(POSTING_ERROR, GetLastErrorText);
                    end;
                end;

                Commit;
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

    procedure CreateEndWorkshiftCheckpoint_POSEntry(POSUnitNo: Code[20]) CheckpointEntryNo: Integer
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin

        POSWorkshiftCheckpoint.Init();
        POSWorkshiftCheckpoint."Entry No." := 0;
        POSWorkshiftCheckpoint."POS Unit No." := POSUnitNo;
        POSWorkshiftCheckpoint."Created At" := CurrentDateTime();
        POSWorkshiftCheckpoint.Open := true;
        POSWorkshiftCheckpoint.Insert();
        Commit();

        if (POSUnitNo <> '') then
            CalculateCheckpointStatistics(POSUnitNo, POSWorkshiftCheckpoint);

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

    local procedure CreatePOSPostingLogEntry(var POSEntry: Record "NPR POS Entry"; ErrorReason: Text): Integer
    var
        POSPostingLog: Record "NPR POS Posting Log";
        LastPOSEntry: Record "NPR POS Entry";
    begin

        LastPOSEntry.Reset;
        LastPOSEntry.FindLast;

        POSPostingLog.Init;
        POSPostingLog."Entry No." := 0;
        POSPostingLog."User ID" := UserId;
        POSPostingLog."Posting Timestamp" := CurrentDateTime;
        POSPostingLog."With Error" := true;
        POSPostingLog."Error Description" := CopyStr(ErrorReason, 1, MaxStrLen(POSPostingLog."Error Description"));
        POSPostingLog."POS Entry View" := CopyStr(POSEntry.GetView, 1, MaxStrLen(POSPostingLog."POS Entry View"));
        POSPostingLog."Last POS Entry No. at Posting" := LastPOSEntry."Entry No.";
        POSPostingLog.Insert(true);
        exit(POSPostingLog."Entry No.");

    end;

    local procedure StoreCountedDenominations(UnitNo: Code[10]; WorkshiftEntryNo: Integer)
    var
        PaymentTypeDetailed: Record "NPR Payment Type - Detailed";
        POSPaymentBinDenomination: Record "NPR POS Paym. Bin Denomin.";
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
    begin

        PaymentTypeDetailed.SetFilter("Register No.", '=%1', UnitNo);
        if (PaymentTypeDetailed.IsEmpty()) then
            exit;

        POSPaymentBinCheckpoint.Reset;
        POSPaymentBinCheckpoint.SetCurrentKey("Workshift Checkpoint Entry No.");
        POSPaymentBinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', WorkshiftEntryNo);
        POSPaymentBinCheckpoint.SetFilter(Status, '=%1', POSPaymentBinCheckpoint.Status::TRANSFERED);
        if (POSPaymentBinCheckpoint.FindSet()) then begin
            repeat
                PaymentTypeDetailed.SetFilter("Payment No.", '=%1', POSPaymentBinCheckpoint."Payment Type No.");
                if (PaymentTypeDetailed.FindSet()) then begin
                    repeat
                        POSPaymentBinDenomination."Entry No." := 0;
                        POSPaymentBinDenomination."Payment Method No." := POSPaymentBinCheckpoint."Payment Method No.";
                        POSPaymentBinDenomination."Payment Type No." := POSPaymentBinCheckpoint."Payment Type No.";
                        POSPaymentBinDenomination."POS Unit No." := UnitNo;
                        POSPaymentBinDenomination."Workshift Checkpoint Entry No." := WorkshiftEntryNo;
                        POSPaymentBinDenomination."Bin Checkpoint Entry No." := POSPaymentBinCheckpoint."Entry No.";

                        POSPaymentBinDenomination.Denomination := PaymentTypeDetailed.Weight;
                        POSPaymentBinDenomination.Quantity := PaymentTypeDetailed.Quantity;
                        POSPaymentBinDenomination.Amount := PaymentTypeDetailed.Amount;

                        if (POSPaymentBinDenomination.Quantity <> 0) then
                            POSPaymentBinDenomination.Insert();

                    until (PaymentTypeDetailed.Next() = 0);
                end;
            until (POSPaymentBinCheckpoint.Next() = 0);
        end;

        PaymentTypeDetailed.Reset();
        PaymentTypeDetailed.SetFilter("Register No.", '=%1', UnitNo);
        PaymentTypeDetailed.DeleteAll();

    end;

    local procedure CalculateCheckpointStatistics(POSUnitNo: Code[20]; var POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        PreviousUnitCheckpoint: Record "NPR POS Workshift Checkpoint";
        FromEntryNo: Integer;
        EntriesToBalance: Record "NPR POS Entry";
    begin

        FromEntryNo := 1;
        // PreviousUnitCheckpoint.SetCurrentKey("Entry No.");
        PreviousUnitCheckpoint.SetCurrentKey("POS Unit No.", Open, "Type");
        PreviousUnitCheckpoint.SetFilter("POS Unit No.", '=%1', POSUnitNo);
        PreviousUnitCheckpoint.SetFilter(Open, '=%1', false);
        PreviousUnitCheckpoint.SetFilter(Type, '=%1', PreviousUnitCheckpoint.Type::ZREPORT);

        if (PreviousUnitCheckpoint.FindLast()) then
            FromEntryNo := PreviousUnitCheckpoint."POS Entry No.";

        // When a managed POS is balanced, the workshift is marked as WORKSHIFT_CLOSED. Z-REPORT is posted, WORKSHIFT is not.
        PreviousUnitCheckpoint.SetFilter(Type, '=%1', PreviousUnitCheckpoint.Type::WORKSHIFT_CLOSE);
        PreviousUnitCheckpoint.SetFilter("Entry No.", '%1..', PreviousUnitCheckpoint."Entry No.");
        if (PreviousUnitCheckpoint.FindLast()) then begin
            PreviousUnitCheckpoint.Get(PreviousUnitCheckpoint."Consolidated With Entry No.");
            FromEntryNo := PreviousUnitCheckpoint."POS Entry No.";
        end;

        EntriesToBalance.SetFilter("Entry No.", '%1..', FromEntryNo);
        EntriesToBalance.SetFilter("System Entry", '=%1', false);
        EntriesToBalance.SetFilter("POS Unit No.", '=%1', POSUnitNo);
        if (EntriesToBalance.IsEmpty()) then
            exit;

        CalculateWorkshiftSummary(POSUnitNo, POSWorkshiftCheckpoint, FromEntryNo);
    end;

    local procedure CalculateWorkshiftSummary(POSUnitNo: Code[20]; var POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; FromPosEntryNo: Integer)
    var
        POSSalesLine: Record "NPR POS Sales Line";
        POSPaymentLine: Record "NPR POS Payment Line";
        POSEntry: Record "NPR POS Entry";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin

        SetGeneralStatistics(POSUnitNo, POSWorkshiftCheckpoint, FromPosEntryNo);
        GetTransferStatistics(POSWorkshiftCheckpoint, FromPosEntryNo);
        AggregateVat_PE(POSWorkshiftCheckpoint."Entry No.", POSUnitNo, FromPosEntryNo);

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

        FinalizeCheckpoint(POSWorkshiftCheckpoint);
    end;

    local procedure SetGeneralStatistics(POSUnitNo: Code[20]; var POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; FromPosEntryNo: Integer)
    var
        POSEntry: Record "NPR POS Entry";
        DocDeleted: Boolean;
    begin

        // Number of sales
        POSEntry.SetFilter("Entry No.", '%1..', FromPosEntryNo);
        POSEntry.SetFilter("POS Unit No.", '=%1', POSUnitNo);
        POSEntry.SetFilter("Entry Type", '=%1', POSEntry."Entry Type"::"Direct Sale");
        POSEntry.SetFilter("System Entry", '=%1', false);
        POSWorkshiftCheckpoint."Direct Sales Count" := POSEntry.Count();

        // Number of cancelled sales
        POSEntry.SetFilter("Entry No.", '%1..', FromPosEntryNo);
        POSEntry.SetFilter("POS Unit No.", '=%1', POSUnitNo);
        POSEntry.SetFilter("Entry Type", '=%1', POSEntry."Entry Type"::"Cancelled Sale");
        POSEntry.SetFilter("System Entry", '=%1', false);
        POSWorkshiftCheckpoint."Cancelled Sales Count" := POSEntry.Count();

        // Number of sales moved to ERP
        POSEntry.SetFilter("Entry No.", '%1..', FromPosEntryNo);
        POSEntry.SetFilter("POS Unit No.", '=%1', POSUnitNo);
        POSEntry.SetFilter("Entry Type", '=%1', POSEntry."Entry Type"::"Credit Sale");
        POSEntry.SetFilter("System Entry", '=%1', false);
        POSWorkshiftCheckpoint."Credit Sales Count" := 0;
        if POSEntry.FindSet then
            repeat
                CheckIsPosted(POSEntry."Sales Document Type", POSEntry."Sales Document No.", DocDeleted);
                if not DocDeleted then
                    POSWorkshiftCheckpoint."Credit Sales Count" += 1;
            until POSEntry.Next = 0;
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

    local procedure GetTransferStatistics(var POSWorkshiftCheckpointOut: Record "NPR POS Workshift Checkpoint"; FromPosEntryNo: Integer)
    var
        POSEntry: Record "NPR POS Entry";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSBalancingLine: Record "NPR POS Balancing Line";
        POSBinEntry: Record "NPR POS Bin Entry";
        POSUnittoBinRelation: Record "NPR POS Unit to Bin Relation";
    begin

        // Get intermediate end-of-day
        POSWorkshiftCheckpoint.SetCurrentKey("POS Entry No.");
        POSWorkshiftCheckpoint.SetFilter("POS Entry No.", '%1..', FromPosEntryNo);
        POSWorkshiftCheckpoint.SetFilter(Open, '=%1', true);
        if (POSWorkshiftCheckpoint.IsEmpty()) then
            exit;

        POSWorkshiftCheckpoint.FindSet();
        repeat
            // Find the balancing lines that specify bin transfer
            POSBalancingLine.SetFilter("POS Entry No.", '=%1', POSWorkshiftCheckpoint."POS Entry No.");
            POSBalancingLine.SetFilter("Move-To Bin Code", '<>%1', '');
            if (POSBalancingLine.FindSet()) then begin
                repeat
                    // Find the binentry to get LCY
                    POSBinEntry.SetCurrentKey("Bin Checkpoint Entry No.");
                    POSBinEntry.SetFilter("Bin Checkpoint Entry No.", '=%1', POSBalancingLine."POS Bin Checkpoint Entry No.");
                    POSBinEntry.SetFilter(Type, '%1|%2|%3', POSBinEntry.Type::BIN_TRANSFER, POSBinEntry.Type::BIN_TRANSFER_IN, POSBinEntry.Type::BIN_TRANSFER_OUT);
                    POSBinEntry.SetFilter("Payment Bin No.", '=%1', POSBalancingLine."Move-To Bin Code");

                    if (POSBinEntry.FindFirst()) then begin
                        if (POSUnittoBinRelation.Get(POSWorkshiftCheckpointOut."POS Unit No.", POSBalancingLine."Move-To Bin Code")) then
                            POSWorkshiftCheckpointOut."Bin Transfer In Amount (LCY)" += POSBinEntry."Transaction Amount (LCY)"
                        else
                            POSWorkshiftCheckpointOut."Bin Transfer Out Amount (LCY)" += POSBinEntry."Transaction Amount (LCY)";
                    end;

                until (POSBalancingLine.Next() = 0);
            end;

        until (POSWorkshiftCheckpoint.Next() = 0);
    end;

    local procedure SetTurnoverAndProfit(var POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; POSSalesLine: Record "NPR POS Sales Line"; POSEntry: Record "NPR POS Entry")
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
                (POSSalesLine.Type <> POSSalesLine.Type::"G/L Account")) then begin

                POSWorkshiftCheckpoint."Turnover (LCY)" += POSSalesLine."Amount Incl. VAT (LCY)";
                POSWorkshiftCheckpoint."Net Turnover (LCY)" += POSSalesLine."Amount Excl. VAT (LCY)";
                POSWorkshiftCheckpoint."Net Cost (LCY)" += POSSalesLine."Unit Cost (LCY)" * POSSalesLine.Quantity;
            end;
        end;

        if POSEntry."Entry Type" in [POSEntry."Entry Type"::"Direct Sale"] then begin
            if ((POSSalesLine.Type <> POSSalesLine.Type::Voucher) and
                (POSSalesLine.Type <> POSSalesLine.Type::Payout) and
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

    local procedure SetDiscounts(var POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; POSSalesLine: Record "NPR POS Sales Line")
    begin

        POSWorkshiftCheckpoint."Total Discount (LCY)" += POSSalesLine."Line Dsc. Amt. Incl. VAT (LCY)";
        POSWorkshiftCheckpoint."Total Net Discount (LCY)" += POSSalesLine."Line Dsc. Amt. Excl. VAT (LCY)";

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

    local procedure SetPayments(var POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; POSPaymentLine: Record "NPR POS Payment Line"; LCYCode: Code[10])
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

            POSPaymentMethod."Processing Type"::CUSTOMER:
                POSWorkshiftCheckpoint."Debtor Payment (LCY)" += POSPaymentLine."Amount (LCY)";
            POSPaymentMethod."Processing Type"::EFT:
                POSWorkshiftCheckpoint."EFT (LCY)" += POSPaymentLine."Amount (LCY)";
            POSPaymentMethod."Processing Type"::PAYOUT:
                ; // PAYOUT is recorded on Sales Line POSWorkshiftCheckpoint."GL Payment (LCY)" += "Amount (LCY)";
            POSPaymentMethod."Processing Type"::VOUCHER:
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
        exit(POSSetup.Salesperson);

    end;

    procedure CreatePeriodCheckpoint(POSEntryNo: Integer; POSUnit: Code[10]; FromWorkshiftEntryNo: Integer; ToWorkshiftEntryNo: Integer; PeriodType: Code[20]) PeriodEntryNo: Integer
    var
        ZReportWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        PeriodWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSEntry: Record "NPR POS Entry";
        TmpTaxEntryNo: Integer;
        TmpPeriodWorkshiftTaxCheckpoint: Record "NPR POS Worksh. Tax Checkp." temporary;
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

        PeriodWorkshiftCheckpoint.Init;
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

            AggregateTaxCheckpoint(TmpPeriodWorkshiftTaxCheckpoint, PeriodWorkshiftCheckpoint."Entry No.", ZReportWorkshiftCheckpoint."Entry No.", TmpTaxEntryNo);
        until (ZReportWorkshiftCheckpoint.Next() = 0);

        PeriodWorkshiftCheckpoint."Perpetual Dir. Item Sales(LCY)" := ZReportWorkshiftCheckpoint."Perpetual Dir. Item Sales(LCY)";
        PeriodWorkshiftCheckpoint."Perpetual Dir. Item Ret. (LCY)" := ZReportWorkshiftCheckpoint."Perpetual Dir. Item Ret. (LCY)";
        PeriodWorkshiftCheckpoint."Perpetual Dir. Turnover (LCY)" := ZReportWorkshiftCheckpoint."Perpetual Dir. Turnover (LCY)";
        PeriodWorkshiftCheckpoint."Perpetual Dir. Neg. Turn (LCY)" := ZReportWorkshiftCheckpoint."Perpetual Dir. Neg. Turn (LCY)";
        PeriodWorkshiftCheckpoint."Perpetual Rounding Amt. (LCY)" := ZReportWorkshiftCheckpoint."Perpetual Rounding Amt. (LCY)";

        FinalizeCheckpoint(PeriodWorkshiftCheckpoint);
        PeriodWorkshiftCheckpoint.Open := false;
        PeriodWorkshiftCheckpoint.Modify();

        TmpPeriodWorkshiftTaxCheckpoint.Reset();
        if (TmpPeriodWorkshiftTaxCheckpoint.FindSet()) then begin
            repeat
                PeriodWorkshiftTaxCheckpoint.TransferFields(TmpPeriodWorkshiftTaxCheckpoint, false);
                PeriodWorkshiftTaxCheckpoint."Entry No." := 0;
                PeriodWorkshiftTaxCheckpoint.Insert();
            until (TmpPeriodWorkshiftTaxCheckpoint.Next() = 0);
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


    local procedure AggregateVat_PE(WorkshiftCheckpointEntryNo: Integer; PosUnitNo: Code[10]; var FromPosEntryNo: Integer)
    var
        TmpPOSWorkshiftTaxCheckpoint: Record "NPR POS Worksh. Tax Checkp." temporary;
        POSTaxAmountLine: Record "NPR POS Tax Amount Line";
        POSWorkshiftTaxCheckpoint: Record "NPR POS Worksh. Tax Checkp.";
        POSEntry: Record "NPR POS Entry";
        TempEntryNo: Integer;
    begin

        POSEntry.SetFilter("Entry No.", '%1..', FromPosEntryNo);
        POSEntry.SetFilter("POS Unit No.", '=%1', PosUnitNo);
        POSEntry.SetFilter("Entry Type", '=%1', POSEntry."Entry Type"::"Direct Sale");
        if (POSEntry.IsEmpty()) then
            exit;

        POSEntry.FindSet();
        repeat

            POSTaxAmountLine.SetFilter("POS Entry No.", '=%1', POSEntry."Entry No.");
            if (POSTaxAmountLine.FindSet()) then begin
                repeat

                    TmpPOSWorkshiftTaxCheckpoint.Reset();
                    TmpPOSWorkshiftTaxCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', WorkshiftCheckpointEntryNo);
                    TmpPOSWorkshiftTaxCheckpoint.SetFilter("Tax Area Code", '=%1', POSTaxAmountLine."Tax Area Code");
                    TmpPOSWorkshiftTaxCheckpoint.SetFilter("Tax Calculation Type", '=%1', POSTaxAmountLine."Tax Calculation Type");

                    TmpPOSWorkshiftTaxCheckpoint.SetFilter("VAT Identifier", '=%1', POSTaxAmountLine."VAT Identifier");
                    TmpPOSWorkshiftTaxCheckpoint.SetFilter("Tax Jurisdiction Code", '=%1', POSTaxAmountLine."Tax Jurisdiction Code");
                    TmpPOSWorkshiftTaxCheckpoint.SetFilter("Tax Group Code", '=%1', POSTaxAmountLine."Tax Group Code");

                    if (not TmpPOSWorkshiftTaxCheckpoint.FindFirst()) then begin
                        TempEntryNo += 1;
                        TmpPOSWorkshiftTaxCheckpoint."Entry No." := TempEntryNo;

                        TmpPOSWorkshiftTaxCheckpoint.Init();
                        TmpPOSWorkshiftTaxCheckpoint."Workshift Checkpoint Entry No." := WorkshiftCheckpointEntryNo;

                        TmpPOSWorkshiftTaxCheckpoint."Tax Calculation Type" := POSTaxAmountLine."Tax Calculation Type";

                        TmpPOSWorkshiftTaxCheckpoint."VAT Identifier" := POSTaxAmountLine."VAT Identifier";
                        TmpPOSWorkshiftTaxCheckpoint."Tax Jurisdiction Code" := POSTaxAmountLine."Tax Jurisdiction Code";
                        TmpPOSWorkshiftTaxCheckpoint."Tax Group Code" := POSTaxAmountLine."Tax Group Code";

                        TmpPOSWorkshiftTaxCheckpoint."Tax Area Code" := POSTaxAmountLine."Tax Area Code";
                        TmpPOSWorkshiftTaxCheckpoint."Tax %" := POSTaxAmountLine."Tax %";
                        TmpPOSWorkshiftTaxCheckpoint.Insert();
                    end;

                    TmpPOSWorkshiftTaxCheckpoint."Tax Base Amount" += POSTaxAmountLine."Tax Base Amount";
                    TmpPOSWorkshiftTaxCheckpoint."Tax Amount" += POSTaxAmountLine."Tax Amount";
                    TmpPOSWorkshiftTaxCheckpoint."Line Amount" += POSTaxAmountLine."Line Amount";
                    TmpPOSWorkshiftTaxCheckpoint."Amount Including Tax" += POSTaxAmountLine."Amount Including Tax";
                    TmpPOSWorkshiftTaxCheckpoint.Modify();

                until (POSTaxAmountLine.Next() = 0);
            end;
        until (POSEntry.Next() = 0);

        TmpPOSWorkshiftTaxCheckpoint.Reset();
        if (TmpPOSWorkshiftTaxCheckpoint.IsEmpty()) then
            exit;

        TmpPOSWorkshiftTaxCheckpoint.FindSet();
        repeat
            POSWorkshiftTaxCheckpoint.TransferFields(TmpPOSWorkshiftTaxCheckpoint, false);
            POSWorkshiftTaxCheckpoint."Entry No." := 0;
            POSWorkshiftTaxCheckpoint.Insert();
        until (TmpPOSWorkshiftTaxCheckpoint.Next() = 0);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostWorkshift(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    begin
    end;


}

