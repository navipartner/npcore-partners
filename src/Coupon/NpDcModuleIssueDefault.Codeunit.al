codeunit 6151592 "NPR NpDc Module Issue: Default"
{
    // NPR5.34/MHA /20170720  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon
    // NPR5.42/MHA /20180521  CASE 305859 Added "Print on Issue" functionality


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Issue Coupon - Default';

    procedure IssueCoupons(CouponType: Record "NPR NpDc Coupon Type")
    var
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        NpDcIssueCouponsQty: Report "NPR NpDc Request Coupon Qty.";
        IssueCouponsQty: Integer;
        i: Integer;
    begin
        CouponType.TestField("Reference No. Pattern");
        //-NPR5.42 [305859]
        if CouponType."Print on Issue" then
            CouponType.TestField("Print Template Code");
        //+NPR5.42 [305859]

        IssueCouponsQty := NpDcIssueCouponsQty.RequestCouponQty();
        if IssueCouponsQty <= 0 then
            exit;

        for i := 1 to IssueCouponsQty do
            //-NPR5.42 [305859]
            //IssueCoupon(CouponType);
            IssueCoupon(CouponType, TempCoupon);
        //+NPR5.42 [305859]

        //-NPR5.42 [305859]
        if CouponType."Print on Issue" then
            PrintCoupons(TempCoupon);
        //+NPR5.42 [305859]
    end;

    local procedure IssueCoupon(CouponType: Record "NPR NpDc Coupon Type"; var TempCoupon: Record "NPR NpDc Coupon" temporary)
    var
        Coupon: Record "NPR NpDc Coupon";
        CouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
    begin
        Coupon.Init;
        Coupon.Validate("Coupon Type", CouponType.Code);
        Coupon."No." := '';
        Coupon.Insert(true);

        CouponMgt.PostIssueCoupon(Coupon);

        //-NPR5.42 [305859]
        TempCoupon.Init;
        TempCoupon := Coupon;
        TempCoupon.Insert;
        //+NPR5.42 [305859]
    end;

    local procedure PrintCoupons(var TempCoupon: Record "NPR NpDc Coupon" temporary)
    var
        Coupon: Record "NPR NpDc Coupon";
        NpDcCouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
    begin
        if not TempCoupon.FindSet then
            exit;

        repeat
            Coupon.Get(TempCoupon."No.");
            NpDcCouponMgt.PrintCoupon(Coupon);
        until TempCoupon.Next = 0;
    end;

    local procedure "--- Coupon Interface"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnInitCouponModules', '', true, true)]
    local procedure OnInitCouponModules(var CouponModule: Record "NPR NpDc Coupon Module")
    begin
        if CouponModule.Get(CouponModule.Type::"Issue Coupon", ModuleCode()) then
            exit;

        CouponModule.Init;
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

        //-NPR5.42 [305859]
        //HasIssueSetup := FALSE;
        HasIssueSetup := true;
        //+NPR5.42 [305859]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnSetupIssueCoupon', '', true, true)]
    local procedure OnSetupIssueCoupon(var CouponType: Record "NPR NpDc Coupon Type")
    var
        RPTemplateHeader: Record "NPR RP Template Header";
    begin
        if not IsSubscriber(CouponType) then
            exit;

        //-NPR5.42 [305859]
        CouponType.TestField("Print Template Code");
        RPTemplateHeader.Get(CouponType."Print Template Code");
        PAGE.Run(PAGE::"NPR RP Template Card", RPTemplateHeader);
        //+NPR5.42 [305859]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnRunIssueCoupon', '', true, true)]
    local procedure OnRunIssueCoupon(CouponType: Record "NPR NpDc Coupon Type"; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if not IsSubscriber(CouponType) then
            exit;

        Handled := true;
        IssueCoupons(CouponType);
    end;

    local procedure "--- Aux"()
    begin
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

