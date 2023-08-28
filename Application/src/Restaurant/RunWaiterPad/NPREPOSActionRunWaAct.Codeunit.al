codeunit 6150676 "NPR NPRE POSAction: Run Wa.Act" implements "NPR IPOS Workflow"
{
    Access = Internal;

    local procedure ActionCode(): Code[20]
    begin
        exit(Format("NPR POS Workflow"::"RUN_W/PAD_ACTION"));
    end;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This built-in action allows to run Waiter Pad related functions directly from Sales View';
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
    var
        BusinessLogic: Codeunit "NPR NPRE POSAction: Run WAct-B";
        WPadAction: Option "Print Pre-Receipt","Send Kitchen Order","Request Next Serving","Request Specific Serving","Merge Waiter Pad","Close w/out Saving";
        WPadLinesToSend: Option "New/Updated",All;
        ServingStepToRequest: Code[10];
        NewWaiterPadNo: Code[20];
        CleanupMessageText: Text;
        ResultMessageText: Text;
        ClearSaleOnFinish: Boolean;
        ReturnToDefaultView: Boolean;
    begin
        WPadAction := Context.GetIntegerParameter('WaiterPadAction');
        if not Context.GetBooleanParameter('MoveSaleToWPadOnFinish', ClearSaleOnFinish) then
            ClearSaleOnFinish := false;
        if not Context.GetBooleanParameter('ReturnToDefaultView', ReturnToDefaultView) then
            ReturnToDefaultView := false;
        if ReturnToDefaultView then
            ClearSaleOnFinish := true;

        case Step of
            'runMainAction':
                begin
                    case WPadAction of
                        WPadAction::"Send Kitchen Order":
                            WPadLinesToSend := Context.GetIntegerParameter('LinesToSend');
                        WPadAction::"Request Specific Serving":
                            ServingStepToRequest := CopyStr(Context.GetStringParameter('ServingStep'), 1, MaxStrLen(ServingStepToRequest));
                    end;

                    FrontEnd.WorkflowResponse(
                        BusinessLogic.RunWaiterPadAction(
                            WPadAction, WPadLinesToSend, ServingStepToRequest, ClearSaleOnFinish, Sale, SaleLine, NewWaiterPadNo, ResultMessageText, CleanupMessageText));

                    IF WPadAction = WPadAction::"Merge Waiter Pad" then
                        Context.SetContext('NewWaiterPadNo', NewWaiterPadNo);
                    Context.SetContext('ShowResultMessage', ResultMessageText <> '');
                    Context.SetContext('ResultMessageText', ResultMessageText);
                    if CleanupMessageText <> '' then
                        Context.SetContext('CleanupMessageText', CleanupMessageText);
                end;

            'runCleanup':
                begin
                    if (WPadAction = WPadAction::"Merge Waiter Pad") and not ClearSaleOnFinish then
                        NewWaiterPadNo := CopyStr(Context.GetString('NewWaiterPadNo'), 1, MaxStrLen(NewWaiterPadNo));
                    BusinessLogic.CleanupSale(WPadAction, NewWaiterPadNo, ClearSaleOnFinish, Sale, SaleLine);
                    if ReturnToDefaultView then
                        Sale.SelectViewForEndOfSale();
                end;
        end;
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
        //###NPR_INJECT_FROM_FILE:NPREPOSActionRunWaAct.js###
'let main=async({workflow:s,context:e,popup:a})=>{let i=await s.respond("runMainAction");if(e.ShowResultMessage&&await a.message(e.ResultMessageText),e.CleanupMessageText)if(i){if(!await a.confirm(e.CleanupMessageText))return}else{a.error(e.CleanupMessageText);return}await s.respond("runCleanup")};'
        );
    end;
}
