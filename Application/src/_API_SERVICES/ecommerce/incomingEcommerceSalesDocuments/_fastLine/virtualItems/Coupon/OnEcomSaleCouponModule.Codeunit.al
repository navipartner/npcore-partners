#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6151147 "NPR OnEcomSaleCouponModule"
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


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", OnInitCouponModules, '', true, true)]
    local procedure OnInitCouponModules(var CouponModule: Record "NPR NpDc Coupon Module")
    var
        ModuleDescriptionTxt: Label 'Issue Coupon - Ecommerce Sale', MaxLength = 50;
    begin
        if CouponModule.Get(CouponModule.Type::"Issue Coupon", ModuleCode()) then
            exit;

        CouponModule.Init();
        CouponModule.Type := CouponModule.Type::"Issue Coupon";
        CouponModule.Code := ModuleCode();
        CouponModule.Description := ModuleDescriptionTxt;
        CouponModule."Event Codeunit ID" := CurrCodeunitId();
        CouponModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", OnHasIssueCouponSetup, '', true, true)]
    local procedure OnHasIssueCouponsSetup(CouponType: Record "NPR NpDc Coupon Type"; var HasIssueSetup: Boolean)
    begin
        if not IsSubscriber(CouponType) then
            exit;

        HasIssueSetup := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", OnSetupIssueCoupon, '', true, true)]
    local procedure OnSetupIssueCoupon(var CouponType: Record "NPR NpDc Coupon Type")
    var
        EcomSalesCouponSetupLine: Record "NPR NpDc Iss.OnEcomSale S.Line";
    begin
        if not IsSubscriber(CouponType) then
            exit;

        EcomSalesCouponSetupLine.FilterGroup(2);
        EcomSalesCouponSetupLine.SetRange("Coupon Type", CouponType.Code);
        CouponType.FilterGroup(0);
        Page.Run(Page::"NPR NpDc Iss.OnEcomSale SLines", EcomSalesCouponSetupLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", OnRunIssueCoupon, '', true, true)]
    local procedure OnRunIssueCoupon(CouponType: Record "NPR NpDc Coupon Type"; var Handled: Boolean)
    var
        ManualIssueNotSupported: Label 'On-Ecommerce-Sale Coupons can only be issued through Ecommerce sales documents.';
    begin
        if Handled then
            exit;
        if not IsSubscriber(CouponType) then
            exit;

        Handled := true;
        Error(ManualIssueNotSupported);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon Type", OnAfterDeleteEvent, '', true, true)]
    local procedure OnDeleteCouponType(var Rec: Record "NPR NpDc Coupon Type"; RunTrigger: Boolean)
    var
        EcomSalesCouponSetupLine: Record "NPR NpDc Iss.OnEcomSale S.Line";
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        EcomSalesCouponSetupLine.SetRange("Coupon Type", Rec.Code);
        if not EcomSalesCouponSetupLine.IsEmpty() then
            EcomSalesCouponSetupLine.DeleteAll();
    end;

    internal procedure ModuleCode(): Code[20]
    begin
        exit('ON-ECOM-SALE');
    end;

    local procedure IsSubscriber(CouponType: Record "NPR NpDc Coupon Type"): Boolean
    begin
        exit(CouponType."Issue Coupon Module" = ModuleCode());
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR OnEcomSaleCouponModule");
    end;
}
#endif