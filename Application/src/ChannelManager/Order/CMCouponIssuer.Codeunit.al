codeunit 6151057 "NPR CMCouponIssuer"
{
    Access = Internal;

    internal procedure IssueAndAttachCouponsForWallet(WalletEntryNo: Integer; var Order: Record "NPR CMOrder"; var OrderLine: Record "NPR CMOrderLine"; var TempOrderWallet: Record "NPR CMOrderWallet" temporary)
    var
        MasterItem: Record Item;
        AddOnLine: Record "NPR NpIa Item AddOn Line";
        GLSetup: Record "General Ledger Setup";
        PricesExcl: Dictionary of [Integer, Decimal];
        PricesIncl: Dictionary of [Integer, Decimal];
    begin
        if (not OrderLine.IsPackage) then
            exit;

        if (not MasterItem.Get(OrderLine.ItemNo)) then
            exit;

        if (MasterItem."NPR Item AddOn No." = '') then
            exit;

        AddOnLine.SetFilter("AddOn No.", '=%1', MasterItem."NPR Item AddOn No.");
        AddOnLine.SetFilter(Type, '=%1', AddOnLine.Type::Quantity);
        AddOnLine.SetFilter("Item No.", '<>%1', '');
        if (not AddOnLine.FindSet()) then
            exit;

        GLSetup.Get();

        repeat
            IssueAndAttachForAddOnLine(WalletEntryNo, Order, OrderLine, AddOnLine, TempOrderWallet, GLSetup."LCY Code", PricesExcl, PricesIncl);
        until (AddOnLine.Next() = 0);
    end;

    local procedure IssueAndAttachForAddOnLine(
        WalletEntryNo: Integer;
        var Order: Record "NPR CMOrder";
        var OrderLine: Record "NPR CMOrderLine";
        var AddOnLine: Record "NPR NpIa Item AddOn Line";
        var TempOrderWallet: Record "NPR CMOrderWallet" temporary;
        CurrencyCode: Code[10];
        var PricesExcl: Dictionary of [Integer, Decimal];
        var PricesIncl: Dictionary of [Integer, Decimal])
    var
        CouponSetup: Record "NPR WalletCouponSetup";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        Coupons: Codeunit "NPR AttractionWalletCoupon";
        WalletFacade: Codeunit "NPR AttractionWallet";
        CouponIds: List of [Guid];
        UnitPriceExclVat: Decimal;
        UnitPriceInclVat: Decimal;
        Quantity: Integer;
        VisitDate: Date;
        VisitTime: Time;
        PostCouponEntries: Boolean;
    begin
        CouponSetup.SetCurrentKey(TriggerOnItemNo);
        CouponSetup.SetFilter(TriggerOnItemNo, '=%1', AddOnLine."Item No.");
        if (not CouponSetup.FindFirst()) then
            exit;

        Quantity := GetAddOnQuantity(AddOnLine);
        if (Quantity <= 0) then
            exit;

        ResolveVisitForComponent(OrderLine, AddOnLine."Item No.", VisitDate, VisitTime);
        GetOrComputeAddOnLinePrice(AddOnLine, VisitDate, VisitTime, PricesExcl, PricesIncl, UnitPriceExclVat, UnitPriceInclVat);

        PostCouponEntries := Order.PaymentReference <> '';
        Coupons.IssueCoupons(CouponSetup."Coupon Type", Quantity, TempCoupon, PostCouponEntries);

        TempCoupon.Reset();
        if (TempCoupon.FindSet()) then
            repeat
                CouponIds.Add(TempCoupon.SystemId);
            until (TempCoupon.Next() = 0);

        if (CouponIds.Count() = 0) then
            exit;

        WalletFacade.AddCouponsToWallet(WalletEntryNo, CouponIds, AddOnLine."Item No.", Order.DocumentNo);

        AccumulatePriceOnWallet(TempOrderWallet, UnitPriceExclVat * Quantity, UnitPriceInclVat * Quantity, CurrencyCode);
    end;

    internal procedure ConfirmCoupons(var Order: Record "NPR CMOrder")
    var
        Coupon: Record "NPR NpDc Coupon";
        CouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
        CouponIds: List of [Guid];
        CouponId: Guid;
    begin
        // Don't confirm coupons for draft orders — let them stay unissued until the partner calls Confirm API with a payment reference
        if (Order.PaymentReference = '') then
            exit;

        CollectCouponSystemIdsForOrder(Order, CouponIds);
        Coupon.SetAutoCalcFields("Coupon Issued");
        foreach CouponId in CouponIds do
            if (Coupon.GetBySystemId(CouponId)) then begin
                if (not Coupon."Coupon Issued") then
                    CouponMgt.PostIssueCoupon(Coupon);
            end;
    end;

    internal procedure CollectCouponSystemIdsForOrder(var Order: Record "NPR CMOrder"; var CouponIds: List of [Guid])
    var
        OrderWallet: Record "NPR CMOrderWallet";
        Ref: Record "NPR WalletAssetLineReference";
        AssetLine: Record "NPR WalletAssetLine";
    begin
        OrderWallet.SetFilter(OrderId, '=%1', Order.OrderId);
        OrderWallet.SetLoadFields(WalletEntryNo);
        if (not OrderWallet.FindSet()) then
            exit;

        repeat
            if (OrderWallet.WalletEntryNo <> 0) then begin
                Ref.SetCurrentKey(WalletEntryNo);
                Ref.SetFilter(WalletEntryNo, '=%1', OrderWallet.WalletEntryNo);
                Ref.SetFilter(SupersededBy, '=%1', 0);
                if (Ref.FindSet()) then
                    repeat
                        if (AssetLine.Get(Ref.WalletAssetLineEntryNo)) then
                            if (AssetLine.Type = AssetLine.Type::Coupon) then
                                if (not CouponIds.Contains(AssetLine.LineTypeSystemId)) then
                                    CouponIds.Add(AssetLine.LineTypeSystemId);
                    until (Ref.Next() = 0);
            end;
        until (OrderWallet.Next() = 0);
    end;

    internal procedure DeleteCoupons(CouponIds: List of [Guid])
    var
        Coupon: Record "NPR NpDc Coupon";
        CouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
        CouponId: Guid;
    begin
        Coupon.SetAutoCalcFields("Coupon Issued");
        foreach CouponId in CouponIds do
            if (Coupon.GetBySystemId(CouponId)) then
                if (Coupon."Coupon Issued") then
                    CouponMgt.ArchiveCoupon(Coupon)
                else
                    Coupon.Delete(true);
    end;

    local procedure GetOrComputeAddOnLinePrice(
        AddOnLine: Record "NPR NpIa Item AddOn Line";
        VisitDate: Date; VisitTime: Time;
        var PricesExcl: Dictionary of [Integer, Decimal];
        var PricesIncl: Dictionary of [Integer, Decimal];
        var UnitPriceExclVat: Decimal; var UnitPriceInclVat: Decimal)
    var
        WalletMgr: Codeunit "NPR AttractionWallet";
    begin
        if (PricesExcl.ContainsKey(AddOnLine."Line No.")) then begin
            UnitPriceExclVat := PricesExcl.Get(AddOnLine."Line No.");
            UnitPriceInclVat := PricesIncl.Get(AddOnLine."Line No.");
            exit;
        end;

        WalletMgr.CalculateAddOnLineUnitPrice(AddOnLine, '', VisitDate, VisitTime, UnitPriceExclVat, UnitPriceInclVat);
        PricesExcl.Add(AddOnLine."Line No.", UnitPriceExclVat);
        PricesIncl.Add(AddOnLine."Line No.", UnitPriceInclVat);
    end;

    local procedure GetAddOnQuantity(var AddOnLine: Record "NPR NpIa Item AddOn Line"): Integer
    begin
        if (AddOnLine.Quantity < 1) then
            exit(1);
        exit(Round(AddOnLine.Quantity, 1, '<'));
    end;

    local procedure ResolveVisitForComponent(var OrderLine: Record "NPR CMOrderLine"; ComponentItemNo: Code[20]; var VisitDate: Date; var VisitTime: Time)
    var
        Component: Record "NPR CMOrderComponent";
    begin
        Component.SetFilter(OrderId, '=%1', OrderLine.OrderId);
        Component.SetFilter(LineNo, '=%1', OrderLine.LineNo);
        Component.SetFilter(ComponentItemNo, '=%1', ComponentItemNo);
        if (Component.FindFirst()) then begin
            VisitDate := Component.VisitDate;
            VisitTime := Component.VisitTime;
            exit;
        end;
        VisitDate := OrderLine.VisitDate;
        VisitTime := OrderLine.VisitTime;
    end;

    local procedure AccumulatePriceOnWallet(var TempOrderWallet: Record "NPR CMOrderWallet" temporary; UnitPriceExclVat: Decimal; UnitPriceInclVat: Decimal; CurrencyCode: Code[10])
    begin
        TempOrderWallet.UnitPriceExclVat += UnitPriceExclVat;
        TempOrderWallet.UnitPriceInclVat += UnitPriceInclVat;
        if (TempOrderWallet.CurrencyCode = '') then
            TempOrderWallet.CurrencyCode := CurrencyCode;
        TempOrderWallet.Modify();
    end;
}
