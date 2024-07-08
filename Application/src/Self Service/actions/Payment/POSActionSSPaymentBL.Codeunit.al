codeunit 6151482 "NPR POS Action: SS Payment BL"
{
    Access = Internal;
    internal procedure PrepareForPayment(PaymentLine: Codeunit "NPR POS Payment Line"; PaymentMethodCode: Code[10]; var WorkflowNameOut: Code[20]; var POSPaymentMethodOut: Record "NPR POS Payment Method"; var AmountOut: Decimal)
    var
        ReturnPOSPaymentMethod: Record "NPR POS Payment Method";
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
    begin
        POSPaymentMethodOut.Get(PaymentMethodCode);
        ReturnPOSPaymentMethod.Get(POSPaymentMethodOut."Return Payment Method Code");
        POSPaymentMethodOut.TestField("Block POS Payment", false);
        ReturnPOSPaymentMethod.TestField("Block POS Payment", false);

        // TODO: Add a payment interface specifically for selfservice as it will have less options and each of them will have a different workflow.
        // For now hardcoding this to EFT.        
        // (same flow normal payment uses)
        case POSPaymentMethodOut."Processing Type" of
            POSPaymentMethodOut."Processing Type"::CASH:
                WorkflowNameOut := Format(Enum::"NPR POS Workflow"::SS_PAYMENT_CASH);
            POSPaymentMethodOut."Processing Type"::EFT:
                WorkflowNameOut := Format(Enum::"NPR POS Workflow"::SS_EFT);
            else
                Error('Unsupported payment method');
        end;

        PaymentLine.CalculateBalance(POSPaymentMethodOut, SalesAmount, PaidAmount, ReturnAmount, SubTotal);
        AmountOut := PaymentLine.CalculateRemainingPaymentSuggestion(SalesAmount, PaidAmount, POSPaymentMethodOut, ReturnPOSPaymentMethod, true);
    end;

    internal procedure AttemptEndCurrentSale(PaymentMethodCode: Code[10]): Boolean
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        ReturnPOSPaymentMethod: Record "NPR POS Payment Method";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
    begin
        POSPaymentMethod.Get(PaymentMethodCode);
        POSPaymentMethod.TestField("Block POS Payment", false);
        if (not POSPaymentMethod."Auto End Sale") then
            exit(false);

        ReturnPOSPaymentMethod.Get(POSPaymentMethod."Return Payment Method Code");
        ReturnPOSPaymentMethod.TestField("Block POS Payment", false);

        POSSession.GetSale(POSSale);
        exit(POSSale.TryEndDirectSaleWithBalancing(POSSession, POSPaymentMethod, ReturnPOSPaymentMethod));
    end;
}