codeunit 6150871 "NPR POS Action: LayawayShow" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Show layaway orders and all associated prepayment invoices';
        CaptionSelectCustomer: Label 'Select Customer';
        CaptionOrderPayTermsFilter: Label 'Order Payment Term';
        DescOrderPayTermsFilter: Label 'Payment Terms to use for filtering layaway orders.';
        DescSelectCustomer: Label 'Prompt for customer selection if none on sale';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddBooleanParameter(ParameterSelectCustomer_Name(), true, CaptionSelectCustomer, DescSelectCustomer);
        WorkflowConfig.AddTextParameter(ParameterOrderPayTermsFilter_Name(), '', CaptionOrderPayTermsFilter, DescOrderPayTermsFilter);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionLayawayShow.js###
'let main=async({})=>await workflow.respond("ShowLayawayInvoices");'
                );
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'ShowLayawayInvoices':
                OnActionShowDocuments(Context, Sale);
        end;
    end;

    procedure OnActionShowDocuments(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale")
    var
        LayawayShowB: Codeunit "NPR POS Action: LayawayShow-B";
        SelectCustomer: Boolean;
        OrderPaymentTerms: Text;
    begin
        OrderPaymentTerms := Context.GetStringParameter(ParameterOrderPayTermsFilter_Name());
        SelectCustomer := Context.GetBooleanParameter(ParameterSelectCustomer_Name());
        LayawayShowB.RunDocument(SelectCustomer, OrderPaymentTerms, Sale);
    end;

    procedure ActionCode(): Text
    begin
        exit(Format(enum::"NPR POS Workflow"::LAYAWAY_SHOW));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupParameter(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        PaymentTerms: Record "Payment Terms";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            ParameterOrderPayTermsFilter_Name():
                begin
                    if PAGE.RunModal(0, PaymentTerms) = ACTION::LookupOK then
                        POSParameterValue.Value := PaymentTerms.Code;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateParameter(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        PaymentTerms: Record "Payment Terms";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            ParameterOrderPayTermsFilter_Name():
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    PaymentTerms.Get(POSParameterValue.Value);
                end;
        end;
    end;

    local procedure ParameterOrderPayTermsFilter_Name(): Text[30]
    begin
        exit('OrderPaymentTermsFilter');
    end;

    local procedure ParameterSelectCustomer_Name(): Text[30]
    begin
        exit('SelectCustomer');
    end;
}

