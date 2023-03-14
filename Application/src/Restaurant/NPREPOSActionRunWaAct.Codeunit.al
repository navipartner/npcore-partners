codeunit 6150676 "NPR NPRE POSAction: Run Wa.Act" implements "NPR IPOS Workflow"
{
    Access = Internal;

    local procedure ActionCode(): Code[20]
    begin
        exit(Format("NPR POS Workflow"::"RUN_W/PAD_ACTION"));
    end;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'An action to run Waiter Pad functions directly from Sales View';
        ParamWaiterPadAction_OptLbl: Label 'Print Pre-Receipt,Send Kitchen Order,Request Next Serving,Request Specific Serving,Merge Waiter Pad,Close w/out Saving', MaxLength = 250;
        ParamWaiterPadAction_NameLbl: Label 'Waiter Pad Action';
        ParamWaiterPadAction_DescLbl: Label 'Defines which waiter pad action is to be run by the POS action.';
        ParamWaiterPadAction_CaptOptLbl: Label 'Print Pre-Receipt,Send Kitchen Order,Request Next Serving,Request Specific Serving,Merge Waiter Pad,Close w/out Saving';
        ParamLinesToSend_OptLbl: Label 'New/Updated,All', MaxLength = 250;
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
#pragma warning disable AA0139
                                          SelectStr(1, ParamWaiterPadAction_OptLbl),
#pragma warning restore
                                          ParamWaiterPadAction_NameLbl,
                                          ParamWaiterPadAction_DescLbl,
                                          ParamWaiterPadAction_CaptOptLbl);
        WorkflowConfig.AddOptionParameter('LinesToSend',
                                          ParamLinesToSend_OptLbl,
#pragma warning disable AA0139
                                          SelectStr(1, ParamLinesToSend_OptLbl),
#pragma warning restore
                                          ParamLinesToSend_NameLbl,
                                          ParamLinesToSend_DescLbl,
                                          ParamLinesToSend_CaptOptLbl);
        WorkflowConfig.AddTextParameter('ServingStep', '', ParamServingStep_CptLbl, ParamServingStep_DescLbl);
        WorkflowConfig.AddBooleanParameter('MoveSaleToWPadOnFinish', false, ParamMoveSaleToWPadOnFinish_CptLbl, ParamMoveSaleToWPadOnFinish_DescLbl);
        WorkflowConfig.AddBooleanParameter('ReturnToDefaultView', false, ParamReturnToDefaultView_CptLbl, ParamReturnToDefaultView_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        SalePOS: Record "NPR POS Sale";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPad2: Record "NPR NPRE Waiter Pad";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        POSSession: Codeunit "NPR POS Session";
        WPadAction: Option "Print Pre-Receipt","Send Kitchen Order","Request Next Serving","Request Specific Serving","Merge Waiter Pad","Close w/out Saving";
        WPadLinesToSend: Option "New/Updated",All;
        ServingStepToRequest: Code[10];
        ResultMessageText: Text;
        ClearSaleOnFinish: Boolean;
        ReturnToDefaultView: Boolean;
        WPadNotSelectedErr: Label 'Please select a waiter pad first.';
    begin
        WPadAction := Context.GetIntegerParameter('WaiterPadAction');
        if not Context.GetBooleanParameter('MoveSaleToWPadOnFinish', ClearSaleOnFinish) then
            ClearSaleOnFinish := false;
        if not Context.GetBooleanParameter('ReturnToDefaultView', ReturnToDefaultView) then
            ReturnToDefaultView := false;
        if ReturnToDefaultView then
            ClearSaleOnFinish := true;

        POSSession.GetSale(Sale);
        Sale.GetCurrentSale(SalePOS);
        if WPadAction <> WPadAction::"Close w/out Saving" then begin
            if SalePOS."NPRE Pre-Set Waiter Pad No." = '' then
                Error(WPadNotSelectedErr);
            WaiterPad.Get(SalePOS."NPRE Pre-Set Waiter Pad No.");
            WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, WaiterPad, false);
            Commit();

            case WPadAction of
                WPadAction::"Print Pre-Receipt":
                    begin
                        RestaurantPrint.PrintWaiterPadPreReceiptPressed(WaiterPad);
                    end;

                WPadAction::"Send Kitchen Order":
                    begin
                        WPadLinesToSend := Context.GetIntegerParameter('LinesToSend');
                        RestaurantPrint.PrintWaiterPadPreOrderToKitchenPressed(WaiterPad, WPadLinesToSend = WPadLinesToSend::All);
                    end;

                WPadAction::"Request Next Serving":
                    begin
                        ResultMessageText := RestaurantPrint.RequestRunServingStepToKitchen(WaiterPad, true, '');
                    end;

                WPadAction::"Request Specific Serving":
                    begin
                        ServingStepToRequest := CopyStr(Context.GetStringParameter('ServingStep'), 1, MaxStrLen(ServingStepToRequest));
                        if ServingStepToRequest = '' then
                            if not LookupServingStep(ServingStepToRequest) then
                                Error('');
                        ResultMessageText := RestaurantPrint.RequestRunServingStepToKitchen(WaiterPad, false, ServingStepToRequest);
                    end;

                WPadAction::"Merge Waiter Pad":
                    begin
                        if not WaiterPadPOSMgt.SelectWaiterPadToMergeTo(WaiterPad, WaiterPad2) then
                            Error('');
                        POSSession.GetSaleLine(SaleLine);
                        SaleLine.DeleteAll();
                        WaiterPadMgt.MergeWaiterPad(WaiterPad, WaiterPad2);
                        WaiterPad := WaiterPad2;
                    end;
            end;
        end;

        Context.SetContext('ShowResultMessage', ResultMessageText <> '');
        Context.SetContext('ResultMessageText', ResultMessageText);

        if ClearSaleOnFinish or
           (WPadAction in [WPadAction::"Merge Waiter Pad", WPadAction::"Close w/out Saving"])
        then begin
            if WPadAction <> WPadAction::"Merge Waiter Pad" then begin
                POSSession.GetSaleLine(SaleLine);
                SaleLine.DeleteAll();
            end;

            SalePOS.Find();
            WaiterPadPOSMgt.ClearSaleHdrNPREPresetFields(SalePOS, false);
            Sale.Refresh(SalePOS);
            Sale.Modify(true, false);

            if (WPadAction = WPadAction::"Merge Waiter Pad") and not ClearSaleOnFinish then
                WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(WaiterPad, POSSession);

            if ReturnToDefaultView then
                Sale.SelectViewForEndOfSale(POSSession);
        end;
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
'let main=async({workflow:s,context:e,popup:a})=>{await s.respond(),e.ShowResultMessage&&a.message(e.ResultMessageText)};'
        );
    end;
}
