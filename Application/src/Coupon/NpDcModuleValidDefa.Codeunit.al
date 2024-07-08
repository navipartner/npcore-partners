codeunit 6151593 "NPR NpDc ModuleValid.: Defa."
{
    Access = Internal;

    var
        Text000: Label 'Coupon is not Valid';
        Text001: Label 'Coupon is being used';
        Text002: Label 'Max Use per Sale is %1';
        Text003: Label 'Coupon has already been used';
        Text004: Label 'Validate Coupon - Default';

    procedure ValidateCoupon(SalePOS: Record "NPR POS Sale"; Coupon: Record "NPR NpDc Coupon")
    var
        SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcExtCouponSalesLine: Record "NPR NpDc Ext. Coupon Reserv.";
        Timestamp: DateTime;
        CurrSaleCouponCount: Integer;
    begin
        Timestamp := CurrentDateTime;
        if Coupon."Starting Date" > Timestamp then
            Error(Text000);
        if (Coupon."Ending Date" < Timestamp) and (Coupon."Ending Date" <> 0DT) then
            Error(Text000);

        Coupon.CalcFields(Open, "Remaining Quantity");
        if (not Coupon.Open) or (Coupon."Remaining Quantity" < 1) then
            Error(Text003);

        if Coupon.CalcInUseQty() >= Coupon."Remaining Quantity" then
            Error(Text001);

        if SalePOS."Register No." <> '' then begin
            SaleLinePOSCoupon.SetRange(Type, SaleLinePOSCoupon.Type::Coupon);
            SaleLinePOSCoupon.SetRange("Coupon No.", Coupon."No.");
            SaleLinePOSCoupon.SetRange("Register No.", SalePOS."Register No.");
            SaleLinePOSCoupon.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
            CurrSaleCouponCount := SaleLinePOSCoupon.Count();

        end else begin
            NpDcExtCouponSalesLine.SetRange("External Document No.", SalePOS."Sales Ticket No.");
            NpDcExtCouponSalesLine.SetRange("Coupon No.", Coupon."No.");
            CurrSaleCouponCount := NpDcExtCouponSalesLine.Count();
        end;

        if Coupon."Max Use per Sale" < 1 then
            Coupon."Max Use per Sale" := 1;
        if CurrSaleCouponCount >= Coupon."Max Use per Sale" then
            Error(Text002, Coupon."Max Use per Sale");

        CheckIfCuponIsForCurrentStore(SalePOS, Coupon);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", 'OnInitCouponModules', '', true, true)]
    local procedure OnInitCouponModules(var CouponModule: Record "NPR NpDc Coupon Module")
    begin
        if CouponModule.Get(CouponModule.Type::"Validate Coupon", ModuleCode()) then
            exit;

        CouponModule.Init();
        CouponModule.Type := CouponModule.Type::"Validate Coupon";
        CouponModule.Code := ModuleCode();
        CouponModule.Description := Text004;
        CouponModule."Event Codeunit ID" := CurrCodeunitId();
        CouponModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", 'OnHasValidateCouponSetup', '', true, true)]
    local procedure OnHasValidateCouponSetup(CouponType: Record "NPR NpDc Coupon Type"; var HasValidateSetup: Boolean)
    begin
        if not IsSubscriber(CouponType) then
            exit;

        HasValidateSetup := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", 'OnSetupValidateCoupon', '', true, true)]
    local procedure OnSetupValidateCoupon(var CouponType: Record "NPR NpDc Coupon Type")
    begin
        if not IsSubscriber(CouponType) then
            exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", 'OnRunValidateCoupon', '', true, true)]
    local procedure OnRunValidateCoupon(SalePOS: Record "NPR POS Sale"; Coupon: Record "NPR NpDc Coupon"; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if not IsSubscriberCoupon(Coupon) then
            exit;

        Handled := true;

        ValidateCoupon(SalePOS, Coupon);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpDc ModuleValid.: Defa.");
    end;

    local procedure IsSubscriber(CouponType: Record "NPR NpDc Coupon Type"): Boolean
    begin
        exit(CouponType."Validate Coupon Module" = ModuleCode());
    end;

    local procedure IsSubscriberCoupon(Coupon: Record "NPR NpDc Coupon"): Boolean
    begin
        Coupon.CalcFields("Validate Coupon Module");
        exit(Coupon."Validate Coupon Module" = ModuleCode());
    end;

    local procedure ModuleCode(): Code[20]
    begin
        exit('DEFAULT');
    end;

    local procedure CheckIfCuponIsForCurrentStore(SalePOS: Record "NPR POS Sale"; Coupon: Record "NPR NpDc Coupon")
    var
        POSStoreGroupLine: Record "NPR POS Store Group Line";
        InvalidStoreErr: Label 'Coupon %1 cannot be used in this store! Assigned store group is %2.', Comment = '%1 = Reference No. of Coupon; %2 = POS Store Group';
    begin
        if Coupon."POS Store Group" = '' then
            exit;
        POSStoreGroupLine.SetRange("No.", Coupon."POS Store Group");
        POSStoreGroupLine.SetRange("POS Store", SalePOS."POS Store Code");
        if POSStoreGroupLine.IsEmpty() then
            Error(InvalidStoreErr, Coupon."Reference No.", Coupon."POS Store Group");
    end;
}

