codeunit 6059778 "NPR POS Action: Payment WF2 BL"
{
    Access = Internal;
    internal procedure PrepareForPayment(PaymentLine: Codeunit "NPR POS Payment Line"; PaymentMethodCode: Code[10]; var WorkflowNameOut: Code[20]; var POSPaymentMethodOut: Record "NPR POS Payment Method"; var AmountOut: Decimal)
    var
        ReturnPOSPaymentMethod: Record "NPR POS Payment Method";
        PaymentLinePOS: Record "NPR POS Sale Line";
        PaymentProcessingEvents: Codeunit "NPR Payment Processing Events";
        IProcessingType: Interface "NPR POS IPaymentWFHandler";
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
    begin
        POSPaymentMethodOut.Get(PaymentMethodCode);
        ReturnPOSPaymentMethod.Get(POSPaymentMethodOut."Return Payment Method Code");
        POSPaymentMethodOut.TestField("Block POS Payment", false);
        ReturnPOSPaymentMethod.TestField("Block POS Payment", false);

        IProcessingType := POSPaymentMethodOut."Processing Type";
        WorkflowNameOut := IProcessingType.GetPaymentHandler();

        PaymentLine.CalculateBalance(POSPaymentMethodOut, SalesAmount, PaidAmount, ReturnAmount, SubTotal);
        AmountOut := PaymentLine.CalculateRemainingPaymentSuggestion(SalesAmount, PaidAmount, POSPaymentMethodOut, ReturnPOSPaymentMethod, true);
        PaymentLine.GetPaymentLine(PaymentLinePOS);
        PaymentProcessingEvents.OnAfterCalculateSuggestionPaymentAmount(PaymentLinePOS."Sales Ticket No.", SalesAmount, PaidAmount, POSPaymentMethodOut, ReturnPOSPaymentMethod, AmountOut);
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