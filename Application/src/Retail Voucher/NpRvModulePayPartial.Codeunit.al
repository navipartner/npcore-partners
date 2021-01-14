codeunit 6151018 "NPR NpRv Module Pay. - Partial"
{
    var
        Text000: Label 'Apply Payment - Partial';

    procedure ApplyPayment(FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session"; VoucherType: Record "NPR NpRv Voucher Type"; SaleLinePOSVoucher: Record "NPR NpRv Sales Line")
    var
        POSAction: Record "NPR POS Action";
        SaleLinePOS: Record "NPR Sale Line POS";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSale: Codeunit "NPR POS Sale";
        ReturnPOSActionMgt: Codeunit "NPR NpRv Ret. POSAction Mgt.";
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SaleAmount: Decimal;
        Subtotal: Decimal;
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SaleAmount, PaidAmount, ReturnAmount, Subtotal);
        if Subtotal >= 0 then
            exit;

        SaleLinePOS.Get(SaleLinePOSVoucher."Register No.", SaleLinePOSVoucher."Sales Ticket No.", SaleLinePOSVoucher."Sale Date", SaleLinePOSVoucher."Sale Type", SaleLinePOSVoucher."Sale Line No.");
        SaleLinePOS."Amount Including VAT" += Subtotal;
        SaleLinePOS."Currency Amount" := SaleLinePOS."Amount Including VAT";
        SaleLinePOS.Modify;

        if SaleLinePOS."Amount Including VAT" < 0 then
            SaleLinePOS.Delete(true);
    end;

    procedure ApplyPaymentSalesDoc(NpRvVoucherType: Record "NPR NpRv Voucher Type"; SalesHeader: Record "Sales Header"; var NpRvSalesLine: Record "NPR NpRv Sales Line")
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        ReturnAmount: Decimal;
    begin
        SalesHeader.CalcFields("NPR Magento Payment Amount");
        ReturnAmount := SalesHeader."NPR Magento Payment Amount" - GetTotalAmtInclVat(SalesHeader);
        if ReturnAmount <= 0 then
            exit;

        NpRvSalesLine.Get(NpRvSalesLine.Id);
        NpRvSalesLine.TestField("Document Source", NpRvSalesLine."Document Source"::"Payment Line");
        MagentoPaymentLine.Get(DATABASE::"Sales Header", SalesHeader."Document Type", SalesHeader."No.", NpRvSalesLine."Document Line No.");

        MagentoPaymentLine.Amount -= ReturnAmount;
        MagentoPaymentLine.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnInitVoucherModules', '', true, true)]
    local procedure OnInitVoucherModules(var VoucherModule: Record "NPR NpRv Voucher Module")
    begin
        if VoucherModule.Get(VoucherModule.Type::"Apply Payment", ModuleCode()) then
            exit;

        VoucherModule.Init;
        VoucherModule.Type := VoucherModule.Type::"Apply Payment";
        VoucherModule.Code := ModuleCode();
        VoucherModule.Description := Text000;
        VoucherModule."Event Codeunit ID" := CurrCodeunitId();
        VoucherModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnHasApplyPaymentSetup', '', true, true)]
    local procedure OnHasApplyPaymentSetup(VoucherType: Record "NPR NpRv Voucher Type"; var HasApplySetup: Boolean)
    begin
        if not IsSubscriber(VoucherType) then
            exit;

        HasApplySetup := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnSetupApplyPayment', '', true, true)]
    local procedure OnSetupApplyPayment(var VoucherType: Record "NPR NpRv Voucher Type")
    begin
        if not IsSubscriber(VoucherType) then
            exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnRunApplyPayment', '', true, true)]
    local procedure OnRunApplyPayment(FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session"; VoucherType: Record "NPR NpRv Voucher Type"; SaleLinePOSVoucher: Record "NPR NpRv Sales Line"; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if not IsSubscriber(VoucherType) then
            exit;

        Handled := true;

        ApplyPayment(FrontEnd, POSSession, VoucherType, SaleLinePOSVoucher);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnRunApplyPaymentSalesDoc', '', true, true)]
    local procedure OnRunApplyPaymentSalesDoc(VoucherType: Record "NPR NpRv Voucher Type"; SalesHeader: Record "Sales Header"; var NpRvSalesLine: Record "NPR NpRv Sales Line"; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if not IsSubscriber(VoucherType) then
            exit;

        Handled := true;

        ApplyPaymentSalesDoc(VoucherType, SalesHeader, NpRvSalesLine);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpRv Module Pay. - Partial");
    end;

    local procedure IsSubscriber(VoucherType: Record "NPR NpRv Voucher Type"): Boolean
    begin
        exit(VoucherType."Apply Payment Module" = ModuleCode());
    end;

    local procedure ModuleCode(): Code[20]
    begin
        exit('PARTIAL');
    end;

    local procedure GetTotalAmtInclVat(SalesHeader: Record "Sales Header"): Decimal
    var
        SalesLineTemp: Record "Sales Line" temporary;
        VATAmountLineTemp: Record "VAT Amount Line" temporary;
        SalesPost: Codeunit "Sales-Post";
    begin
        SalesPost.GetSalesLines(SalesHeader, SalesLineTemp, 0);
        SalesLineTemp.CalcVATAmountLines(0, SalesHeader, SalesLineTemp, VATAmountLineTemp);
        SalesLineTemp.UpdateVATOnLines(0, SalesHeader, SalesLineTemp, VATAmountLineTemp);
        exit(VATAmountLineTemp.GetTotalAmountInclVAT());
    end;
}

