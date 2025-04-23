codeunit 6150631 "NPR POS Action Scan Voucher2B"
{
    Access = Internal;
    internal procedure SetReferenceNo(VoucherTypeCode: Code[20]): Text
    var
        Voucher: Record "NPR NpRv Voucher";
        NpRvVouchers: Page "NPR NpRv Vouchers";
        ReferenceNo: Text;
        BlankReferenceNoErr: Label 'Reference No. can''t be blank';
    begin
        Voucher.SetCurrentKey("Voucher Type");
        Voucher.SetRange("Voucher Type", VoucherTypeCode);
        Voucher.SetRange(Open, true);

        Clear(NpRvVouchers);
        NpRvVouchers.LookupMode := true;
        NpRvVouchers.SetTableView(Voucher);
        if NpRvVouchers.RunModal() = Action::LookupOK then begin
            NpRvVouchers.GetRecord(Voucher);
            ReferenceNo := CopyStr(Voucher."Reference No.", 1, MaxStrLen(Voucher."Reference No."));
        end;
        if ReferenceNo = '' then
            Error(BlankReferenceNoErr);
        exit(ReferenceNo);

    end;

    internal procedure ProcessPayment(VoucherTypeCode: Code[20]; VoucherNumber: Text; SuggestedAmount: Decimal; Sale: Codeunit "NPR POS Sale"; PaymentLine: Codeunit "NPR POS Payment Line"; SaleLine: Codeunit "NPR POS Sale Line"; ParamEndSale: Boolean; var ActionContext: JsonObject)
    var
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        SalePOS: Record "NPR POS Sale";
        POSLine: Record "NPR POS Sale Line";
        POSSession: Codeunit "NPR POS Session";
    begin
        Sale.GetCurrentSale(SalePOS);
        PaymentLine.GetPaymentLine(POSLine);

        NpRvVoucherMgt.ApplyVoucherPayment(VoucherTypeCode, VoucherNumber, SuggestedAmount, POSLine, SalePOS, POSSession, PaymentLine, POSLine, ParamEndSale, ActionContext);
    end;

    internal procedure ProcessPayment(VoucherTypeCode: Code[20]; VoucherNumber: Text; Sale: Codeunit "NPR POS Sale"; PaymentLine: Codeunit "NPR POS Payment Line"; SaleLine: Codeunit "NPR POS Sale Line"; ParamEndSale: Boolean; var ActionContext: JsonObject)
    begin
        ProcessPayment(VoucherTypeCode,
                       VoucherNumber,
                       0,
                       Sale,
                       PaymentLine,
                       SaleLine,
                       ParamEndSale,
                       ActionContext)
    end;

    internal procedure EndSale(VoucherTypeCode: Text; Sale: Codeunit "NPR POS Sale"; PaymentLine: Codeunit "NPR POS Payment Line"; SaleLine: Codeunit "NPR POS Sale Line"; Setup: Codeunit "NPR POS Setup")
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

    internal procedure CheckReferenceNo(var ReferenceNoIn: Text; VoucherListEnabledIn: Boolean; VoucherTypeCodeIn: Code[20])
    var
        BlankReferenceNoErr: Label 'Reference No. can''t be blank';
    begin
        if VoucherListEnabledIn then
            ReferenceNoIn := SetReferenceNo(VoucherTypeCodeIn)
        else
            Error(BlankReferenceNoErr);
    end;

    internal procedure CalculateRemainingAmount(PaymentLine: Codeunit "NPR POS Payment Line";
                                                PaymentMethodCode: Code[10];
                                                var POSPaymentMethodOut: Record "NPR POS Payment Method";
                                                var RemainingAmount: Decimal)
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

        PaymentLine.CalculateBalance(POSPaymentMethodOut, SalesAmount, PaidAmount, ReturnAmount, SubTotal);
        RemainingAmount := PaymentLine.CalculateRemainingPaymentSuggestion(SalesAmount, PaidAmount, POSPaymentMethodOut, ReturnPOSPaymentMethod, true);
    end;

    internal procedure CalculateRemainingSalesBalanceAmount(PaymentLine: Codeunit "NPR POS Payment Line") RemainingSalesBalanceAmount: Decimal
    var
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
    begin
        PaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);
        RemainingSalesBalanceAmount := SubTotal;
    end;

    internal procedure VoucherHasItemFilterLimitation(NPRNpRvVoucher: Record "NPR NpRv Voucher") HasItemFilterLimitation: boolean
    var
        POSPmtMethodItemMgt: Codeunit "NPR POS Pmt. Method Item Mgt.";
        VoucherType: Record "NPR NpRv Voucher Type";
    begin
        if not VoucherType.Get(NPRNpRvVoucher."Voucher Type") then
            exit;

        if VoucherType."Payment Type" = '' then
            exit;

        HasItemFilterLimitation := POSPmtMethodItemMgt.HasPOSPaymentMethodItemFilter(VoucherType."Payment Type");
    end;

    internal procedure GetVoucherSalesLineId(PaymentLinePOS: Record "NPR POS Sale Line") ParentId: Guid
    var
        VoucherSaleLine: Record "NPR NpRv Sales Line";
    begin
        VoucherSaleLine.Reset();
        VoucherSaleLine.SetCurrentKey("Retail ID", "Document Source", Type);
        VoucherSaleLine.SetRange("Retail ID", PaymentLinePOS.SystemId);
        VoucherSaleLine.SetLoadFields("Retail ID", Id);
        if not VoucherSaleLine.FindFirst() then
            exit;

        ParentId := VoucherSaleLine.Id;
    end;

    internal procedure ValidateVoucher(ReferenceNo: Text[50])
    var
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        ArchvoucherEntry: Record "NPR NpRv Arch. Voucher Entry";
        Voucher: Record "NPR NpRv Voucher";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        VourcherRedeemedErr: Label 'The voucher with Reference No. %1 has already been redeemed in another transaction on %2.', Comment = '%1 - voucher reference number, 2% - date';
        InvalidReferenceErr: Label 'Invalid Reference No. %1', Comment = '%1 - Reference Number value';
    begin
        if NpRvVoucherMgt.FindVoucher('', ReferenceNo, Voucher) then
            exit;
        if NpRvVoucherMgt.FindArchivedVoucher('', ReferenceNo, ArchVoucher) then begin
            ArchvoucherEntry.SetCurrentKey("Arch. Voucher No.");
            ArchvoucherEntry.SetRange("Arch. Voucher No.", ArchVoucher."No.");
            if ArchvoucherEntry.FindLast() then;
            Error(VourcherRedeemedErr, ReferenceNo, ArchvoucherEntry."Posting Date");
        end else
            Error(InvalidReferenceErr, ReferenceNo);
    end;
}
