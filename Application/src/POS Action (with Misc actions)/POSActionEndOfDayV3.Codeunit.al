﻿codeunit 6150849 "NPR POS Action: EndOfDay V3"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteReason = 'Not used any more. Please use BALANCE_V4 action instead.';

    var
        ActionDescription: Label 'This is the built in function to perform balancing of the register (Version 1)';

        NextWorkflowStep: Option NA,JUMP_BALANCE_REGISTER,EFT_CLOSE;
        EndOfDayTypeOption: Option "X-Report","Z-Report",CloseWorkShift;

    local procedure ActionCode(): Code[20]
    begin
        exit('BALANCE_V3');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.10');
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
            Sender.RegisterBooleanParameter('SuppressParkedSalesDialog', false);

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
        POSEndOfDay: Codeunit "NPR End Of Day Worker";
        SalePOS: Record "NPR POS Sale";
        POSUnit: Record "NPR POS Unit";
        POSWorkShiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        EndOfDayType: Integer;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        POSManagePOSUnit: Codeunit "NPR POS Manage POS Unit";
        CashDrawerNo: Code[10];
        OpenUnit: Boolean;
        CurrentView: Codeunit "NPR POS View";
        EntryNo: Integer;
        HidePopup: Boolean;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        OpenUnit := JSON.GetBooleanParameter('Auto-Open Cash Drawer');
        CashDrawerNo := CopyStr(JSON.GetStringParameter('Cash Drawer No.'), 1, MaxStrLen(CashDrawerNo));
        HidePopup := JSON.GetBooleanParameter('SuppressParkedSalesDialog');

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
                    if (not (POSEndOfDay.ValidateRequirements(POSUnit."No.", SalePOS."Sales Ticket No.", HidePopup))) then
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
                                if (not UseBusinessCentralUI(POSUnit."No.")) then begin
                                    EntryNo := POSEndOfDay.CreateReport(EndOfDayType, POSUnit."No.", SalespersonPurchaser.Code, SalePOS."Dimension Set ID", POSSession, FrontEnd);
                                    if (POSWorkShiftCheckpoint.Get(EntryNo)) then
                                        POSEndOfDay.SwitchView(FrontEnd, EndOfDayType, POSWorkShiftCheckpoint);
                                end;
                            end;

                        EndOfDayTypeOption::CloseWorkShift:
                            POSEndOfDay.CloseWorkshift(POSUnit."No.", SalespersonPurchaser.Code, SalePOS."Dimension Set ID");

                        else begin
                            if (UseBusinessCentralUI(POSUnit."No.")) then begin
                                PreliminaryEndOfDay(POSUnit."No.", SalePOS."Dimension Set ID");
                                POSManagePOSUnit.ReOpenLastPeriodRegister(POSUnit."No.");
                            end;
                            if (not UseBusinessCentralUI(POSUnit."No.")) then POSEndOfDay.CreateReport(EndOfDayType, POSUnit."No.", SalespersonPurchaser.Code, SalePOS."Dimension Set ID", POSSession, FrontEnd);
                        end;
                    end;
                end;

            'EndOfWorkflow':
                begin
                    POSSession.GetCurrentView(CurrentView);
                    if (CurrentView.GetType() <> CurrentView.GetType() ::Login) then
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

    local procedure FinalEndOfDay(UnitNo: Code[10]; DimensionSetId: Integer; var EntryNo: Integer): Boolean
    var
        POSEntry: Record "NPR POS Entry";
        POSWorkShiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSCheckpointMgr: Codeunit "NPR POS Workshift Checkpoint";
        POSEndOfDay: Codeunit "NPR End Of Day Worker";
    begin
        POSEndOfDay.CloseSlaveUnits(UnitNo, DimensionSetId);
        EntryNo := POSCheckpointMgr.EndWorkshift(EndOfDayTypeOption::"Z-Report", UnitNo, DimensionSetId);

        if (not POSEntry.Get(EntryNo)) then
            exit(false);

        POSWorkShiftCheckpoint.SetFilter("POS Entry No.", '=%1', EntryNo);
        if (POSWorkShiftCheckpoint.FindFirst()) then
            exit(not POSWorkShiftCheckpoint.Open);

        exit(false);
    end;

    procedure PreliminaryEndOfDay(UnitNo: Code[10]; DimensionSetId: Integer): Boolean
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

        POSPaymentBinInvokeMgt.EjectDrawer(POSPaymentBin, SalePOS, false);
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

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterNameCaption', '', true, false)]
    local procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        CaptionSavedSalesOption: Label 'Suppress Parked Sales Dialog';
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'SuppressParkedSalesDialog':
                Caption := CaptionSavedSalesOption;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterDescriptionCaption', '', true, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        DescSavedSalesOption: Label 'Specifies whether to suppress parked sales dialog.';
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'SuppressParkedSalesDialog':
                Caption := DescSavedSalesOption;
        end;
    end;
}
