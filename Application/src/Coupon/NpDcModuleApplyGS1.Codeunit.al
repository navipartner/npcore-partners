codeunit 6060085 "NPR NpDc Module Apply GS1"
{
    Access = Internal;

    var
        Text000: Label 'Apply Discount - GS1';



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", 'OnInitCouponModules', '', true, true)]
    local procedure OnInitCouponModules(var CouponModule: Record "NPR NpDc Coupon Module")
    begin
        if CouponModule.Get(CouponModule.Type::"Apply Discount", ModuleCode()) then
            exit;

        CouponModule.Init();
        CouponModule.Type := CouponModule.Type::"Apply Discount";
        CouponModule.Code := ModuleCode();
        CouponModule.Description := Text000;
        CouponModule."Event Codeunit ID" := CurrCodeunitId();
        CouponModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", 'OnHasApplyDiscountSetup', '', true, true)]
    local procedure OnHasApplyDiscountSetup(CouponType: Record "NPR NpDc Coupon Type"; var HasApplySetup: Boolean)
    begin
        if not IsSubscriber(CouponType) then
            exit;

        HasApplySetup := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", 'OnSetupApplyDiscount', '', true, true)]
    local procedure OnSetupApplyDiscount(var CouponType: Record "NPR NpDc Coupon Type")
    begin
        if not IsSubscriber(CouponType) then
            exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", 'OnRunApplyDiscount', '', true, true)]
    local procedure OnRunApplyDiscount(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if not IsSubscriberPosCoupon(SaleLinePOSCoupon) then
            exit;

        Handled := true;

        ApplyDiscount(SaleLinePOSCoupon);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpDc Module Apply GS1");
    end;

    local procedure IsSubscriber(CouponType: Record "NPR NpDc Coupon Type"): Boolean
    begin
        exit(CouponType."Apply Discount Module" = ModuleCode());
    end;

    local procedure IsSubscriberPosCoupon(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"): Boolean
    var
        CouponType: Record "NPR NpDc Coupon Type";
    begin
        if not CouponType.Get(SaleLinePOSCoupon."Coupon Type") then
            exit(false);

        exit(IsSubscriber(CouponType));
    end;

    procedure ModuleCode(): Code[20]
    begin
        exit('GS1');
    end;


    local procedure ApplyDiscount(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon")
    var
        Coupon: Record "NPR NpDc Coupon";
        CouponType: Record "NPR NpDc Coupon Type";
        SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon";
        DiscountAmt: Decimal;
    begin
        if FindSaleLinePOSCouponApply(SaleLinePOSCoupon, SaleLinePOSCouponApply) then
            SaleLinePOSCouponApply.DeleteAll();

        Coupon.Get(SaleLinePOSCoupon."Coupon No.");
        DiscountAmt := Coupon."Discount Amount";

        CouponType.Get(Coupon."Coupon Type");
        CouponType.TestField("GS1 Account No.");

        ApplyDiscountAmount(SaleLinePOSCoupon, DiscountAmt, CouponType, Coupon."Reference No.");
    end;

    local procedure FindSaleLinePOSCouponApply(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; var SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon"): Boolean
    begin
        Clear(SaleLinePOSCouponApply);
        SaleLinePOSCouponApply.SetRange("Register No.", SaleLinePOSCoupon."Register No.");
        SaleLinePOSCouponApply.SetRange("Sales Ticket No.", SaleLinePOSCoupon."Sales Ticket No.");
        SaleLinePOSCouponApply.SetRange("Sale Date", SaleLinePOSCoupon."Sale Date");
        SaleLinePOSCouponApply.SetRange(Type, SaleLinePOSCouponApply.Type::Discount);
        SaleLinePOSCouponApply.SetRange("Applies-to Sale Line No.", SaleLinePOSCoupon."Sale Line No.");
        SaleLinePOSCouponApply.SetRange("Applies-to Coupon Line No.", SaleLinePOSCoupon."Line No.");
        SaleLinePOSCouponApply.SetRange("Coupon Type", SaleLinePOSCoupon."Coupon Type");
        SaleLinePOSCouponApply.SetRange("Coupon No.", SaleLinePOSCoupon."Coupon No.");
        exit(SaleLinePOSCouponApply.FindFirst());
    end;

    local procedure ApplyDiscountAmount(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; DiscountAmt: Decimal; CouponType: Record "NPR NpDc Coupon Type"; ReferenceNumber: Text[50])
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.SetRange("Register No.", SaleLinePOSCoupon."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SaleLinePOSCoupon."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SaleLinePOSCoupon."Sale Date");
        SaleLinePOS.SetRange("Sale Type", SaleLinePOSCoupon."Sale Type");
        SaleLinePOS.SetRange("Line No.", SaleLinePOSCoupon."Sale Line No.");
        if not SaleLinePOS.FindFirst() then
            exit;

        SaleLinePOS.Validate("Line Type", SaleLinePOS."Line Type"::"GL Payment");
        SaleLinePOS.Validate("No.", CouponType."GS1 Account No.");
        SaleLinePOS.Description := CopyStr((ReferenceNumber + ' ' + SaleLinePOS.Description), 1, MaxStrLen(SaleLinePOS.Description));
        SaleLinePOS.Validate("Amount", -1 * DiscountAmt);
        SaleLinePOS.Validate("Unit Price", -1 * DiscountAmt);
        SaleLinePOS.Modify();
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
    end;
}

