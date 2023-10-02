codeunit 6150726 "NPR POSAction: Ins. Customer" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This is a built-in action for setting a customer on the current transaction';
        ParamCardPageId_NameCaptionLbl: Label 'CardPageId';
        ParamCardPageId_DescrptionLbl: Label 'Card Page Id';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddIntegerParameter(ParameterCardPageId_Name(), 0, ParamCardPageId_NameCaptionLbl, ParamCardPageId_DescrptionLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        SalePOS: Record "NPR POS Sale";
        PosActionBusinessLogic: Codeunit "NPR POSAction: Ins. Customer-B";
        CardPageId: Integer;
    begin
        CardPageId := Context.GetIntegerParameter(ParameterCardPageId_Name());

        Sale.GetCurrentSale(SalePOS);
        PosActionBusinessLogic.OnActionCreateCustomer(CardPageId, SalePOS);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionCustInsert.js###
'let main=async({})=>await workflow.respond();'
        );
    end;

    local procedure ParameterCardPageId_Name(): Text[30]
    begin
        exit('CardPageId');
    end;
}

