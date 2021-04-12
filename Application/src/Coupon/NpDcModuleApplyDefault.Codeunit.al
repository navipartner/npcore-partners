codeunit 6151594 "NPR NpDc Module Apply: Default"
{
    var
        Text000: Label 'Apply Discount - Default';

    procedure ApplyDiscount(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon")
    var
        SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon";
        SaleLinePOS: Record "NPR POS Sale Line";
        DiscountAmt: Decimal;
        AppliedDiscountAmt: Decimal;
        TotalAmt: Decimal;
    begin
        if FindSaleLinePOSCouponApply(SaleLinePOSCoupon, SaleLinePOSCouponApply) then
            SaleLinePOSCouponApply.DeleteAll();

        if not FindSaleLinePOSItems(SaleLinePOSCoupon, SaleLinePOS) then
            exit;

        SaleLinePOS.CalcSums("Amount Including VAT");
        TotalAmt := SaleLinePOS."Amount Including VAT" - CalcAppliedDiscountTotal(SaleLinePOSCoupon);
        if TotalAmt <= 0 then
            exit;

        DiscountAmt := CalcDiscountAmount(SaleLinePOSCoupon, TotalAmt);
        if DiscountAmt <= 0 then
            exit;

        SaleLinePOS.FindSet();
        repeat
            ApplyDiscountLine(SaleLinePOSCoupon, DiscountAmt, TotalAmt, SaleLinePOS, AppliedDiscountAmt);
        until SaleLinePOS.Next() = 0;

        if AppliedDiscountAmt < DiscountAmt then begin
            SaleLinePOS.FindSet();
            repeat
                ApplyDiscountAdjustment(SaleLinePOSCoupon, DiscountAmt, SaleLinePOS, AppliedDiscountAmt);
            until (SaleLinePOS.Next() = 0) or (AppliedDiscountAmt = DiscountAmt);
        end;
    end;

    procedure ApplyDiscountLine(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; DiscountAmt: Decimal; TotalAmt: Decimal; SaleLinePOS: Record "NPR POS Sale Line"; var AppliedDiscountAmt: Decimal)
    var
        SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon";
        LineNo: Integer;
        LineDiscountAmt: Decimal;
        LineDiscountPct: Decimal;
        LineDiscountBaseAmt: Decimal;
    begin
        LineDiscountPct := (SaleLinePOS."Amount Including VAT" - CalcAppliedDiscount(SaleLinePOS)) / TotalAmt;
        LineDiscountAmt := Round(DiscountAmt * LineDiscountPct, 0.01);
        if LineDiscountAmt <= 0 then
            exit;

        LineDiscountBaseAmt := SaleLinePOS."Amount Including VAT";
        if (not SaleLinePOS."Price Includes VAT") then
            LineDiscountBaseAmt := SaleLinePOS.Amount;

        if LineDiscountAmt > LineDiscountBaseAmt then
            LineDiscountAmt := LineDiscountBaseAmt;

        LineNo := GetNextLineNo(SaleLinePOS);
        SaleLinePOSCouponApply.Init();
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

        AppliedDiscountAmt += LineDiscountAmt;
    end;

    local procedure ApplyDiscountAdjustment(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; DiscountAmt: Decimal; SaleLinePOS: Record "NPR POS Sale Line"; var AppliedDiscountAmt: Decimal)
    var
        SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon";
        AdjustmentAmount: Decimal;
        LineDiscountBaseAmt: Decimal;
    begin
        AdjustmentAmount := DiscountAmt - AppliedDiscountAmt;
        if AdjustmentAmount <= 0 then
            exit;

        if not FindSaleLinePOSCouponApply2(SaleLinePOSCoupon, SaleLinePOS, SaleLinePOSCouponApply) then
            exit;

        LineDiscountBaseAmt := SaleLinePOS."Amount Including VAT";
        if (not SaleLinePOS."Price Includes VAT") then
            LineDiscountBaseAmt := SaleLinePOS.Amount;

        if AdjustmentAmount > LineDiscountBaseAmt - SaleLinePOSCouponApply."Discount Amount" then
            AdjustmentAmount := LineDiscountBaseAmt - SaleLinePOSCouponApply."Discount Amount";

        if AdjustmentAmount <= 0 then
            exit;

        AppliedDiscountAmt += AdjustmentAmount;

        SaleLinePOSCouponApply."Discount Amount" += AdjustmentAmount;
        SaleLinePOSCouponApply.Modify();
    end;

    local procedure CalcAppliedDiscountTotal(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"): Decimal
    var
        SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon";
    begin
        SaleLinePOSCouponApply.SetRange("Register No.", SaleLinePOSCoupon."Register No.");
        SaleLinePOSCouponApply.SetRange("Sales Ticket No.", SaleLinePOSCoupon."Sales Ticket No.");
        SaleLinePOSCouponApply.SetRange("Sale Type", SaleLinePOSCoupon."Sale Type");
        SaleLinePOSCouponApply.SetRange("Sale Date", SaleLinePOSCoupon."Sale Date");
        SaleLinePOSCouponApply.SetRange(Type, SaleLinePOSCouponApply.Type::Discount);
        if SaleLinePOSCouponApply.IsEmpty then
            exit(0);

        SaleLinePOSCouponApply.CalcSums("Discount Amount");
        exit(SaleLinePOSCouponApply."Discount Amount");
    end;

    local procedure CalcAppliedDiscount(SaleLinePOS: Record "NPR POS Sale Line"): Decimal
    var
        SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon";
    begin
        SaleLinePOSCouponApply.SetRange("Register No.", SaleLinePOS."Register No.");
        SaleLinePOSCouponApply.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        SaleLinePOSCouponApply.SetRange("Sale Type", SaleLinePOS."Sale Type");
        SaleLinePOSCouponApply.SetRange("Sale Date", SaleLinePOS.Date);
        SaleLinePOSCouponApply.SetRange("Sale Line No.", SaleLinePOS."Line No.");
        SaleLinePOSCouponApply.SetRange(Type, SaleLinePOSCouponApply.Type::Discount);
        if SaleLinePOSCouponApply.IsEmpty then
            exit(0);

        SaleLinePOSCouponApply.CalcSums("Discount Amount");
        exit(SaleLinePOSCouponApply."Discount Amount");
    end;

    procedure CalcDiscountAmount(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; TotalAmt: Decimal) DiscountAmount: Decimal
    var
        Coupon: Record "NPR NpDc Coupon";
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

    local procedure FindSaleLinePOSItems(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; var SaleLinePOS: Record "NPR POS Sale Line"): Boolean
    begin
        Clear(SaleLinePOS);
        SaleLinePOS.SetRange("Register No.", SaleLinePOSCoupon."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SaleLinePOSCoupon."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SaleLinePOSCoupon."Sale Date");
        SaleLinePOS.SetRange("Sale Type", SaleLinePOSCoupon."Sale Type");
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
        SaleLinePOS.SetFilter(Quantity, '>%1', 0);
        exit(SaleLinePOS.FindFirst());
    end;

    local procedure FindSaleLinePOSCouponApply(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; var SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon"): Boolean
    begin
        Clear(SaleLinePOSCouponApply);
        SaleLinePOSCouponApply.SetRange("Register No.", SaleLinePOSCoupon."Register No.");
        SaleLinePOSCouponApply.SetRange("Sales Ticket No.", SaleLinePOSCoupon."Sales Ticket No.");
        SaleLinePOSCouponApply.SetRange("Sale Type", SaleLinePOSCoupon."Sale Type");
        SaleLinePOSCouponApply.SetRange("Sale Date", SaleLinePOSCoupon."Sale Date");
        SaleLinePOSCouponApply.SetRange(Type, SaleLinePOSCouponApply.Type::Discount);
        SaleLinePOSCouponApply.SetRange("Applies-to Sale Line No.", SaleLinePOSCoupon."Sale Line No.");
        SaleLinePOSCouponApply.SetRange("Applies-to Coupon Line No.", SaleLinePOSCoupon."Line No.");
        SaleLinePOSCouponApply.SetRange("Coupon Type", SaleLinePOSCoupon."Coupon Type");
        SaleLinePOSCouponApply.SetRange("Coupon No.", SaleLinePOSCoupon."Coupon No.");

        exit(SaleLinePOSCouponApply.FindFirst());
    end;

    local procedure FindSaleLinePOSCouponApply2(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; SaleLinePOS: Record "NPR POS Sale Line"; var SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon"): Boolean
    begin
        Clear(SaleLinePOSCouponApply);
        SaleLinePOSCouponApply.SetRange("Register No.", SaleLinePOS."Register No.");
        SaleLinePOSCouponApply.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        SaleLinePOSCouponApply.SetRange("Sale Type", SaleLinePOS."Sale Type");
        SaleLinePOSCouponApply.SetRange("Sale Date", SaleLinePOS.Date);
        SaleLinePOSCouponApply.SetRange("Line No.", SaleLinePOS."Line No.");
        SaleLinePOSCouponApply.SetRange(Type, SaleLinePOSCouponApply.Type::Discount);
        SaleLinePOSCouponApply.SetRange("Applies-to Sale Line No.", SaleLinePOSCoupon."Sale Line No.");
        SaleLinePOSCouponApply.SetRange("Applies-to Coupon Line No.", SaleLinePOSCoupon."Line No.");
        SaleLinePOSCouponApply.SetRange("Coupon Type", SaleLinePOSCoupon."Coupon Type");
        SaleLinePOSCouponApply.SetRange("Coupon No.", SaleLinePOSCoupon."Coupon No.");

        exit(SaleLinePOSCouponApply.FindFirst());
    end;

    local procedure GetNextLineNo(SaleLinePOS: Record "NPR POS Sale Line"): Integer
    var
        SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
    begin
        SaleLinePOSCoupon.SetRange("Register No.", SaleLinePOS."Register No.");
        SaleLinePOSCoupon.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        SaleLinePOSCoupon.SetRange("Sale Type", SaleLinePOS."Sale Type");
        SaleLinePOSCoupon.SetRange("Sale Date", SaleLinePOS.Date);
        SaleLinePOSCoupon.SetRange("Sale Line No.", SaleLinePOS."Line No.");
        if SaleLinePOSCoupon.FindLast() then;

        exit(SaleLinePOSCoupon."Line No." + 10000);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnInitCouponModules', '', true, true)]
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

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnHasApplyDiscountSetup', '', true, true)]
    local procedure OnHasApplyDiscountSetup(CouponType: Record "NPR NpDc Coupon Type"; var HasApplySetup: Boolean)
    begin
        if not IsSubscriber(CouponType) then
            exit;

        HasApplySetup := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnSetupApplyDiscount', '', true, true)]
    local procedure OnSetupApplyDiscount(var CouponType: Record "NPR NpDc Coupon Type")
    begin
        if not IsSubscriber(CouponType) then
            exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnRunApplyDiscount', '', true, true)]
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
        exit(CODEUNIT::"NPR NpDc Module Apply: Default");
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

    local procedure ModuleCode(): Code[20]
    begin
        exit('DEFAULT');
    end;
}

