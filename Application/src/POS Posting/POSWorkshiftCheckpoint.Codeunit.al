codeunit 6150627 "NPR POS Workshift Checkpoint"
{
    var
        t030: Label 'Balancing';
        t031: Label 'Sales occur on this register after this balancing. Cancel and save countings.';
        MissingBin: Label 'No payment bin relation found for POS Unit %1.';
        ALL_REGISTERS_MUST_BE_BALANCED: Label 'Not all %1 have %2 %3! Only %1 with %2 %3 will have their balance transfered. Do you want to continue anyway?';
        NOT_ALL_CR_HAVE_POS_UNIT: Label 'All %1 must have a %2 when activating POS Entry posting. %1 %3 is missing its %2.';
        CHECKPOINT_PROGRESS: Label 'Creating checkpoints for: %1 %2\\@1@@@@@@@@';
        POS_UNIT_SLAVE_STATUS: Label 'This POS manages other units for End-of-Day. The other units need to be in status closed, which is done with "Close Workshift" action. POS unit %1 has status %2.';
        EndOfDayUIOption: Option SUMMARY,BALANCING,"NONE";
        EodWorkshiftMode: Option XREPORT,ZREPORT,CLOSEWORKSHIFT;
        EntrySourceMethodOption: Option NA,AUDITROLL,BINENTRY;
        POSTING_ERROR: Label 'While posting end-of-day, the following error occured:\\%1';

    procedure BeginWorkshift(POSUnit: Code[10])
    begin
    end;

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
        EntrySourceMethod: Option;
    begin

        POSWorkshiftCheckpoint.Get(CheckPointEntryNo);

        POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.");
        EntrySourceMethod := GetEntrySourceMethod();
        if (POSUnit."Default POS Payment Bin" <> '') then begin
            case EntrySourceMethod of
                EntrySourceMethodOption::AUDITROLL:
                    PaymentBinCheckpoint.CreateAuditRollBinCheckpoint(POSUnit."No.", POSUnit."Default POS Payment Bin", CheckPointEntryNo);
                EntrySourceMethodOption::BINENTRY:
                    PaymentBinCheckpoint.CreatePosEntryBinCheckpoint(POSUnit."No.", POSUnit."Default POS Payment Bin", CheckPointEntryNo);
            end;
        end;

        UnittoBinRelation.SetFilter("POS Unit No.", '=%1', POSWorkshiftCheckpoint."POS Unit No.");
        if (UnittoBinRelation.FindSet()) then begin
            repeat

                case EntrySourceMethod of
                    EntrySourceMethodOption::AUDITROLL:
                        PaymentBinCheckpoint.CreateAuditRollBinCheckpoint(UnittoBinRelation."POS Unit No.", UnittoBinRelation."POS Payment Bin No.", CheckPointEntryNo);
                    EntrySourceMethodOption::BINENTRY:
                        PaymentBinCheckpoint.CreatePosEntryBinCheckpoint(UnittoBinRelation."POS Unit No.", UnittoBinRelation."POS Payment Bin No.", CheckPointEntryNo);
                end;

            until (UnittoBinRelation.Next() = 0);
        end else begin
            if (POSUnit."Default POS Payment Bin" = '') then
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
                    with POSEndofDayProfile do
                        case POSEndofDayProfile."Z-Report UI" of
                            "Z-Report UI"::SUMMARY_BALANCING:
                                UIOption := EndOfDayUIOption::SUMMARY;
                            "Z-Report UI"::BALANCING:
                                UIOption := EndOfDayUIOption::BALANCING;
                        end;

                EodWorkshiftMode::XREPORT:
                    with POSEndofDayProfile do
                        case POSEndofDayProfile."X-Report UI" of
                            "X-Report UI"::SUMMARY_PRINT:
                                UIOption := EndOfDayUIOption::SUMMARY;
                            "X-Report UI"::PRINT:
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

        case GetEntrySourceMethod() of
            EntrySourceMethodOption::AUDITROLL:
                CheckPointEntryNo := CreateEndWorkshiftCheckpoint_AuditRoll(UnitNo);
            EntrySourceMethodOption::BINENTRY:
                CheckPointEntryNo := CreateEndWorkshiftCheckpoint_POSEntry(UnitNo);
        end;

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

    procedure CreateEndWorkshiftCheckpoint_AuditRoll(POSUnit: Code[10]) CheckpointEntryNo: Integer
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin

        // Legacy
        POSWorkshiftCheckpoint.Init();
        POSWorkshiftCheckpoint."Entry No." := 0;
        POSWorkshiftCheckpoint.Insert();

        BalanceRegister_AR(POSUnit, POSWorkshiftCheckpoint);
        POSWorkshiftCheckpoint.Modify();
        exit(POSWorkshiftCheckpoint."Entry No.");
        // End Legacy
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

    local procedure ConvertFCYToLCY(Amount: Decimal; PaymentTypeCode: Code[10]) "Amount (LCY)": Decimal
    var
        Currency: Record Currency;
        CurrencyFactor: Decimal;
        CurrExchRate: Record "Currency Exchange Rate";
        PaymentTypePOS: Record "NPR Payment Type POS";
    begin

        "Amount (LCY)" := Amount;

        if (Amount = 0) then
            exit;

        if (PaymentTypeCode = '') then
            exit;

        // ** Legacy Way
        if (not PaymentTypePOS.Get(PaymentTypeCode)) then
            exit;

        if (PaymentTypePOS."Fixed Rate" <> 0) then
            "Amount (LCY)" := Amount * PaymentTypePOS."Fixed Rate" / 100;

        if (PaymentTypePOS."Rounding Precision" = 0) then
            exit;

        "Amount (LCY)" := Round("Amount (LCY)", PaymentTypePOS."Rounding Precision", '=');
        exit;
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

        with TargetPOSWorkshiftCheckpoint do begin

            "Debtor Payment (LCY)" += POSWorkshiftCheckpoint."Debtor Payment (LCY)";
            "GL Payment (LCY)" += POSWorkshiftCheckpoint."GL Payment (LCY)";
            "Rounding (LCY)" += POSWorkshiftCheckpoint."Rounding (LCY)";
            "Credit Item Sales (LCY)" += POSWorkshiftCheckpoint."Credit Item Sales (LCY)";
            "Credit Item Quantity Sum" += POSWorkshiftCheckpoint."Credit Item Quantity Sum";
            "Credit Net Sales Amount (LCY)" += POSWorkshiftCheckpoint."Credit Net Sales Amount (LCY)";
            "Credit Sales Count" += POSWorkshiftCheckpoint."Credit Sales Count";
            "Credit Sales Amount (LCY)" += POSWorkshiftCheckpoint."Credit Sales Amount (LCY)";
            "Issued Vouchers (LCY)" += POSWorkshiftCheckpoint."Issued Vouchers (LCY)";
            "Redeemed Vouchers (LCY)" += POSWorkshiftCheckpoint."Redeemed Vouchers (LCY)";
            "Local Currency (LCY)" += POSWorkshiftCheckpoint."Local Currency (LCY)";
            "Foreign Currency (LCY)" += POSWorkshiftCheckpoint."Foreign Currency (LCY)";
            "EFT (LCY)" += POSWorkshiftCheckpoint."EFT (LCY)";

            "Manual Card (LCY)" += POSWorkshiftCheckpoint."Manual Card (LCY)";
            "Other Credit Card (LCY)" += POSWorkshiftCheckpoint."Other Credit Card (LCY)";
            "Cash Terminal (LCY)" += POSWorkshiftCheckpoint."Cash Terminal (LCY)";
            "Redeemed Credit Voucher (LCY)" += POSWorkshiftCheckpoint."Redeemed Credit Voucher (LCY)";
            "Created Credit Voucher (LCY)" += POSWorkshiftCheckpoint."Created Credit Voucher (LCY)";

            "Direct Item Sales (LCY)" += POSWorkshiftCheckpoint."Direct Item Sales (LCY)";
            "Direct Sales - Staff (LCY)" += POSWorkshiftCheckpoint."Direct Sales - Staff (LCY)";
            "Direct Item Net Sales (LCY)" += POSWorkshiftCheckpoint."Direct Item Net Sales (LCY)";
            "Direct Sales Count" += POSWorkshiftCheckpoint."Direct Sales Count";
            "Cancelled Sales Count" += POSWorkshiftCheckpoint."Cancelled Sales Count";
            "Net Turnover (LCY)" += POSWorkshiftCheckpoint."Net Turnover (LCY)";
            "Turnover (LCY)" += POSWorkshiftCheckpoint."Turnover (LCY)";
            "Direct Turnover (LCY)" += POSWorkshiftCheckpoint."Direct Turnover (LCY)";
            "Direct Negative Turnover (LCY)" += POSWorkshiftCheckpoint."Direct Negative Turnover (LCY)";
            "Direct Net Turnover (LCY)" += POSWorkshiftCheckpoint."Direct Net Turnover (LCY)";
            "Net Cost (LCY)" += POSWorkshiftCheckpoint."Net Cost (LCY)";
            "Profit Amount (LCY)" += POSWorkshiftCheckpoint."Profit Amount (LCY)";

            "Direct Item Returns (LCY)" += POSWorkshiftCheckpoint."Direct Item Returns (LCY)";
            "Direct Item Returns Line Count" += POSWorkshiftCheckpoint."Direct Item Returns Line Count";
            "Credit Real. Sale Amt. (LCY)" += POSWorkshiftCheckpoint."Credit Real. Sale Amt. (LCY)";
            "Credit Unreal. Sale Amt. (LCY)" += POSWorkshiftCheckpoint."Credit Unreal. Sale Amt. (LCY)";
            "Credit Real. Return Amt. (LCY)" += POSWorkshiftCheckpoint."Credit Real. Return Amt. (LCY)";
            "Credit Unreal. Ret. Amt. (LCY)" += POSWorkshiftCheckpoint."Credit Unreal. Ret. Amt. (LCY)";
            "Credit Turnover (LCY)" += POSWorkshiftCheckpoint."Credit Turnover (LCY)";
            "Credit Net Turnover (LCY)" += POSWorkshiftCheckpoint."Credit Net Turnover (LCY)";

            "Total Discount (LCY)" += POSWorkshiftCheckpoint."Total Discount (LCY)";
            "Total Net Discount (LCY)" += POSWorkshiftCheckpoint."Total Net Discount (LCY)";
            "Campaign Discount (LCY)" += POSWorkshiftCheckpoint."Campaign Discount (LCY)";
            "Mix Discount (LCY)" += POSWorkshiftCheckpoint."Mix Discount (LCY)";
            "Quantity Discount (LCY)" += POSWorkshiftCheckpoint."Quantity Discount (LCY)";
            "Custom Discount (LCY)" += POSWorkshiftCheckpoint."Custom Discount (LCY)";
            "BOM Discount (LCY)" += POSWorkshiftCheckpoint."BOM Discount (LCY)";
            "Customer Discount (LCY)" += POSWorkshiftCheckpoint."Customer Discount (LCY)";
            "Line Discount (LCY)" += POSWorkshiftCheckpoint."Line Discount (LCY)";
            "Calculated Diff (LCY)" += POSWorkshiftCheckpoint."Calculated Diff (LCY)";

            "Direct Item Quantity Sum" += POSWorkshiftCheckpoint."Direct Item Quantity Sum";
            "Direct Item Sales Line Count" += POSWorkshiftCheckpoint."Direct Item Sales Line Count";
            "Receipts Count" += POSWorkshiftCheckpoint."Receipts Count";
            "Cash Drawer Open Count" += POSWorkshiftCheckpoint."Cash Drawer Open Count";
            "Receipt Copies Count" += POSWorkshiftCheckpoint."Receipt Copies Count";
            "Receipt Copies Sales (LCY)" += POSWorkshiftCheckpoint."Receipt Copies Sales (LCY)";

            "Bin Transfer Out Amount (LCY)" += POSWorkshiftCheckpoint."Bin Transfer Out Amount (LCY)";
            "Bin Transfer In Amount (LCY)" += POSWorkshiftCheckpoint."Bin Transfer In Amount (LCY)";

            "Opening Cash (LCY)" += POSWorkshiftCheckpoint."Opening Cash (LCY)";

        end;
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

        with POSWorkshiftTaxCheckpoint do begin

            SetFilter("Workshift Checkpoint Entry No.", '=%1', WorkshiftEntryNo);
            SetFilter("Consolidated With Entry No.", '=%1', 0); // not yet consolidated.

            if (FindSet()) then begin

                repeat
                    // consolidation key: "Workshift Checkpoint Entry No.","Tax Area Code","VAT Identifier","Tax Calculation Type"
                    TargetWorkshiftTaxCheckpoint.SetCurrentKey("Workshift Checkpoint Entry No.", "Tax Area Code", "VAT Identifier", "Tax Calculation Type");
                    TargetWorkshiftTaxCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', TargetWorkshiftEntryNo);
                    TargetWorkshiftTaxCheckpoint.SetFilter("Tax Area Code", '=%1', "Tax Area Code");
                    TargetWorkshiftTaxCheckpoint.SetFilter("VAT Identifier", '=%1', "VAT Identifier");
                    TargetWorkshiftTaxCheckpoint.SetFilter("Tax Calculation Type", '=%1', "Tax Calculation Type");
                    TargetWorkshiftTaxCheckpoint.SetFilter("Tax Jurisdiction Code", '=%1', "Tax Jurisdiction Code");
                    TargetWorkshiftTaxCheckpoint.SetFilter("Tax Group Code", '=%1', "Tax Group Code");

                    if (TargetWorkshiftTaxCheckpoint.FindFirst()) then begin
                        TargetWorkshiftTaxCheckpoint."Tax Base Amount" += "Tax Base Amount";
                        TargetWorkshiftTaxCheckpoint."Tax Amount" += "Tax Amount";
                        TargetWorkshiftTaxCheckpoint."Amount Including Tax" += "Amount Including Tax";
                        TargetWorkshiftTaxCheckpoint."Line Amount" += "Line Amount";
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

    end;

    local procedure CreatePOSPostingLogEntry(var POSEntry: Record "NPR POS Entry"; ErrorReason: Text): Integer
    var
        POSPostingLog: Record "NPR POS Posting Log";
        LastPOSEntry: Record "NPR POS Entry";
    begin

        LastPOSEntry.Reset;
        LastPOSEntry.FindLast;

        with POSPostingLog do begin
            Init;
            "Entry No." := 0;
            "User ID" := UserId;
            "Posting Timestamp" := CurrentDateTime;
            "With Error" := true;
            "Error Description" := CopyStr(ErrorReason, 1, MaxStrLen("Error Description"));
            "POS Entry View" := CopyStr(POSEntry.GetView, 1, MaxStrLen("POS Entry View"));
            "Last POS Entry No. at Posting" := LastPOSEntry."Entry No.";
            Insert(true);
            exit("Entry No.");
        end;

    end;

    local procedure GetEntrySourceMethod(): Integer
    var
        NPRetailSetup: Record "NPR NP Retail Setup";
    begin

        NPRetailSetup.Get();

        if (not NPRetailSetup."Advanced POS Entries Activated") then
            exit(EntrySourceMethodOption::AUDITROLL);

        if (NPRetailSetup."Advanced POS Entries Activated") then
            exit(EntrySourceMethodOption::BINENTRY);

        exit(EntrySourceMethodOption::NA);

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

        with POSSalesLine do begin

            //Total turnover must not include POS sales transfered to ERP as unposted.
            if (POSEntry."Entry Type" = POSEntry."Entry Type"::"Credit Sale") then begin

                if (CheckIsPosted(POSEntry."Sales Document Type", POSEntry."Sales Document No.", DocDeleted) and
                    (Type <> Type::Voucher) and
                    (Type <> Type::Payout) and
                    (Type <> Type::"G/L Account")) then begin

                    case (POSEntry."Sales Document Type") of
                        POSEntry."Sales Document Type"::Invoice:
                            POSWorkshiftCheckpoint."Credit Real. Sale Amt. (LCY)" += "Amount Excl. VAT (LCY)";
                        POSEntry."Sales Document Type"::Order:
                            POSWorkshiftCheckpoint."Credit Real. Sale Amt. (LCY)" += "Amount Excl. VAT (LCY)";
                        POSEntry."Sales Document Type"::"Credit Memo":
                            POSWorkshiftCheckpoint."Credit Real. Return Amt. (LCY)" += "Amount Excl. VAT (LCY)";
                        POSEntry."Sales Document Type"::"Return Order":
                            POSWorkshiftCheckpoint."Credit Real. Return Amt. (LCY)" += "Amount Excl. VAT (LCY)";
                    end;

                    POSWorkshiftCheckpoint."Turnover (LCY)" += "Amount Incl. VAT (LCY)";
                    POSWorkshiftCheckpoint."Net Turnover (LCY)" += "Amount Excl. VAT (LCY)";
                    POSWorkshiftCheckpoint."Credit Turnover (LCY)" += "Amount Incl. VAT (LCY)";
                    POSWorkshiftCheckpoint."Credit Net Turnover (LCY)" += "Amount Excl. VAT (LCY)";
                    POSWorkshiftCheckpoint."Net Cost (LCY)" += "Unit Cost (LCY)" * Quantity;

                end else begin
                    if not DocDeleted then
                        case (POSEntry."Sales Document Type") of
                            POSEntry."Sales Document Type"::Invoice:
                                POSWorkshiftCheckpoint."Credit Unreal. Sale Amt. (LCY)" += "Amount Excl. VAT (LCY)";
                            POSEntry."Sales Document Type"::Order:
                                POSWorkshiftCheckpoint."Credit Unreal. Sale Amt. (LCY)" += "Amount Excl. VAT (LCY)";
                            POSEntry."Sales Document Type"::"Credit Memo":
                                POSWorkshiftCheckpoint."Credit Unreal. Ret. Amt. (LCY)" += "Amount Excl. VAT (LCY)";
                            POSEntry."Sales Document Type"::"Return Order":
                                POSWorkshiftCheckpoint."Credit Unreal. Ret. Amt. (LCY)" += "Amount Excl. VAT (LCY)";
                        end;
                end;

                if not DocDeleted then begin
                    POSWorkshiftCheckpoint."Credit Sales Amount (LCY)" += "Amount Incl. VAT (LCY)";
                    POSWorkshiftCheckpoint."Credit Net Sales Amount (LCY)" += "Amount Excl. VAT (LCY)";
                end;
            end;


            if (POSEntry."Entry Type" <> POSEntry."Entry Type"::"Credit Sale") then begin
                if ((Type <> Type::Voucher) and
                    (Type <> Type::Payout) and
                    (Type <> Type::"G/L Account")) then begin

                    POSWorkshiftCheckpoint."Turnover (LCY)" += "Amount Incl. VAT (LCY)";
                    POSWorkshiftCheckpoint."Net Turnover (LCY)" += "Amount Excl. VAT (LCY)";
                    POSWorkshiftCheckpoint."Net Cost (LCY)" += "Unit Cost (LCY)" * Quantity;
                end;
            end;

            if POSEntry."Entry Type" in [POSEntry."Entry Type"::"Direct Sale"] then begin
                if ((Type <> Type::Voucher) and
                    (Type <> Type::Payout) and
                    (Type <> Type::"G/L Account")) then begin
                    POSWorkshiftCheckpoint."Direct Net Turnover (LCY)" += "Amount Excl. VAT (LCY)";
                    POSWorkshiftCheckpoint."Direct Turnover (LCY)" += "Amount Incl. VAT (LCY)";
                    if "Amount Incl. VAT (LCY)" < 0 then
                        POSWorkshiftCheckpoint."Direct Negative Turnover (LCY)" += "Amount Incl. VAT (LCY)";
                end;
            end;

            case Type of
                Type::Item:
                    begin
                        if (POSEntry."Entry Type" = POSEntry."Entry Type"::"Direct Sale") then begin
                            if (Quantity > 0) then begin
                                POSWorkshiftCheckpoint."Direct Item Sales (LCY)" += "Amount Incl. VAT (LCY)";
                                POSWorkshiftCheckpoint."Direct Item Net Sales (LCY)" += "Amount Excl. VAT (LCY)";
                                POSWorkshiftCheckpoint."Direct Item Sales Line Count" += 1;
                                POSWorkshiftCheckpoint."Direct Item Sales Quantity" += Quantity;
                            end;

                            if (Quantity < 0) then begin
                                POSWorkshiftCheckpoint."Direct Item Returns (LCY)" += "Amount Incl. VAT (LCY)";
                                POSWorkshiftCheckpoint."Direct Item Returns Line Count" += 1;
                                POSWorkshiftCheckpoint."Direct Item Returns Quantity" += Quantity;
                            end;

                            POSWorkshiftCheckpoint."Direct Item Quantity Sum" += Quantity;
                        end;

                        if (POSEntry."Entry Type" = POSEntry."Entry Type"::"Credit Sale") then begin
                            POSWorkshiftCheckpoint."Credit Item Sales (LCY)" += "Amount Incl. VAT (LCY)";
                            POSWorkshiftCheckpoint."Credit Item Quantity Sum" += Quantity;
                        end;
                    end;

                Type::Customer:
                    begin
                        POSWorkshiftCheckpoint."Debtor Payment (LCY)" += "Amount Incl. VAT (LCY)";
                    end;

                Type::"G/L Account":
                    begin
                        POSWorkshiftCheckpoint."GL Payment (LCY)" += "Amount Incl. VAT (LCY)";
                    end;

                Type::Payout:
                    begin
                        // Net value, a "Payin" has reversed sign
                        POSWorkshiftCheckpoint."GL Payment (LCY)" += "Amount Incl. VAT (LCY)";
                    end;

                Type::Rounding:
                    begin
                        POSWorkshiftCheckpoint."Rounding (LCY)" += "Amount Incl. VAT (LCY)";
                    end;

                Type::Voucher:
                    begin
                        POSWorkshiftCheckpoint."Issued Vouchers (LCY)" += "Amount Incl. VAT (LCY)";
                    end;

                else
                    ;
            end;

        end;
    end;

    local procedure SetDiscounts(var POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; POSSalesLine: Record "NPR POS Sales Line")
    begin

        with POSSalesLine do begin

            POSWorkshiftCheckpoint."Total Discount (LCY)" += "Line Dsc. Amt. Incl. VAT (LCY)";
            POSWorkshiftCheckpoint."Total Net Discount (LCY)" += "Line Dsc. Amt. Excl. VAT (LCY)";

            case "Discount Type" of
                "Discount Type"::"BOM List":
                    POSWorkshiftCheckpoint."BOM Discount (LCY)" += "Line Dsc. Amt. Incl. VAT (LCY)";
                "Discount Type"::Campaign:
                    POSWorkshiftCheckpoint."Campaign Discount (LCY)" += "Line Dsc. Amt. Incl. VAT (LCY)";
                "Discount Type"::Customer:
                    POSWorkshiftCheckpoint."Customer Discount (LCY)" += "Line Dsc. Amt. Incl. VAT (LCY)";
                "Discount Type"::Manual:
                    POSWorkshiftCheckpoint."Custom Discount (LCY)" += "Line Dsc. Amt. Incl. VAT (LCY)";
                "Discount Type"::Mix:
                    POSWorkshiftCheckpoint."Mix Discount (LCY)" += "Line Dsc. Amt. Incl. VAT (LCY)";
                "Discount Type"::Quantity:
                    POSWorkshiftCheckpoint."Quantity Discount (LCY)" += "Line Dsc. Amt. Incl. VAT (LCY)";
                else
                    POSWorkshiftCheckpoint."Line Discount (LCY)" += "Line Dsc. Amt. Incl. VAT (LCY)";
            end;
        end;
    end;

    local procedure SetPayments(var POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; POSPaymentLine: Record "NPR POS Payment Line"; LCYCode: Code[10])
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        IsLCY: Boolean;
    begin

        with POSPaymentLine do begin
            POSPaymentMethod.Get(POSPaymentLine."POS Payment Method Code");
            IsLCY := (("Currency Code" = '') or ("Currency Code" = LCYCode));

            case POSPaymentMethod."Processing Type" of
                POSPaymentMethod."Processing Type"::CASH:
                    begin
                        if (IsLCY) then POSWorkshiftCheckpoint."Local Currency (LCY)" += "Amount (LCY)";
                        if (not IsLCY) then POSWorkshiftCheckpoint."Foreign Currency (LCY)" += "Amount (LCY)";
                    end;

                POSPaymentMethod."Processing Type"::CHECK:
                    begin
                        if (IsLCY) then POSWorkshiftCheckpoint."Local Currency (LCY)" += "Amount (LCY)";
                        if (not IsLCY) then POSWorkshiftCheckpoint."Foreign Currency (LCY)" += "Amount (LCY)";
                    end;

                POSPaymentMethod."Processing Type"::CUSTOMER:
                    POSWorkshiftCheckpoint."Debtor Payment (LCY)" += "Amount (LCY)";
                POSPaymentMethod."Processing Type"::EFT:
                    POSWorkshiftCheckpoint."EFT (LCY)" += "Amount (LCY)";
                POSPaymentMethod."Processing Type"::PAYOUT:
                    ; // PAYOUT is recorded on Sales Line POSWorkshiftCheckpoint."GL Payment (LCY)" += "Amount (LCY)";
                POSPaymentMethod."Processing Type"::VOUCHER:
                    POSWorkshiftCheckpoint."Redeemed Vouchers (LCY)" += "Amount (LCY)";

            end;

        end;
    end;

    local procedure FinalizeCheckpoint(var POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    begin

        with POSWorkshiftCheckpoint do begin

            "Profit Amount (LCY)" := "Net Turnover (LCY)" - "Net Cost (LCY)";

            if ("Net Turnover (LCY)" <> 0) then
                "Profit %" := "Profit Amount (LCY)" * 100 / "Net Turnover (LCY)";

            if ("Profit Amount (LCY)" < 0) and ("Profit %" > 0) then
                "Profit %" := -"Profit %";

            "Calculated Diff (LCY)" := 0;

            if ("Turnover (LCY)" <> 0) then begin
                "Custom Discount %" := Round("Custom Discount (LCY)" * 100 / "Turnover (LCY)", 0.01);
                "Quantity Discount %" := Round("Quantity Discount (LCY)" * 100 / "Turnover (LCY)", 0.01);
                "Mix Discount %" := Round("Mix Discount (LCY)" * 100 / "Turnover (LCY)", 0.01);
                "Campaign Discount %" := Round("Campaign Discount (LCY)" * 100 / "Turnover (LCY)", 0.01);
                "Line Discount %" := Round("Line Discount (LCY)" * 100 / "Turnover (LCY)", 0.01);
                "Total Discount %" := Round("Total Discount (LCY)" * 100 / "Turnover (LCY)", 0.01);
                "BOM Discount %" := Round("BOM Discount (LCY)" * 100 / "Turnover (LCY)", 0.01);
                "Customer Discount %" := Round("Customer Discount (LCY)" * 100 / "Turnover (LCY)", 0.01);
            end;

        end;
    end;

    local procedure TryGetSalesperson(): Code[10]
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
            with ZReportWorkshiftCheckpoint do begin
                PeriodWorkshiftCheckpoint."Debtor Payment (LCY)" += "Debtor Payment (LCY)";
                PeriodWorkshiftCheckpoint."GL Payment (LCY)" += "GL Payment (LCY)";
                PeriodWorkshiftCheckpoint."Rounding (LCY)" += "Rounding (LCY)";
                PeriodWorkshiftCheckpoint."Credit Item Sales (LCY)" += "Credit Item Sales (LCY)";
                PeriodWorkshiftCheckpoint."Credit Item Quantity Sum" += "Credit Item Quantity Sum";
                PeriodWorkshiftCheckpoint."Credit Net Sales Amount (LCY)" += "Credit Net Sales Amount (LCY)";
                PeriodWorkshiftCheckpoint."Credit Sales Count" += "Credit Sales Count";
                PeriodWorkshiftCheckpoint."Issued Vouchers (LCY)" += "Issued Vouchers (LCY)";
                PeriodWorkshiftCheckpoint."Redeemed Vouchers (LCY)" += "Redeemed Vouchers (LCY)";
                PeriodWorkshiftCheckpoint."Local Currency (LCY)" += "Local Currency (LCY)";
                PeriodWorkshiftCheckpoint."Foreign Currency (LCY)" += "Foreign Currency (LCY)";
                PeriodWorkshiftCheckpoint."EFT (LCY)" += "EFT (LCY)";
                PeriodWorkshiftCheckpoint."Manual Card (LCY)" += "Manual Card (LCY)";
                PeriodWorkshiftCheckpoint."Other Credit Card (LCY)" += "Other Credit Card (LCY)";
                PeriodWorkshiftCheckpoint."Cash Terminal (LCY)" += "Cash Terminal (LCY)";
                PeriodWorkshiftCheckpoint."Redeemed Credit Voucher (LCY)" += "Redeemed Credit Voucher (LCY)";
                PeriodWorkshiftCheckpoint."Created Credit Voucher (LCY)" += "Created Credit Voucher (LCY)";
                PeriodWorkshiftCheckpoint."Direct Item Sales (LCY)" += "Direct Item Sales (LCY)";
                PeriodWorkshiftCheckpoint."Direct Sales - Staff (LCY)" += "Direct Sales - Staff (LCY)";
                PeriodWorkshiftCheckpoint."Direct Sales Count" += "Direct Sales Count";
                PeriodWorkshiftCheckpoint."Cancelled Sales Count" += "Cancelled Sales Count";
                PeriodWorkshiftCheckpoint."Net Turnover (LCY)" += "Net Turnover (LCY)";
                PeriodWorkshiftCheckpoint."Turnover (LCY)" += "Turnover (LCY)";
                PeriodWorkshiftCheckpoint."Net Cost (LCY)" += "Net Cost (LCY)";
                PeriodWorkshiftCheckpoint."Profit Amount (LCY)" += "Profit Amount (LCY)";
                PeriodWorkshiftCheckpoint."Direct Item Returns (LCY)" += "Direct Item Returns (LCY)";
                PeriodWorkshiftCheckpoint."Direct Item Returns Line Count" += "Direct Item Returns Line Count";
                PeriodWorkshiftCheckpoint."Total Discount (LCY)" += "Total Discount (LCY)";
                PeriodWorkshiftCheckpoint."Campaign Discount (LCY)" += "Campaign Discount (LCY)";
                PeriodWorkshiftCheckpoint."Mix Discount (LCY)" += "Mix Discount (LCY)";
                PeriodWorkshiftCheckpoint."Quantity Discount (LCY)" += "Quantity Discount (LCY)";
                PeriodWorkshiftCheckpoint."Custom Discount (LCY)" += "Custom Discount (LCY)";
                PeriodWorkshiftCheckpoint."BOM Discount (LCY)" += "BOM Discount (LCY)";
                PeriodWorkshiftCheckpoint."Customer Discount (LCY)" += "Customer Discount (LCY)";
                PeriodWorkshiftCheckpoint."Line Discount (LCY)" += "Line Discount (LCY)";
                PeriodWorkshiftCheckpoint."Calculated Diff (LCY)" += "Calculated Diff (LCY)";
                PeriodWorkshiftCheckpoint."Direct Item Quantity Sum" += "Direct Item Quantity Sum";
                PeriodWorkshiftCheckpoint."Direct Item Sales Line Count" += "Direct Item Sales Line Count";
                PeriodWorkshiftCheckpoint."Receipts Count" += "Receipts Count";
                PeriodWorkshiftCheckpoint."Cash Drawer Open Count" += "Cash Drawer Open Count";
                PeriodWorkshiftCheckpoint."Receipt Copies Count" += "Receipt Copies Count";
                PeriodWorkshiftCheckpoint."Receipt Copies Sales (LCY)" += "Receipt Copies Sales (LCY)";
                PeriodWorkshiftCheckpoint."Bin Transfer Out Amount (LCY)" += "Bin Transfer Out Amount (LCY)";
                PeriodWorkshiftCheckpoint."Bin Transfer In Amount (LCY)" += "Bin Transfer In Amount (LCY)";
                PeriodWorkshiftCheckpoint."Opening Cash (LCY)" += "Opening Cash (LCY)";
                PeriodWorkshiftCheckpoint."Direct Negative Turnover (LCY)" += "Direct Negative Turnover (LCY)";
                PeriodWorkshiftCheckpoint."Direct Turnover (LCY)" += "Direct Turnover (LCY)";

                AggregateTaxCheckpoint(TmpPeriodWorkshiftTaxCheckpoint, PeriodWorkshiftCheckpoint."Entry No.", ZReportWorkshiftCheckpoint."Entry No.", TmpTaxEntryNo);

            end;
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

                with TmpPeriodTaxWorkshiftCheckpoint do begin
                    Reset();
                    SetFilter("Workshift Checkpoint Entry No.", '=%1', PeriodEntryNo);
                    SetFilter("Tax Area Code", '=%1', POSWorkshiftTaxCheckpoint."Tax Area Code");
                    SetFilter("Tax Calculation Type", '=%1', POSWorkshiftTaxCheckpoint."Tax Calculation Type");
                    SetFilter("VAT Identifier", '=%1', POSWorkshiftTaxCheckpoint."VAT Identifier");
                    SetFilter("Tax Jurisdiction Code", '=%1', POSWorkshiftTaxCheckpoint."Tax Jurisdiction Code");
                    SetFilter("Tax Group Code", '=%1', POSWorkshiftTaxCheckpoint."Tax Group Code");

                    if (not FindFirst()) then begin
                        TempEntryNo += 1;
                        "Entry No." := TempEntryNo;

                        Init();
                        "Workshift Checkpoint Entry No." := PeriodEntryNo;

                        "Tax Calculation Type" := POSWorkshiftTaxCheckpoint."Tax Calculation Type";
                        "VAT Identifier" := POSWorkshiftTaxCheckpoint."VAT Identifier";
                        "Tax Area Code" := POSWorkshiftTaxCheckpoint."Tax Area Code";
                        "Tax Jurisdiction Code" := POSWorkshiftTaxCheckpoint."Tax Jurisdiction Code";
                        "Tax Group Code" := POSWorkshiftTaxCheckpoint."Tax Group Code";
                        "Tax %" := POSWorkshiftTaxCheckpoint."Tax %";
                        "Tax Type" := POSWorkshiftTaxCheckpoint."Tax Type";
                        Insert();
                    end;

                    "Tax Base Amount" += POSWorkshiftTaxCheckpoint."Tax Base Amount";
                    "Tax Amount" += POSWorkshiftTaxCheckpoint."Tax Amount";
                    "Line Amount" += POSWorkshiftTaxCheckpoint."Line Amount";
                    "Amount Including Tax" += POSWorkshiftTaxCheckpoint."Amount Including Tax";
                    Modify();
                end;
            until (POSWorkshiftTaxCheckpoint.Next() = 0);

        end;
    end;



    #region ***************** Original AuditRoll Balancing Functions 

    local procedure BalanceRegister_AR(RegNo: Code[20]; var POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        FirstReceiptNo: Code[20];
        AuditRoll: Record "NPR Audit Roll";
        "Payment Type POS": Record "NPR Payment Type POS";
        POSUnit: Record "NPR POS Unit";
        POSSetup: Codeunit "NPR POS Setup";
        ThisReceiptNo: Code[20];
        aReceiptType_count: array[10] of Integer;
        aReceiptType_amount: array[10] of Decimal;
        t001: Label 'Opening receipt is missing!';
        i: Integer;
        item: Record Item;
        countdec: Decimal;
        Customer: Record Customer;
        t002: Label 'Please wait...';
        t003: Label 'Searching for last End of day';
        t004: Label 'Customer payments';
        t005: Label 'Counting';
        t006: Label 'Outpayments';
        t007: Label 'Debit sales';
        t008: Label 'Cash inventory';
        t009: Label 'Foreign currencies';
        t010: Label 'Terminal transactions';
        t011: Label 'Manual cards';
        t012: Label 'Other credit cards';
        t013: Label 'Cash terminal';
        t014: Label 'Received/issued gift vouchers';
        t015: Label 'Received/issued credit vouchers';
        t016: Label 'Number of sales, staff sale etc.';
        t017: Label 'Net turnover';
        t018: Label 'Net cost';
        t020: Label 'Total discount';
        t021: Label 'Negative sale (returned goods etc.)';
        t022: Label 'Custom discount type';
        t023: Label 'Profit';
        LastReceiptNo: Code[20];
        GvFilter: Text[30];
        GvActFilter: Text[30];
        "--PreviousGlobals": Integer;
        Window: Dialog;
        RetailSetup: Record "NPR Retail Setup";
        CashRegister: Record "NPR Register";
        G_ReceiptFilter: Text;
    begin
        RetailSetup.Get();
        CashRegister.Get(RegNo);
        POSUnit.Get(RegNo);
        POSSetup.SetPOSUnit(POSUnit);

        Window.Open(t005 + '\#1##############################\' + t002);

        //Primo := Kasse."Opening Cash";
        POSWorkshiftCheckpoint."Opening Cash (LCY)" := CashRegister."Opening Cash";
        POSWorkshiftCheckpoint."Created At" := CurrentDateTime;
        POSWorkshiftCheckpoint."POS Unit No." := RegNo;
        POSWorkshiftCheckpoint.Open := true;

        /* FIND LAST OPEN/CLOSE */
        Window.Update(1, t003);

        /* SET KEY ----- */
        AuditRoll.SetCurrentKey("Register No.",
                                    "Sales Ticket No.",
                                    "Sale Type",
                                    Type);

        AuditRoll.SetRange("Register No.", CashRegister."Register No.");
        AuditRoll.SetFilter("Sales Ticket No.", '<>%1', '');
        G_ReceiptFilter := StrSubstNo('>=%1', CashRegister."Opened on Sales Ticket");
        AuditRoll.SetFilter("Sales Ticket No.", G_ReceiptFilter);

        //find the date that the register open was done, and make that date the minimum date
        if AuditRoll.FindFirst then
            AuditRoll.SetFilter("Sale Date", '%1..', AuditRoll."Sale Date");

        if AuditRoll.FindLast then
            G_ReceiptFilter := StrSubstNo('..%1', AuditRoll."Sales Ticket No.");

        if not AuditRoll.FindSet then
            Error(t001)
        else
            G_ReceiptFilter := StrSubstNo('%1' + G_ReceiptFilter, AuditRoll."Sales Ticket No.");

        if (not (AuditRoll.Next() > 0)) then begin
            Window.Close();
            exit;
        end;

        /* CALCULATIONS */
        /* SET INITIAL FILTERS */
        AuditRoll.SetFilter("Sales Ticket No.", G_ReceiptFilter);

        /* CUSTOMER PAYMENTS */
        Window.Update(1, t004);
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Deposit);
        AuditRoll.SetRange(Type, AuditRoll.Type::Customer);
        AuditRoll.CalcSums("Amount Including VAT");
        POSWorkshiftCheckpoint."Debtor Payment (LCY)" := AuditRoll."Amount Including VAT";

        /* G/L PAYOUTS */
        Window.Update(1, t006);
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::"Out payment");
        AuditRoll.SetRange(Type, AuditRoll.Type::"G/L");
        AuditRoll.SetFilter("No.", '<>%1', POSSetup.RoundingAccount(true));
        AuditRoll.CalcSums("Amount Including VAT");
        POSWorkshiftCheckpoint."GL Payment (LCY)" := AuditRoll."Amount Including VAT";

        /* DEBIT SALES */
        Window.Update(1, t007);
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::"Debit Sale");
        AuditRoll.SetRange(Type, AuditRoll.Type::Item);
        AuditRoll.SetRange("No.");
        if AuditRoll.FindSet() then
            repeat
                if AuditRoll."Gift voucher ref." = '' then
                    POSWorkshiftCheckpoint."Credit Item Sales (LCY)" += AuditRoll."Amount Including VAT"
                else begin
                    POSWorkshiftCheckpoint."Redeemed Vouchers (LCY)" -= AuditRoll."Amount Including VAT";
                end;
            until AuditRoll.Next = 0;

        /* CASH INVENTORY */
        Window.Update(1, t008);
        AuditRoll.SetRange(Type, AuditRoll.Type::Payment);
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Payment);
        "Payment Type POS".SetRange(Status, "Payment Type POS".Status::Active);
        "Payment Type POS".SetRange("Processing Type", "Payment Type POS"."Processing Type"::Cash);
        if "Payment Type POS".FindSet then
            repeat
                AuditRoll.SetRange("No.", "Payment Type POS"."No.");
                AuditRoll.CalcSums("Amount Including VAT");
                POSWorkshiftCheckpoint."Local Currency (LCY)" += AuditRoll."Amount Including VAT";
            until "Payment Type POS".Next = 0;

        /* CURRENCY */
        Window.Update(1, t009);
        "Payment Type POS".SetRange("Processing Type", "Payment Type POS"."Processing Type"::"Foreign Currency");
        if "Payment Type POS".FindSet then
            repeat
                AuditRoll.SetRange(Type, AuditRoll.Type::Payment);
                AuditRoll.SetRange("No.", "Payment Type POS"."No.");
                AuditRoll.CalcSums("Amount Including VAT", "Currency Amount");
                POSWorkshiftCheckpoint."Foreign Currency (LCY)" += AuditRoll."Amount Including VAT";
            until "Payment Type POS".Next = 0;

        /* CREDIT CARDS */
        Window.Update(1, t010);
        "Payment Type POS".SetRange("Processing Type", "Payment Type POS"."Processing Type"::"Terminal Card");
        if "Payment Type POS".FindSet then
            repeat
                AuditRoll.SetRange(Type, AuditRoll.Type::Payment);
                AuditRoll.SetRange("No.", "Payment Type POS"."No.");
                AuditRoll.CalcSums("Amount Including VAT");
                POSWorkshiftCheckpoint."EFT (LCY)" += AuditRoll."Amount Including VAT";
            until "Payment Type POS".Next = 0;

        /* MANUAL CREDIT CARDS */
        Window.Update(1, t011);
        "Payment Type POS".SetRange("Processing Type", "Payment Type POS"."Processing Type"::"Manual Card");
        if "Payment Type POS".FindSet then
            repeat
                AuditRoll.SetRange(Type, AuditRoll.Type::Payment);
                AuditRoll.SetRange("No.", "Payment Type POS"."No.");
                AuditRoll.CalcSums("Amount Including VAT");
                POSWorkshiftCheckpoint."Manual Card (LCY)" += AuditRoll."Amount Including VAT";
            until "Payment Type POS".Next = 0;

        /* OTHER CREDIT CARDS */
        Window.Update(1, t012);

        "Payment Type POS".SetRange("Processing Type", "Payment Type POS"."Processing Type"::"Other Credit Cards");
        if "Payment Type POS".FindSet then
            repeat
                AuditRoll.SetRange(Type, AuditRoll.Type::Payment);
                AuditRoll.SetRange("No.", "Payment Type POS"."No.");
                AuditRoll.CalcSums("Amount Including VAT");
                POSWorkshiftCheckpoint."Other Credit Card (LCY)" += AuditRoll."Amount Including VAT";
            until "Payment Type POS".Next = 0;

        /* TERMINAL CARDS */
        Window.Update(1, t013);

        "Payment Type POS".SetRange("Processing Type", "Payment Type POS"."Processing Type"::EFT);
        if "Payment Type POS".FindSet then begin
            AuditRoll.SetRange(Type, AuditRoll.Type::Payment);
            AuditRoll.SetRange("No.", "Payment Type POS"."No.");
            AuditRoll.CalcSums("Amount Including VAT");
            POSWorkshiftCheckpoint."Cash Terminal (LCY)" += AuditRoll."Amount Including VAT";
        end;

        /* RECEIVED CREDIT VOUCHERS */
        Window.Update(1, t015);

        "Payment Type POS".SetRange("Processing Type", "Payment Type POS"."Processing Type"::"Credit Voucher");
        if "Payment Type POS".FindSet then begin
            AuditRoll.SetRange(Type, AuditRoll.Type::Payment);
            AuditRoll.SetRange("No.", "Payment Type POS"."No.");
            AuditRoll.CalcSums("Amount Including VAT");
            POSWorkshiftCheckpoint."Redeemed Credit Voucher (LCY)" := AuditRoll."Amount Including VAT";

            /* BUT NOT OUT-HANDED CREDIT VOUCHERS */
            AuditRoll.SetRange(Type, AuditRoll.Type::"G/L");
            AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Deposit);
            AuditRoll.SetRange("No.", CashRegister."Credit Voucher Account");
            AuditRoll.CalcSums("Amount Including VAT");
            POSWorkshiftCheckpoint."Created Credit Voucher (LCY)" := AuditRoll."Amount Including VAT";
        end;

        /* RECEIVED GIFT VOUCHERS */
        Window.Update(1, t014);

        "Payment Type POS".SetRange("Processing Type", "Payment Type POS"."Processing Type"::"Gift Voucher");
        if "Payment Type POS".FindSet then
            repeat
                GvFilter += '|' + "Payment Type POS"."No.";
                GvActFilter += '|' + "Payment Type POS"."G/L Account No.";
            until "Payment Type POS".Next = 0;

        GvFilter := CopyStr(GvFilter, 2);
        GvActFilter := CopyStr(GvActFilter, 2);

        /* CREATED GIFT VOUCHERS */
        AuditRoll.SetRange(Type, AuditRoll.Type::"G/L");
        AuditRoll.SetFilter("Sale Type", '%1|%2', AuditRoll."Sale Type"::Deposit, AuditRoll."Sale Type"::"Debit Sale");
        AuditRoll.SetFilter("No.", GvActFilter);
        AuditRoll.CalcSums("Amount Including VAT");
        POSWorkshiftCheckpoint."Issued Vouchers (LCY)" -= AuditRoll."Amount Including VAT";

        Window.Update(1, t016);
        LastReceiptNo := '';
        AuditRoll.SetRange("No.");
        AuditRoll.SetRange("Sale Type");
        AuditRoll.SetRange(Type);
        if AuditRoll.FindSet then
            repeat

                if AuditRoll."Sales Ticket No." <> LastReceiptNo then
                    if (AuditRoll."Sale Type" = AuditRoll."Sale Type"::Comment) then
                        if AuditRoll.Type = AuditRoll.Type::Cancelled then
                            POSWorkshiftCheckpoint."Cancelled Sales Count" += 1;

                if (AuditRoll."Sale Type" = AuditRoll."Sale Type"::Sale) then begin

                    if AuditRoll."Sales Ticket No." <> LastReceiptNo then begin
                        if AuditRoll.Type = AuditRoll.Type::Cancelled then begin
                            // CancelledSales += 1;
                            // zzz POSWorkshiftCheckpoint."Cancelled Sales Count" += 1;
                        end else begin
                            //"Sales (Qty)" += 1;
                            //"Sales (LCY)" += AuditRoll."Amount Including VAT";
                            POSWorkshiftCheckpoint."Direct Sales Count" += 1;
                        end;
                    end;

                    //"Sales (LCY)" += AuditRoll."Amount Including VAT";
                    POSWorkshiftCheckpoint."Direct Item Sales (LCY)" += AuditRoll."Amount Including VAT";

                    if item.Get(AuditRoll."No.") then;
                    if (AuditRoll."Customer No." <> '') then begin
                        if (Customer.Get(AuditRoll."Customer No.")) then begin
                            if (Customer."Customer Disc. Group" = RetailSetup."Staff Disc. Group") or
                                (Customer."Customer Price Group" = RetailSetup."Staff Price Group") then begin
                                POSWorkshiftCheckpoint."Direct Sales - Staff (LCY)" += AuditRoll."Amount Including VAT";
                            end;
                        end;
                    end;
                    LastReceiptNo := AuditRoll."Sales Ticket No.";

                end else
                    if (AuditRoll."Sales Ticket No." <> LastReceiptNo) then
                        if AuditRoll."Sale Type" = AuditRoll."Sale Type"::"Debit Sale" then begin
                            POSWorkshiftCheckpoint."Direct Sales Count" += 1;
                            POSWorkshiftCheckpoint."Credit Item Quantity Sum" += 1;
                            LastReceiptNo := AuditRoll."Sales Ticket No.";
                        end;
            until AuditRoll.Next = 0;


        /* NET TURNOVER */
        Window.Update(1, t017);

        AuditRoll.SetRange("No.");
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Sale);
        AuditRoll.SetRange(Type, AuditRoll.Type::Item);
        AuditRoll.CalcSums(Amount, "Amount Including VAT");

        POSWorkshiftCheckpoint."Net Turnover (LCY)" := AuditRoll.Amount;
        POSWorkshiftCheckpoint."Turnover (LCY)" += AuditRoll."Amount Including VAT";


        /* NET COST */
        Window.Update(1, t018);

        AuditRoll.CalcSums(Cost);
        POSWorkshiftCheckpoint."Net Cost (LCY)" := AuditRoll.Cost;

        /* TOTAL DISCOUNT */
        Window.Update(1, t020);

        /* NEGATIVE SALES */
        Window.Update(1, t021);

        // TODO CountNegSales( Kasse."Register No.");
        // GetStatsOfTheDay("Audit Roll");
        /* NoOfGoodsSold */
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Sale);
        AuditRoll.SetRange(Type, AuditRoll.Type::Item);
        AuditRoll.CalcSums(Quantity);
        POSWorkshiftCheckpoint."Direct Item Quantity Sum" := AuditRoll.Quantity;
        POSWorkshiftCheckpoint."Direct Item Sales Line Count" := AuditRoll.Count();
        AuditRoll.SetRange("Sale Type");
        AuditRoll.SetRange(Type);

        /* NoOfCashReciepts */
        LastReceiptNo := '';
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Payment);
        AuditRoll.SetRange(Type, AuditRoll.Type::Payment);
        if (AuditRoll.FindSet()) then
            repeat
                if (AuditRoll."Sales Ticket No." <> LastReceiptNo) then begin
                    LastReceiptNo := AuditRoll."Sales Ticket No.";
                    POSWorkshiftCheckpoint."Receipts Count" += 1;
                end;
            until AuditRoll.Next = 0;
        AuditRoll.SetRange("Sale Type");
        AuditRoll.SetRange(Type);

        /* NoOfCasBoxOpenings */
        AuditRoll.SetRange("Sale Type");
        AuditRoll.SetRange(Type);
        AuditRoll.SetRange("Receipt Type", AuditRoll."Receipt Type"::"Change money");
        if (AuditRoll.FindSet()) then
            repeat
                POSWorkshiftCheckpoint."Cash Drawer Open Count" += 1;
            until AuditRoll.Next = 0;

        AuditRoll.SetRange("Receipt Type");
        AuditRoll.SetRange("Drawer Opened", true);
        if (AuditRoll.FindSet()) then
            repeat
                POSWorkshiftCheckpoint."Cash Drawer Open Count" += 1;
            until AuditRoll.Next = 0;
        AuditRoll.SetRange("Drawer Opened");


        /* NoOfReceiptCopiesAndAmount */
        LastReceiptNo := '';
        AuditRoll.SetFilter("Copy No.", '>%1', 0);
        if AuditRoll.FindSet then
            repeat
                if (AuditRoll."Sales Ticket No." <> LastReceiptNo) then begin
                    POSWorkshiftCheckpoint."Receipt Copies Count" += 1;
                    POSWorkshiftCheckpoint."Receipt Copies Sales (LCY)" += AuditRoll."Amount Including VAT";
                    LastReceiptNo := AuditRoll."Sales Ticket No.";
                end;
            until AuditRoll.Next = 0;
        AuditRoll.SetRange("Copy No.");


        // VAT
        AggregateVat_AR(POSWorkshiftCheckpoint."Entry No.", AuditRoll);

        LastReceiptNo := '';
        AuditRoll.SetRange(Type, AuditRoll.Type::Payment);
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Payment);
        AuditRoll.SetFilter("Receipt Type", '%1', AuditRoll."Receipt Type"::"Negative receipt");
        AuditRoll.SetRange("No.");
        if AuditRoll.FindSet then
            repeat
                if (AuditRoll."Amount Including VAT" < 0) then begin
                    if (LastReceiptNo <> AuditRoll."Sales Ticket No.") then begin
                        POSWorkshiftCheckpoint."Direct Item Returns Line Count" += 1;
                        POSWorkshiftCheckpoint."Direct Item Returns (LCY)" += AuditRoll."Amount Including VAT";
                    end;
                end;
                LastReceiptNo := AuditRoll."Sales Ticket No.";
            until AuditRoll.Next = 0;
        AuditRoll.SetRange(Type);
        AuditRoll.SetRange("Sale Type");
        AuditRoll.SetRange("Receipt Type");

        /* DIVERSE DISCOUNTS */
        Window.Update(1, t022);

        AuditRoll.SetFilter("Sales Ticket No.", G_ReceiptFilter);
        AuditRoll.CalcSums("Line Discount Amount");
        POSWorkshiftCheckpoint."Total Discount (LCY)" := AuditRoll."Line Discount Amount";

        with POSWorkshiftCheckpoint do begin

            if AuditRoll.FindSet then
                repeat
                    case AuditRoll."Discount Type" of
                        AuditRoll."Discount Type"::Campaign:
                            "Campaign Discount (LCY)" += AuditRoll."Line Discount Amount";
                        AuditRoll."Discount Type"::Mix:
                            "Mix Discount (LCY)" += AuditRoll."Line Discount Amount";
                        AuditRoll."Discount Type"::Quantity:
                            "Quantity Discount (LCY)" += AuditRoll."Line Discount Amount";
                        AuditRoll."Discount Type"::Manual:
                            "Custom Discount (LCY)" += AuditRoll."Line Discount Amount";
                        AuditRoll."Discount Type"::"BOM List":
                            "BOM Discount (LCY)" += AuditRoll."Line Discount Amount";
                        AuditRoll."Discount Type"::Customer:
                            "Customer Discount (LCY)" += AuditRoll."Line Discount Amount";
                        else
                            "Line Discount (LCY)" += AuditRoll."Line Discount Amount";
                    end;
                until AuditRoll.Next = 0;

            Window.Update(1, t023);
            "Profit Amount (LCY)" := "Net Turnover (LCY)" - "Net Cost (LCY)";

            if ("Net Turnover (LCY)" <> 0) then
                "Profit %" := "Profit Amount (LCY)" * 100 / "Net Turnover (LCY)";

            if ("Profit Amount (LCY)" < 0) and ("Profit %" > 0) then
                "Profit %" := -"Profit %";

            if ("Turnover (LCY)" <> 0) then begin
                "Custom Discount %" := Round("Custom Discount (LCY)" * 100 / "Turnover (LCY)", 0.01);
                "Quantity Discount %" := Round("Quantity Discount (LCY)" * 100 / "Turnover (LCY)", 0.01);
                "Mix Discount %" := Round("Mix Discount (LCY)" * 100 / "Turnover (LCY)", 0.01);
                "Campaign Discount %" := Round("Campaign Discount (LCY)" * 100 / "Turnover (LCY)", 0.01);
                "Line Discount %" := Round("Line Discount (LCY)" * 100 / "Turnover (LCY)", 0.01);
                "Total Discount %" := Round("Total Discount (LCY)" * 100 / "Turnover (LCY)", 0.01);
                "BOM Discount %" := Round("BOM Discount (LCY)" * 100 / "Turnover (LCY)", 0.01);
                "Customer Discount %" := Round("Customer Discount (LCY)" * 100 / "Turnover (LCY)", 0.01);
            end;
        end;

        POSWorkshiftCheckpoint."Calculated Diff (LCY)" := POSWorkshiftCheckpoint."Opening Cash (LCY)" + POSWorkshiftCheckpoint."Local Currency (LCY)";
        Window.Close;

    end;

    procedure CopyCheckpointToPeriode_AR(CheckpointEntryNo: Integer; var Sale: Record "NPR Sale POS"; BalanceDate: Date; BalanceTime: Time; Balanced: Boolean)
    var
        Kasseperiode: Record "NPR Period";
        "Period Line": Record "NPR Period Line";
        "Payment Type - Detailed": Record "NPR Payment Type - Detailed";
        ar: Record "NPR Audit Roll";
        AuditRoll: Record "NPR Audit Roll";
        Itt: Integer;
        "--": Integer;
        Register: Record "NPR Register";
        POSUnit: Record "NPR POS Unit";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        POSBinEntry: Record "NPR POS Bin Entry";
        PaymentTypePOS: Record "NPR Payment Type POS";
        POSWorkshiftTaxCheckpoint: Record "NPR POS Worksh. Tax Checkp.";
    begin

        POSWorkshiftCheckpoint.Get(CheckpointEntryNo);

        ar.SetRange("Register No.", Sale."Register No.");
        if ar.FindLast then begin
            if ar."Sales Ticket No." > Sale."Sales Ticket No." then
                Error(t031);
        end;

        Kasseperiode.Init;
        Register.Get(Sale."Register No.");
        POSUnit.Get(Sale."Register No.");

        Kasseperiode."Register No." := Register."Register No.";
        Kasseperiode."Sales Ticket No." := Sale."Sales Ticket No.";
        Kasseperiode.Description := t030;

        Kasseperiode.Status := Kasseperiode.Status::Ongoing;
        if (Balanced) then
            Kasseperiode.Status := Kasseperiode.Status::Balanced;

        Kasseperiode."Salesperson Code" := Sale."Salesperson Code";
        Kasseperiode."Date Closed" := BalanceDate;
        Kasseperiode."Date Saved" := Today;
        Kasseperiode."Closing Time" := BalanceTime;
        Kasseperiode."Saving  Time" := Time;
        Kasseperiode."Sales Ticket No." := Sale."Sales Ticket No.";
        Kasseperiode."Opening Sales Ticket No." := Register."Opened on Sales Ticket";

        AuditRoll.SetRange("Register No.", Register."Register No.");
        AuditRoll.SetRange("Sales Ticket No.", Kasseperiode."Opening Sales Ticket No.");
        if AuditRoll.FindSet then begin
            Kasseperiode."Date Opened" := AuditRoll."Sale Date";
            Kasseperiode."Opening Time" := AuditRoll."Starting Time";
        end;

        POSPaymentBinCheckpoint.SetCurrentKey("Workshift Checkpoint Entry No.");
        POSPaymentBinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', CheckpointEntryNo);
        if (POSPaymentBinCheckpoint.FindSet()) then begin
            repeat
                if (PaymentTypePOS.Get(POSPaymentBinCheckpoint."Payment Type No.")) then;

                Kasseperiode."Opening Cash" += ConvertFCYToLCY(POSPaymentBinCheckpoint."Float Amount", POSPaymentBinCheckpoint."Payment Type No.");
                Kasseperiode."Closing Cash" += ConvertFCYToLCY(POSPaymentBinCheckpoint."New Float Amount", POSPaymentBinCheckpoint."Payment Type No.");
                Kasseperiode."Change Register" := POSPaymentBinCheckpoint."New Float Amount";

                // *** Mandatory for audit roll posting
                POSPaymentBinCheckpoint.CalcFields("Payment Bin Entry Amount (LCY)");
                POSBinEntry.SetCurrentKey("Bin Checkpoint Entry No.");
                POSBinEntry.SetFilter("Bin Checkpoint Entry No.", '=%1', CheckpointEntryNo);
                if (POSBinEntry.FindSet()) then begin
                    repeat
                        case POSBinEntry.Type of

                            POSBinEntry.Type::DIFFERENCE:
                                begin
                                    if (PaymentTypePOS.Euro) then
                                        Kasseperiode."Euro Difference" += POSBinEntry."Transaction Amount (LCY)";
                                    if (not PaymentTypePOS.Euro) then
                                        Kasseperiode.Difference += POSBinEntry."Transaction Amount (LCY)"
                                end;

                            POSBinEntry.Type::BANK_TRANSFER:
                                begin
                                    Kasseperiode."Deposit in Bank" += POSBinEntry."Transaction Amount (LCY)";
                                    Kasseperiode."Money bag no." := CopyStr(POSBinEntry."External Transaction No.", 1, MaxStrLen(Kasseperiode."Money bag no."));
                                end;

                        end;

                    until (POSBinEntry.Next() = 0);
                end;
            until (POSPaymentBinCheckpoint.Next() = 0);
        end;

        Kasseperiode.Insert(true);

        Kasseperiode."Net. Cash Change" := POSWorkshiftCheckpoint."Local Currency (LCY)"; //"Cash Movements";
        Kasseperiode."Net. Credit Voucher Change" := POSWorkshiftCheckpoint."Redeemed Credit Voucher (LCY)" - POSWorkshiftCheckpoint."Created Credit Voucher (LCY)";// "Credit Vouches";
        Kasseperiode."Net. Gift Voucher Change" := POSWorkshiftCheckpoint."Issued Vouchers (LCY)"; // "Gift Vouchers";
        Kasseperiode."Net. Terminal Change" := POSWorkshiftCheckpoint."Cash Terminal (LCY)"; // "Credit Cards";
        Kasseperiode."Net. Dankort Change" := POSWorkshiftCheckpoint."EFT (LCY)"; // Dank;
        Kasseperiode."Net. VisaCard Change" := POSWorkshiftCheckpoint."Manual Card (LCY)"; // VisaDk;
        Kasseperiode."Net. Change Other Cedit Cards" := POSWorkshiftCheckpoint."Other Credit Card (LCY)"; // "Other Credit Cards";
        Kasseperiode."Gift Voucher Sales" := Abs(POSWorkshiftCheckpoint."Issued Vouchers (LCY)"); //Udstedtegavekort;
        Kasseperiode."Credit Voucher issuing" := Abs(POSWorkshiftCheckpoint."Created Credit Voucher (LCY)"); //Udstedtetilgodebeviser;
        Kasseperiode."Cash Received" := POSWorkshiftCheckpoint."Debtor Payment (LCY)"; // "Customer Payments";
        Kasseperiode."Pay Out" := POSWorkshiftCheckpoint."GL Payment (LCY)"; // "Out Payments";
        Kasseperiode."Debit Sale" := POSWorkshiftCheckpoint."Credit Item Sales (LCY)"; //DebetSalg;
        Kasseperiode."Negative Sales Count" := POSWorkshiftCheckpoint."Direct Item Returns Line Count";
        Kasseperiode."Negative Sales Amount" := POSWorkshiftCheckpoint."Direct Item Returns (LCY)";

        Kasseperiode."Shortcut Dimension 1 Code" := POSUnit."Global Dimension 1 Code";
        Kasseperiode."Shortcut Dimension 2 Code" := POSUnit."Global Dimension 2 Code";
        Kasseperiode."Location Code" := Register."Location Code";
        Kasseperiode."Alternative Register No." := Sale."Alternative Register No.";

        Kasseperiode."Sales (Qty)" := POSWorkshiftCheckpoint."Direct Sales Count"; //"Sales (Qty)";
        Kasseperiode."Sales (LCY)" := POSWorkshiftCheckpoint."Direct Item Sales (LCY)"; //"Sales (LCY)";
        Kasseperiode."Debit Sales (Qty)" := POSWorkshiftCheckpoint."Credit Item Quantity Sum"; // "Sales Debit (Qty)";
        Kasseperiode."Cancelled Sales" := POSWorkshiftCheckpoint."Cancelled Sales Count"; //CancelledSales;

        Kasseperiode."Campaign Discount (LCY)" := POSWorkshiftCheckpoint."Campaign Discount (LCY)"; //"Campaign Discount (LCY)";
        Kasseperiode."Mix Discount (LCY)" := POSWorkshiftCheckpoint."Mix Discount (LCY)"; //"Mix Discount (LCY)";
        Kasseperiode."Quantity Discount (LCY)" := POSWorkshiftCheckpoint."Quantity Discount (LCY)"; //"Quantity Discount (LCY)";
        Kasseperiode."Line Discount (LCY)" := POSWorkshiftCheckpoint."Line Discount (LCY)"; // "Line Discount (LCY)";
        Kasseperiode."Custom Discount (LCY)" := POSWorkshiftCheckpoint."Custom Discount (LCY)"; //"Custom Discount (LCY)";
        Kasseperiode."Total Discount (LCY)" := POSWorkshiftCheckpoint."Total Discount (LCY)"; //"Total Discount (LCY)";
        Kasseperiode."Net Turnover (LCY)" := POSWorkshiftCheckpoint."Net Turnover (LCY)"; //"Net Turnover (LCY)";
        Kasseperiode."Net Cost (LCY)" := POSWorkshiftCheckpoint."Net Cost (LCY)"; //"Net Cost (LCY)";
        Kasseperiode."Turnover Including VAT" := POSWorkshiftCheckpoint."Turnover (LCY)"; // "Turnover (LCY)" ;
        Kasseperiode."Currencies Amount (LCY)" := POSWorkshiftCheckpoint."Foreign Currency (LCY)"; // "Currencies Amount (LCY)";
        Kasseperiode."Profit Amount (LCY)" := POSWorkshiftCheckpoint."Profit Amount (LCY)"; //"Profit Amount (LCY)";
        Kasseperiode."Profit %" := POSWorkshiftCheckpoint."Profit %"; // "Profit %";

        // { Save Statistics }
        Kasseperiode."No. Of Goods Sold" := POSWorkshiftCheckpoint."Direct Item Quantity Sum";
        Kasseperiode."No. Of Cash Receipts" := POSWorkshiftCheckpoint."Receipts Count";
        Kasseperiode."No. Of Cash Box Openings" := POSWorkshiftCheckpoint."Cash Drawer Open Count";
        Kasseperiode."No. Of Receipt Copies" := POSWorkshiftCheckpoint."Receipt Copies Count";

        POSWorkshiftTaxCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', POSWorkshiftCheckpoint."Entry No.");
        if (POSWorkshiftTaxCheckpoint.FindSet()) then begin
            repeat
                Kasseperiode."VAT Info String" += StrSubstNo('%1:%2;', (POSWorkshiftTaxCheckpoint."Tax %"), POSWorkshiftTaxCheckpoint."Tax Amount");
            until (POSWorkshiftTaxCheckpoint.Next() = 0);
        end;

        Kasseperiode.Modify();

        // { SAVE REGISTER COUNTING }
        "Payment Type - Detailed".SetFilter("Register No.", '=%1', Kasseperiode."Register No.");
        if "Payment Type - Detailed".FindSet then
            repeat
                if "Payment Type - Detailed".Quantity <> 0 then begin
                    "Period Line".Init;
                    "Period Line"."Register No." := Kasseperiode."Register No.";
                    "Period Line"."Sales Ticket No." := Kasseperiode."Sales Ticket No.";
                    "Period Line"."No." := Kasseperiode."No.";
                    "Period Line"."Payment Type No." := "Payment Type - Detailed"."Payment No.";
                    "Period Line".Weight := "Payment Type - Detailed".Weight;
                    "Period Line".Quantity := "Payment Type - Detailed".Quantity;
                    "Period Line".Amount := "Payment Type - Detailed".Amount;
                    if not "Period Line".Insert(true) then
                        "Period Line".Modify(true);
                end;
            until "Payment Type - Detailed".Next = 0;
    end;

    local procedure AggregateVat_AR(WorkshiftCheckpointEntryNo: Integer; var AuditRoll: Record "NPR Audit Roll")
    var
        TmpPOSWorkshiftTaxCheckpoint: Record "NPR POS Worksh. Tax Checkp." temporary;
        POSWorkshiftTaxCheckpoint: Record "NPR POS Worksh. Tax Checkp.";
        TempEntryNo: Integer;
    begin

        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Sale);
        AuditRoll.SetRange(Type, AuditRoll.Type::Item);

        if (AuditRoll.FindSet()) then begin
            repeat

                with TmpPOSWorkshiftTaxCheckpoint do begin
                    Reset();
                    SetFilter("Workshift Checkpoint Entry No.", '=%1', WorkshiftCheckpointEntryNo);
                    if (AuditRoll.Quantity > 0) then
                        SetFilter("Tax Calculation Type", '=%1', "Tax Calculation Type"::"Normal VAT");
                    if (AuditRoll.Quantity < 0) then
                        SetFilter("Tax Calculation Type", '=%1', "Tax Calculation Type"::"Reverse Charge VAT");
                    SetFilter("Tax Area Code", '=%1', AuditRoll."VAT Bus. Posting Group");
                    SetFilter("VAT Identifier", '=%1', AuditRoll."VAT Prod. Posting Group");

                    if (not FindFirst()) then begin
                        TempEntryNo += 1;
                        "Entry No." := TempEntryNo;

                        Init();
                        "Workshift Checkpoint Entry No." := WorkshiftCheckpointEntryNo;

                        if (AuditRoll.Quantity > 0) then
                            "Tax Calculation Type" := "Tax Calculation Type"::"Normal VAT";

                        if (AuditRoll.Quantity < 0) then
                            "Tax Calculation Type" := "Tax Calculation Type"::"Reverse Charge VAT";

                        "Tax Area Code" := AuditRoll."VAT Bus. Posting Group";
                        "VAT Identifier" := AuditRoll."VAT Prod. Posting Group";
                        "Tax %" := AuditRoll."VAT %";
                        Insert();
                    end;

                    "Tax Base Amount" += AuditRoll."VAT Base Amount";
                    "Tax Amount" += AuditRoll."Amount Including VAT" - AuditRoll.Amount;
                    "Line Amount" += AuditRoll.Amount;
                    "Amount Including Tax" += AuditRoll."Amount Including VAT";
                    Modify();
                end;

            until (AuditRoll.Next() = 0);
        end;

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

    #endregion

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

                    with TmpPOSWorkshiftTaxCheckpoint do begin
                        Reset();
                        SetFilter("Workshift Checkpoint Entry No.", '=%1', WorkshiftCheckpointEntryNo);
                        SetFilter("Tax Area Code", '=%1', POSTaxAmountLine."Tax Area Code");
                        SetFilter("Tax Calculation Type", '=%1', POSTaxAmountLine."Tax Calculation Type");

                        SetFilter("VAT Identifier", '=%1', POSTaxAmountLine."VAT Identifier");
                        SetFilter("Tax Jurisdiction Code", '=%1', POSTaxAmountLine."Tax Jurisdiction Code");
                        SetFilter("Tax Group Code", '=%1', POSTaxAmountLine."Tax Group Code");

                        if (not FindFirst()) then begin
                            TempEntryNo += 1;
                            "Entry No." := TempEntryNo;

                            Init();
                            "Workshift Checkpoint Entry No." := WorkshiftCheckpointEntryNo;

                            "Tax Calculation Type" := POSTaxAmountLine."Tax Calculation Type";

                            "VAT Identifier" := POSTaxAmountLine."VAT Identifier";
                            "Tax Jurisdiction Code" := POSTaxAmountLine."Tax Jurisdiction Code";
                            "Tax Group Code" := POSTaxAmountLine."Tax Group Code";

                            "Tax Area Code" := POSTaxAmountLine."Tax Area Code";
                            "Tax %" := POSTaxAmountLine."Tax %";
                            Insert();
                        end;

                        "Tax Base Amount" += POSTaxAmountLine."Tax Base Amount";
                        "Tax Amount" += POSTaxAmountLine."Tax Amount";
                        "Line Amount" += POSTaxAmountLine."Line Amount";
                        "Amount Including Tax" += POSTaxAmountLine."Amount Including Tax";
                        Modify();
                    end;

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

    procedure CreateFirstCheckpointForUnit(POSUnitNo: Code[10]; Comment: Text[50])
    var
        BinEntry: Record "NPR POS Bin Entry";
        POSUnit: Record "NPR POS Unit";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSEntry: Record "NPR POS Entry";
        CashRegister: Record "NPR Register";
        PaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        PaymentTypePOS: Record "NPR Payment Type POS";
        POSPaymentMethod: Record "NPR POS Payment Method";
        Window: Dialog;
        CurrentCurrent: Integer;
        MaxCount: Integer;
        ClosingEntryNo: Integer;
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSManagePOSUnit: Codeunit "NPR POS Manage POS Unit";
    begin

        if (not POSEntry.FindLast()) then
            exit;

        POSUnit.Get(POSUnitNo);

        POSWorkshiftCheckpoint.Init();
        POSWorkshiftCheckpoint."Entry No." := 0;
        POSWorkshiftCheckpoint."POS Unit No." := POSUnitNo;
        POSWorkshiftCheckpoint."Created At" := CurrentDateTime();
        POSWorkshiftCheckpoint.Open := false;
        POSWorkshiftCheckpoint.Type := POSWorkshiftCheckpoint.Type::ZREPORT;
        POSWorkshiftCheckpoint."POS Entry No." := POSEntry."Entry No.";
        POSWorkshiftCheckpoint.Insert();

        if (CashRegister.Get(POSUnitNo)) then begin

            if (GuiAllowed) then
                Window.Open(StrSubstNo(CHECKPOINT_PROGRESS, POSUnit.TableCaption, POSUnitNo));
            MaxCount := POSPaymentMethod.Count();

            POSCreateEntry.InsertUnitCloseBeginEntry(POSUnitNo, UserId);

            POSPaymentMethod.FindSet();
            repeat

                BinEntry.Init();
                BinEntry."Entry No." := 0;
                BinEntry."Created At" := CurrentDateTime();

                BinEntry.Type := BinEntry.Type::CHECKPOINT;
                BinEntry."Payment Bin No." := POSUnit."Default POS Payment Bin";

                BinEntry."Transaction Date" := Today;
                BinEntry."Transaction Time" := Time;
                BinEntry.Comment := Comment;

                BinEntry."Register No." := POSUnitNo;
                BinEntry."POS Unit No." := POSUnitNo;
                BinEntry."POS Store Code" := POSUnit."POS Store Code";

                BinEntry."Payment Type Code" := POSPaymentMethod.Code;
                BinEntry."Payment Method Code" := POSPaymentMethod.Code;

                BinEntry.Insert();

                PaymentBinCheckpoint.Init;
                PaymentBinCheckpoint."Entry No." := 0;
                PaymentBinCheckpoint."Checkpoint Bin Entry No." := BinEntry."Entry No.";
                PaymentBinCheckpoint."Workshift Checkpoint Entry No." := POSWorkshiftCheckpoint."Entry No.";
                PaymentBinCheckpoint.Status := PaymentBinCheckpoint.Status::TRANSFERED;
                PaymentBinCheckpoint.Type := PaymentBinCheckpoint.Type::ZREPORT;

                PaymentBinCheckpoint."Created On" := CurrentDateTime();
                PaymentBinCheckpoint."Checkpoint Date" := Today;
                PaymentBinCheckpoint."Checkpoint Time" := Time;
                PaymentBinCheckpoint.Comment := BinEntry.Comment;

                PaymentBinCheckpoint."Payment Type No." := BinEntry."Payment Type Code";
                PaymentBinCheckpoint."Payment Method No." := BinEntry."Payment Method Code";
                PaymentBinCheckpoint."Currency Code" := POSPaymentMethod."Currency Code";
                PaymentBinCheckpoint."Payment Bin No." := POSUnit."Default POS Payment Bin";
                PaymentBinCheckpoint."Include In Counting" := POSPaymentMethod."Include In Counting"::YES;

                PaymentBinCheckpoint.Description := POSPaymentMethod.Code;
                PaymentTypePOS.SetFilter("No.", '=%1', POSPaymentMethod.Code);
                if (PaymentTypePOS.FindFirst()) then
                    PaymentBinCheckpoint.Description := PaymentTypePOS.Description;

                if (CashRegister."Primary Payment Type" = PaymentTypePOS."No.") and (CashRegister.Status = CashRegister.Status::Afsluttet) then begin
                    PaymentBinCheckpoint."Calculated Amount Incl. Float" := CashRegister."Closing Cash";
                    PaymentBinCheckpoint."New Float Amount" := CashRegister."Closing Cash";
                end;

                PaymentBinCheckpoint.Insert();

                // Update checkpoint and make total balance on bin entry zero
                PaymentBinCheckpoint.CalcFields("Payment Bin Entry Amount", "Payment Bin Entry Amount (LCY)");
                BinEntry."Transaction Amount" := -1 * PaymentBinCheckpoint."Payment Bin Entry Amount";
                BinEntry."Transaction Amount (LCY)" := -1 * PaymentBinCheckpoint."Payment Bin Entry Amount (LCY)";
                BinEntry."Bin Checkpoint Entry No." := PaymentBinCheckpoint."Entry No.";
                BinEntry.Modify();

                // Create the required bin entry for float
                BinEntry."Entry No." := 0;
                BinEntry."Payment Type Code" := PaymentBinCheckpoint."Payment Type No.";
                BinEntry."Transaction Amount" := 0;
                BinEntry."Transaction Amount (LCY)" := 0;

                if (CashRegister."Primary Payment Type" = PaymentTypePOS."No.") and (CashRegister.Status = CashRegister.Status::Afsluttet) then begin
                    BinEntry."Transaction Amount" := CashRegister."Closing Cash";
                    BinEntry."Transaction Amount (LCY)" := CashRegister."Closing Cash";
                end;

                BinEntry.Type := BinEntry.Type::FLOAT;
                BinEntry.Insert();

                if (GuiAllowed) then
                    Window.Update(1, Round(CurrentCurrent / MaxCount * 10000, 1));

                CurrentCurrent += 1;

            until (POSPaymentMethod.Next() = 0);

            ClosingEntryNo := POSCreateEntry.InsertUnitCloseEndEntry(POSUnitNo, UserId);
            POSManagePOSUnit.ClosePOSUnitNo(POSUnitNo, ClosingEntryNo);

            if (GuiAllowed) then
                Window.Close();

        end;
    end;

    #region **************** Upgrade from AuditRoll to POS Entry
    procedure OnActivatePosEntryPosting()
    begin

        ActivationValidationCheck();
        MigrateOpenBalance();

        CreatePOSSystemEntry('', UserId, 'POS Entry postings is activated.');
    end;

    procedure OnDeactivatePosEntryPosting()
    begin

        CreatePOSSystemEntry('', UserId, 'POS Entry postings is deactivated.');
    end;

    local procedure ActivationValidationCheck()
    var
        CacheRegister: Record "NPR Register";
        POSUnit: Record "NPR POS Unit";
    begin

        CacheRegister.SetFilter(Status, '<>%1', CacheRegister.Status::Afsluttet);
        if (not CacheRegister.IsEmpty()) then
            if (not Confirm(ALL_REGISTERS_MUST_BE_BALANCED, false, CacheRegister.TableCaption, CacheRegister.FieldCaption(Status), Format(CacheRegister.Status::Afsluttet))) then
                Error('POS Entry posting is not activated.');

        CacheRegister.Reset;
        if (CacheRegister.FindSet()) then begin
            repeat
                if (not POSUnit.Get(CacheRegister."Register No.")) then
                    Error(NOT_ALL_CR_HAVE_POS_UNIT, CacheRegister.TableCaption(), POSUnit.TableCaption, CacheRegister."Register No.");
            until (CacheRegister.Next() = 0);
        end;
    end;

    local procedure MigrateOpenBalance()
    var
        POSUnit: Record "NPR POS Unit";
        CashRegister: Record "NPR Register";
        POSOpenPOSUnit: Codeunit "NPR POS Manage POS Unit";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        OpeningEntryNo: Integer;
    begin

        if (POSUnit.FindSet()) then begin
            repeat

                POSOpenPOSUnit.ClosePOSUnitOpenPeriods(POSUnit."No."); // make sure pos period register is correct
                POSOpenPOSUnit.OpenPOSUnit(POSUnit);
                OpeningEntryNo := POSCreateEntry.InsertUnitOpenEntry(POSUnit."No.", CopyStr(UserId, 1, 20));
                POSOpenPOSUnit.SetOpeningEntryNo(POSUnit."No.", OpeningEntryNo);

                CreateFirstCheckpointForUnit(POSUnit."No.", 'POS Entry Activation - Checkpoint.');
                CreatePOSSystemEntry(POSUnit."No.", UserId, 'Initial Workshift Checkpoint Created.');

            until (POSUnit.Next() = 0);
        end;

        CashRegister.ModifyAll(Status, CashRegister.Status::Ekspedition);

    end;

    local procedure CreatePOSSystemEntry(POSUnitNo: Code[10]; SalespersonCode: Code[10]; Description: Text[80]) EntryNo: Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSPeriodRegister: Record "NPR POS Period Register";
    begin

        POSEntry.Init;

        POSEntry."Entry No." := 0;
        POSEntry."Entry Type" := POSEntry."Entry Type"::Other;
        POSEntry."System Entry" := true;

        POSEntry."POS Period Register No." := 0;
        POSEntry."POS Store Code" := '';
        POSEntry."POS Unit No." := POSUnitNo;

        POSEntry."Entry Date" := Today;
        POSEntry."Starting Time" := Time;
        POSEntry."Ending Time" := Time;
        POSEntry."Salesperson Code" := SalespersonCode;

        POSEntry.Description := Description;
        POSEntry."Post Item Entry Status" := POSEntry."Post Item Entry Status"::"Not To Be Posted";
        POSEntry."Post Entry Status" := POSEntry."Post Entry Status"::"Not To Be Posted";

        POSEntry.Insert();

        exit(POSEntry."Entry No.");
    end;

    #endregion
}

