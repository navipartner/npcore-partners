#if not BC17
codeunit 6185022 "NPR NpRv Module Pay. - Shopify"
{
    Access = Internal;

    procedure ModuleCode(): Code[20]
    begin
        exit('SHOPIFY');
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnInitVoucherModules', '', true, true)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", OnInitVoucherModules, '', true, true)]
#endif
    local procedure OnInitVoucherModules(var VoucherModule: Record "NPR NpRv Voucher Module")
    var
        ModuleNameLbl: Label 'Apply Payment - Shopify', MaxLength = 50;
    begin
        if VoucherModule.Get(VoucherModule.Type::"Apply Payment", ModuleCode()) then
            exit;

        VoucherModule.Init();
        VoucherModule.Type := VoucherModule.Type::"Apply Payment";
        VoucherModule.Code := ModuleCode();
        VoucherModule.Description := ModuleNameLbl;
        VoucherModule."Event Codeunit ID" := CurrCodeunitId();
        VoucherModule.Insert(true);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnHasApplyPaymentSetup', '', true, true)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", OnHasApplyPaymentSetup, '', true, true)]
#endif
    local procedure OnHasApplyPaymentSetup(VoucherType: Record "NPR NpRv Voucher Type"; var HasApplySetup: Boolean)
    begin
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnSetupApplyPayment', '', true, true)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", OnSetupApplyPayment, '', true, true)]
#endif
    local procedure OnSetupApplyPayment(var VoucherType: Record "NPR NpRv Voucher Type")
    begin
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnRunApplyPaymentSalesDoc', '', true, true)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", OnRunApplyPaymentSalesDoc, '', true, true)]
#endif
    local procedure OnRunApplyPaymentSalesDoc(VoucherType: Record "NPR NpRv Voucher Type"; SalesHeader: Record "Sales Header"; var NpRvSalesLine: Record "NPR NpRv Sales Line"; var Handled: Boolean)
    var
        PaymentLine: Record "NPR Magento Payment Line";
        ModulePayDefault: Codeunit "NPR NpRv Module Pay.: Default";
        ModulePayPartial: Codeunit "NPR NpRv Module Pay. - Partial";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
        PartialApplicationAllowed: Boolean;
    begin
        if Handled then
            exit;
        if not IsSubscriber(VoucherType) then
            exit;

        Handled := true;

        PartialApplicationAllowed := IsShopifyPlusSubscription(VoucherType.GetStoreCode());
        if not PartialApplicationAllowed then begin
            NpRvSalesLine.Get(NpRvSalesLine.Id);
            NpRvSalesLine.TestField("Document Source", NpRvSalesLine."Document Source"::"Payment Line");
            PaymentLine.Get(Database::"Sales Header", SalesHeader."Document Type", SalesHeader."No.", NpRvSalesLine."Document Line No.");
            PartialApplicationAllowed := SpfyAssignedIDMgt.GetAssignedShopifyID(PaymentLine.RecordId(), "NPR Spfy ID Type"::"Entry ID") <> '';
        end;

        if PartialApplicationAllowed then
            ModulePayPartial.ApplyPaymentSalesDoc(VoucherType, SalesHeader, NpRvSalesLine)
        else
            ModulePayDefault.ApplyPaymentSalesDoc(VoucherType, SalesHeader, NpRvSalesLine);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnPreApplyPaymentV3', '', true, true)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", OnPreApplyPaymentV3, '', true, true)]
#endif
    local procedure OnPreApplyPaymentV3(var TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary; var SalePOS: Record "NPR POS Sale"; VoucherType: Record "NPR NpRv Voucher Type"; ReferenceNo: Text; SuggestedAmount: Decimal)
    begin
        if not IsSubscriber(VoucherType) then
            exit;
        if not IsShopifyPlusSubscription(VoucherType.GetStoreCode()) then
            exit;

        IF (TempNpRvVoucherBuffer.Amount > SuggestedAmount) AND (SuggestedAmount <> 0) THEN
            TempNpRvVoucherBuffer.Amount := SuggestedAmount;
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnRunApplyPaymentV3', '', true, true)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", OnRunApplyPaymentV3, '', true, true)]
#endif
    local procedure OnRunApplyPaymentV3(POSSession: Codeunit "NPR POS Session"; VoucherType: Record "NPR NpRv Voucher Type"; SaleLinePOSVoucher: Record "NPR NpRv Sales Line"; EndSale: Boolean; var Handled: Boolean; var ActionContext: JsonObject)
    var
        ModulePayDefault: Codeunit "NPR NpRv Module Pay.: Default";
        ModulePayPartial: Codeunit "NPR NpRv Module Pay. - Partial";
    begin
        if Handled then
            exit;
        if not IsSubscriber(VoucherType) then
            exit;

        Handled := true;

        if IsShopifyPlusSubscription(VoucherType.GetStoreCode()) then
            ModulePayPartial.ApplyPayment(POSSession, VoucherType, SaleLinePOSVoucher, ActionContext)
        else
            ModulePayDefault.ApplyPayment(POSSession, VoucherType, SaleLinePOSVoucher, EndSale, ActionContext);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR NpRv Module Pay. - Shopify");
    end;

    local procedure IsSubscriber(VoucherType: Record "NPR NpRv Voucher Type"): Boolean
    begin
        exit(VoucherType."Apply Payment Module" = ModuleCode());
    end;

    local procedure IsShopifyPlusSubscription(ShopifyStoreCode: Code[20]): Boolean
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        exit(ShopifyStore.Get(ShopifyStoreCode) and ShopifyStore."Shopify Plus Subscription");
    end;
}
#endif