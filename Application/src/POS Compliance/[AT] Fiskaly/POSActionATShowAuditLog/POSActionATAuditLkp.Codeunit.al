codeunit 6184906 "NPR POS Action: AT Audit Lkp" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This is a built-in action for showing AT Audit Log data.';
        ParamShowNameCaptionLbl: Label 'Show';
        ParamShowNameDescriptionLbl: Label 'Specifies the type of AT Audit Log related data you want to display.';
        ParamShowOptionCaptionsLbl: Label 'All,All Signed,All Non-Signed,Last Transaction';
        ParamShowOptionsLbl: Label 'All,AllSigned,AllNonSigned,LastTransaction', Locked = true;
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddOptionParameter('Show', ParamShowOptionsLbl, '', ParamShowNameCaptionLbl, ParamShowNameDescriptionLbl, ParamShowOptionCaptionsLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        ShowATAuditLog(Context.GetIntegerParameter('Show'));
    end;

    local procedure ShowATAuditLog(Show: Option All,AllSigned,AllNonSigned,LastTransaction)
    var
        POSActionATAuditLkpB: Codeunit "NPR POS Action: AT Audit Lkp B";
    begin
        POSActionATAuditLkpB.ShowATAuditLog(Show);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionATAuditLkp.js###
'let main=async({})=>await workflow.respond();'
        )
    end;
}
