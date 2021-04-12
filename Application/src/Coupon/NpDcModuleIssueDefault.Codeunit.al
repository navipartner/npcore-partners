codeunit 6151592 "NPR NpDc Module Issue: Default"
{
    var
        Text000: Label 'Issue Coupon - Default';
        CouponIssuedTxt: Label 'Coupon No. %1 has been issued.';
        CouponPrintedText: Label 'Coupon No. %1 has been printed.';
        CouponsIssuedTxt: Label '%1 coupons (No. %2 - %3) have been issued.';
        CouponsPrintedText: Label '%1 coupons (No. %2 - %3) have been printed.';

    procedure IssueCoupons(CouponType: Record "NPR NpDc Coupon Type"; IssueCouponsQty: Integer)
    var
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        NpDcIssueCouponsQty: Report "NPR NpDc Request Coupon Qty.";
        i: Integer;
        FromCouponNo: Code[20];
    begin
        CouponType.TestField("Reference No. Pattern");
        if CouponType."Print on Issue" then
            CouponType.TestField("Print Template Code");

        if IssueCouponsQty <= 0 then
            IssueCouponsQty := NpDcIssueCouponsQty.RequestCouponQty();
        if IssueCouponsQty <= 0 then
            exit;

        for i := 1 to IssueCouponsQty do
            IssueCoupon(CouponType, TempCoupon);

        if CouponType."Print on Issue" then
            PrintCoupons(TempCoupon);

        if TempCoupon.IsEmpty then
            exit;
        TempCoupon.FindFirst();
        if TempCoupon.Count() = 1 then begin
            if CouponType."Print on Issue" then
                Message(CouponPrintedText, TempCoupon."No.")
            else
                Message(CouponIssuedTxt, TempCoupon."No.");
        end else begin
            FromCouponNo := TempCoupon."No.";
            TempCoupon.FindLast();
            if CouponType."Print on Issue" then
                Message(CouponsPrintedText, IssueCouponsQty, FromCouponNo, TempCoupon."No.")
            else
                Message(CouponsIssuedTxt, IssueCouponsQty, FromCouponNo, TempCoupon."No.");
        end;
    end;

    local procedure IssueCoupon(CouponType: Record "NPR NpDc Coupon Type"; var TempCoupon: Record "NPR NpDc Coupon" temporary)
    var
        Coupon: Record "NPR NpDc Coupon";
        CouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
    begin
        Coupon.Init();
        Coupon.Validate("Coupon Type", CouponType.Code);
        Coupon."No." := '';
        Coupon.Insert(true);

        CouponMgt.PostIssueCoupon(Coupon);

        TempCoupon.Init();
        TempCoupon := Coupon;
        TempCoupon.Insert();
    end;

    local procedure PrintCoupons(var TempCoupon: Record "NPR NpDc Coupon" temporary)
    var
        Coupon: Record "NPR NpDc Coupon";
        NpDcCouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
    begin
        if not TempCoupon.FindSet() then
            exit;

        repeat
            Coupon.Get(TempCoupon."No.");
            NpDcCouponMgt.PrintCoupon(Coupon);
        until TempCoupon.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnInitCouponModules', '', true, true)]
    local procedure OnInitCouponModules(var CouponModule: Record "NPR NpDc Coupon Module")
    begin
        if CouponModule.Get(CouponModule.Type::"Issue Coupon", ModuleCode()) then
            exit;

        CouponModule.Init();
        CouponModule.Type := CouponModule.Type::"Issue Coupon";
        CouponModule.Code := ModuleCode();
        CouponModule.Description := Text000;
        CouponModule."Event Codeunit ID" := CurrCodeunitId();
        CouponModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnHasIssueCouponSetup', '', true, true)]
    local procedure OnHasIssueCouponsSetup(CouponType: Record "NPR NpDc Coupon Type"; var HasIssueSetup: Boolean)
    begin
        if not IsSubscriber(CouponType) then
            exit;

        HasIssueSetup := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnSetupIssueCoupon', '', true, true)]
    local procedure OnSetupIssueCoupon(var CouponType: Record "NPR NpDc Coupon Type")
    var
        RPTemplateHeader: Record "NPR RP Template Header";
    begin
        if not IsSubscriber(CouponType) then
            exit;

        CouponType.TestField("Print Template Code");
        RPTemplateHeader.Get(CouponType."Print Template Code");
        PAGE.Run(PAGE::"NPR RP Template Card", RPTemplateHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnRunIssueCoupon', '', true, true)]
    local procedure OnRunIssueCoupon(CouponType: Record "NPR NpDc Coupon Type"; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if not IsSubscriber(CouponType) then
            exit;

        Handled := true;
        IssueCoupons(CouponType, 0);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpDc Module Issue: Default");
    end;

    local procedure IsSubscriber(CouponType: Record "NPR NpDc Coupon Type"): Boolean
    begin
        exit(CouponType."Issue Coupon Module" = ModuleCode());
    end;

    local procedure ModuleCode(): Code[20]
    begin
        exit('DEFAULT');
    end;
}