codeunit 6150624 "NPR POS Act.Issue Return VchrB"
{
    Access = Internal;
    internal procedure ValidateAmount(VoucherTypeCodeIn: code[20]; var ReturnAmount: Decimal; PaymentLine: Codeunit "NPR POS Payment Line"; RegisterNo: Code[10]; SalesTicketNo: Code[20]; VoucherSalesLineParentId: Guid)
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        POSPaymentMethod: Record "NPR POS Payment Method";
        CurrentPOSPaymentMethod: Record "NPR POS Payment Method";
        ReturnPOSPaymentMethod: Record "NPR POS Payment Method";
        PaymentLinePOS: Record "NPR POS Sale Line";
        VoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        SaleAmount: Decimal;
        PaidAmount: Decimal;
        SubTotal: Decimal;
        Text005: Label 'Nothing to return';
        Text007: Label 'Minimum Amount for %1 %2 is %3';
    begin
        NpRvVoucherType.Get(VoucherTypeCodeIn);
        POSPaymentMethod.Get(NpRvVoucherType."Payment Type");
        ReturnPOSPaymentMethod.Get(POSPaymentMethod."Return Payment Method Code");
        PaymentLine.GetCurrentPaymentLine(PaymentLinePOS);

        VoucherMgt.GetCurrPOSPaymentMethod(VoucherTypeCodeIn, VoucherSalesLineParentId, CurrentPOSPaymentMethod);
        PaymentLine.CalculateBalance(CurrentPOSPaymentMethod, SaleAmount, PaidAmount, ReturnAmount, SubTotal);

        ReturnAmount := SaleAmount - PaidAmount;

        if POSPaymentMethod."Rounding Precision" > 0 then
            ReturnAmount := Round(SaleAmount - PaidAmount, POSPaymentMethod."Rounding Precision");
        if ReturnAmount >= 0 then
            Error(Text005);

        if POSPaymentMethod."Minimum Amount" < 0 then
            POSPaymentMethod."Minimum Amount" := 0;
        if (POSPaymentMethod."Minimum Amount" > 0) and (-ReturnAmount < POSPaymentMethod."Minimum Amount") then
            Error(Text007, POSPaymentMethod.TableCaption, POSPaymentMethod.Code, POSPaymentMethod."Minimum Amount");

        if NpRvVoucherType."Minimum Amount Issue" < 0 then
            NpRvVoucherType."Minimum Amount Issue" := 0;
        if (NpRvVoucherType."Minimum Amount Issue" > 0) and (-ReturnAmount < NpRvVoucherType."Minimum Amount Issue") then
            Error(Text007, NpRvVoucherType.TableCaption, NpRvVoucherType.Code, NpRvVoucherType."Minimum Amount Issue");

    end;

    internal procedure ValidateCapturedAmount(VoucherTypeCodeIn: code[20]; var ReturnAmt: Decimal)
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        POSPaymentMethod: Record "NPR POS Payment Method";
        Text006: Label 'The amount of %1 is less that the Minimum Amount allowed (%2) to create a Voucher';
    begin
        NpRvVoucherType.Get(VoucherTypeCodeIn);
        POSPaymentMethod.Get(NpRvVoucherType."Payment Type");

        if POSPaymentMethod."Rounding Precision" > 0 then
            ReturnAmt := Round(ReturnAmt, POSPaymentMethod."Rounding Precision");

        if NpRvVoucherType."Minimum Amount Issue" < 0 then
            NpRvVoucherType."Minimum Amount Issue" := 0;
        if ReturnAmt < NpRvVoucherType."Minimum Amount Issue" then
            Error(Text006, ReturnAmt, NpRvVoucherType."Minimum Amount Issue");
    end;

    procedure FindSendMethod(POSSale: Codeunit "NPR POS Sale"; var Email: Text; var PhoneNo: Text)
    var
        Customer: Record Customer;
        SalePOS: Record "NPR POS Sale";
    begin
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Customer No." = '' then
            exit;

        if Customer.Get(SalePOS."Customer No.") then begin
            Email := Customer."E-Mail";
            PhoneNo := Customer."Phone No.";
        end;

    end;

    internal procedure EndSale(VoucherTypeCode: Text; Sale: codeunit "NPR POS Sale"; PaymentLine: codeunit "NPR POS Payment Line"; SaleLine: codeunit "NPR POS Sale Line"; Setup: codeunit "NPR POS Setup")
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        POSPaymentMethod: Record "NPR POS Payment Method";
        ReturnPOSPaymentMethod: Record "NPR POS Payment Method";
        POSSession: Codeunit "NPR POS Session";
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SaleAmount: Decimal;
        Subtotal: Decimal;
    begin
        PaymentLine.CalculateBalance(SaleAmount, PaidAmount, ReturnAmount, Subtotal);

        if Abs(Subtotal) > Abs(Setup.AmountRoundingPrecision()) then
            exit;

        NpRvVoucherType.Get(VoucherTypeCode);
        if not POSPaymentMethod.Get(NpRvVoucherType."Payment Type") then
            exit;
        if not ReturnPOSPaymentMethod.Get(POSPaymentMethod."Return Payment Method Code") then
            exit;
        if PaymentLine.CalculateRemainingPaymentSuggestion(SaleAmount, PaidAmount, POSPaymentMethod, ReturnPOSPaymentMethod, false) <> 0 then
            exit;
        if not Sale.TryEndDirectSaleWithBalancing(POSSession, POSPaymentMethod, ReturnPOSPaymentMethod) then
            exit;
    end;

    procedure ContactInfo(SaleLinePOS: Record "NPR POS Sale Line")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        NpRvSalesLine.SetRange("Register No.", SaleLinePOS."Register No.");
        NpRvSalesLine.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        NpRvSalesLine.SetRange("Sale Date", SaleLinePOS.Date);
        NpRvSalesLine.SetRange("Sale Line No.", SaleLinePOS."Line No.");
        if not NpRvSalesLine.FindSet() then
            exit;

        repeat
            Page.RunModal(Page::"NPR NpRv Sales Line Card", NpRvSalesLine);
            Commit();
        until NpRvSalesLine.Next() = 0;
    end;

    procedure ScanReferenceNos(SaleLinePOS: Record "NPR POS Sale Line"; Quantity: Decimal)
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvSalesLineReferences: Page "NPR NpRv Sales Line Ref.";
    begin
        if not GuiAllowed then
            exit;

        NpRvSalesLine.SetRange("Retail ID", SaleLinePOS.SystemId);
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::"New Voucher");
        if not NpRvSalesLine.FindFirst() then
            exit;

        NpRvSalesLineReferences.SetNpRvSalesLine(NpRvSalesLine, Quantity);
        NpRvSalesLineReferences.RunModal();
    end;

}
