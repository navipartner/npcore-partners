codeunit 6151593 "NpDc Module Validate - Default"
{
    // NPR5.34/MHA /20170720  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon
    // NPR5.47/MHA /20181022  CASE 333113 Max Use per Sale should only consider within same POS Sale
    // NPR5.51/MHA /20190724  CASE 343352 Added CalcInUseQty() to include "In-Use Quantity (External)"


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Coupon is not Valid';
        Text001: Label 'Coupon is being used';
        Text002: Label 'Max Use per Sale is %1';
        Text003: Label 'Coupon has already been used';
        Text004: Label 'Validate Coupon - Default';

    procedure ValidateCoupon(SalePOS: Record "Sale POS";Coupon: Record "NpDc Coupon")
    var
        SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon";
        NpDcExtCouponSalesLine: Record "NpDc Ext. Coupon Reservation";
        Timestamp: DateTime;
        CurrSaleCouponCount: Integer;
    begin
        Timestamp := CurrentDateTime;
        if Coupon."Starting Date" >  Timestamp then
          Error(Text000);
        if (Coupon."Ending Date" < Timestamp) and (Coupon."Ending Date" <> 0DT) then
          Error(Text000);

        Coupon.CalcFields(Open);
        if not Coupon.Open then
          Error(Text003);

        Coupon.CalcFields("Remaining Quantity");

        //-NPR5.51 [343352]
        if Coupon.CalcInUseQty() >= Coupon."Remaining Quantity" then
          Error(Text001);

        if SalePOS."Register No." <> '' then begin
          SaleLinePOSCoupon.SetRange(Type,SaleLinePOSCoupon.Type::Coupon);
          SaleLinePOSCoupon.SetRange("Coupon No.",Coupon."No.");
          SaleLinePOSCoupon.SetRange("Register No.",SalePOS."Register No.");
          SaleLinePOSCoupon.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
          CurrSaleCouponCount := SaleLinePOSCoupon.Count;

        end else begin
          NpDcExtCouponSalesLine.SetRange("External Document No.",SalePOS."Sales Ticket No.");
          NpDcExtCouponSalesLine.SetRange("Coupon No.",Coupon."No.");
          CurrSaleCouponCount := NpDcExtCouponSalesLine.Count;
        end;

        if Coupon."Max Use per Sale" < 1 then
          Coupon."Max Use per Sale" := 1;
        if CurrSaleCouponCount >= Coupon."Max Use per Sale" then
          Error(Text002,Coupon."Max Use per Sale");
        //+NPR5.51 [343352]
    end;

    local procedure "--- Coupon Interface"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnInitCouponModules', '', true, true)]
    local procedure OnInitCouponModules(var CouponModule: Record "NpDc Coupon Module")
    begin
        if CouponModule.Get(CouponModule.Type::"Validate Coupon",ModuleCode()) then
          exit;

        CouponModule.Init;
        CouponModule.Type := CouponModule.Type::"Validate Coupon";
        CouponModule.Code := ModuleCode();
        CouponModule.Description := Text004;
        CouponModule."Event Codeunit ID" := CurrCodeunitId();
        CouponModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnHasValidateCouponSetup', '', true, true)]
    local procedure OnHasValidateCouponSetup(CouponType: Record "NpDc Coupon Type";var HasValidateSetup: Boolean)
    begin
        if not IsSubscriber(CouponType) then
          exit;

        HasValidateSetup := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnSetupValidateCoupon', '', true, true)]
    local procedure OnSetupValidateCoupon(var CouponType: Record "NpDc Coupon Type")
    begin
        if not IsSubscriber(CouponType) then
          exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnRunValidateCoupon', '', true, true)]
    local procedure OnRunValidateCoupon(SalePOS: Record "Sale POS";Coupon: Record "NpDc Coupon";var Handled: Boolean)
    begin
        if Handled then
          exit;
        if not IsSubscriberCoupon(Coupon) then
          exit;

        Handled := true;

        ValidateCoupon(SalePOS,Coupon);
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NpDc Module Validate - Default");
    end;

    local procedure IsSubscriber(CouponType: Record "NpDc Coupon Type"): Boolean
    begin
        exit(CouponType."Validate Coupon Module" = ModuleCode());
    end;

    local procedure IsSubscriberCoupon(Coupon: Record "NpDc Coupon"): Boolean
    begin
        Coupon.CalcFields("Validate Coupon Module");
        exit(Coupon."Validate Coupon Module" = ModuleCode());
    end;

    local procedure ModuleCode(): Code[20]
    begin
        exit('DEFAULT');
    end;
}

