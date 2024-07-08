codeunit 6184602 "NPR POS Action: SIAudit Lkp" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This is a built-in action for displaying RS Audit transactions log.';
        ParameterShow_NameCaptionLbl: Label 'Show';
        ParameterShow_NameDescriptionLbl: Label 'Specifies the type of RS Audit related data you want to display.';
        ParameterShow_OptionCaptionsLbl: Label 'All,All Fiscalised,All Non-Fiscalised,Last Transaction';
        ParameterShow_OptionsLbl: Label 'All,AllFiscalised,AllNonFiscalised,LastTransaction', Locked = true;
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddOptionParameter(
            ParameterShow_Name(),
            ParameterShow_OptionsLbl,
#pragma warning disable AA0139
            SelectStr(1, ParameterShow_OptionsLbl),
#pragma warning restore
            ParameterShow_NameCaptionLbl,
            ParameterShow_NameDescriptionLbl,
            ParameterShow_OptionCaptionsLbl
        );
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionSIAuditLookUp.js###
'let main=async({})=>await workflow.respond();'
        )
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        POSActionSIAuditLkpB: Codeunit "NPR POS Action: SIAudit Lkp-B";
        ParameterShow: Option All,AllFiscalised,AllNonFiscalised,LastTransaction;
    begin
        ParameterShow := Context.GetIntegerParameter(ParameterShow_Name());
        POSActionSIAuditLkpB.ProcessRequest(ParameterShow);
    end;

    local procedure ParameterShow_Name(): Text[30]
    begin
        exit('Show');
    end;


}
