codeunit 6151594 "NpDc Module Apply - Default"
{
    // NPR5.34/MHA /20170720  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Apply Discount - Default';

    procedure ApplyDiscount(SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon")
    var
        SaleLinePOSCouponApply: Record "NpDc Sale Line POS Coupon";
        SaleLinePOS: Record "Sale Line POS";
        DiscountAmt: Decimal;
        TotalAmt: Decimal;
    begin
        if FindSaleLinePOSCouponApply(SaleLinePOSCoupon,SaleLinePOSCouponApply) then
          SaleLinePOSCouponApply.DeleteAll;

        if not FindSaleLinePOSItems(SaleLinePOSCoupon,SaleLinePOS) then
          exit;

        SaleLinePOS.CalcSums("Amount Including VAT");
        TotalAmt := SaleLinePOS."Amount Including VAT" - CalcAppliedDiscountTotal(SaleLinePOSCoupon);
        if TotalAmt <= 0 then
          exit;

        DiscountAmt := CalcDiscountAmount(SaleLinePOSCoupon,TotalAmt);
        if DiscountAmt <= 0 then
          exit;

        SaleLinePOS.FindSet;
        repeat
          ApplyDiscountLine(SaleLinePOSCoupon,DiscountAmt,TotalAmt,SaleLinePOS);
        until SaleLinePOS.Next = 0;
    end;

    procedure ApplyDiscountLine(SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon";DiscountAmt: Decimal;TotalAmt: Decimal;SaleLinePOS: Record "Sale Line POS")
    var
        SaleLinePOSCouponApply: Record "NpDc Sale Line POS Coupon";
        LineNo: Integer;
        LineDiscountAmt: Decimal;
        LineDiscountPct: Decimal;
    begin
        LineDiscountPct := (SaleLinePOS."Amount Including VAT" - CalcAppliedDiscount(SaleLinePOS)) / TotalAmt;
        LineDiscountAmt := Round(DiscountAmt * LineDiscountPct,0.01);
        if LineDiscountAmt <= 0 then
          exit;

        LineNo := GetNextLineNo(SaleLinePOS);
        SaleLinePOSCouponApply.Init;
        SaleLinePOSCouponApply."Register No." := SaleLinePOS."Register No.";
        SaleLinePOSCouponApply."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        SaleLinePOSCouponApply."Sale Type" := SaleLinePOS."Sale Type";
        SaleLinePOSCouponApply."Sale Date" := SaleLinePOS.Date;
        SaleLinePOSCouponApply."Sale Line No." := SaleLinePOS."Line No.";
        SaleLinePOSCouponApply."Line No." := LineNo;
        SaleLinePOSCouponApply.Type := SaleLinePOSCouponApply.Type::Discount;
        SaleLinePOSCouponApply."Applies-to Sale Line No." := SaleLinePOSCoupon."Sale Line No.";
        SaleLinePOSCouponApply."Applies-to Coupon Line No." := SaleLinePOSCoupon."Line No.";
        SaleLinePOSCouponApply."Coupon Type" := SaleLinePOSCoupon."Coupon Type";
        SaleLinePOSCouponApply."Coupon No." := SaleLinePOSCoupon."Coupon No.";
        SaleLinePOSCouponApply.Description := SaleLinePOSCoupon.Description;
        SaleLinePOSCouponApply."Discount Amount" := LineDiscountAmt;
        SaleLinePOSCouponApply.Insert(true);
    end;

    local procedure "--- Calc"()
    begin
    end;

    local procedure CalcAppliedDiscountTotal(SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon"): Decimal
    var
        SaleLinePOSCouponApply: Record "NpDc Sale Line POS Coupon";
    begin
        SaleLinePOSCouponApply.SetRange("Register No.",SaleLinePOSCoupon."Register No.");
        SaleLinePOSCouponApply.SetRange("Sales Ticket No.",SaleLinePOSCoupon."Sales Ticket No.");
        SaleLinePOSCouponApply.SetRange("Sale Type",SaleLinePOSCoupon."Sale Type");
        SaleLinePOSCouponApply.SetRange("Sale Date",SaleLinePOSCoupon."Sale Date");
        SaleLinePOSCouponApply.SetRange(Type,SaleLinePOSCouponApply.Type::Discount);
        if SaleLinePOSCouponApply.IsEmpty then
          exit(0);

        SaleLinePOSCouponApply.CalcSums("Discount Amount");
        exit(SaleLinePOSCouponApply."Discount Amount");
    end;

    local procedure CalcAppliedDiscount(SaleLinePOS: Record "Sale Line POS"): Decimal
    var
        SaleLinePOSCouponApply: Record "NpDc Sale Line POS Coupon";
    begin
        SaleLinePOSCouponApply.SetRange("Register No.",SaleLinePOS."Register No.");
        SaleLinePOSCouponApply.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        SaleLinePOSCouponApply.SetRange("Sale Type",SaleLinePOS."Sale Type");
        SaleLinePOSCouponApply.SetRange("Sale Date",SaleLinePOS.Date);
        SaleLinePOSCouponApply.SetRange("Sale Line No.",SaleLinePOS."Line No.");
        SaleLinePOSCouponApply.SetRange(Type,SaleLinePOSCouponApply.Type::Discount);
        if SaleLinePOSCouponApply.IsEmpty then
          exit(0);

        SaleLinePOSCouponApply.CalcSums("Discount Amount");
        exit(SaleLinePOSCouponApply."Discount Amount");
    end;

    procedure CalcDiscountAmount(SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon";TotalAmt: Decimal) DiscountAmount: Decimal
    var
        Coupon: Record "NpDc Coupon";
    begin
        Coupon.Get(SaleLinePOSCoupon."Coupon No.");
        case Coupon."Discount Type" of
          Coupon."Discount Type"::"Discount %":
            begin
              DiscountAmount := TotalAmt * (Coupon."Discount %" / 100);
              if (Coupon."Max. Discount Amount" > 0) and (DiscountAmount > Coupon."Max. Discount Amount") then
                DiscountAmount := Coupon."Max. Discount Amount";
              exit(DiscountAmount);
            end;
          Coupon."Discount Type"::"Discount Amount":
            begin
              exit(Coupon."Discount Amount");
            end;
        end;

        exit(0);
    end;

    local procedure "--- Find"()
    begin
    end;

    local procedure FindSaleLinePOSItems(SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon";var SaleLinePOS: Record "Sale Line POS"): Boolean
    begin
        Clear(SaleLinePOS);
        SaleLinePOS.SetRange("Register No.",SaleLinePOSCoupon."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.",SaleLinePOSCoupon."Sales Ticket No.");
        SaleLinePOS.SetRange(Date,SaleLinePOSCoupon."Sale Date");
        SaleLinePOS.SetRange("Sale Type",SaleLinePOSCoupon."Sale Type");
        SaleLinePOS.SetRange(Type,SaleLinePOS.Type::Item);
        SaleLinePOS.SetFilter(Quantity,'>%1',0);
        exit(SaleLinePOS.FindFirst);
    end;

    local procedure FindSaleLinePOSCouponApply(SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon";var SaleLinePOSCouponApply: Record "NpDc Sale Line POS Coupon"): Boolean
    begin
        Clear(SaleLinePOSCouponApply);
        SaleLinePOSCouponApply.SetRange("Register No.",SaleLinePOSCoupon."Register No.");
        SaleLinePOSCouponApply.SetRange("Sales Ticket No.",SaleLinePOSCoupon."Sales Ticket No.");
        SaleLinePOSCouponApply.SetRange("Sale Type",SaleLinePOSCoupon."Sale Type");
        SaleLinePOSCouponApply.SetRange("Sale Date",SaleLinePOSCoupon."Sale Date");
        SaleLinePOSCouponApply.SetRange(Type,SaleLinePOSCouponApply.Type::Discount);
        SaleLinePOSCouponApply.SetRange("Applies-to Sale Line No.",SaleLinePOSCoupon."Sale Line No.");
        SaleLinePOSCouponApply.SetRange("Applies-to Coupon Line No.",SaleLinePOSCoupon."Line No.");
        SaleLinePOSCouponApply.SetRange("Coupon Type",SaleLinePOSCoupon."Coupon Type");
        SaleLinePOSCouponApply.SetRange("Coupon No.",SaleLinePOSCoupon."Coupon No.");

        exit(SaleLinePOSCouponApply.FindFirst);
    end;

    local procedure GetNextLineNo(SaleLinePOS: Record "Sale Line POS"): Integer
    var
        SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon";
    begin
        SaleLinePOSCoupon.SetRange("Register No.",SaleLinePOS."Register No.");
        SaleLinePOSCoupon.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        SaleLinePOSCoupon.SetRange("Sale Type",SaleLinePOS."Sale Type");
        SaleLinePOSCoupon.SetRange("Sale Date",SaleLinePOS.Date);
        SaleLinePOSCoupon.SetRange("Sale Line No.",SaleLinePOS."Line No.");
        if SaleLinePOSCoupon.FindLast then;

        exit(SaleLinePOSCoupon."Line No." + 10000);
    end;

    local procedure "--- Coupon Interface"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnInitCouponModules', '', true, true)]
    local procedure OnInitCouponModules(var CouponModule: Record "NpDc Coupon Module")
    begin
        if CouponModule.Get(CouponModule.Type::"Apply Discount",ModuleCode()) then
          exit;

        CouponModule.Init;
        CouponModule.Type := CouponModule.Type::"Apply Discount";
        CouponModule.Code := ModuleCode();
        CouponModule.Description := Text000;
        CouponModule."Event Codeunit ID" := CurrCodeunitId();
        CouponModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnHasApplyDiscountSetup', '', true, true)]
    local procedure OnHasApplyDiscountSetup(CouponType: Record "NpDc Coupon Type";var HasApplySetup: Boolean)
    begin
        if not IsSubscriber(CouponType) then
          exit;

        HasApplySetup := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnSetupApplyDiscount', '', true, true)]
    local procedure OnSetupApplyDiscount(var CouponType: Record "NpDc Coupon Type")
    begin
        if not IsSubscriber(CouponType) then
          exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnRunApplyDiscount', '', true, true)]
    local procedure OnRunApplyDiscount(SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon";var Handled: Boolean)
    begin
        if Handled then
          exit;
        if not IsSubscriberPosCoupon(SaleLinePOSCoupon) then
          exit;

        Handled := true;

        ApplyDiscount(SaleLinePOSCoupon);
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NpDc Module Apply - Default");
    end;

    local procedure IsSubscriber(CouponType: Record "NpDc Coupon Type"): Boolean
    begin
        exit(CouponType."Apply Discount Module" = ModuleCode());
    end;

    local procedure IsSubscriberPosCoupon(SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon"): Boolean
    var
        CouponType: Record "NpDc Coupon Type";
    begin
        if not CouponType.Get(SaleLinePOSCoupon."Coupon Type") then
          exit(false);

        exit(IsSubscriber(CouponType));
    end;

    local procedure ModuleCode(): Code[20]
    begin
        exit('DEFAULT');
    end;
}

