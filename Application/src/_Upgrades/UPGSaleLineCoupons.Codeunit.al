codeunit 6151368 "NPR UPG SaleLine Coupons"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeSaleLineCouponDiscountAmount();
        UpgradeCouponModuleCodeunitApplyExtraItemQty();
    end;

    local procedure UpgradeSaleLineCouponDiscountAmount()
    var
    LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG SaleLine Coupons', 'OnUpgradePerCompany');
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG SaleLine Coupons", 'UpgradeSaleLineCouponDiscountAmount')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpdateSaleLineCouponDiscountAmount();

        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG SaleLine Coupons", 'UpgradeSaleLineCouponDiscountAmount'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradeCouponModuleCodeunitApplyExtraItemQty()
    var
    LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG SaleLine Coupons', 'OnUpgradePerCompany');
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG SaleLine Coupons", 'UpgradeCouponModuleCodeunitApplyExtraItemQty')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpdateCouponModuleCodeunitApplyExtraItemQty();

        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG SaleLine Coupons", 'UpgradeCouponModuleCodeunitApplyExtraItemQty'));
        LogMessageStopwatch.LogFinish();
    end;


    local procedure UpdateSaleLineCouponDiscountAmount()
    var
        NPRNpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NPRPOSSaleLine: Record "NPR POS Sale Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
    begin
        NPRNpDcSaleLinePOSCoupon.Reset();
        if not NPRNpDcSaleLinePOSCoupon.FindSet(true) then
            exit;

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        repeat
            if not NPRPOSSaleLine.Get(NPRNpDcSaleLinePOSCoupon."Register No.",
                                      NPRNpDcSaleLinePOSCoupon."Sales Ticket No.",
                                      NPRNpDcSaleLinePOSCoupon."Sale Date",
                                      NPRNpDcSaleLinePOSCoupon."Sale Type",
                                      NPRNpDcSaleLinePOSCoupon."Sale Line No.")
             then
                Clear(NPRPOSSaleLine);

            NPRNpDcSaleLinePOSCoupon."Discount Amount Including VAT" := NPRNpDcSaleLinePOSCoupon."Discount Amount";
            NPRNpDcSaleLinePOSCoupon."Discount Amount Excluding VAT" := NPRPOSSaleTaxCalc.CalcAmountWithoutVAT(NPRNpDcSaleLinePOSCoupon."Discount Amount",
                                                                                                               NPRPOSSaleLine."VAT %",
                                                                                                               GeneralLedgerSetup."Amount Rounding Precision");
            if NPRPOSSaleLine."Price Includes VAT" then
                NPRNpDcSaleLinePOSCoupon."Discount Amount" := NPRNpDcSaleLinePOSCoupon."Discount Amount Including VAT"
            else
                NPRNpDcSaleLinePOSCoupon."Discount Amount" := NPRNpDcSaleLinePOSCoupon."Discount Amount Excluding VAT";

            NPRNpDcSaleLinePOSCoupon.Modify(true);

        until NPRNpDcSaleLinePOSCoupon.Next() = 0;
    end;

    local procedure UpdateCouponModuleCodeunitApplyExtraItemQty()
    var
        NPRNpDcCouponModule: Record "NPR NpDc Coupon Module";
        NPRNpDcApplyExtraItemQty: Codeunit "NPR NpDc Apply: Extra ItemQty.";
    begin
        if not NPRNpDcCouponModule.Get(NPRNpDcCouponModule.Type::"Apply Discount",
                                       NPRNpDcApplyExtraItemQty.ModuleCode())
        then
            exit;

        if NPRNpDcCouponModule."Event Codeunit ID" = Codeunit::"NPR NpDc Apply: Extra ItemQty." then
            exit;

        NPRNpDcCouponModule."Event Codeunit ID" := Codeunit::"NPR NpDc Apply: Extra ItemQty.";
        NPRNpDcCouponModule.Modify(true);
    end;
}