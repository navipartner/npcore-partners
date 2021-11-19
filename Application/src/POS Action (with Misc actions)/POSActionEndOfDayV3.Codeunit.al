codeunit 6150849 "NPR POS Action: EndOfDay V3"
{
    var
        ActionDescription: Label 'This is the built in function to perform balancing of the register (Version 1)';
        t002: Label 'Delete all sales lines before balancing the register';
        NextWorkflowStep: Option NA,JUMP_BALANCE_REGISTER,EFT_CLOSE;
        EndOfDayTypeOption: Option "X-Report","Z-Report",CloseWorkShift;
        MustBeManaged: Label 'The Close Work shift function is only intended for POS units that are managed for End-of-Day. Use X-Report or Z-Report instead.';

    local procedure ActionCode(): Code[20]
    begin
        exit('BALANCE_V3');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.9');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
        then begin

            Sender.RegisterWorkflowStep('ValidateRequirements', 'respond()');
            Sender.RegisterWorkflowStep('NotifySubscribers', 'respond()');
            Sender.RegisterWorkflowStep('Eft_Discovery', 'respond()');
            Sender.RegisterWorkflowStep('Eft_Close', 'respond()');
            Sender.RegisterWorkflowStep('Eft_CloseDone', 'respond()');
            Sender.RegisterWorkflowStep('OpenCashDrawer', 'respond()');
            Sender.RegisterWorkflowStep('BalanceRegister', 'respond()');
            Sender.RegisterWorkflowStep('EndOfWorkflow', 'respond()');

            Sender.RegisterOptionParameter('Security', 'None,SalespersonPassword,CurrentSalespersonPassword,SupervisorPassword', 'None');
            Sender.RegisterOptionParameter('Type', 'X-Report (prel),Z-Report (final),Close Workshift', 'X-Report (prel)');
            Sender.RegisterBooleanParameter('Auto-Open Cash Drawer', false);
            Sender.RegisterTextParameter('Cash Drawer No.', '');

            Sender.RegisterWorkflow(false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSSetup: Codeunit "NPR POS Setup";
        POSSale: Codeunit "NPR POS Sale";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        SalePOS: Record "NPR POS Sale";
        POSUnit: Record "NPR POS Unit";
        EndOfDayType: Integer;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        POSManagePOSUnit: Codeunit "NPR POS Manage POS Unit";
        ClosingEntryNo: Integer;
        CashDrawerNo: Code[10];
        OpenUnit: Boolean;
        BalanceEntryToPrint: Integer;
        CurrentView: Codeunit "NPR POS View";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        OpenUnit := JSON.GetBooleanParameter('Auto-Open Cash Drawer');
        CashDrawerNo := CopyStr(JSON.GetStringParameter('Cash Drawer No.'), 1, MaxStrLen(CashDrawerNo));

        EndOfDayType := JSON.GetIntegerParameterOrFail('Type', ActionCode());
        if (EndOfDayType < 0) then
            EndOfDayType := 0;

        POSSession.GetSetup(POSSetup);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        POSSetup.GetPOSUnit(POSUnit);
        POSSetup.GetSalespersonRecord(SalespersonPurchaser);
        SalePOS."Register No." := POSUnit."No.";

        NextWorkflowStep := NextWorkflowStep::NA;
        case WorkflowStep of
            'ValidateRequirements':
                begin
                    if (not (ValidateRequirements(POSUnit."No.", SalePOS."Sales Ticket No."))) then
                        FrontEnd.ContinueAtStep('EndOfWorkflow');
                    POSCreateEntry.InsertUnitCloseBeginEntry(POSUnit."No.", SalespersonPurchaser.Code);
                end;

            'NotifySubscribers':
                begin
                end;

            'Eft_Discovery':
                if (EndOfDayType = EndOfDayTypeOption::"Z-Report") then
                    EftDiscovery(POSSession);

            'Eft_Close':
                if (EndOfDayType = EndOfDayTypeOption::"Z-Report") then
                    EftClose(POSSession);

            'Eft_CloseDone':
                if (EndOfDayType = EndOfDayTypeOption::"Z-Report") then
                    EftCloseDone(POSSession);

            'OpenCashDrawer':
                if (OpenUnit) then
                    OpenDrawer(CashDrawerNo, POSUnit, SalePOS);

            'BalanceRegister':
                begin

                    POSManagePOSUnit.SetEndOfDayPOSUnitNo(POSUnit."No.");

                    case (EndOfDayType) of
                        EndOfDayTypeOption::"Z-Report":
                            begin
                                if (UseBusinessCentralUI(POSUnit."No.")) then CreateZReport(POSUnit."No.", SalespersonPurchaser.Code, SalePOS."Dimension Set ID", POSSession);
                                if (not UseBusinessCentralUI(POSUnit."No.")) then CreateZReportPosUI(POSUnit."No.", SalespersonPurchaser.Code, SalePOS."Dimension Set ID", POSSession, FrontEnd);
                            end;

                        EndOfDayTypeOption::CloseWorkShift:
                            begin
                                CloseWorkShift(POSUnit."No.", SalePOS."Dimension Set ID", BalanceEntryToPrint);
                                ClosingEntryNo := POSCreateEntry.InsertUnitCloseEndEntry(POSUnit."No.", SalespersonPurchaser.Code);
                                POSManagePOSUnit.ClosePOSUnitNo(POSUnit."No.", ClosingEntryNo);

                                if (BalanceEntryToPrint <> 0) then begin
                                    Commit();
                                    POSSession.ChangeViewLogin();
                                    PrintEndOfDayReport(POSUnit."No.", BalanceEntryToPrint);
                                end;

                            end;
                        else begin
                                if (UseBusinessCentralUI(POSUnit."No.")) then begin
                                    PreliminaryEndOfDay(POSUnit."No.", SalePOS."Dimension Set ID");
                                    POSManagePOSUnit.ReOpenLastPeriodRegister(POSUnit."No.");
                                end;
                                if (not UseBusinessCentralUI(POSUnit."No.")) then CreateXReportPosUI(POSUnit."No.", SalespersonPurchaser.Code, SalePOS."Dimension Set ID", POSSession, FrontEnd);
                            end;
                    end;
                end;

            'EndOfWorkflow':
                begin
                    POSSession.GetCurrentView(CurrentView);
                    if (CurrentView.Type() <> CurrentView.Type() ::Login) then
                        POSSession.ChangeViewLogin();
                end;
        end;

        case NextWorkflowStep of
            NextWorkflowStep::JUMP_BALANCE_REGISTER:
                FrontEnd.ContinueAtStep('OpenCashDrawer');
            NextWorkflowStep::EFT_CLOSE:
                FrontEnd.ContinueAtStep('Eft_Close');
        end;
    end;

    procedure ValidateRequirements(POSUnitCode: Code[10]; SalesTicketNo: Code[20]): Boolean
    var
        POSUnit: Record "NPR POS Unit";
        SalePOS: Record "NPR POS Sale";
        POSQuoteMgt: Codeunit "NPR POS Saved Sale Mgt.";
    begin

        if (SalesTicketNo = '') then
            exit(true);

        // TODO - Needs to verified for UNITS / BINS
        POSUnit.Get(POSUnitCode);

        SalePOS.Get(POSUnitCode, SalesTicketNo);
        if (LineExists(SalePOS)) then
            Error(t002);

        if not POSQuoteMgt.CleanupPOSQuotesBeforeBalancing(SalePOS) then
            Error('');

        exit(true);
    end;

    local procedure FinalEndOfDay(UnitNo: Code[10]; DimensionSetId: Integer; var EntryNo: Integer): Boolean
    var
        POSEntry: Record "NPR POS Entry";
        POSWorkShiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSCheckpointMgr: Codeunit "NPR POS Workshift Checkpoint";
    begin
        CloseSlaveUnits(UnitNo, DimensionSetId);
        EntryNo := POSCheckpointMgr.EndWorkshift(EndOfDayTypeOption::"Z-Report", UnitNo, DimensionSetId);

        if (not POSEntry.Get(EntryNo)) then
            exit(false);

        POSWorkShiftCheckpoint.SetFilter("POS Entry No.", '=%1', EntryNo);
        if (POSWorkShiftCheckpoint.FindFirst()) then
            exit(not POSWorkShiftCheckpoint.Open);

        exit(false);
    end;

    local procedure PreliminaryEndOfDay(UnitNo: Code[10]; DimensionSetId: Integer): Boolean
    var
        POSEntry: Record "NPR POS Entry";
        POSCheckpointMgr: Codeunit "NPR POS Workshift Checkpoint";
        EntryNo: Integer;
    begin
        EntryNo := POSCheckpointMgr.EndWorkshift(EndOfDayTypeOption::"X-Report", UnitNo, DimensionSetId);
        if (not POSEntry.Get(EntryNo)) then
            exit(false);

        PrintEndOfDayReport(UnitNo, EntryNo);

        exit(true);
    end;

    local procedure CloseWorkShift(UnitNo: Code[10]; DimensionSetId: Integer; var PrintEntryNo: Integer): Boolean
    var
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        POSEndOfDayProfile: Record "NPR POS End of Day Profile";
        POSCheckpointMgr: Codeunit "NPR POS Workshift Checkpoint";
        EntryNo: Integer;
        PosIsManaged: Boolean;
        WithPrint: Boolean;
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

        EntryNo := POSCheckpointMgr.EndWorkshift(EndOfDayTypeOption::CloseWorkShift, UnitNo, DimensionSetId);

        if (not POSEntry.Get(EntryNo)) then
            exit(false);

        if (WithPrint) then
            PrintEntryNo := EntryNo;

        exit(true);
    end;

    internal procedure PrintEndOfDayReport(UnitNo: Code[10]; EntryNo: Integer)
    var
        POSEntry: Record "NPR POS Entry";
        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        RecRef: RecordRef;
    begin
        POSEntry.Get(EntryNo);
        POSEntry.TestField("Entry Type", POSEntry."Entry Type"::Balancing);

        POSWorkshiftCheckpoint.SetFilter("POS Entry No.", '=%1', EntryNo);
        POSWorkshiftCheckpoint.FindFirst();
        RecRef.GetTable(POSWorkshiftCheckpoint);

        RetailReportSelectionMgt.SetRegisterNo(UnitNo);
        RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Balancing (POS Entry)");
    end;

    local procedure EftDiscovery(POSSession: Codeunit "NPR POS Session")
    var
        EFTInterface: Codeunit "NPR EFT Interface";
        TempEFTSetup: Record "NPR EFT Setup" temporary;
        EFTSetup: Record "NPR EFT Setup";
    begin
        EFTInterface.OnQueueCloseBeforeRegisterBalance(POSSession, TempEFTSetup);
        if not TempEFTSetup.FindSet() then begin
            NextWorkflowStep := NextWorkflowStep::JUMP_BALANCE_REGISTER;
            exit;
        end;

        repeat
            EFTSetup.Get(TempEFTSetup.RecordId);
            EFTSetup.Mark(true);
        until TempEFTSetup.Next() = 0;
        EFTSetup.MarkedOnly(true);
        EFTSetup.FindSet();

        POSSession.ClearActionState();
        POSSession.BeginAction(ActionCode());
        POSSession.StoreActionState('eft_close_list', EFTSetup);
    end;

    local procedure EftClose(POSSession: Codeunit "NPR POS Session")
    var
        RecRef: RecordRef;
        EFTSetup: Record "NPR EFT Setup";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        POSSetup: Codeunit "NPR POS Setup";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        POSSession.RetrieveActionStateRecordRef('eft_close_list', RecRef);
        if RecRef.Number = 0 then
            exit;
        RecRef.SetTable(EFTSetup);
        if not EFTSetup.Find() then
            exit;

        POSSession.GetSale(POSSale);
        POSSession.GetSetup(POSSetup);
        POSSale.GetCurrentSale(SalePOS);

        EFTTransactionMgt.StartEndWorkshift(EFTSetup, SalePOS);
    end;

    local procedure EftCloseDone(POSSession: Codeunit "NPR POS Session")
    var
        RecRef: RecordRef;
        EFTSetup: Record "NPR EFT Setup";
    begin

        POSSession.RetrieveActionStateRecordRef('eft_close_list', RecRef);
        if RecRef.Number = 0 then
            exit;
        RecRef.SetTable(EFTSetup);
        if EFTSetup.Next() = 0 then
            exit;

        POSSession.StoreActionState('eft_close_list', EFTSetup);
        NextWorkflowStep := NextWorkflowStep::EFT_CLOSE;
    end;

    local procedure OpenDrawer(CashDrawerNo: Code[10]; POSUnit: Record "NPR POS Unit"; SalePOS: Record "NPR POS Sale")
    var
        POSPaymentBin: Record "NPR POS Payment Bin";
        POSPaymentBinInvokeMgt: Codeunit "NPR POS Payment Bin Eject Mgt.";
    begin
        if (CashDrawerNo = '') then begin
            CashDrawerNo := POSUnit."Default POS Payment Bin";
        end;

        if not POSPaymentBin.Get(CashDrawerNo) then
            exit;

        POSPaymentBinInvokeMgt.EjectDrawer(POSPaymentBin, SalePOS);
    end;

    local procedure CloseSlaveUnits(UnitNo: Code[10]; DimensionSetId: Integer)
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
        if (POSUnit."POS End of Day Profile" <> '') then
            if (POSEndOfDayProfile.Get(POSUnit."POS End of Day Profile")) then
                if (POSEndOfDayProfile."End of Day Type" = POSEndOfDayProfile."End of Day Type"::MASTER_SLAVE) then begin
                    POSUnitSlaves.SetFilter("POS End of Day Profile", '=%1', POSUnit."POS End of Day Profile");
                    if (POSUnitSlaves.FindSet()) then begin
                        repeat
                            if (POSUnitSlaves."No." <> POSEndOfDayProfile."Master POS Unit No.") then
                                if (POSUnitSlaves.Status = POSUnitSlaves.Status::OPEN) then begin
                                    CloseWorkShift(POSUnitSlaves."No.", DimensionSetId, EntryNo);
                                    ClosingEntryNo := POSCreateEntry.InsertUnitCloseEndEntry(POSUnitSlaves."No.", '');
                                    POSManagePOSUnit.ClosePOSUnitNo(POSUnitSlaves."No.", ClosingEntryNo);
                                end;
                        until (POSUnitSlaves.Next() = 0);
                    end;
                end;
    end;

    local procedure UseBusinessCentralUI(UnitNo: Code[10]): Boolean
    var
        POSUnit: Record "NPR POS Unit";
        POSEndOfDayProfile: Record "NPR POS End of Day Profile";
    begin
        POSUnit.Get(UnitNo);
        if (POSUnit."POS End of Day Profile" <> '') then
            if (POSEndOfDayProfile.Get(POSUnit."POS End of Day Profile")) then
                exit(POSEndOfDayProfile."User Experience" = POSEndOfDayProfile."User Experience"::BC);
        exit(true);
    end;

    procedure LineExists(var SalePOS: Record "NPR POS Sale"): Boolean
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        exit(not SaleLinePOS.IsEmpty());
    end;

    procedure CreateZReport(POSUnitNo: Code[10]; SalespersonPurchaserCode: Text; SaleDimSetID: Integer; POSSession: Codeunit "NPR POS Session"): Integer
    var
        ClosingEntryNo: Integer;
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSManagePOSUnit: Codeunit "NPR POS Manage POS Unit";
        BalanceEntryToPrint: Integer;
    begin
        if (FinalEndOfDay(POSUnitNo, SaleDimSetID, BalanceEntryToPrint)) then begin
            ClosingEntryNo := POSCreateEntry.InsertUnitCloseEndEntry(POSUnitNo, CopyStr(SalespersonPurchaserCode, 1, 20));
            POSManagePOSUnit.ClosePOSUnitNo(POSUnitNo, ClosingEntryNo);

            Commit();
            POSSession.ChangeViewLogin();
            PrintEndOfDayReport(POSUnitNo, BalanceEntryToPrint);
        end else begin
            POSManagePOSUnit.ReOpenLastPeriodRegister(POSUnitNo);
        end;

        exit(BalanceEntryToPrint);
    end;

    procedure CreateZReportPosUI(POSUnitNo: Code[10]; SalesPersonCode: Code[10]; SaleDimSetID: Integer; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"): Integer
    var
        POSCheckpointMgr: Codeunit "NPR POS Workshift Checkpoint";
        EntryNo: Integer;
        Request: Codeunit "NPR Front-End: Generic";
        BalancingContext: JsonObject;
    begin
        CloseSlaveUnits(POSUnitNo, SaleDimSetID);
        EntryNo := POSCheckpointMgr.CreateCheckpointWorker(EndOfDayTypeOption::"Z-Report", POSUnitNo);

        BalancingContext.Add('endOfDayCheckpointEntryNo', EntryNo);
        BalancingContext.Add('DimensionSetId', SaleDimSetID);
        BalancingContext.Add('SalesPersonCode', SalesPersonCode);

        Request.SetMethod('BalanceSetContext');
        Request.GetContent().Add('balancingContext', BalancingContext);

        POSSession.GetFrontEnd(FrontEnd, true);
        FrontEnd.InvokeFrontEndMethod(Request);
        POSSession.ChangeViewBalancing();

        // Execution in AL continues when frontend invokes OnCustomMethod with method BalancingSetState

    end;

    procedure CreateXReportPosUI(POSUnitNo: Code[10]; SalesPersonCode: Code[10]; SaleDimSetID: Integer; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"): Integer
    var
        POSCheckpointMgr: Codeunit "NPR POS Workshift Checkpoint";
        EntryNo: Integer;
        Request: Codeunit "NPR Front-End: Generic";
        BalancingContext: JsonObject;
    begin
        CloseSlaveUnits(POSUnitNo, SaleDimSetID);
        EntryNo := POSCheckpointMgr.CreateCheckpointWorker(EndOfDayTypeOption::"X-Report", POSUnitNo);

        BalancingContext.Add('endOfDayCheckpointEntryNo', EntryNo);
        BalancingContext.Add('DimensionSetId', SaleDimSetID);
        BalancingContext.Add('SalesPersonCode', SalesPersonCode);

        Request.SetMethod('BalanceSetContext');
        Request.GetContent().Add('balancingContext', BalancingContext);

        POSSession.GetFrontEnd(FrontEnd, true);
        FrontEnd.InvokeFrontEndMethod(Request);
        POSSession.ChangeViewBalancing();

        // Execution in AL continues when frontend invokes OnCustomMethod with method BalancingSetState

    end;

}
