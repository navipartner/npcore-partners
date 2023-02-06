codeunit 6150793 "NPR POS Action: Open Drawer" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This is a built-in action for opening the cash drawer';
        ParamCashDrawer_CaptLbl: Label 'Cash Drawer No.';
        ParamCashDrawer_DescLbl: Label 'Specify Cash Drawer No.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddTextParameter('Cash Drawer No.', '', ParamCashDrawer_CaptLbl, ParamCashDrawer_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    var
        OpenDrawerBL: Codeunit "NPR POS Action: Open Drawer B";
        CashDrawerParam: Text;
        CashDrawerNo: Code[10];
        LengthErrorLbl: Label 'Cash Drawer No. length more then 10 characters.';
    begin
        CashDrawerParam := Context.GetStringParameter('Cash Drawer No.');
        if StrLen(CashDrawerParam) > 10 then
            Error(LengthErrorLbl);

        Evaluate(CashDrawerNo, CashDrawerParam);

        OpenDrawerBL.OnActionOpenCashDrawer(Sale, Setup, CashDrawerNo);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionOpenDrawer.js###
'let main=async({})=>await workflow.respond();'
        );
    end;
}

