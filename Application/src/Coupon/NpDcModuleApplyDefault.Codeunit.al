codeunit 6151594 "NPR NpDc Module Apply: Default"
{
    Access = Internal;

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

        if AppliedDiscountAmt <> DiscountAmt then begin
            SaleLinePOS.FindSet();
            repeat
                ApplyDiscountAdjustment(SaleLinePOSCoupon, DiscountAmt, SaleLinePOS, AppliedDiscountAmt);
            until (SaleLinePOS.Next() = 0) or (AppliedDiscountAmt = DiscountAmt);
        end;
    end;

    procedure ApplyDiscountLine(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; DiscountAmtIncludingVAT: Decimal; TotalAmt: Decimal; SaleLinePOS: Record "NPR POS Sale Line"; var AppliedDiscountAmt: Decimal)
    var
        SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        LineNo: Integer;
        LineDiscountAmt: Decimal;
        LineDiscountAmountIncludingVAT: Decimal;
        LineDiscountAmountExcludingVAT: Decimal;
        LineDiscountPct: Decimal;
        LineDiscountBaseAmt: Decimal;
    begin
        LineDiscountPct := (SaleLinePOS."Amount Including VAT" - CalcAppliedDiscount(SaleLinePOS)) / TotalAmt;
        LineDiscountAmountIncludingVAT := Round(DiscountAmtIncludingVAT * LineDiscountPct, 0.01);
        if LineDiscountAmountIncludingVAT <= 0 then
            exit;

        LineDiscountBaseAmt := SaleLinePOS."Amount Including VAT";

        if LineDiscountAmountIncludingVAT > LineDiscountBaseAmt then
            LineDiscountAmountIncludingVAT := LineDiscountBaseAmt;

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        LineDiscountAmountExcludingVAT := NPRPOSSaleTaxCalc.CalcAmountWithoutVAT(LineDiscountAmountIncludingVAT,
                                                                                 SaleLinePOS."VAT %",
                                                                                 GeneralLedgerSetup."Amount Rounding Precision");
        if SaleLinePOS."Price Includes VAT" then
            LineDiscountAmt := LineDiscountAmountIncludingVAT
        else
            LineDiscountAmt := LineDiscountAmountExcludingVAT;

        LineNo := GetNextLineNo(SaleLinePOS);
        SaleLinePOSCouponApply.Init();
        SaleLinePOSCouponApply."Register No." := SaleLinePOS."Register No.";
        SaleLinePOSCouponApply."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
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
        SaleLinePOSCouponApply."Discount Amount Excluding VAT" := LineDiscountAmountExcludingVAT;
        SaleLinePOSCouponApply."Discount Amount Including VAT" := LineDiscountAmountIncludingVAT;
        SaleLinePOSCouponApply.Insert(true);

        AppliedDiscountAmt += LineDiscountAmountIncludingVAT;
    end;

    local procedure ApplyDiscountAdjustment(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; DiscountAmt: Decimal; SaleLinePOS: Record "NPR POS Sale Line"; var AppliedDiscountAmt: Decimal)
    var
        SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        AdjustmentAmountIncludingVAT: Decimal;
        AdjustmentAmountExcludingVAT: Decimal;
        AdjustmentAmount: Decimal;
        LineDiscountBaseAmt: Decimal;
    begin
        AdjustmentAmountIncludingVAT := DiscountAmt - AppliedDiscountAmt;
        if AdjustmentAmountIncludingVAT = 0 then
            exit;

        if not FindSaleLinePOSCouponApply2(SaleLinePOSCoupon, SaleLinePOS, SaleLinePOSCouponApply) then
            exit;

        if AdjustmentAmountIncludingVAT > 0 then begin
            LineDiscountBaseAmt := SaleLinePOS."Amount Including VAT";

            if AdjustmentAmountIncludingVAT > LineDiscountBaseAmt - SaleLinePOSCouponApply."Discount Amount Including VAT" then
                AdjustmentAmountIncludingVAT := LineDiscountBaseAmt - SaleLinePOSCouponApply."Discount Amount Including VAT";

            if AdjustmentAmountIncludingVAT <= 0 then
                exit;
        end;

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        AdjustmentAmountExcludingVAT := NPRPOSSaleTaxCalc.CalcAmountWithoutVAT(AdjustmentAmountIncludingVAT,
                                                                               SaleLinePOS."VAT %",
                                                                               GeneralLedgerSetup."Amount Rounding Precision");

        if SaleLinePOS."Price Includes VAT" then
            AdjustmentAmount := AdjustmentAmountIncludingVAT
        else
            AdjustmentAmount := AdjustmentAmountExcludingVAT;

        AppliedDiscountAmt += AdjustmentAmountIncludingVAT;

        SaleLinePOSCouponApply."Discount Amount" += AdjustmentAmount;
        SaleLinePOSCouponApply."Discount Amount Including VAT" += AdjustmentAmountIncludingVAT;
        SaleLinePOSCouponApply."Discount Amount Excluding VAT" += AdjustmentAmountExcludingVAT;
        SaleLinePOSCouponApply.Modify();
    end;

    local procedure CalcAppliedDiscountTotal(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"): Decimal
    var
        SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon";
    begin
        SaleLinePOSCouponApply.SetRange("Register No.", SaleLinePOSCoupon."Register No.");
        SaleLinePOSCouponApply.SetRange("Sales Ticket No.", SaleLinePOSCoupon."Sales Ticket No.");
        SaleLinePOSCouponApply.SetRange("Sale Date", SaleLinePOSCoupon."Sale Date");
        SaleLinePOSCouponApply.SetRange(Type, SaleLinePOSCouponApply.Type::Discount);
        if SaleLinePOSCouponApply.IsEmpty then
            exit(0);

        SaleLinePOSCouponApply.CalcSums("Discount Amount Including VAT");
        exit(SaleLinePOSCouponApply."Discount Amount Including VAT");
    end;

    local procedure CalcAppliedDiscount(SaleLinePOS: Record "NPR POS Sale Line"): Decimal
    var
        SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon";
    begin
        SaleLinePOSCouponApply.SetRange("Register No.", SaleLinePOS."Register No.");
        SaleLinePOSCouponApply.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        SaleLinePOSCouponApply.SetRange("Sale Date", SaleLinePOS.Date);
        SaleLinePOSCouponApply.SetRange("Sale Line No.", SaleLinePOS."Line No.");
        SaleLinePOSCouponApply.SetRange(Type, SaleLinePOSCouponApply.Type::Discount);
        if SaleLinePOSCouponApply.IsEmpty then
            exit(0);

        SaleLinePOSCouponApply.CalcSums("Discount Amount Including VAT");
        exit(SaleLinePOSCouponApply."Discount Amount Including VAT");
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
        SaleLinePOS.SetFilter("Line Type", '=%1|=%2', SaleLinePOS."Line Type"::Item, SaleLinePOS."Line Type"::"Issue Voucher");
        SaleLinePOS.SetFilter(Quantity, '>%1', 0);
        exit(SaleLinePOS.FindFirst());
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

    local procedure FindSaleLinePOSCouponApply2(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; SaleLinePOS: Record "NPR POS Sale Line"; var SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon"): Boolean
    begin
        Clear(SaleLinePOSCouponApply);
        SaleLinePOSCouponApply.SetRange("Register No.", SaleLinePOS."Register No.");
        SaleLinePOSCouponApply.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
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
        SaleLinePOSCoupon.SetRange("Sale Date", SaleLinePOS.Date);
        SaleLinePOSCoupon.SetRange("Sale Line No.", SaleLinePOS."Line No.");
        if SaleLinePOSCoupon.FindLast() then;

        exit(SaleLinePOSCoupon."Line No." + 10000);
    end;

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

