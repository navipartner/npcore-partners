codeunit 6150684 "NPR NPRE RVA: Set WPad Status" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This built-in action sets Waiter Pad status/serving step from Restaurant View';
        ParamWaiterPadCode_CptLbl: Label 'Waiter Pad Code';
        ParamWaiterPadCode_DescLbl: Label 'Selected waiter pad code.';
        ParamStatusCode_CptLbl: Label 'Status Code';
        ParamStatusCode_DescLbl: Label 'Selected table status.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddTextParameter('WaiterPadCode', '', ParamWaiterPadCode_CptLbl, ParamWaiterPadCode_DescLbl);
        WorkflowConfig.AddTextParameter('StatusCode', '', ParamStatusCode_CptLbl, ParamStatusCode_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        FlowStatus: Record "NPR NPRE Flow Status";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        NewStatusParamValue: Text;
        NewStatusCode: Code[10];
        ResultMessageText: Text;
    begin
        WaiterPad."No." := CopyStr(Context.GetStringParameter('WaiterPadCode'), 1, MaxStrLen(WaiterPad."No."));
        if not Context.GetStringParameter('StatusCode', NewStatusParamValue) or (NewStatusParamValue = '') then
            exit;

        NewStatusCode := CopyStr(NewStatusParamValue, 1, MaxStrLen(NewStatusCode));

        WaiterPad.Find();

        FlowStatus.SetRange("Status Object", FlowStatus."Status Object"::WaiterPad, FlowStatus."Status Object"::WaiterPadLineMealFlow);
        FlowStatus.SetRange(Code, NewStatusCode);
        FlowStatus.FindFirst();
        if FlowStatus."Status Object" = FlowStatus."Status Object"::WaiterPadLineMealFlow then begin
            ResultMessageText := RestaurantPrint.RequestRunServingStepToKitchen(WaiterPad, false, NewStatusCode);
            Context.SetContext('ShowResultMessage', ResultMessageText <> '');
            Context.SetContext('ResultMessageText', ResultMessageText);
        end else begin
            WaiterPad.Status := NewStatusCode;
            WaiterPad.Modify();
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:NPRERVASetWPadStatus.js###
'let main=async({workflow:s,context:e,popup:a})=>{await s.respond(),e.ShowResultMessage&&a.message(e.ResultMessageText)};'
        );
    end;
}
