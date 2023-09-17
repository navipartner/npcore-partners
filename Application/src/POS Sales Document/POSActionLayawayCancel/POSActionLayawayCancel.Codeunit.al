codeunit 6150870 "NPR POS Action: Layaway Cancel" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Cancel a layaway. Fees can be posted and paid prepayment invoices will be refunded.';
        CaptionSelectCustomer: Label 'Select Customer';
        CaptionCancellationFee: Label 'Cancellation Fee';
        CaptionSkipFeeInvoice: Label 'Skip Fee Invoice';
        CaptionOrderPayTermsFilter: Label 'Order Payment Term';
        DescSelectCustomer: Label 'Prompt for customer selection if none on sale';
        DescCancellationFee: Label 'Service item to enter in order as cancellation fee';
        DescSkipFeeInvoice: Label 'Skip invoicing of all service items. Can be used to cancel layaways created by mistake, bypassing all fees.';
        DescOrderPayTermsFilter: Label 'Payment Terms to use for filtering layaway orders.';
        ConfirmInvDiscAmtLbl: Label 'Inv. Disc. Amt.';
        ConfirmInvDiscAmtDescLbl: Label 'Confirm Inv. Disc. Amt.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());

        WorkflowConfig.AddTextParameter(ParameterCancellationFee_Name(), '', CaptionCancellationFee, DescCancellationFee);
        WorkflowConfig.AddTextParameter(ParameterPaymentTerms_Name(), '', CaptionOrderPayTermsFilter, DescOrderPayTermsFilter);
        WorkflowConfig.AddBooleanParameter(ParameterSkipFee_Name(), false, CaptionSkipFeeInvoice, DescSkipFeeInvoice);//Can be used to cancel a layaway that was created by accident, where no fees should be invoiced.
        WorkflowConfig.AddBooleanParameter(ParameterSelectCustomer_Name(), true, CaptionSelectCustomer, DescSelectCustomer);
        WorkflowConfig.AddBooleanParameter(ParameterConfInvDisc_Name(), false, ConfirmInvDiscAmtLbl, ConfirmInvDiscAmtDescLbl);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionLayawayCancel.js###
'let main=async({})=>await workflow.respond("CancelLayaway");'
       )
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'CancelLayaway':
                Cancel(Context, Sale, SaleLine);
        end;
    end;

    local procedure Cancel(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line")
    var
        LayawayCancelB: Codeunit "NPR POS Act.:Layaway Cancel-B";
        CancellationFeeItemNo: Text;
        OrderPaymentTermsFilter: Text;
        SelectCustomer, SkipFeeInvoice, ConfirmInvDiscAmt : Boolean;
    begin
        CancellationFeeItemNo := Context.GetStringParameter(ParameterCancellationFee_Name());
        OrderPaymentTermsFilter := Context.GetStringParameter(ParameterPaymentTerms_Name());
        SkipFeeInvoice := Context.GetBooleanParameter(ParameterSkipFee_Name());
        SelectCustomer := Context.GetBooleanParameter(ParameterSelectCustomer_Name());
        ConfirmInvDiscAmt := Context.GetBooleanParameter(ParameterConfInvDisc_Name());

        LayawayCancelB.CancelLayaway(Sale, SaleLine, CancellationFeeItemNo, OrderPaymentTermsFilter, SelectCustomer, SkipFeeInvoice, ConfirmInvDiscAmt);

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupParameter(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        Item: Record Item;
        PaymentTerms: Record "Payment Terms";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            ParameterCancellationFee_Name():
                begin
                    Item.SetRange(Type, Item.Type::Service);
                    if PAGE.RunModal(0, Item) = ACTION::LookupOK then
                        POSParameterValue.Value := Item."No.";
                end;
            ParameterPaymentTerms_Name():
                begin
                    if PAGE.RunModal(0, PaymentTerms) = ACTION::LookupOK then
                        POSParameterValue.Value := PaymentTerms.Code;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateParameter(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        Item: Record Item;
        PaymentTerms: Record "Payment Terms";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            ParameterCancellationFee_Name():
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    Item.Get(POSParameterValue.Value);
                    Item.TestField(Type, Item.Type::Service);
                end;
            ParameterPaymentTerms_Name():
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    PaymentTerms.Get(POSParameterValue.Value);
                end;
        end;
    end;

    procedure ActionCode(): Text
    begin
        exit(Format(enum::"NPR POS Workflow"::LAYAWAY_CANCEL));
    end;

    local procedure ParameterCancellationFee_Name(): Text[30]
    begin
        exit('CancellationFeeItemNo');
    end;

    local procedure ParameterPaymentTerms_Name(): Text[30]
    begin
        exit('OrderPaymentTermsFilter');
    end;

    local procedure ParameterSkipFee_Name(): Text[30]
    begin
        exit('SkipFeeInvoice');
    end;

    local procedure ParameterSelectCustomer_Name(): Text[30]
    begin
        exit('SelectCustomer');
    end;

    local procedure ParameterConfInvDisc_Name(): Text[30]
    begin
        exit('ConfirmInvDiscAmt');
    end;
}
