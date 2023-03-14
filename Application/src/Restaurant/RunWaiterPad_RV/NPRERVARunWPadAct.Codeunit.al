codeunit 6150677 "NPR NPRE RVA: Run WPad Act." implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This built-in action allows to run Waiter Pad related functions directly from Restaurant View';
        ParamWaiterPadCode_CptLbl: Label 'Waiter Pad Code';
        ParamWaiterPadCode_DescLbl: Label 'Defines waiter pad number the action is to be run upon. The parameter is set automatically by the system on the runtime.';
        ParamWaiterPadAction_OptLbl: Label 'Print Pre-Receipt,Send Kitchen Order,Request Next Serving,Request Specific Serving,Merge Waiter Pad,Open Waiter Pad', MaxLength = 250;
        ParamWaiterPadAction_NameLbl: Label 'Waiter Pad Action';
        ParamWaiterPadAction_DescLbl: Label 'Defines which waiter pad action is to be run by the POS action.';
        ParamWaiterPadAction_CaptOptLbl: Label 'Print Pre-Receipt,Send Kitchen Order,Request Next Serving,Request Specific Serving,Merge Waiter Pad,Open Waiter Pad';
        ParamLinesToSend_OptLbl: Label 'New/Updated,All', MaxLength = 250;
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
        WorkflowConfig.AddBooleanParameter('ReturnToDefaultView', false, ParamReturnToDefaultView_CptLbl, ParamReturnToDefaultView_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        POSSession: Codeunit "NPR POS Session";
        ReturnToDefaultView: Boolean;
    begin
        if not Context.GetBooleanParameter('ReturnToDefaultView', ReturnToDefaultView) then
            ReturnToDefaultView := false;

        RunWaiterPadAction(Context);

        if ReturnToDefaultView then begin
            POSSession.GetSale(Sale);
            Sale.SelectViewForEndOfSale(POSSession);
        end;
    end;

    local procedure ActionCode(): Code[20]
    begin
        exit('RV_RUN_W/PAD_ACTION');
    end;

    local procedure RunWaiterPadAction(Context: Codeunit "NPR POS JSON Helper");
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPad2: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        WPadAction: Option "Print Pre-Receipt","Send Kitchen Order","Request Next Serving","Request Specific Serving","Merge Waiter Pad","Open Waiter Pad";
        WPadLinesToSend: Option "New/Updated",All;
        ServingStepToRequest: Code[10];
        ResultMessageText: Text;
        WPadIsOpenedInPOSSale: Label 'The waiter pad is opened in a POS sale at the moment and might have unsaved changes. Are you sure you want to continue on running the action?';
    begin
        WaiterPad."No." := CopyStr(Context.GetStringParameter('WaiterPadCode'), 1, MaxStrLen(WaiterPad."No."));
        WPadAction := Context.GetIntegerParameter('WaiterPadAction');

        WaiterPad.Find();
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        WaiterPadLine.SetFilter("Sale Retail ID", '<>%1', WaiterPadPOSMgt.GetNullGuid());
        if not WaiterPadLine.IsEmpty then
            if not Confirm(WPadIsOpenedInPOSSale, false) then
                Error('');

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
                    WaiterPadMgt.MergeWaiterPad(WaiterPad, WaiterPad2);
                end;

            WPadAction::"Open Waiter Pad":
                begin
                    Page.Run(Page::"NPR NPRE Waiter Pad", WaiterPad);
                end;
        end;

        Context.SetContext('ShowResultMessage', ResultMessageText <> '');
        Context.SetContext('ResultMessageText', ResultMessageText);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', true, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean);
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

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', true, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value");
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

    local procedure LookupServingStep(var SelectedServingStep: Code[10]): Boolean;
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
        if Page.RunModal(0, FlowStatus) = Action::LookupOK then begin
            SelectedServingStep := FlowStatus.Code;
            exit(true);
        end;
        exit(false);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:NPRERVARunWPadAct.js###
'let main=async({workflow:s,context:e,popup:a})=>{await s.respond(),e.ShowResultMessage&&a.message(e.ResultMessageText)};'
        );
    end;
}
