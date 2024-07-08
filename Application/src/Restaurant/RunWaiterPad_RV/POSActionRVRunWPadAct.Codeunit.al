codeunit 6150677 "NPR POSAction: RV Run WPadAct." implements "NPR IPOS Workflow"
{
    Access = Internal;

    local procedure ActionCode(): Code[20]
    begin
        exit(Format("NPR POS Workflow"::"RV_RUN_W/PAD_ACTION"));
    end;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This built-in action allows to run Waiter Pad related functions directly from Restaurant View';
        ParamWaiterPadCode_CptLbl: Label 'Waiter Pad Code';
        ParamWaiterPadCode_DescLbl: Label 'Defines waiter pad number the action is to be run upon. The parameter is set automatically by the system on the runtime.';
        ParamWaiterPadAction_OptLbl: Label 'Print Pre-Receipt,Send Kitchen Order,Request Next Serving,Request Specific Serving,Merge Waiter Pad,Open Waiter Pad', MaxLength = 250, Locked = true;
        ParamWaiterPadAction_NameLbl: Label 'Waiter Pad Action';
        ParamWaiterPadAction_DescLbl: Label 'Defines which waiter pad action is to be run by the POS action.';
        ParamWaiterPadAction_CaptOptLbl: Label 'Print Pre-Receipt,Send Kitchen Order,Request Next Serving,Request Specific Serving,Merge Waiter Pad,Open Waiter Pad';
        ParamLinesToSend_OptLbl: Label 'New/Updated,All', MaxLength = 250, Locked = true;
        ParamLinesToSend_NameLbl: Label 'Lines to Send to Kitchen';
        ParamLinesToSend_DescLbl: Label 'Defines which waiter pad lines are to be sent to kitchen, if ''Send Kitchen Order'' is selected as Waiter Pad Action.';
        ParamLinesToSend_CaptOptLbl: Label 'New/Updated,All';
        ParamServingStep_CptLbl: Label 'Serving Step to Request';
        ParamServingStep_DescLbl: Label 'Defines which serving step is to be requested, if ''Request Specific Serving'' is selected as Waiter Pad Action.';
        ParamReturnToDefaultView_CptLbl: Label 'Return to Default View on Finish';
        ParamReturnToDefaultView_DescLbl: Label 'Switch to the default view defined for the POS Unit after the Waiter Pad Action has completed.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddTextParameter('WaiterPadCode', '', ParamWaiterPadCode_CptLbl, ParamWaiterPadCode_DescLbl);
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
        WorkflowConfig.AddBooleanParameter('ReturnToDefaultView', false, ParamReturnToDefaultView_CptLbl, ParamReturnToDefaultView_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        BusinessLogic: Codeunit "NPR POSAct. RV Run W/PadB";
        WPadAction: Option "Print Pre-Receipt","Send Kitchen Order","Request Next Serving","Request Specific Serving","Merge Waiter Pad","Open Waiter Pad";
        WPadLinesToSend: Option "New/Updated",All;
        ServingStepToRequest: Code[10];
        WaiterPadNo: Code[20];
        ResultMessageText: Text;
        ReturnToDefaultView: Boolean;
    begin
        WaiterPadNo := CopyStr(Context.GetStringParameter('WaiterPadCode'), 1, MaxStrLen(WaiterPadNo));
        WPadAction := Context.GetIntegerParameter('WaiterPadAction');
        if not Context.GetBooleanParameter('ReturnToDefaultView', ReturnToDefaultView) then
            ReturnToDefaultView := false;

        case WPadAction of
            WPadAction::"Send Kitchen Order":
                WPadLinesToSend := Context.GetIntegerParameter('LinesToSend');
            WPadAction::"Request Specific Serving":
                ServingStepToRequest := CopyStr(Context.GetStringParameter('ServingStep'), 1, MaxStrLen(ServingStepToRequest));
        end;

        BusinessLogic.RunWaiterPadAction(WPadAction, WaiterPadNo, WPadLinesToSend, ServingStepToRequest, ResultMessageText);

        Context.SetContext('ShowResultMessage', ResultMessageText <> '');
        Context.SetContext('ResultMessageText', ResultMessageText);

        if ReturnToDefaultView then
            Sale.SelectViewForEndOfSale();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        SelectedServingStep: Code[10];
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'ServingStep':
                begin
                    SelectedServingStep := CopyStr(POSParameterValue.Value, 1, MaxStrLen(SelectedServingStep));
                    if WaiterPadPOSMgt.LookupServingStep(SelectedServingStep) then
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

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionRVRunWPad.js###
'let main=async({workflow:s,context:e,popup:a})=>{await s.respond(),e.ShowResultMessage&&a.message(e.ResultMessageText)};'
        );
    end;
}
