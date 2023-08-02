codeunit 6150827 "NPR POS Action: Item Card" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This built in function opens the item card page for a selected sales line in the POS.';
        ParamRefreshLine_CptLbl: Label 'Refresh Line';
        ParamRefreshLine_DescLbl: Label 'Specifies if lines should be refreshed.';
        ParamPageEditable_CptLbl: Label 'Page Editable';
        ParamPageEditable_DescLbl: Label 'Specifies if the opened page should be editable or not.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddBooleanParameter('RefreshLine', true, ParamRefreshLine_CptLbl, ParamRefreshLine_DescLbl);
        WorkflowConfig.AddBooleanParameter('PageEditable', true, ParamPageEditable_CptLbl, ParamPageEditable_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        BusinessLogic: Codeunit "NPR POS Action: Item Card-B";
        POSSession: Codeunit "NPR POS Session";
        PageEditable: Boolean;
        RefreshLine: Boolean;
    begin
        if not Context.GetBooleanParameter('PageEditable', PageEditable) then
            PageEditable := false;
        if not Context.GetBooleanParameter('RefreshLine', RefreshLine) then
            RefreshLine := false;

        BusinessLogic.OpenItemPage(POSSession, PageEditable, RefreshLine);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionItemCard.js###
'let main=async({})=>await workflow.respond();'
        )
    end;
}
