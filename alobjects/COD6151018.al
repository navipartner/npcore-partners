codeunit 6151018 "NpRv Module Payment - Partial"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.55/MHA /20200603  CASE 363864 Added interface for Sales Document Payments


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Apply Payment - Partial';

    procedure ApplyPayment(FrontEnd: Codeunit "POS Front End Management";POSSession: Codeunit "POS Session";VoucherType: Record "NpRv Voucher Type";SaleLinePOSVoucher: Record "NpRv Sales Line")
    var
        POSAction: Record "POS Action";
        SaleLinePOS: Record "Sale Line POS";
        POSPaymentLine: Codeunit "POS Payment Line";
        POSSale: Codeunit "POS Sale";
        ReturnPOSActionMgt: Codeunit "NpRv Return POS Action Mgt.";
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SaleAmount: Decimal;
        Subtotal: Decimal;
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SaleAmount,PaidAmount,ReturnAmount,Subtotal);
        if Subtotal >= 0 then
          exit;

        SaleLinePOS.Get(SaleLinePOSVoucher."Register No.",SaleLinePOSVoucher."Sales Ticket No.",SaleLinePOSVoucher."Sale Date",SaleLinePOSVoucher."Sale Type",SaleLinePOSVoucher."Sale Line No.");
        SaleLinePOS."Amount Including VAT" += Subtotal;
        SaleLinePOS."Currency Amount" := SaleLinePOS."Amount Including VAT";
        SaleLinePOS.Modify;

        if SaleLinePOS."Amount Including VAT" < 0 then
          SaleLinePOS.Delete(true);
    end;

    procedure ApplyPaymentSalesDoc(NpRvVoucherType: Record "NpRv Voucher Type";SalesHeader: Record "Sales Header";var NpRvSalesLine: Record "NpRv Sales Line")
    var
        MagentoPaymentLine: Record "Magento Payment Line";
        ReturnAmount: Decimal;
    begin
        //-NPR5.55 [363864]
        SalesHeader.CalcFields("Magento Payment Amount");
        ReturnAmount := SalesHeader."Magento Payment Amount" - GetTotalAmtInclVat(SalesHeader);
        if ReturnAmount <= 0 then
          exit;

        NpRvSalesLine.Get(NpRvSalesLine.Id);
        NpRvSalesLine.TestField("Document Source",NpRvSalesLine."Document Source"::"Payment Line");
        MagentoPaymentLine.Get(DATABASE::"Sales Header",SalesHeader."Document Type",SalesHeader."No.",NpRvSalesLine."Document Line No.");

        MagentoPaymentLine.Amount -= ReturnAmount;
        MagentoPaymentLine.Modify(true);
        //+NPR5.55 [363864]
    end;

    local procedure "--- Voucher Interface"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnInitVoucherModules', '', true, true)]
    local procedure OnInitVoucherModules(var VoucherModule: Record "NpRv Voucher Module")
    begin
        if VoucherModule.Get(VoucherModule.Type::"Apply Payment",ModuleCode()) then
          exit;

        VoucherModule.Init;
        VoucherModule.Type := VoucherModule.Type::"Apply Payment";
        VoucherModule.Code := ModuleCode();
        VoucherModule.Description := Text000;
        VoucherModule."Event Codeunit ID" := CurrCodeunitId();
        VoucherModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnHasApplyPaymentSetup', '', true, true)]
    local procedure OnHasApplyPaymentSetup(VoucherType: Record "NpRv Voucher Type";var HasApplySetup: Boolean)
    begin
        if not IsSubscriber(VoucherType) then
          exit;

        HasApplySetup := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnSetupApplyPayment', '', true, true)]
    local procedure OnSetupApplyPayment(var VoucherType: Record "NpRv Voucher Type")
    begin
        if not IsSubscriber(VoucherType) then
          exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnRunApplyPayment', '', true, true)]
    local procedure OnRunApplyPayment(FrontEnd: Codeunit "POS Front End Management";POSSession: Codeunit "POS Session";VoucherType: Record "NpRv Voucher Type";SaleLinePOSVoucher: Record "NpRv Sales Line";var Handled: Boolean)
    begin
        if Handled then
          exit;
        if not IsSubscriber(VoucherType) then
          exit;

        Handled := true;

        ApplyPayment(FrontEnd,POSSession,VoucherType,SaleLinePOSVoucher);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnRunApplyPaymentSalesDoc', '', true, true)]
    local procedure OnRunApplyPaymentSalesDoc(VoucherType: Record "NpRv Voucher Type";SalesHeader: Record "Sales Header";var NpRvSalesLine: Record "NpRv Sales Line";var Handled: Boolean)
    begin
        //-NPR5.55 [363864]
        if Handled then
          exit;
        if not IsSubscriber(VoucherType) then
          exit;

        Handled := true;

        ApplyPaymentSalesDoc(VoucherType,SalesHeader,NpRvSalesLine);
        //+NPR5.55 [363864]
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NpRv Module Payment - Partial");
    end;

    local procedure IsSubscriber(VoucherType: Record "NpRv Voucher Type"): Boolean
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
        //-NPR5.55 [363864]
        SalesPost.GetSalesLines(SalesHeader,SalesLineTemp,0);
        SalesLineTemp.CalcVATAmountLines(0,SalesHeader,SalesLineTemp,VATAmountLineTemp);
        SalesLineTemp.UpdateVATOnLines(0,SalesHeader,SalesLineTemp,VATAmountLineTemp);
        exit(VATAmountLineTemp.GetTotalAmountInclVAT());
        //+NPR5.55 [363864]
    end;
}

