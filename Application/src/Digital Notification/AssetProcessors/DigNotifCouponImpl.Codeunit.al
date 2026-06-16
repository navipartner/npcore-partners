#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248202 "NPR DigNotif Coupon Impl" implements "NPR IDigNotifAssetProcessor"
{
    Access = Internal;

    procedure ProcessAsset(var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary; var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary; var Context: Codeunit "NPR DigNotif Manifest Context")
    var
        EcomSalesCouponLink: Record "NPR Ecom Sales Coupon Link";
        Coupon: Record "NPR NpDc Coupon";
        CouponType: Record "NPR NpDc Coupon Type";
        NPDesignerManifestFacade: Codeunit "NPR NPDesignerManifestFacade";
    begin
        // Coupon asset emission is Ecom-exclusive.
        // For Magento/Shopify, coupons are not part of the digital notification manifest by product decision.
        if TempHeaderBuffer."Document Type" <> TempHeaderBuffer."Document Type"::"Ecom Sales Document" then
            exit;

        EcomSalesCouponLink.SetCurrentKey("Source", "Source System Id", "Source Line System Id");
        EcomSalesCouponLink.SetRange("Source", EcomSalesCouponLink."Source"::"Ecom Sales Document");
        EcomSalesCouponLink.SetRange("Source System Id", TempHeaderBuffer."Source Document Id");
        EcomSalesCouponLink.SetRange("Source Line System Id", TempLineBuffer."Source Line System Id");
        if not EcomSalesCouponLink.FindSet() then
            exit;

        repeat
            if Coupon.GetBySystemId(EcomSalesCouponLink."Coupon System Id") then begin
                CouponType.SetLoadFields(NPDesignerTemplateId);
                if CouponType.Get(Coupon."Coupon Type") and (CouponType.NPDesignerTemplateId <> '') then begin
                    NPDesignerManifestFacade.AddAssetToManifest(
                        Context.ManifestId(),
                        Database::"NPR NpDc Coupon",
                        Coupon.SystemId,
                        Coupon."Reference No.",
                        CouponType.NPDesignerTemplateId);
                    Context.RegisterAsset();
                end;
            end;
        until EcomSalesCouponLink.Next() = 0;
    end;
}
#endif
