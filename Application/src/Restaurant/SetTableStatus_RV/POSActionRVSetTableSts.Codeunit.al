codeunit 6150685 "NPR POSAction: RV Set TableSts" implements "NPR IPOS Workflow"
{
    Access = Internal;

    internal procedure ActionCode(): Code[20]
    begin
        exit(Format("NPR POS Workflow"::RV_SET_TABLE_STATUS));
    end;

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
        Seating: Record "NPR NPRE Seating";
        BusinessLogic: Codeunit "NPR POSAct: RV Set Tabl.Stat-B";
        FrontendAssistant: Codeunit "NPR NPRE Frontend Assistant";
        NewStatusCode: Code[10];
        ParameterValueText: Text;
    begin
        if Context.GetStringParameter('StatusCode', ParameterValueText) then
            NewStatusCode := CopyStr(ParameterValueText, 1, MaxStrLen(NewStatusCode));
        Seating.Code := CopyStr(Context.GetStringParameter('SeatingCode'), 1, MaxStrLen(Seating.Code));
        Seating.Find();
        BusinessLogic.SetSeatingStatus(Seating.Code, NewStatusCode);

        FrontendAssistant.RefreshStatus(FrontEnd, Seating.GetSeatingRestaurant(), Seating."Seating Location", Seating.Code);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionRVSetTableStatus.js###
'let main=async({})=>await workflow.respond();'
        );
    end;
}
