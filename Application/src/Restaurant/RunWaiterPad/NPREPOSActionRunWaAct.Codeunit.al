codeunit 6150676 "NPR NPRE POSAction: Run Wa.Act" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        _WPadAction: Option "Print Pre-Receipt","Send Kitchen Order","Request Next Serving","Request Specific Serving","Merge Waiter Pad","Close w/out Saving";
        _ClearSaleOnFinish: Boolean;
        _ReturnToDefaultView: Boolean;

    local procedure ActionCode(): Code[20]
    begin
        exit(Format("NPR POS Workflow"::"RUN_W/PAD_ACTION"));
    end;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'An action to run Waiter Pad functions directly from Sales View';
        ParamWaiterPadAction_OptLbl: Label 'Print Pre-Receipt,Send Kitchen Order,Request Next Serving,Request Specific Serving,Merge Waiter Pad,Close w/out Saving', MaxLength = 250, Locked = true;
        ParamWaiterPadAction_NameLbl: Label 'Waiter Pad Action';
        ParamWaiterPadAction_DescLbl: Label 'Defines which waiter pad action is to be run by the POS action.';
        ParamWaiterPadAction_CaptOptLbl: Label 'Print Pre-Receipt,Send Kitchen Order,Request Next Serving,Request Specific Serving,Merge Waiter Pad,Close w/out Saving';
        ParamLinesToSend_OptLbl: Label 'New/Updated,All', MaxLength = 250, Locked = true;
        ParamLinesToSend_NameLbl: Label 'Lines to Send to Kitchen';
        ParamLinesToSend_DescLbl: Label 'Defines which waiter pad lines are to be sent to kitchen, if ''Send Kitchen Order'' is selected as Waiter Pad Action.';
        ParamLinesToSend_CaptOptLbl: Label 'New/Updated,All';
        ParamServingStep_CptLbl: Label 'Serving Step to Request';
        ParamServingStep_DescLbl: Label 'Defines which serving step is to be requested, if ''Request Specific Serving'' is selected as Waiter Pad Action.';
        ParamMoveSaleToWPadOnFinish_CptLbl: Label 'Move Sale to W/Pad on Finish';
        ParamMoveSaleToWPadOnFinish_DescLbl: Label 'Move POS sale lines to waiter pad after the Waiter Pad Action has completed';
        ParamReturnToDefaultView_CptLbl: Label 'Return to Default View on Finish';
        ParamReturnToDefaultView_DescLbl: Label 'Switch to the default view defined for the POS Unit after the Waiter Pad Action has completed.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddOptionParameter('WaiterPadAction',
                                          ParamWaiterPadAction_OptLbl,
                                          CopyStr(SelectStr(1, ParamWaiterPadAction_OptLbl), 1, 250),
                                          ParamWaiterPadAction_NameLbl,
                                          ParamWaiterPadAction_DescLbl,
                                          ParamWaiterPadAction_CaptOptLbl);
        WorkflowConfig.AddOptionParameter('LinesToSend',
                                          ParamLinesToSend_OptLbl,
                                          CopyStr(SelectStr(1, ParamLinesToSend_OptLbl), 1, 250),
                                          ParamLinesToSend_NameLbl,
                                          ParamLinesToSend_DescLbl,
                                          ParamLinesToSend_CaptOptLbl);
        WorkflowConfig.AddTextParameter('ServingStep', '', ParamServingStep_CptLbl, ParamServingStep_DescLbl);
        WorkflowConfig.AddBooleanParameter('MoveSaleToWPadOnFinish', false, ParamMoveSaleToWPadOnFinish_CptLbl, ParamMoveSaleToWPadOnFinish_DescLbl);
        WorkflowConfig.AddBooleanParameter('ReturnToDefaultView', false, ParamReturnToDefaultView_CptLbl, ParamReturnToDefaultView_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        _WPadAction := Context.GetIntegerParameter('WaiterPadAction');
        if not Context.GetBooleanParameter('MoveSaleToWPadOnFinish', _ClearSaleOnFinish) then
            _ClearSaleOnFinish := false;
        if not Context.GetBooleanParameter('ReturnToDefaultView', _ReturnToDefaultView) then
            _ReturnToDefaultView := false;
        if _ReturnToDefaultView then
            _ClearSaleOnFinish := true;

        case Step of
            'runMainAction':
                FrontEnd.WorkflowResponse(RunMainAction(Context, Sale, SaleLine));
            'runCleanup':
                CleanupSale(Context, Sale, SaleLine);
        end;
    end;

    local procedure RunMainAction(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line") ConfirmSaleCleanup: Boolean
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPad2: Record "NPR NPRE Waiter Pad";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        WPadLinesToSend: Option "New/Updated",All;
        ServingStepToRequest: Code[10];
        ResultMessageText: Text;
        PartlyPaid: Boolean;
        PartlyPaidErr: Label 'This sales has been partly paid. You must first void the payment.';
        WPadNotSelectedErr: Label 'Please select a waiter pad first.';
        ConfirmDeletionQst: Label 'All changes not saved to waiter pad will be lost. Are you sure you want to continue?';
    begin
        Sale.GetCurrentSale(SalePOS);
        if _WPadAction <> _WPadAction::"Close w/out Saving" then begin
            if SalePOS."NPRE Pre-Set Waiter Pad No." = '' then
                Error(WPadNotSelectedErr);
            WaiterPad.Get(SalePOS."NPRE Pre-Set Waiter Pad No.");
            WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, WaiterPad, false);
            Commit();

            case _WPadAction of
                _WPadAction::"Print Pre-Receipt":
                    begin
                        RestaurantPrint.PrintWaiterPadPreReceiptPressed(WaiterPad);
                    end;

                _WPadAction::"Send Kitchen Order":
                    begin
                        WPadLinesToSend := Context.GetIntegerParameter('LinesToSend');
                        RestaurantPrint.PrintWaiterPadPreOrderToKitchenPressed(WaiterPad, WPadLinesToSend = WPadLinesToSend::All);
                    end;

                _WPadAction::"Request Next Serving":
                    begin
                        ResultMessageText := RestaurantPrint.RequestRunServingStepToKitchen(WaiterPad, true, '');
                    end;

                _WPadAction::"Request Specific Serving":
                    begin
                        ServingStepToRequest := CopyStr(Context.GetStringParameter('ServingStep'), 1, MaxStrLen(ServingStepToRequest));
                        if ServingStepToRequest = '' then
                            if not LookupServingStep(ServingStepToRequest) then
                                Error('');
                        ResultMessageText := RestaurantPrint.RequestRunServingStepToKitchen(WaiterPad, false, ServingStepToRequest);
                    end;

                _WPadAction::"Merge Waiter Pad":
                    begin
                        if not WaiterPadPOSMgt.SelectWaiterPadToMergeTo(WaiterPad, WaiterPad2) then
                            Error('');
                        SaleLine.DeleteWPadSupportedLinesOnly();
                        WaiterPadMgt.MergeWaiterPad(WaiterPad, WaiterPad2);
                        Context.SetContext('NewWaiterPadNo', WaiterPad2."No.");
                    end;
            end;
            Context.SetContext('ShowResultMessage', ResultMessageText <> '');
            Context.SetContext('ResultMessageText', ResultMessageText);
        end;

        if (_WPadAction = _WPadAction::"Close w/out Saving") or _ClearSaleOnFinish then begin
            SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
            SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::"POS Payment");
            SaleLinePOS.SetFilter("Amount Including VAT", '<> %1', 0);
            PartlyPaid := not SaleLinePOS.IsEmpty();
            if PartlyPaid and (_WPadAction = _WPadAction::"Close w/out Saving") then
                Error(PartlyPaidErr)
        end;

        if (_WPadAction <> _WPadAction::"Merge Waiter Pad") or _ClearSaleOnFinish then begin
            if _WPadAction = _WPadAction::"Close w/out Saving" then begin
                Context.SetContext('CleanupMessageText', ConfirmDeletionQst);
                ConfirmSaleCleanup := true;
            end else
                if WaiterPadPOSMgt.UnsupportedSaleLinesExist(SalePOS) then begin
                    Context.SetContext('CleanupMessageText', WaiterPadPOSMgt.UnableToCleanupSaleMsgText(not PartlyPaid));
                    ConfirmSaleCleanup := not PartlyPaid;
                end;
        end;
    end;

    local procedure CleanupSale(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line")
    var
        SalePOS: Record "NPR POS Sale";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        POSSession: Codeunit "NPR POS Session";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        if not (_ClearSaleOnFinish or (_WPadAction in [_WPadAction::"Merge Waiter Pad", _WPadAction::"Close w/out Saving"])) then
            exit;

        if (_WPadAction <> _WPadAction::"Merge Waiter Pad") or _ClearSaleOnFinish then
            SaleLine.DeleteAll();

        Sale.GetCurrentSale(SalePOS);
        SalePOS.Find();
        WaiterPadPOSMgt.ClearSaleHdrNPREPresetFields(SalePOS, false);
        Sale.Refresh(SalePOS);
        Sale.Modify(true, false);

        if (_WPadAction = _WPadAction::"Merge Waiter Pad") and not _ClearSaleOnFinish then begin
            WaiterPad."No." := CopyStr(Context.GetString('NewWaiterPadNo'), 1, MaxStrLen(WaiterPad."No."));
            WaiterPad.Find();
            WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(WaiterPad, POSSession);
        end;

        if _ReturnToDefaultView then
            Sale.SelectViewForEndOfSale(POSSession);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        SelectedServingStep: Code[10];
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'ServingStep':
                begin
                    SelectedServingStep := CopyStr(POSParameterValue.Value, 1, MaxStrLen(SelectedServingStep));
                    if LookupServingStep(SelectedServingStep) then
                        POSParameterValue.Value := SelectedServingStep;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        FlowStatus: Record "NPR NPRE Flow Status";
        FlowStatusCodeLbl: Label '@%1*', Locked = true;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'ServingStep':
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    FlowStatus."Status Object" := FlowStatus."Status Object"::WaiterPadLineMealFlow;
                    FlowStatus.Code := CopyStr(POSParameterValue.Value, 1, MaxStrLen(FlowStatus.Code));
                    if not FlowStatus.Find() then begin
                        FlowStatus.SetRange("Status Object", FlowStatus."Status Object"::WaiterPadLineMealFlow);
                        FlowStatus.SetFilter(Code, CopyStr(StrSubstNo(FlowStatusCodeLbl, POSParameterValue.Value), 1, MaxStrLen(FlowStatus.Code)));
                        FlowStatus.FindFirst();
                    end;
                    POSParameterValue.Value := FlowStatus.Code;
                end;
        end;
    end;

    local procedure LookupServingStep(var SelectedServingStep: Code[10]): Boolean
    var
        FlowStatus: Record "NPR NPRE Flow Status";
    begin
        FlowStatus.FilterGroup(2);
        FlowStatus.SetRange("Status Object", FlowStatus."Status Object"::WaiterPadLineMealFlow);
        FlowStatus.FilterGroup(0);
        if SelectedServingStep <> '' then begin
            FlowStatus."Status Object" := FlowStatus."Status Object"::WaiterPadLineMealFlow;
            FlowStatus.Code := SelectedServingStep;
            if FlowStatus.Find('=><') then;
        end;
        if PAGE.RunModal(0, FlowStatus) = ACTION::LookupOK then begin
            SelectedServingStep := FlowStatus.Code;
            exit(true);
        end;
        exit(false);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:NPREPOSActionRunWaAct.js###
'let main=async({workflow:s,context:e,popup:a})=>{let i=await s.respond("runMainAction");if(e.ShowResultMessage&&await a.message(e.ResultMessageText),e.CleanupMessageText)if(i){if(!await a.confirm(e.CleanupMessageText))return}else{a.error(e.CleanupMessageText);return}await s.respond("runCleanup")};'
        );
    end;
}
