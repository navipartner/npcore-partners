codeunit 6150718 "NPR NpRv Module Valid.: Lim."
{
    Access = Internal;
    ObsoleteReason = 'Moving LIMIT from Validation to Apply Payment module';
    ObsoleteState = Pending;
    ObsoleteTag = '2023-06-28';
    procedure ValidateVoucher(var TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary)
    var
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        ArchvoucherEntry: Record "NPR NpRv Arch. Voucher Entry";
        Voucher: Record "NPR NpRv Voucher";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        AvailableAmount: Decimal;
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
        VoucherType: Record "NPR NpRv Voucher Type";
        POSPaymentMethod: Record "NPR POS Payment Method";
        VoucherAmtErr: Label 'Available Voucher amount %1 is higher than the Subtotal %2.', Comment = '%1 = Voucher.Amount;%2=Subtotal';
        VourcherRedeemedErr: Label 'The voucher with Reference No. %1 has already been redeemed in another transaction on %2.', Comment = '%1 - voucher reference number, 2% - date';
        InvalidReferenceErr: Label 'Invalid Reference No. %1', Comment = '%1 - Reference Number value';
    begin
        if not NpRvVoucherMgt.FindVoucher(TempNpRvVoucherBuffer."Voucher Type", TempNpRvVoucherBuffer."Reference No.", Voucher) then begin
            if NpRvVoucherMgt.FindArchivedVoucher(TempNpRvVoucherBuffer."Voucher Type", TempNpRvVoucherBuffer."Reference No.", ArchVoucher) then begin
                ArchvoucherEntry.SetCurrentKey("Arch. Voucher No.");
                ArchvoucherEntry.SetRange("Arch. Voucher No.", ArchVoucher."No.");
                if ArchvoucherEntry.FindLast() then;
                Error(VourcherRedeemedErr, TempNpRvVoucherBuffer."Reference No.", ArchvoucherEntry."Posting Date");
            end else
                Error(InvalidReferenceErr, TempNpRvVoucherBuffer."Reference No.");
        end;
        CheckVoucher(Voucher);
        POSSession.GetSale(POSSale);
        POSSession.GetPaymentLine(POSPaymentLine);

        VoucherType.Get(Voucher."Voucher Type");
        POSPaymentMethod.Get(VoucherType."Payment Type");

        POSPaymentLine.CalculateBalance(POSPaymentMethod, SalesAmount, PaidAmount, ReturnAmount, SubTotal);

        if NpRvVoucherMgt.VoucherReservationByAmountFeatureEnabled() then begin
            if not NpRvVoucherMgt.ValidateAmount(Voucher, ABS(SubTotal), AvailableAmount) then
                Error(VoucherAmtErr, FORMAT(AvailableAmount), Format(SubTotal));
        end else begin
            Voucher.CalcFields(Amount);
            if Voucher.Amount > ABS(SubTotal) then
                Error(VoucherAmtErr, FORMAT(Voucher.Amount), Format(SubTotal));
        end;

        NpRvVoucherMgt.Voucher2Buffer(Voucher, TempNpRvVoucherBuffer);
    end;

    local procedure CheckVoucher(var Voucher: Record "NPR NpRv Voucher")
    var
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        IsHandled: Boolean;
        Timestamp: DateTime;
        VoucherAlreadyUsedErr: Label 'The voucher has already been used. No amount remains on the voucher.';
        VoucherBeingUsedErr: Label 'Voucher is being used.';
        VoucherNotValidAnymoreErr: Label 'Voucher is not valid anymore.';
        VoucherNotValidYetErr: Label 'Voucher is not valid yet.';
    begin
        OnBeforeCheckVoucher(Voucher, IsHandled);
        if IsHandled then
            exit;

        Timestamp := CurrentDateTime;
        if Voucher."Starting Date" > Timestamp then
            Error(VoucherNotValidYetErr);

        if (Voucher."Ending Date" < Timestamp) and (Voucher."Ending Date" <> 0DT) then
            Error(VoucherNotValidAnymoreErr);

        Voucher.CalcFields(Open);
        if not Voucher.Open then
            Error(VoucherAlreadyUsedErr);

        TestVoucherType(Voucher."Voucher Type");
        if not NpRvVoucherMgt.VoucherReservationByAmountFeatureEnabled() then begin
            if Voucher.CalcInUseQty() > 0 then
                Error(VoucherBeingUsedErr);
        end;
    end;

    local procedure TestVoucherType(VoucherTypeCode: Code[20])
    var
        VoucherType: Record "NPR NpRv Voucher Type";
    begin
        VoucherType.Get(VoucherTypeCode);
        VoucherType.TestField("Payment Type");
    end;


    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckVoucher(var Voucher: Record "NPR NpRv Voucher"; var IsHandled: Boolean)
    begin
    end;
}

