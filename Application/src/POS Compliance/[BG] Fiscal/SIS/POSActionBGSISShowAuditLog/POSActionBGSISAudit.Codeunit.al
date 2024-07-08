codeunit 6184626 "NPR POS Action: BG SIS Audit" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This is a built-in action for showing BG Audit Log data.';
        ParamShowNameCaptionLbl: Label 'Show';
        ParamShowNameDescriptionLbl: Label 'Specifies the type of BG Audit Log related data you want to display.';
        ParamShowOptionCaptionsLbl: Label 'All,All Fiscalized,All Non-Fiscalized,Last Transaction';
        ParamShowOptionsLbl: Label 'All,AllFiscalized,AllNonFiscalized,LastTransaction', Locked = true;
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddOptionParameter('Show', ParamShowOptionsLbl, '', ParamShowNameCaptionLbl, ParamShowNameDescriptionLbl, ParamShowOptionCaptionsLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        ShowBGSISAuditLog(Context.GetIntegerParameter('Show'));
    end;

    local procedure ShowBGSISAuditLog(Show: Option All,AllFiscalized,AllNonFiscalized,LastTransaction)
    var
        POSActionBGSISAuditB: Codeunit "NPR POS Action: BG SIS Audit B";
    begin
        POSActionBGSISAuditB.ShowBGSISAuditLog(Show);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionBGSISAudit.js###
'let main=async({})=>await workflow.respond();'
        )
    end;
}
