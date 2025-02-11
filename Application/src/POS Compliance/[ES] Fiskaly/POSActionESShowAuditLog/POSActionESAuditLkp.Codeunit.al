codeunit 6184979 "NPR POS Action: ES Audit Lkp" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This is a built-in action for showing ES Audit Log data.';
        ParamShowNameCaptionLbl: Label 'Show';
        ParamShowNameDescriptionLbl: Label 'Specifies the type of ES Audit Log related data you want to display.';
        ParamShowOptionCaptionsLbl: Label 'All,All Registered,All Non-Registered,Last Transaction';
        ParamShowOptionsLbl: Label 'All,AllRegistered,AllNonRegistered,LastTransaction', Locked = true;
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddOptionParameter('Show', ParamShowOptionsLbl, '', ParamShowNameCaptionLbl, ParamShowNameDescriptionLbl, ParamShowOptionCaptionsLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        ShowESAuditLog(Context.GetIntegerParameter('Show'));
    end;

    local procedure ShowESAuditLog(Show: Option All,AllRegistered,AllNonRegistered,LastTransaction)
    var
        POSActionESAuditLkpB: Codeunit "NPR POS Action: ES Audit Lkp B";
    begin
        POSActionESAuditLkpB.ShowESAuditLog(Show);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionESAuditLkp.js###
'let main=async({})=>await workflow.respond();'
        )
    end;
}
