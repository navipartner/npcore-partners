codeunit 6150847 "NPR POS Action: RunPage (Item)" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSDataMgt: Codeunit "NPR POS Data Management";
        ActionDescription: Label 'This is a built-in action for running a page.';
        ParamPageId_CptLbl: Label 'Page ID';
        ParamPageId_DescLbl: Label 'Specifies a page ID that will be opened';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.SetDataSourceBinding(POSDataMgt.POSDataSource_BuiltInSaleLine());
        WorkflowConfig.SetCustomJavaScriptLogic('enable', 'return row.getField(' + Format(SaleLinePOS.FieldNo("Line Type")) + ').rawValue == 1;');
        WorkflowConfig.AddIntegerParameter('PageId', PAGE::"Item Availability by Location", ParamPageId_CptLbl, ParamPageId_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        BusinessLogic: Codeunit "NPR POS Action: RunPageItem-B";
        POSSession: Codeunit "NPR POS Session";
        PageId: Integer;
    begin
        PageId := Context.GetIntegerParameter('PageId');
        if PageId = 0 then
            exit;

        BusinessLogic.RunPageItem(POSSession, PageId);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionRunPageItem.js###
'let main=async({})=>await workflow.respond();'
        )
    end;
}
