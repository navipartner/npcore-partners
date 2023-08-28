codeunit 6059860 "NPR End Of Day Worker"
{
    Access = Internal;

    var
        EndOfDayOptions: Option "X-Report","Z-Report",CloseWorkShift;

    procedure ValidateRequirements(POSUnitCode: Code[10]; SalesTicketNo: Code[20]): Boolean
    var
        POSUnit: Record "NPR POS Unit";
        SalePOS: Record "NPR POS Sale";
        POSQuoteMgt: Codeunit "NPR POS Saved Sale Mgt.";
        SaleMustBeEmpty: Label 'Delete all sales lines before balancing the register';
    begin

        if (SalesTicketNo = '') then
            exit(true);

        POSUnit.Get(POSUnitCode);
        SalePOS.Get(POSUnitCode, SalesTicketNo);
        if (LineExists(SalePOS)) then
            Error(SaleMustBeEmpty);

        if not POSQuoteMgt.CleanupPOSQuotesBeforeBalancing(SalePOS) then
            Error('');

        exit(true);
    end;

    procedure CalculateEndOfDay(EndOfDayType: Option "X-Report","Z-Report",CloseWorkShift; Setup: codeunit "NPR POS Setup"; Sale: codeunit "NPR POS Sale"; POSUnitNo: Code[10]): Integer
    var
        POSManagePOSUnit: Codeunit "NPR POS Manage POS Unit";
        SalePOS: Record "NPR POS Sale";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        POSSession: Codeunit "NPR POS Session";
        FrontEnd: Codeunit "NPR POS Front End Management";
        CheckpointEntryNo: Integer;
        POSUnitIn: Record "NPR POS Unit";
        NullGuid: Guid;
    begin
        POSSession.GetFrontEnd(FrontEnd);
        if not Sale.IsInitialized() then begin
            if POSUnitIn.Get(POSUnitNo) then
                Sale.InitializeNewSale(POSUnitIn, FrontEnd, Setup, Sale, NullGuid);
        end;
        Sale.GetCurrentSale(SalePOS);

        Setup.GetSalespersonRecord(SalespersonPurchaser);
        CheckpointEntryNo := 0;

        POSManagePOSUnit.SetEndOfDayPOSUnitNo(POSUnitNo);
        case (EndOfDayType) of
            EndOfDayType::"Z-Report":
                CheckpointEntryNo := CreateReport(EndOfDayType, POSUnitNo, SalespersonPurchaser.Code, SalePOS."Dimension Set ID", POSSession, FrontEnd);

            EndOfDayType::CloseWorkShift:
                CheckpointEntryNo := CloseWorkshift(POSUnitNo, SalespersonPurchaser.Code, SalePOS."Dimension Set ID");

            EndOfDayType::"X-Report":
                begin
                    CheckpointEntryNo := CreateReport(EndOfDayType, POSUnitNo, SalespersonPurchaser.Code, SalePOS."Dimension Set ID", POSSession, FrontEnd);
                    POSManagePOSUnit.ReOpenLastPeriodRegister(POSUnitNo);
                end;
        end;
        exit(CheckpointEntryNo);
    end;

    procedure SwitchView(FrontEnd: codeunit "NPR POS Front End Management"; EndOfDayType: Option "X-Report","Z-Report",CloseWorkShift; POSWorkShiftCheckpoint: Record "NPR POS Workshift Checkpoint") Result: JsonObject
    var
        Request: Codeunit "NPR Front-End: Generic";
        POSSession: Codeunit "NPR POS Session";
        BalancingContext: JsonObject;
        POSSaleCodeunit: Codeunit "NPR POS Sale";
        POSSale: Record "NPR POS Sale";
    begin

        Result.ReadFrom('{}');
        if (EndOfDayType = EndOfDayType::CloseWorkShift) then begin
            POSSession.ChangeViewLogin();

        end else begin
            POSSession.GetSale(POSSaleCodeunit);
            POSSaleCodeunit.GetCurrentSale(POSSale);

            BalancingContext.Add('checkPointId', POSWorkShiftCheckpoint."Entry No.");
            BalancingContext.Add('salesPersonCode', POSSale."Salesperson Code");
            BalancingContext.Add('dimensionId', POSSale."Dimension Set ID");

            Request.SetMethod('BalanceSetContext'); // ==> Transfer control to codeunit 6014568 "NPR End Of Day UI Handler" on next ping
            Request.GetContent().Add('balancingContext', BalancingContext);
            FrontEnd.InvokeFrontEndMethod2(Request);

            POSSession.ChangeViewBalancing();
        end;

        Exit(Result);
    end;

    procedure CreateReport(EndOfDayType: Option "X-Report","Z-Report",CloseWorkShift; POSUnitNo: Code[10]; SalesPersonCode: Code[20]; SaleDimSetID: Integer; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management") EntryNo: Integer;
    var
        POSCheckpointMgr: Codeunit "NPR POS Workshift Checkpoint";
    begin
        CloseSlaveUnits(POSUnitNo, SaleDimSetID);
        EntryNo := POSCheckpointMgr.CreateCheckpointWorker(EndOfDayType, POSUnitNo);
    end;

    procedure CloseSlaveUnits(UnitNo: Code[10]; DimensionSetId: Integer)
    var
        POSEndOfDayProfile: Record "NPR POS End of Day Profile";
        POSUnit: Record "NPR POS Unit";
        POSUnitSlaves: Record "NPR POS Unit";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSManagePOSUnit: Codeunit "NPR POS Manage POS Unit";
        ClosingEntryNo: Integer;
        EntryNo: Integer;
    begin
        POSUnit.Get(UnitNo);
        if (POSUnit."POS End of Day Profile" = '') then
            exit;

        if (not POSEndOfDayProfile.Get(POSUnit."POS End of Day Profile")) then
            exit;

        if (POSEndOfDayProfile."End of Day Type" <> POSEndOfDayProfile."End of Day Type"::MASTER_SLAVE) then
            exit;

        POSUnitSlaves.SetFilter("POS End of Day Profile", '=%1', POSUnit."POS End of Day Profile");
        if (POSUnitSlaves.FindSet()) then begin
            repeat
                if (POSUnitSlaves."No." <> POSEndOfDayProfile."Master POS Unit No.") then
                    if (POSUnitSlaves.Status = POSUnitSlaves.Status::OPEN) then begin
                        EndWorkshiftWithCloseWorkShiftOption(POSUnitSlaves."No.", DimensionSetId, EntryNo);
                        ClosingEntryNo := POSCreateEntry.InsertUnitCloseEndEntry(POSUnitSlaves."No.", '');
                        POSManagePOSUnit.ClosePOSUnitNo(POSUnitSlaves."No.", ClosingEntryNo);
                    end;
            until (POSUnitSlaves.Next() = 0);
        end;

    end;

    procedure CloseWorkshift(POSUnitNo: Code[10]; SalespersonPurchaserCode: Code[20]; DimensionSetId: Integer): Integer
    var
        ClosingEntryNo: Integer;
        BalanceEntryToPrint: Integer;
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSSession: Codeunit "NPR POS Session";
        POSManagePOSUnit: Codeunit "NPR POS Manage POS Unit";
    begin
        EndWorkshiftWithCloseWorkShiftOption(POSUnitNo, DimensionSetId, BalanceEntryToPrint);

        ClosingEntryNo := POSCreateEntry.InsertUnitCloseEndEntry(POSUnitNo, SalespersonPurchaserCode);
        POSManagePOSUnit.ClosePOSUnitNo(POSUnitNo, ClosingEntryNo);

        if (BalanceEntryToPrint <> 0) then begin
            Commit();
            POSSession.ChangeViewLogin();
            PrintEndOfDayReport(POSUnitNo, BalanceEntryToPrint);
        end;

        exit(BalanceEntryToPrint);
    end;

    local procedure EndWorkshiftWithCloseWorkShiftOption(UnitNo: Code[10]; DimensionSetId: Integer; var PrintEntryNo: Integer): Boolean
    var
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        POSEndOfDayProfile: Record "NPR POS End of Day Profile";
        POSCheckpointMgr: Codeunit "NPR POS Workshift Checkpoint";
        EntryNo: Integer;
        PosIsManaged: Boolean;
        WithPrint: Boolean;
        MustBeManaged: Label 'The Close Work shift function is only intended for POS units that are managed for End-of-Day. Use X-Report or Z-Report instead.';
    begin
        PosIsManaged := false;
        WithPrint := true;
        POSUnit.Get(UnitNo);
        if (POSUnit."POS End of Day Profile" <> '') then
            if (POSEndOfDayProfile.Get(POSUnit."POS End of Day Profile")) then
                if (POSEndOfDayProfile."End of Day Type" = POSEndOfDayProfile."End of Day Type"::MASTER_SLAVE) then begin
                    PosIsManaged := (POSUnit."No." <> POSEndOfDayProfile."Master POS Unit No.");
                    WithPrint := (POSEndOfDayProfile."Close Workshift UI" <> POSEndOfDayProfile."Close Workshift UI"::NO_PRINT);
                end;

        if (not PosIsManaged) then
            Error(MustBeManaged);

        EntryNo := POSCheckpointMgr.EndWorkshift(EndOfDayOptions::CloseWorkShift, UnitNo, DimensionSetId);

        if (not POSEntry.Get(EntryNo)) then
            exit(false);

        if (WithPrint) then
            PrintEntryNo := EntryNo;

        exit(true);
    end;

    procedure PrintEndOfDayReport(UnitNo: Code[10]; EntryNo: Integer)
    var
        POSEntry: Record "NPR POS Entry";
        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        RecRef: RecordRef;
    begin
        POSEntry.Get(EntryNo);
        POSEntry.TestField("Entry Type", POSEntry."Entry Type"::Balancing);

        POSWorkshiftCheckpoint.SetFilter("POS Entry No.", '=%1', EntryNo);
        POSWorkshiftCheckpoint.FindFirst();
        RecRef.GetTable(POSWorkshiftCheckpoint);

        RetailReportSelectionMgt.SetRegisterNo(UnitNo);
        RetailReportSelectionMgt.RunObjects(RecRef, "NPR Report Selection Type"::"Balancing (POS Entry)".AsInteger());
    end;

    local procedure LineExists(var SalePOS: Record "NPR POS Sale"): Boolean
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        exit(not SaleLinePOS.IsEmpty());
    end;

    procedure OpenDrawer(CashDrawerNo: Code[10]; POSUnitNo: Code[10]; SalePOS: Record "NPR POS Sale")
    var
        POSPaymentBin: Record "NPR POS Payment Bin";
        POSPaymentBinInvokeMgt: Codeunit "NPR POS Payment Bin Eject Mgt.";
        POSUnit: Record "NPR POS Unit";
    begin
        if (CashDrawerNo = '') then begin
            if (not POSUnit.Get(POSUnitNo)) then
                exit;
            CashDrawerNo := POSUnit."Default POS Payment Bin";
        end;

        if (not POSPaymentBin.Get(CashDrawerNo)) then
            exit;

        POSPaymentBinInvokeMgt.EjectDrawer(POSPaymentBin, SalePOS, false);
    end;

    procedure DiscoverEftIntegrationsForEndOfDay(EndOfDayType: Option "X-Report","Z-Report",CloseWorkShift) WorkflowsArray: JsonArray
    var
        EftInterface: Codeunit "NPR Eft Interface";
        Workflows: Dictionary of [Text, JsonObject];
        WorkflowName: Text;
        WorkflowContext: JsonObject;
    begin
        EftInterface.OnEndOfDayCloseEft(EndOfDayType, Workflows);
        //turn the dictionary into a pure JSON array for easier parsing in workflow JS:
        foreach WorkflowName in Workflows.Keys do begin
            WorkflowContext := Workflows.Get(WorkflowName);
            WorkflowContext.Add('WorkflowName', WorkflowName);
            WorkflowsArray.Add(WorkflowContext);
        end;
    end;
}