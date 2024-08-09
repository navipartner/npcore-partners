codeunit 6151596 "NPR NpDc Module Apply ItemList"
{
    Access = Internal;

    var
        Text000: Label 'Apply Discount - Item List';

    local procedure ApplyDiscount(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon")
    var
        Coupon: Record "NPR NpDc Coupon";
        NpDcCouponListItem: Record "NPR NpDc Coupon List Item";
        TempNpDcCouponListItem: Record "NPR NpDc Coupon List Item" temporary;
        SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon";
        DiscountAmt: Decimal;
        RemainingDiscountAmt: Decimal;
        RemainingQty: Decimal;
        TotalAmt: Decimal;
    begin
        if FindSaleLinePOSCouponApply(SaleLinePOSCoupon, SaleLinePOSCouponApply) then
            SaleLinePOSCouponApply.DeleteAll();

        if not FindCouponListItems(SaleLinePOSCoupon, NpDcCouponListItem) then
            exit;

        RemainingQty := -1;
        NpDcCouponListItem."Apply Discount" := NpDcCouponListItem."Apply Discount"::Priority;

        if NpDcCouponListItem.Get(SaleLinePOSCoupon."Coupon Type", -1) then
            RemainingQty := NpDcCouponListItem."Max. Quantity";

        CreateTempNpDcCouponListItems(TempNpDcCouponListItem, SaleLinePOSCoupon, NpDcCouponListItem."Apply Discount");

        TotalAmt := CalcTotalAmt(NpDcCouponListItem, TempNpDcCouponListItem, SaleLinePOSCoupon);
        if TotalAmt <= 0 then
            exit;

        DiscountAmt := CalcDiscountAmount(SaleLinePOSCoupon, TotalAmt);
        if DiscountAmt <= 0 then
            exit;
        RemainingDiscountAmt := DiscountAmt;

        case NpDcCouponListItem."Apply Discount" of
            NpDcCouponListItem."Apply Discount"::"Priority":
                begin
                    TempNpDcCouponListItem.SetCurrentKey(Priority);
                end;
            NpDcCouponListItem."Apply Discount"::"Highest price":
                begin
                    TempNpDcCouponListItem.SetCurrentKey("Unit Price");
                    TempNpDcCouponListItem.SetAscending("Unit Price", false);
                end;

            NpDcCouponListItem."Apply Discount"::"Lowest price":
                begin
                    TempNpDcCouponListItem.SetCurrentKey("Unit Price");
                    TempNpDcCouponListItem.SetAscending("Unit Price", true);
                end;

        end;
        TempNpDcCouponListItem.FindSet();
        Coupon.Get(SaleLinePOSCoupon."Coupon No.");
        if Coupon."Discount Type" = Coupon."Discount Type"::"Discount %" then begin
            repeat
                ApplyDiscountItemListPercent(SaleLinePOSCoupon, Coupon."Discount %", TempNpDcCouponListItem, RemainingDiscountAmt, RemainingQty);
            until TempNpDcCouponListItem.Next() = 0;
            exit;
        end;
        repeat
            ApplyDiscountItemList(SaleLinePOSCoupon, DiscountAmt, TempNpDcCouponListItem, RemainingDiscountAmt, RemainingQty)
        until (TempNpDcCouponListItem.Next() = 0) or (DiscountAmt <= 0);
    end;

    [Obsolete('Use ApplyDiscountItemList instead', '2024-04-28')]
    local procedure ApplyDiscountListItem(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; DiscountAmt: Decimal; NpDcCouponListItem: Record "NPR NpDc Coupon List Item"; var RemainingDiscountAmt: Decimal; RemainingQty: Decimal)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        AppliedListItemDiscAmt: Decimal;
        AppliedQty: Decimal;
    begin
        if DiscountAmt <= 0 then
            exit;

        if not FindSaleLinePOSItems(SaleLinePOSCoupon, NpDcCouponListItem, SaleLinePOS) then
            exit;

        AppliedListItemDiscAmt := 0;
        SaleLinePOS.FindSet();
        repeat
            ApplyDiscountSaleLinePOS(SaleLinePOSCoupon, NpDcCouponListItem, SaleLinePOS, AppliedListItemDiscAmt, RemainingDiscountAmt, AppliedQty, RemainingQty);
        until (SaleLinePOS.Next() = 0) or (RemainingDiscountAmt <= 0) or (RemainingQty = 0);
    end;

    local procedure ApplyDiscountItemList(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; DiscountAmt: Decimal; NpDcCouponListItem: Record "NPR NpDc Coupon List Item"; var RemainingDiscountAmt: Decimal; RemainingQty: Decimal)
    var
        CouponSalesLineApplicationOrderBuffer: Record "NPR Coupon Line Appl Buffer";
        AppliedListItemDiscAmt: Decimal;
        AppliedQty: Decimal;
    begin
        if DiscountAmt <= 0 then
            exit;

        AppliedListItemDiscAmt := 0;

        if not GetSalesLinesCouponApplication(SaleLinePOSCoupon, NpDcCouponListItem, CouponSalesLineApplicationOrderBuffer) then
            exit;

        repeat
            ApplyDiscountSaleLine(SaleLinePOSCoupon, NpDcCouponListItem, CouponSalesLineApplicationOrderBuffer, AppliedListItemDiscAmt, RemainingDiscountAmt, AppliedQty, RemainingQty);
        until (CouponSalesLineApplicationOrderBuffer.Next() = 0) or (RemainingDiscountAmt <= 0) or (RemainingQty = 0);
    end;

    [Obsolete('Use ApplyDiscountItemListPercent instead', '2024-04-28')]
    local procedure ApplyDiscountListItemPct(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; DiscountPct: Decimal; NpDcCouponListItem: Record "NPR NpDc Coupon List Item"; var RemainingDiscountAmt: Decimal; var RemainingQty: Decimal)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        AppliedQty: Decimal;
        DiscountAmt: Decimal;
        DiscountAmountIncludingVAT: Decimal;
        DiscountAmountExcludingVAT: Decimal;
        QtyToApply: Integer;
        LineNo: Integer;
    begin
        if not FindSaleLinePOSItems(SaleLinePOSCoupon, NpDcCouponListItem, SaleLinePOS) then
            exit;

        if DiscountPct > 100 then
            DiscountPct := 100;

        SaleLinePOS.FindSet();
        repeat
            QtyToApply := SaleLinePOS.Quantity;
            if (NpDcCouponListItem."Max. Quantity" > 0) and (AppliedQty + QtyToApply > NpDcCouponListItem."Max. Quantity") then
                QtyToApply := NpDcCouponListItem."Max. Quantity" - AppliedQty;
            if (QtyToApply > RemainingQty) and (RemainingQty >= 0) then
                QtyToApply := RemainingQty;

            SaleLinePOS."Amount Including VAT" := (SaleLinePOS."Amount Including VAT" / SaleLinePOS.Quantity) * QtyToApply;
            DiscountAmountIncludingVAT := SaleLinePOS."Amount Including VAT" * (DiscountPct / 100);
            if (NpDcCouponListItem."Max. Discount Amount" > 0) and (DiscountAmountIncludingVAT > NpDcCouponListItem."Max. Discount Amount") then
                DiscountAmountIncludingVAT := NpDcCouponListItem."Max. Discount Amount";

            if not GeneralLedgerSetup.Get() then
                Clear(GeneralLedgerSetup);

            DiscountAmountExcludingVAT := NPRPOSSaleTaxCalc.CalcAmountWithoutVAT(DiscountAmountIncludingVAT,
                                                                                 SaleLinePOS."VAT %",
                                                                                 GeneralLedgerSetup."Amount Rounding Precision");

            if SaleLinePOS."Price Includes VAT" then
                DiscountAmt := DiscountAmountIncludingVAT
            else
                DiscountAmt := DiscountAmountExcludingVAT;

            if DiscountAmt > 0 then begin
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
                SaleLinePOSCouponApply."Discount Amount" := DiscountAmt;
                SaleLinePOSCouponApply."Discount Amount Including VAT" := DiscountAmountIncludingVAT;
                SaleLinePOSCouponApply."Discount Amount Excluding VAT" := DiscountAmountExcludingVAT;
                SaleLinePOSCouponApply.Insert(true);

                RemainingDiscountAmt -= DiscountAmountIncludingVAT;
                AppliedQty += QtyToApply;
                RemainingQty -= QtyToApply;
            end;
        until (SaleLinePOS.Next() = 0) or (RemainingDiscountAmt <= 0) or (RemainingQty = 0);
    end;

    local procedure ApplyDiscountItemListPercent(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; DiscountPct: Decimal; NpDcCouponListItem: Record "NPR NpDc Coupon List Item"; var RemainingDiscountAmt: Decimal; var RemainingQty: Decimal)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon";
        CouponSalesLineApplicationOrderBuffer: Record "NPR Coupon Line Appl Buffer";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        AppliedQty: Decimal;
        DiscountAmt: Decimal;
        DiscountAmountIncludingVAT: Decimal;
        DiscountAmountExcludingVAT: Decimal;
        QtyToApply: Integer;
        LineNo: Integer;
    begin
        if not GetSalesLinesCouponApplication(SaleLinePOSCoupon, NpDcCouponListItem, CouponSalesLineApplicationOrderBuffer) then
            exit;

        if DiscountPct > 100 then
            DiscountPct := 100;

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        repeat
            QtyToApply := CouponSalesLineApplicationOrderBuffer.Quantity;

            if (NpDcCouponListItem."Max. Quantity" > 0) and (AppliedQty + QtyToApply > NpDcCouponListItem."Max. Quantity") then
                QtyToApply := NpDcCouponListItem."Max. Quantity" - AppliedQty;

            if (QtyToApply > RemainingQty) and (RemainingQty >= 0) then
                QtyToApply := RemainingQty;

            CouponSalesLineApplicationOrderBuffer."Amount Including VAT" := (CouponSalesLineApplicationOrderBuffer."Amount Including VAT" / CouponSalesLineApplicationOrderBuffer.Quantity) * QtyToApply;
            DiscountAmountIncludingVAT := CouponSalesLineApplicationOrderBuffer."Amount Including VAT" * (DiscountPct / 100);
            if (NpDcCouponListItem."Max. Discount Amount" > 0) and (DiscountAmountIncludingVAT > NpDcCouponListItem."Max. Discount Amount") then
                DiscountAmountIncludingVAT := NpDcCouponListItem."Max. Discount Amount";

            DiscountAmountExcludingVAT := NPRPOSSaleTaxCalc.CalcAmountWithoutVAT(DiscountAmountIncludingVAT, CouponSalesLineApplicationOrderBuffer."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

            if CouponSalesLineApplicationOrderBuffer."Price Includes VAT" then
                DiscountAmt := DiscountAmountIncludingVAT
            else
                DiscountAmt := DiscountAmountExcludingVAT;

            if DiscountAmt > 0 then begin
                LineNo := GetNextCouponSalesLineNoFromCouponPriorityBuffer(CouponSalesLineApplicationOrderBuffer);
                SaleLinePOSCouponApply.Init();
                SaleLinePOSCouponApply."Register No." := CouponSalesLineApplicationOrderBuffer."Register No.";
                SaleLinePOSCouponApply."Sales Ticket No." := CouponSalesLineApplicationOrderBuffer."Sales Ticket No.";
                SaleLinePOSCouponApply."Sale Date" := CouponSalesLineApplicationOrderBuffer.Date;
                SaleLinePOSCouponApply."Sale Line No." := CouponSalesLineApplicationOrderBuffer."Line No.";
                SaleLinePOSCouponApply."Line No." := LineNo;
                SaleLinePOSCouponApply.Type := SaleLinePOSCouponApply.Type::Discount;
                SaleLinePOSCouponApply."Applies-to Sale Line No." := SaleLinePOSCoupon."Sale Line No.";
                SaleLinePOSCouponApply."Applies-to Coupon Line No." := SaleLinePOSCoupon."Line No.";
                SaleLinePOSCouponApply."Coupon Type" := SaleLinePOSCoupon."Coupon Type";
                SaleLinePOSCouponApply."Coupon No." := SaleLinePOSCoupon."Coupon No.";
                SaleLinePOSCouponApply.Description := SaleLinePOSCoupon.Description;
                SaleLinePOSCouponApply."Discount Amount" := DiscountAmt;
                SaleLinePOSCouponApply."Discount Amount Including VAT" := DiscountAmountIncludingVAT;
                SaleLinePOSCouponApply."Discount Amount Excluding VAT" := DiscountAmountExcludingVAT;
                SaleLinePOSCouponApply.Insert(true);

                RemainingDiscountAmt -= DiscountAmountIncludingVAT;
                AppliedQty += QtyToApply;
                RemainingQty -= QtyToApply;
            end;
        until (CouponSalesLineApplicationOrderBuffer.Next() = 0) or (RemainingDiscountAmt <= 0) or (RemainingQty = 0);
    end;

    [Obsolete('Use ApplyDiscountSaleLinePOS instead', '2024-04-28')]
    local procedure ApplyDiscountSaleLinePOS(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; NpDcCouponListItem: Record "NPR NpDc Coupon List Item"; SaleLinePOS: Record "NPR POS Sale Line"; var AppliedListItemDiscAmt: Decimal; var RemainingDiscountAmt: Decimal; AppliedQty: Decimal; var RemainingQty: Decimal)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        LineNo: Integer;
        LineDiscountAmt: Decimal;
        DiscountAmountIncludingVAT: Decimal;
        DiscountAmountExcludingVAT: Decimal;
        QtyToApply: Integer;
    begin
        QtyToApply := SaleLinePOS.Quantity;
        if (NpDcCouponListItem."Max. Quantity" > 0) and (AppliedQty + QtyToApply > NpDcCouponListItem."Max. Quantity") then
            QtyToApply := NpDcCouponListItem."Max. Quantity" - AppliedQty;
        if (QtyToApply > RemainingQty) and (RemainingQty >= 0) then
            QtyToApply := RemainingQty;

        DiscountAmountIncludingVAT := SaleLinePOS."Amount Including VAT" - CalcAppliedDiscount(SaleLinePOS);
        if DiscountAmountIncludingVAT > RemainingDiscountAmt then
            DiscountAmountIncludingVAT := RemainingDiscountAmt;
        if (NpDcCouponListItem."Max. Discount Amount" > 0) and (DiscountAmountIncludingVAT + AppliedListItemDiscAmt > NpDcCouponListItem."Max. Discount Amount") then
            DiscountAmountIncludingVAT := NpDcCouponListItem."Max. Discount Amount" - AppliedListItemDiscAmt;
        if DiscountAmountIncludingVAT > SaleLinePOS."Amount Including VAT" then
            DiscountAmountIncludingVAT := SaleLinePOS."Amount Including VAT";
        if DiscountAmountIncludingVAT <= 0 then
            exit;

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        DiscountAmountExcludingVAT := NPRPOSSaleTaxCalc.CalcAmountWithoutVAT(DiscountAmountIncludingVAT,
                                                                            SaleLinePOS."VAT %",
                                                                            GeneralLedgerSetup."Amount Rounding Precision");

        if SaleLinePOS."Price Includes VAT" then
            LineDiscountAmt := DiscountAmountIncludingVAT
        else
            LineDiscountAmt := DiscountAmountExcludingVAT;

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
        SaleLinePOSCouponApply."Discount Amount Including VAT" := DiscountAmountIncludingVAT;
        SaleLinePOSCouponApply."Discount Amount Excluding VAT" := DiscountAmountExcludingVAT;
        SaleLinePOSCouponApply.Insert(true);

        AppliedListItemDiscAmt += DiscountAmountIncludingVAT;
        RemainingDiscountAmt -= DiscountAmountIncludingVAT;
        RemainingQty -= QtyToApply;
    end;

    local procedure ApplyDiscountSaleLine(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; NpDcCouponListItem: Record "NPR NpDc Coupon List Item"; CouponSalesLineApplicationOrderBuffer: Record "NPR Coupon Line Appl Buffer"; var AppliedListItemDiscAmt: Decimal; var RemainingDiscountAmt: Decimal; AppliedQty: Decimal; var RemainingQty: Decimal)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        LineNo: Integer;
        LineDiscountAmt: Decimal;
        DiscountAmountIncludingVAT: Decimal;
        DiscountAmountExcludingVAT: Decimal;
        QtyToApply: Integer;
    begin
        QtyToApply := CouponSalesLineApplicationOrderBuffer.Quantity;
        if (NpDcCouponListItem."Max. Quantity" > 0) and (AppliedQty + QtyToApply > NpDcCouponListItem."Max. Quantity") then
            QtyToApply := NpDcCouponListItem."Max. Quantity" - AppliedQty;
        if (QtyToApply > RemainingQty) and (RemainingQty >= 0) then
            QtyToApply := RemainingQty;

        DiscountAmountIncludingVAT := CouponSalesLineApplicationOrderBuffer."Amount Including VAT" - CalcAppliedDiscountWithVATFromCouponPriorityBuffer(CouponSalesLineApplicationOrderBuffer);
        if DiscountAmountIncludingVAT > RemainingDiscountAmt then
            DiscountAmountIncludingVAT := RemainingDiscountAmt;
        if (NpDcCouponListItem."Max. Discount Amount" > 0) and (DiscountAmountIncludingVAT + AppliedListItemDiscAmt > NpDcCouponListItem."Max. Discount Amount") then
            DiscountAmountIncludingVAT := NpDcCouponListItem."Max. Discount Amount" - AppliedListItemDiscAmt;
        if DiscountAmountIncludingVAT > CouponSalesLineApplicationOrderBuffer."Amount Including VAT" then
            DiscountAmountIncludingVAT := CouponSalesLineApplicationOrderBuffer."Amount Including VAT";
        if DiscountAmountIncludingVAT <= 0 then
            exit;

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        DiscountAmountExcludingVAT := NPRPOSSaleTaxCalc.CalcAmountWithoutVAT(DiscountAmountIncludingVAT, CouponSalesLineApplicationOrderBuffer."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        if CouponSalesLineApplicationOrderBuffer."Price Includes VAT" then
            LineDiscountAmt := DiscountAmountIncludingVAT
        else
            LineDiscountAmt := DiscountAmountExcludingVAT;

        LineNo := GetNextCouponSalesLineNoFromCouponPriorityBuffer(CouponSalesLineApplicationOrderBuffer);
        SaleLinePOSCouponApply.Init();
        SaleLinePOSCouponApply."Register No." := CouponSalesLineApplicationOrderBuffer."Register No.";
        SaleLinePOSCouponApply."Sales Ticket No." := CouponSalesLineApplicationOrderBuffer."Sales Ticket No.";
        SaleLinePOSCouponApply."Sale Date" := CouponSalesLineApplicationOrderBuffer.Date;
        SaleLinePOSCouponApply."Sale Line No." := CouponSalesLineApplicationOrderBuffer."Line No.";
        SaleLinePOSCouponApply."Line No." := LineNo;
        SaleLinePOSCouponApply.Type := SaleLinePOSCouponApply.Type::Discount;
        SaleLinePOSCouponApply."Applies-to Sale Line No." := SaleLinePOSCoupon."Sale Line No.";
        SaleLinePOSCouponApply."Applies-to Coupon Line No." := SaleLinePOSCoupon."Line No.";
        SaleLinePOSCouponApply."Coupon Type" := SaleLinePOSCoupon."Coupon Type";
        SaleLinePOSCouponApply."Coupon No." := SaleLinePOSCoupon."Coupon No.";
        SaleLinePOSCouponApply.Description := SaleLinePOSCoupon.Description;
        SaleLinePOSCouponApply."Discount Amount" := LineDiscountAmt;
        SaleLinePOSCouponApply."Discount Amount Including VAT" := DiscountAmountIncludingVAT;
        SaleLinePOSCouponApply."Discount Amount Excluding VAT" := DiscountAmountExcludingVAT;
        SaleLinePOSCouponApply.Insert(true);

        AppliedListItemDiscAmt += DiscountAmountIncludingVAT;
        RemainingDiscountAmt -= DiscountAmountIncludingVAT;
        RemainingQty -= QtyToApply;
    end;

    [Obsolete('Use CalcAppliedDiscountWithVATFromCouponPriorityBuffer instead', '2024-04-28')]
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

    local procedure CalcAppliedDiscountWithVATFromCouponPriorityBuffer(CouponSalesLineApplicationOrderBuffer: Record "NPR Coupon Line Appl Buffer") AppliedDiscountAmountIncludingVAT: Decimal
    var
        SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon";
    begin
        SaleLinePOSCouponApply.Reset();
        SaleLinePOSCouponApply.SetRange("Register No.", CouponSalesLineApplicationOrderBuffer."Register No.");
        SaleLinePOSCouponApply.SetRange("Sales Ticket No.", CouponSalesLineApplicationOrderBuffer."Sales Ticket No.");
        SaleLinePOSCouponApply.SetRange("Sale Date", CouponSalesLineApplicationOrderBuffer.Date);
        SaleLinePOSCouponApply.SetRange("Sale Line No.", CouponSalesLineApplicationOrderBuffer."Line No.");
        SaleLinePOSCouponApply.SetRange(Type, SaleLinePOSCouponApply.Type::Discount);
        if SaleLinePOSCouponApply.IsEmpty then
            exit;

        SaleLinePOSCouponApply.CalcSums("Discount Amount Including VAT");
        AppliedDiscountAmountIncludingVAT := SaleLinePOSCouponApply."Discount Amount Including VAT";
    end;

    local procedure CalcAppliedDiscountTotal(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"): Decimal
    var
        SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon";
    begin
        SaleLinePOSCouponApply.SetRange("Coupon Type", SaleLinePOSCoupon."Coupon Type");
        SaleLinePOSCouponApply.SetRange("Register No.", SaleLinePOSCoupon."Register No.");
        SaleLinePOSCouponApply.SetRange("Sales Ticket No.", SaleLinePOSCoupon."Sales Ticket No.");
        SaleLinePOSCouponApply.SetRange("Sale Date", SaleLinePOSCoupon."Sale Date");
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

    local procedure CalcTotalAmt(NpDcCouponListItem: Record "NPR NpDc Coupon List Item"; var TempNpDcCouponListItem: Record "NPR NpDc Coupon List Item" temporary; SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon") TotalAmt: Decimal
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        LineAmt: Decimal;
    begin
        TotalAmt := 0;
        case NpDcCouponListItem."Apply Discount" of
            NpDcCouponListItem."Apply Discount"::"Priority":
                begin
                    TempNpDcCouponListItem.SetCurrentKey(Priority);
                end;
            NpDcCouponListItem."Apply Discount"::"Highest price":
                begin
                    TempNpDcCouponListItem.SetCurrentKey("Unit Price");
                    TempNpDcCouponListItem.SetAscending("Unit Price", false);
                end;
            NpDcCouponListItem."Apply Discount"::"Lowest price":
                begin
                    TempNpDcCouponListItem.SetCurrentKey("Unit Price");
                    TempNpDcCouponListItem.SetAscending("Unit Price", true);
                end;
        end;

        if TempNpDcCouponListItem.FindSet() then begin
            repeat
                if FindSaleLinePOSItems(SaleLinePOSCoupon, TempNpDcCouponListItem, SaleLinePOS) then begin
                    SaleLinePOS.CalcSums("Amount Including VAT");
                    LineAmt := SaleLinePOS."Amount Including VAT";
                    if LineAmt < 0 then
                        LineAmt := 0;

                    TotalAmt += LineAmt;
                end;
            until TempNpDcCouponListItem.Next() = 0;
        end;

        TotalAmt -= CalcAppliedDiscountTotal(SaleLinePOSCoupon);
        exit(TotalAmt);
    end;

    local procedure CreateTempNpDcCouponListItems(var TempNpDcCouponListItem: Record "NPR NpDc Coupon List Item" temporary; SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; NpDcCouponListItemAssignOption: Option "Priority","Highest price","Lowest price")
    begin
        case NpDcCouponListItemAssignOption of
            NpDcCouponListItemAssignOption::"Priority":
                begin
                    CreateTempNpDcCouponListItemsPriority(TempNpDcCouponListItem, SaleLinePOSCoupon."Coupon Type");
                end;
            NpDcCouponListItemAssignOption::"Highest price",
            NpDcCouponListItemAssignOption::"Lowest price":
                begin
                    CreateTempNpDcCouponListItemsHighestLowest(TempNpDcCouponListItem, SaleLinePOSCoupon);
                end;
        end;
    end;

    local procedure CreateTempNpDcCouponListItemsPriority(var TempNpDcCouponListItem: Record "NPR NpDc Coupon List Item" temporary; SaleLinePOSCouponCode: Code[20])
    var
        NpDcCouponListItem: Record "NPR NpDc Coupon List Item";
    begin
        NpDcCouponListItem.SetRange("Coupon Type", SaleLinePOSCouponCode);
        NpDcCouponListItem.SetFilter("Line No.", '>%1', 0);
        if NpDcCouponListItem.FindSet() then begin
            repeat
                TempNpDcCouponListItem.Copy(NpDcCouponListItem);
                TempNpDcCouponListItem.Insert();
            until NpDcCouponListItem.Next() = 0;
        end;
    end;

    local procedure CreateTempNpDcCouponListItemsHighestLowest(var TempNpDcCouponListItem: Record "NPR NpDc Coupon List Item" temporary; SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        LineNo: Integer;
    begin
        SaleLinePOS.SetRange("Register No.", SaleLinePOSCoupon."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SaleLinePOSCoupon."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SaleLinePOSCoupon."Sale Date");
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        SaleLinePOS.SetRange("Benefit Item", false);
        SaleLinePOS.SetRange("Shipment Fee", false);
        SaleLinePOS.SetFilter(Quantity, '>%1', 0);


        if SaleLinePOS.FindSet() then begin
            LineNo := GetInitialTempNpDcCouponListItemLineNo(TempNpDcCouponListItem);

            repeat
                CreateTempNpDcCouponListItemFromSpecificScenario(TempNpDcCouponListItem, SaleLinePOSCoupon, SaleLinePOS, LineNo);
            until SaleLinePOS.Next() = 0;
        end;
    end;

    local procedure CreateTempNpDcCouponListItemFromSpecificScenario(var TempNpDcCouponListItem: Record "NPR NpDc Coupon List Item" temporary; SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; SaleLinePOS: Record "NPR POS Sale Line"; var LineNo: Integer)
    var
        NpDcCouponListItem: Record "NPR NpDc Coupon List Item";
    begin
        NpDcCouponListItem.SetRange("Coupon Type", SaleLinePOSCoupon."Coupon Type");
        NpDcCouponListItem.SetRange(Type, NpDcCouponListItem.Type::Item);
        NpDcCouponListItem.SetRange("No.", SaleLinePOS."No.");
        if not NpDcCouponListItem.IsEmpty() then begin
            CreateTempNpDcCouponListItem(TempNpDcCouponListItem, SaleLinePOS, SaleLinePOSCoupon."Coupon Type", LineNo);
            exit;
        end;

        if SaleLinePOS."Item Category Code" <> '' then begin
            NpDcCouponListItem.SetRange(Type, NpDcCouponListItem.Type::"Item Categories");
            NpDcCouponListItem.SetRange("No.", SaleLinePOS."Item Category Code");
            if not NpDcCouponListItem.IsEmpty() then begin
                CreateTempNpDcCouponListItem(TempNpDcCouponListItem, SaleLinePOS, SaleLinePOSCoupon."Coupon Type", LineNo);
                exit;
            end;
        end;

        if SaleLinePOS."Item Disc. Group" <> '' then begin
            NpDcCouponListItem.SetRange(Type, NpDcCouponListItem.Type::"Item Disc. Group");
            NpDcCouponListItem.SetRange("No.", SaleLinePOS."Item Disc. Group");
            if not NpDcCouponListItem.IsEmpty() then begin
                CreateTempNpDcCouponListItem(TempNpDcCouponListItem, SaleLinePOS, SaleLinePOSCoupon."Coupon Type", LineNo);
                exit;
            end;
        end;

        if SaleLinePOS."Magento Brand" <> '' then begin
            NpDcCouponListItem.SetRange(Type, NpDcCouponListItem.Type::"Magento Brand");
            NpDcCouponListItem.SetRange("No.", SaleLinePOS."Magento Brand");
            if not NpDcCouponListItem.IsEmpty() then
                CreateTempNpDcCouponListItem(TempNpDcCouponListItem, SaleLinePOS, SaleLinePOSCoupon."Coupon Type", LineNo);
        end;
    end;

    local procedure GetInitialTempNpDcCouponListItemLineNo(TempNpDcCouponListItem: Record "NPR NpDc Coupon List Item" temporary): Integer
    var
        LineNo: Integer;
    begin
        LineNo := 10000;
        if TempNpDcCouponListItem.FindLast() then
            LineNo += TempNpDcCouponListItem."Line No.";

        exit(LineNo);
    end;

    local procedure CreateTempNpDcCouponListItem(var TempNpDcCouponListItem: Record "NPR NpDc Coupon List Item" temporary; SaleLinePOS: Record "NPR POS Sale Line"; CouponType: Code[20]; var LineNo: Integer)
    begin
        TempNpDcCouponListItem.Init();
        TempNpDcCouponListItem."Coupon Type" := CouponType;
        TempNpDcCouponListItem."Line No." := LineNo;
        TempNpDcCouponListItem.Type := TempNpDcCouponListItem.Type::Item;
        TempNpDcCouponListItem."No." := SaleLinePOS."No.";
        TempNpDcCouponListItem."Unit Price" := SaleLinePOS."Unit Price";
        TempNpDcCouponListItem.Insert();

        LineNo += 10000;
    end;

    local procedure FindCouponListItems(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; var NpDcCouponListItem: Record "NPR NpDc Coupon List Item"): Boolean
    begin
        Clear(NpDcCouponListItem);
        NpDcCouponListItem.SetRange("Coupon Type", SaleLinePOSCoupon."Coupon Type");
        NpDcCouponListItem.SetFilter("No.", '<>%1', '');
        exit(NpDcCouponListItem.FindFirst());
    end;

    local procedure FindSaleLinePOSItems(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; NpDcCouponListItem: Record "NPR NpDc Coupon List Item"; var SaleLinePOS: Record "NPR POS Sale Line"): Boolean
    begin
        Clear(SaleLinePOS);
        SaleLinePOS.SetRange("Register No.", SaleLinePOSCoupon."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SaleLinePOSCoupon."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SaleLinePOSCoupon."Sale Date");
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        SaleLinePOS.SetRange("Benefit Item", false);
        SaleLinePOS.SetRange("Shipment Fee", false);
        case NpDcCouponListItem.Type of
            NpDcCouponListItem.Type::Item:
                begin
                    SaleLinePOS.SetRange("No.", NpDcCouponListItem."No.");
                end;
            NpDcCouponListItem.Type::"Item Categories":
                begin
                    SaleLinePOS.SetFilter("No.", '<>%1', '');
                    SaleLinePOS.SetRange("Item Category Code", NpDcCouponListItem."No.");
                end;
            NpDcCouponListItem.Type::"Item Disc. Group":
                begin
                    SaleLinePOS.SetFilter("No.", '<>%1', '');
                    SaleLinePOS.SetRange("Item Disc. Group", NpDcCouponListItem."No.");
                end;
            NpDcCouponListItem.Type::"Magento Brand":
                begin
                    SaleLinePOS.SetFilter("No.", '<>%1', '');
                    SaleLinePOS.SetRange("Magento Brand", NpDcCouponListItem."No.");
                end;
        end;
        SaleLinePOS.SetFilter(Quantity, '>%1', 0);
        SaleLinePOS.SetFilter("Amount Including VAT", '>0');
        exit(not SaleLinePOS.IsEmpty());
    end;

    local procedure GetSalesLinesCouponApplication(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; NpDcCouponListItem: Record "NPR NpDc Coupon List Item"; var CouponSalesLineApplicationOrderBuffer: Record "NPR Coupon Line Appl Buffer") Found: Boolean
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        CouponApplicationBufferData: Record "NPR Coupon Line Appl Buffer";
        LineBufferWithCalculatedAmounts: Record "NPR Coupon Line Appl Buffer";
        LineAmountBuffer: Record "NPR Coupon Line Appl Buffer";
        EntryNo: Integer;
        RemainingAmountIncludingVAT: Decimal;
        RemainingAmount: Decimal;
    begin
        CouponSalesLineApplicationOrderBuffer.Reset();
        if not CouponSalesLineApplicationOrderBuffer.IsEmpty then
            CouponSalesLineApplicationOrderBuffer.DeleteAll();

        if not FindSaleLinePOSItems(SaleLinePOSCoupon, NpDcCouponListItem, SaleLinePOS) then
            exit;

        SaleLinePOS.SetAutoCalcFields("Coupon Disc. Amount Incl. VAT", "Coupon Disc. Amount Excl. VAT");
        SaleLinePOS.SetLoadFields("Register No.", "Sales Ticket No.", Date, "Line Type", "Benefit Item", "Shipment Fee", "No.", Quantity, "Amount Including VAT", Amount, Quantity, "No.", "VAT %", "Line No.");
        if not SaleLinePOS.FindSet() then
            exit;

        repeat
            RemainingAmountIncludingVAT := SaleLinePOS."Amount Including VAT" - SaleLinePOS."Coupon Disc. Amount Incl. VAT";
            if RemainingAmountIncludingVAT > 0 then begin
                EntryNo += 1;
                RemainingAmount := SaleLinePOS.Amount - SaleLinePOS."Coupon Disc. Amount Excl. VAT";

                //Saving the data to the buffer
                CouponApplicationBufferData.Init();
                CouponApplicationBufferData."Entry No." := EntryNo;
                CouponApplicationBufferData.CopyInformationFromSaleLine(SaleLinePOS);
                CouponApplicationBufferData.Insert();

                //Populating the data with updated amount in buffer
                LineBufferWithCalculatedAmounts.Init();
                LineBufferWithCalculatedAmounts."Entry No." := EntryNo;
                LineBufferWithCalculatedAmounts.CopyInformationFromSaleLine(SaleLinePOS);
                LineBufferWithCalculatedAmounts."Amount Including VAT" := RemainingAmountIncludingVAT;
                LineBufferWithCalculatedAmounts."Amount Excluding VAT" := RemainingAmount;
                LineBufferWithCalculatedAmounts.Insert();

                //Creating a buffer with total amount
                LineAmountBuffer.Reset();
                LineAmountBuffer.SetRange("Amount Including VAT", LineBufferWithCalculatedAmounts."Amount Including VAT");
                if LineAmountBuffer.IsEmpty then begin
                    LineAmountBuffer.Init();
                    LineAmountBuffer := LineBufferWithCalculatedAmounts;
                    LineAmountBuffer.Insert();
                end;
            end;
        until SaleLinePOS.Next() = 0;

        //Ordering the lines in the right order
        EntryNo := 0;

        LineAmountBuffer.Reset();
        LineAmountBuffer.SetCurrentKey("Amount Including VAT");
        LineAmountBuffer.Ascending(false);
        if not LineAmountBuffer.FindSet() then
            exit;

        repeat
            LineBufferWithCalculatedAmounts.Reset();
            LineBufferWithCalculatedAmounts.SetCurrentKey("Amount Including VAT", "Line No.");
            LineBufferWithCalculatedAmounts.SetRange("Amount Including VAT", LineAmountBuffer."Amount Including VAT");
            if LineBufferWithCalculatedAmounts.FindSet() then
                repeat
                    EntryNo += 1;
                    CouponApplicationBufferData.Get(LineBufferWithCalculatedAmounts."Entry No.");

                    CouponSalesLineApplicationOrderBuffer.Init();
                    CouponSalesLineApplicationOrderBuffer := CouponApplicationBufferData;
                    CouponSalesLineApplicationOrderBuffer."Entry No." := EntryNo;
                    CouponSalesLineApplicationOrderBuffer.Insert();
                until LineBufferWithCalculatedAmounts.Next() = 0;

        until LineAmountBuffer.Next() = 0;

        Found := CouponSalesLineApplicationOrderBuffer.FindSet();
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

    [Obsolete('Use GetNextCouponSalesLineNoFromCouponPriorityBuffer instead', '2024-04-28')]
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

    local procedure GetNextCouponSalesLineNoFromCouponPriorityBuffer(CouponSalesLineApplicationOrderBuffer: Record "NPR Coupon Line Appl Buffer") LineNo: Integer
    var
        SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
    begin
        SaleLinePOSCoupon.Reset();
        SaleLinePOSCoupon.SetRange("Register No.", CouponSalesLineApplicationOrderBuffer."Register No.");
        SaleLinePOSCoupon.SetRange("Sales Ticket No.", CouponSalesLineApplicationOrderBuffer."Sales Ticket No.");
        SaleLinePOSCoupon.SetRange("Sale Date", CouponSalesLineApplicationOrderBuffer.Date);
        SaleLinePOSCoupon.SetRange("Sale Line No.", CouponSalesLineApplicationOrderBuffer."Line No.");

        SaleLinePOSCoupon.SetLoadFields("Register No.", "Sales Ticket No.", "Sale Date", "Sale Line No.", "Line No.");
        if not SaleLinePOSCoupon.FindLast() then
            exit;

        LineNo := SaleLinePOSCoupon."Line No." + 10000;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon Type", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeleteCouponType(var Rec: Record "NPR NpDc Coupon Type"; RunTrigger: Boolean)
    var
        NpDcCouponListItem: Record "NPR NpDc Coupon List Item";
    begin
        if Rec.IsTemporary then
            exit;

        NpDcCouponListItem.SetRange("Coupon Type", Rec.Code);
        if NpDcCouponListItem.IsEmpty then
            exit;
        NpDcCouponListItem.DeleteAll();
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

        HasApplySetup := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", 'OnSetupApplyDiscount', '', true, true)]
    local procedure OnSetupApplyDiscount(var CouponType: Record "NPR NpDc Coupon Type")
    var
        NpDcCouponListItem: Record "NPR NpDc Coupon List Item";
    begin
        if not IsSubscriber(CouponType) then
            exit;

        NpDcCouponListItem.FilterGroup(2);
        NpDcCouponListItem.SetRange("Coupon Type", CouponType.Code);
        NpDcCouponListItem.FilterGroup(0);
        PAGE.Run(PAGE::"NPR NpDc Coupon List Items", NpDcCouponListItem);
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
        exit(CODEUNIT::"NPR NpDc Module Apply ItemList");
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

    internal procedure ModuleCode(): Code[20]
    begin
        exit('ITEM_LIST');
    end;
}

