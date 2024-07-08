codeunit 6184574 "NPR POSAction SS InitSale" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'SelfService Initialize Sale';
        ParamSaleIdentifierTitle: Label 'Sale Identifier';
        ParamSaleIdentifierDesc: Label 'The identifier of the sale to be created';
        ParamSalesPersonTitle: Label 'Sales Person Code';
        ParamSalesPersonDesc: Label 'Specifies Sales Person Code';
        ParamLanguageCodeTitle: Label 'Language Code';
        ParamLanguageCodeDesc: Label 'Specifies Language Code';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.SetWorkflowTypeUnattended();
        WorkflowConfig.AddTextParameter('saleSystemId', '', ParamSaleIdentifierTitle, ParamSaleIdentifierDesc);
        WorkflowConfig.AddTextParameter('SalespersonCode', '', ParamSalesPersonTitle, ParamSalesPersonDesc);
        WorkflowConfig.AddTextParameter('LanguageCode', '', ParamLanguageCodeTitle, ParamLanguageCodeDesc);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        SelfServiceBl: Codeunit "NPR SS InitializeSelfServiceBl";
        CurrentSalesId: Guid;
        SalespersonCode: Code[20];
        LanguageCode: Code[10];
    begin
        SalesPersonCode := CopyStr(Context.GetStringParameter('SalespersonCode'), 1, MaxStrLen(SalespersonCode));
        LanguageCode := CopyStr(Context.GetStringParameter('LanguageCode'), 1, MaxStrLen(LanguageCode));
        Evaluate(CurrentSalesId, Context.GetStringParameter('saleSystemId'));

        FrontEnd.WorkflowResponse(SelfServiceBl.Initialize(CurrentSalesId, SalesPersonCode, LanguageCode));
    end;


    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionSSInitSale.js###
'let main=async({workflow:e})=>{let i=await e.respond("")};'
        );
    end;
}
