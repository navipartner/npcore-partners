codeunit 6151018 "NpRv Module Payment - Partial"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Apply Payment - Partial';

    procedure ApplyPayment(FrontEnd: Codeunit "POS Front End Management";POSSession: Codeunit "POS Session";VoucherType: Record "NpRv Voucher Type";SaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher")
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
    local procedure OnRunApplyPayment(FrontEnd: Codeunit "POS Front End Management";POSSession: Codeunit "POS Session";VoucherType: Record "NpRv Voucher Type";SaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher";var Handled: Boolean)
    begin
        if Handled then
          exit;
        if not IsSubscriber(VoucherType) then
          exit;

        Handled := true;

        ApplyPayment(FrontEnd,POSSession,VoucherType,SaleLinePOSVoucher);
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
}

