codeunit 6150726 "NPR POSAction: Ins. Customer" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This is a built-in action for setting a customer on the current transaction';
        ParamCardPageId_NameCaptionLbl: Label 'CardPageId';
        ParamCardPageId_DescrptionLbl: Label 'Card Page Id';
#if not BC17
        ParamUseCustTemplate_CaptionLbl: Label 'Use a Customer Template';
        ParamUseCustTemplate_DescLbl: Label 'Use a template for a new customer';
        ParamCustTemplate_CaptionLbl: Label 'Select a Customer Template Code';
        ParamCustTemplate_DescLbl: Label 'Select a default template for a new customer';
#endif
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddIntegerParameter(ParameterCardPageId_Name(), 0, ParamCardPageId_NameCaptionLbl, ParamCardPageId_DescrptionLbl);
#if not BC17
        WorkflowConfig.AddBooleanParameter('UseCustTemplate', false, ParamUseCustTemplate_CaptionLbl, ParamUseCustTemplate_DescLbl);
        WorkflowConfig.AddTextParameter('CustTemplateCode', '', ParamCustTemplate_CaptionLbl, ParamCustTemplate_DescLbl);
#endif
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        SalePOS: Record "NPR POS Sale";
        PosActionBusinessLogic: Codeunit "NPR POSAction: Ins. Customer-B";
        CardPageId: Integer;
#if not BC17
        UseCustTempl: Boolean;
        CustTemplateCode: Code[20];
#endif
    begin
        CardPageId := Context.GetIntegerParameter(ParameterCardPageId_Name());
#if not BC17
        UseCustTempl := Context.GetBooleanParameter('UseCustTemplate');
#pragma warning disable AA0139
        CustTemplateCode := Context.GetStringParameter('CustTemplateCode');
#pragma warning restore
#endif
        Sale.GetCurrentSale(SalePOS);
#if not BC17
        PosActionBusinessLogic.OnActionCreateCustomer(CardPageId, SalePOS, UseCustTempl, CustTemplateCode);
#else
        PosActionBusinessLogic.OnActionCreateCustomer(CardPageId, SalePOS, false, '');
#endif
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

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupValueParameter(var POSParameterValue: Record "NPR POS Parameter Value")
    var
#if not BC17
        CustomerTempl: Record "Customer Templ.";
#endif
    begin
        if POSParameterValue."Action Code" <> 'INSERT_CUSTOMER' then
            exit;
#if not BC17
        case POSParameterValue.Name of
            'CustTemplateCode':
                begin
                    if PAGE.RunModal(0, CustomerTempl) = ACTION::LookupOK then
                        POSParameterValue.Value := CustomerTempl.Code;
                end;
        end;
#endif
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
#if not BC17
        CustomerTempl: Record "Customer Templ.";
#endif
    begin
        if POSParameterValue."Action Code" <> 'INSERT_CUSTOMER' then
            exit;
#if not BC17
        case POSParameterValue.Name of
            'CustTemplateCode':
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    CustomerTempl.Code := CopyStr(POSParameterValue.Value, 1, MaxStrLen(CustomerTempl.Code));
                    CustomerTempl.Find();
                end;
        end;
#endif
    end;

}

