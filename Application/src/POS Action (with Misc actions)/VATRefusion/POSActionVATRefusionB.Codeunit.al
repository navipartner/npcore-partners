codeunit 6150643 "NPR POSAction: VAT Refusion-B"
{
    Access = Internal;

    procedure DoRefusion(POSSession: Codeunit "NPR POS Session"; PaymentTypeCode: Code[10]; AmountInclVAT: Decimal)
    var
        PaymentLinePOS: Record "NPR POS Sale Line";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        Setup: Codeunit "NPR POS Setup";
    begin
        POSSession.GetSetup(Setup);

        //Get payment type
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.GetPOSPaymentMethod(POSPaymentMethod, PaymentTypeCode);
        POSPaymentMethod.Get(POSPaymentMethod.Code);

        //Get amount and add to payment line
        PaymentLinePOS."No." := POSPaymentMethod.Code;
        PaymentLinePOS."Amount Including VAT" := AmountInclVAT;
        POSPaymentLine.InsertPaymentLine(PaymentLinePOS, 0);
    end;

    procedure CalcVATFromSale(SalePOS: Record "NPR POS Sale"): Decimal
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        if SaleLinePOS.IsEmpty() then
            exit;

        SaleLinePOS.CalcSums("Amount Including VAT", "VAT Base Amount");
        exit(SaleLinePOS."Amount Including VAT" - SaleLinePOS."VAT Base Amount");
    end;

    procedure ValidateMinMaxAmount(NPRPOSPaymentMethod: Record "NPR POS Payment Method"; AmountToCapture: Decimal)
    var
        MaxAmountLimit: Label 'Maximum payment amount for %1 is %2.';
    begin

        if (NPRPOSPaymentMethod."Maximum Amount" <> 0) then
            if (AmountToCapture > NPRPOSPaymentMethod."Maximum Amount") then
                Error(MaxAmountLimit, NPRPOSPaymentMethod.Description, NPRPOSPaymentMethod."Maximum Amount");

        if (NPRPOSPaymentMethod."Minimum Amount" <> 0) then
            if (AmountToCapture < NPRPOSPaymentMethod."Minimum Amount") then
                Error(MaxAmountLimit, NPRPOSPaymentMethod.Description, NPRPOSPaymentMethod."Minimum Amount");
    end;
}

