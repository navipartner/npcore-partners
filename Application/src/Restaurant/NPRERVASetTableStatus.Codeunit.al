codeunit 6150685 "NPR NPRE RVA: Set Table Status" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This built-in action sets table (seating) status from Restaurant View';
        ParamSeatingCode_CptLbl: Label 'Seating Code';
        ParamSeatingCode_DescLbl: Label 'Selected seating code.';
        ParamStatusCode_CptLbl: Label 'Status Code';
        ParamStatusCode_DescLbl: Label 'Selected table status.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddTextParameter('SeatingCode', '', ParamSeatingCode_CptLbl, ParamSeatingCode_DescLbl);
        WorkflowConfig.AddTextParameter('StatusCode', '', ParamStatusCode_CptLbl, ParamStatusCode_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        FlowStatus: Record "NPR NPRE Flow Status";
        SeatingMgt: Codeunit "NPR NPRE Seating Mgt.";
        NewStatusCode: Code[10];
        SeatingCode: Code[20];
        ResultOut: Text;
    begin
        SeatingCode := CopyStr(Context.GetStringParameter('SeatingCode'), 1, MaxStrLen(SeatingCode));
        if not (Context.GetStringParameter('StatusCode', ResultOut)) then
            ResultOut := '';

        NewStatusCode := CopyStr(ResultOut, 1, MaxStrLen(NewStatusCode));

        if NewStatusCode = '' then
            exit;

        FlowStatus.SetRange("Status Object", FlowStatus."Status Object"::Seating);
        FlowStatus.SetRange(Code, NewStatusCode);
        FlowStatus.FindFirst();

        SeatingMgt.SetSeatingStatus(SeatingCode, NewStatusCode);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:NPRERVASetTableStatus.js###
'let main=async({})=>await workflow.respond();'
        );
    end;
}
