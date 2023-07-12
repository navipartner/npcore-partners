﻿codeunit 6151018 "NPR NpRv Module Pay. - Partial"
{
    Access = Internal;
    var
        Text000: Label 'Apply Payment - Partial';

    [Obsolete('Delete when final v1/v2 workflow is gone', 'NPR23.0')]
    procedure ApplyPayment(FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session"; VoucherType: Record "NPR NpRv Voucher Type"; SaleLinePOSVoucher: Record "NPR NpRv Sales Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
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
        if SaleLinePOS."Amount Including VAT" < 0 then begin
            SaleLinePOS.Delete(true);
            exit;
        end;
        SaleLinePOS."Currency Amount" := SaleLinePOS."Amount Including VAT";
        POSPaymentLine.ReverseUnrealizedSalesVAT(SaleLinePOS);
        SaleLinePOS.Modify();
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnInitVoucherModules', '', true, true)]
    local procedure OnInitVoucherModules(var VoucherModule: Record "NPR NpRv Voucher Module")
    begin
        if VoucherModule.Get(VoucherModule.Type::"Apply Payment", ModuleCode()) then
            exit;

        VoucherModule.Init();
        VoucherModule.Type := VoucherModule.Type::"Apply Payment";
        VoucherModule.Code := ModuleCode();
        VoucherModule.Description := Text000;
        VoucherModule."Event Codeunit ID" := CurrCodeunitId();
        VoucherModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnHasApplyPaymentSetup', '', true, true)]
    local procedure OnHasApplyPaymentSetup(VoucherType: Record "NPR NpRv Voucher Type"; var HasApplySetup: Boolean)
    begin
        if not IsSubscriber(VoucherType) then
            exit;

        HasApplySetup := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnSetupApplyPayment', '', true, true)]
    local procedure OnSetupApplyPayment(var VoucherType: Record "NPR NpRv Voucher Type")
    begin
        if not IsSubscriber(VoucherType) then
            exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnRunApplyPayment', '', true, true)]
    local procedure OnRunApplyPayment(FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session"; VoucherType: Record "NPR NpRv Voucher Type"; SaleLinePOSVoucher: Record "NPR NpRv Sales Line"; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if not IsSubscriber(VoucherType) then
            exit;

        Handled := true;

        ApplyPayment(FrontEnd, POSSession, VoucherType, SaleLinePOSVoucher);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnRunApplyPaymentSalesDoc', '', true, true)]
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
        TempSalesLine: Record "Sales Line" temporary;
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        SalesPost: Codeunit "Sales-Post";
    begin
        SalesPost.GetSalesLines(SalesHeader, TempSalesLine, 0);
        TempSalesLine.CalcVATAmountLines(0, SalesHeader, TempSalesLine, TempVATAmountLine);
        TempSalesLine.UpdateVATOnLines(0, SalesHeader, TempSalesLine, TempVATAmountLine);
        exit(TempVATAmountLine.GetTotalAmountInclVAT());
    end;

    #Region V3
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnRunApplyPaymentV3', '', true, true)]
    local procedure OnRunApplyPaymentV3(POSSession: Codeunit "NPR POS Session"; VoucherType: Record "NPR NpRv Voucher Type"; SaleLinePOSVoucher: Record "NPR NpRv Sales Line"; var Handled: Boolean; var ActionContext: JsonObject)
    begin
        if Handled then
            exit;
        if not IsSubscriber(VoucherType) then
            exit;

        Handled := true;

        ApplyPayment(POSSession, VoucherType, SaleLinePOSVoucher, ActionContext);
    end;

    procedure ApplyPayment(POSSession: Codeunit "NPR POS Session"; VoucherType: Record "NPR NpRv Voucher Type"; SaleLinePOSVoucher: Record "NPR NpRv Sales Line"; var ActionContext: JsonObject)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
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
        if SaleLinePOS."Amount Including VAT" < 0 then begin
            SaleLinePOS.Delete(true);
            exit;
        end;
        SaleLinePOS."Currency Amount" := SaleLinePOS."Amount Including VAT";
        POSPaymentLine.ReverseUnrealizedSalesVAT(SaleLinePOS);
        SaleLinePOS.Modify();
    end;
    #endRegion
}

