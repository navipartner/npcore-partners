codeunit 6150869 "NPR POS Action: Layaway Pay" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Pay a layaway prepayment invoice';
        CaptionSelectCustomer: Label 'Select Customer';
        CaptionOrderPayTermsFilter: Label 'Payment Terms Filter';
        CaptionSelectionMethod: Label 'Selection Method';
        DescSelectCustomer: Label 'Prompt for customer selection if none on sale';
        DescOrderPayTermsFilter: Label 'Filter on payment terms for open sales orders.';
        DescSelectionMethod: Label 'Select next prepayment invoice to pay based on due date or manually select from list';
        OptionSelectionMethod: Label 'Next Due,List', Locked = true;
        OptionSelectionCaption: Label 'Next Due,List';
        ConfirmInvDiscAmtLbl: Label 'Inv. Disc. Amt.';
        ConfirmInvDiscAmtDescLbl: Label 'Confirm Inv. Disc. Amt.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());

        WorkflowConfig.AddTextParameter('OrderPaymentTermsFilter', '', CaptionOrderPayTermsFilter, DescOrderPayTermsFilter);
        WorkflowConfig.AddBooleanParameter('SelectCustomer', true, CaptionSelectCustomer, DescSelectCustomer);
        WorkflowConfig.AddBooleanParameter('ConfirmInvDiscAmt', false, ConfirmInvDiscAmtLbl, ConfirmInvDiscAmtDescLbl);
        WorkflowConfig.AddOptionParameter(
            'SelectionMethod',
            OptionSelectionMethod,
#pragma warning disable AA0139
            SelectStr(1, OptionSelectionMethod),
# pragma warning restore
            CaptionSelectionMethod,
            DescSelectionMethod,
            OptionSelectionCaption);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionLayawayPay.js###
'let main=async({})=>await workflow.respond("PayLayawayInvoice");'
        );
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        FrontEnd.GetSession(POSSession);
        case Step of
            'PayLayawayInvoice':
                OnActionPayLayaway(Context, POSSession);
        end;
    end;

    procedure ActionCode(): Text
    begin
        exit(Format(Enum::"NPR POS Workflow"::LAYAWAY_PAY));
    end;

    local procedure OnActionPayLayaway(Context: Codeunit "NPR POS JSON Helper"; var POSSession: Codeunit "NPR POS Session")
    var
        LayawayPayBusLogic: Codeunit "NPR POS Action: Layaway Pay-B";
        OrderPaymentTermsFilter: Text;
        SelectionMethod: Integer;
        SelectCustomer, ConfirmInvDiscAmt : Boolean;
        POSSalesDocumentPost: Enum "NPR POS Sales Document Post";
    begin
        OrderPaymentTermsFilter := Context.GetStringParameter('OrderPaymentTermsFilter');
        SelectionMethod := Context.GetIntegerParameter('SelectionMethod');
        SelectCustomer := Context.GetBooleanParameter('SelectCustomer');
        ConfirmInvDiscAmt := Context.GetBooleanParameter('ConfirmInvDiscAmt');
        POSSalesDocumentPost := POSSalesDocumentPost::Synchronous;

        LayawayPayBusLogic.PayLayaway(POSSession, OrderPaymentTermsFilter, SelectionMethod, SelectCustomer, ConfirmInvDiscAmt, POSSalesDocumentPost);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupParameter(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        PaymentTerms: Record "Payment Terms";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'OrderPaymentTermsFilter':
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
            'OrderPaymentTermsFilter':
                begin
                    if POSParameterValue.Value <> '' then
                        PaymentTerms.Get(POSParameterValue.Value);
                end;
        end;
    end;
}

