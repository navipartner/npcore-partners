codeunit 6185068 "NPR AttractionWalletCoupon"
{
    Access = Internal;
    internal procedure IssueCoupons(CouponType: Code[20]; Quantity: Integer; var TempCoupon: Record "NPR NpDc Coupon" temporary)
    var
        i: Integer;
    begin
        for i := 1 to Quantity do
            IssueCoupon(CouponType, TempCoupon);
    end;

    local procedure IssueCoupon(CouponType: Code[20]; var TempCoupon: Record "NPR NpDc Coupon" temporary)
    var
        Coupon: Record "NPR NpDc Coupon";
        CouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
    begin
        Coupon.Init();
        Coupon.Validate("Coupon Type", CouponType);
        Coupon."No." := '';
        Coupon.Insert(true);

        CouponMgt.PostIssueCoupon(Coupon);

        TempCoupon.Init();
        TempCoupon := Coupon;
        TempCoupon.SystemId := Coupon.SystemId;
        TempCoupon.Insert();
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", 'OnInitCouponModules', '', true, true)]
    local procedure OnInitCouponModules(var CouponModule: Record "NPR NpDc Coupon Module")
    var
        Text000: Label 'Issue Coupon - Attraction Wallet';
    begin
        if (CouponModule.Get(CouponModule.Type::"Issue Coupon", ModuleCode())) then
            exit;

        CouponModule.Init();
        CouponModule.Type := CouponModule.Type::"Issue Coupon";
        CouponModule.Code := ModuleCode();
        CouponModule.Description := Text000;
        CouponModule."Event Codeunit ID" := CurrCodeunitId();
        CouponModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", 'OnHasIssueCouponSetup', '', true, true)]
    local procedure OnHasIssueCouponsSetup(CouponType: Record "NPR NpDc Coupon Type"; var HasIssueSetup: Boolean)
    begin
        if (not IsSubscriber(CouponType)) then
            exit;

        HasIssueSetup := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", 'OnSetupIssueCoupon', '', true, true)]
    local procedure OnSetupIssueCoupon(var CouponType: Record "NPR NpDc Coupon Type")
    var
        CouponSetup: Record "NPR WalletCouponSetup";
    begin
        if (not IsSubscriber(CouponType)) then
            exit;

        if (not CouponSetup.Get(CouponType.Code)) then begin
            CouponSetup.Init();
            CouponSetup."Coupon Type" := CouponType.Code;
            CouponSetup.Insert();
        end;

        Page.Run(Page::"NPR WalletCouponSetupCard", CouponSetup);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", 'OnRunIssueCoupon', '', true, true)]
    local procedure OnRunIssueCoupon(CouponType: Record "NPR NpDc Coupon Type"; var Handled: Boolean)
    var
        Text001: Label 'On-Attraction Wallet Coupons can only be issued through Wallet management.';
    begin
        if (Handled) then
            exit;
        if (not IsSubscriber(CouponType)) then
            exit;

        Handled := true;
        Error(Text001);
    end;

    local procedure ModuleCode(): Code[20]
    begin
        exit('ON-ATTRACTION-WALLET');
    end;

    local procedure IsSubscriber(CouponType: Record "NPR NpDc Coupon Type"): Boolean
    begin
        exit(CouponType."Issue Coupon Module" = ModuleCode());
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR AttractionWalletCoupon");
    end;
}