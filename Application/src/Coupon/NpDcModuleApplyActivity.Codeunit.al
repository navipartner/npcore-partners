codeunit 6151609 "NPR Np Dc Module ApplyActivity"
{
    Access = Internal;

    local procedure ApplyDiscount(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon")
    var
        Coupon: Record "NPR NpDc Coupon";
        CouponListSttings: Record "NPR NpDc Coupon List Item";
        NpDcCouponListItem: Record "NPR NpDc Coupon List Item";
        SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon";
        TempAllPosSaleLineForCoupon: Record "NPR POS Sale Line" temporary;
        TempPosSaleLineForApplication: Record "NPR POS Sale Line" temporary;
    begin
        if not Coupon.Get(SaleLinePOSCoupon."Coupon No.") then
            exit;

        if FindSaleLinePOSCouponApply(SaleLinePOSCoupon, SaleLinePOSCouponApply) then
            SaleLinePOSCouponApply.DeleteAll();

        if not GetCouponListSettings(SaleLinePOSCoupon, CouponListSttings) then
            exit;

        if not GetCouponListItems(SaleLinePOSCoupon, NpDcCouponListItem) then
            exit;

        if not FillPosSalesLineBuffers(SaleLinePOSCoupon, NpDcCouponListItem, TempPosSaleLineForApplication, TempAllPosSaleLineForCoupon) then
            exit;

        ApplyCouponDiscount(CouponListSttings, TempPosSaleLineForApplication, Coupon, SaleLinePOSCoupon);
    end;

    local procedure ApplyCouponDiscount(CouponListSttings: Record "NPR NpDc Coupon List Item"; var TempPosSaleLineForApplication: Record "NPR POS Sale Line" temporary; Coupon: Record "NPR NpDc Coupon"; SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon")
    var
        TemporarySalesLineParamErrorLbl: Label 'TempPosSaleLineForApplication must be a temporary parameter.';
    begin
        if not TempPosSaleLineForApplication.IsTemporary then
            Error(TemporarySalesLineParamErrorLbl);

        ApplyCouponSettingsToPOSSalesLines(CouponListSttings, TempPosSaleLineForApplication);

        case Coupon."Discount Type" of
            Coupon."Discount Type"::"Discount %":
                ApplyCoupontDiscountPercent(TempPosSaleLineForApplication, SaleLinePOSCoupon, Coupon."Discount %", Coupon."Max. Discount Amount");
            Coupon."Discount Type"::"Discount Amount":
                ApplyCouponDiscountAmount(TempPosSaleLineForApplication, SaleLinePOSCoupon, Coupon."Discount Amount");
        end;
    end;

    local procedure ApplyCouponSettingsToPOSSalesLines(CouponListSttings: Record "NPR NpDc Coupon List Item"; var TempPosSaleLineForApplication: Record "NPR POS Sale Line" temporary)
    begin
        case CouponListSttings."Apply Discount" of
            CouponListSttings."Apply Discount"::"Highest price":
                begin
                    TempPosSaleLineForApplication.SetCurrentKey("Unit Price");
                    TempPosSaleLineForApplication.Ascending(false);
                end;
            CouponListSttings."Apply Discount"::"Lowest price":
                begin
                    TempPosSaleLineForApplication.SetCurrentKey("Unit Price");
                    TempPosSaleLineForApplication.Ascending(true);
                end;
        end;
    end;

    local procedure ApplyCoupontDiscountPercent(var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; DiscountPercent: Decimal; MaxDiscountAmount: Decimal)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        AppliedQuantity: Decimal;
        DiscountAmount: Decimal;
        DiscountAmountIncludingVAT: Decimal;
        DiscountAmountExcludingVAT: Decimal;
        MaxQuantityToApply: Decimal;
        RemainingQuantity: Decimal;
        LineNo: Integer;
        QuantityToApply: Integer;
        TemporarySalesLineParamErrorLbl: Label 'TempSalesLinePOS must be a temporary parameter.';
    begin
        if not TempSaleLinePOS.IsTemporary then
            Error(TemporarySalesLineParamErrorLbl);

        MaxQuantityToApply := 1;
        RemainingQuantity := 1;
        if DiscountPercent > 100 then
            DiscountPercent := 100;

        if not TempSaleLinePOS.FindSet(false) then
            exit;

        repeat
            QuantityToApply := TempSaleLinePOS.Quantity;
            if (AppliedQuantity + QuantityToApply > MaxQuantityToApply) then
                QuantityToApply := MaxQuantityToApply - AppliedQuantity;

            if (QuantityToApply > RemainingQuantity) and (RemainingQuantity >= 0) then
                QuantityToApply := RemainingQuantity;

            TempSaleLinePOS."Amount Including VAT" := (TempSaleLinePOS."Amount Including VAT" / TempSaleLinePOS.Quantity) * QuantityToApply;
            DiscountAmountIncludingVAT := TempSaleLinePOS."Amount Including VAT" * (DiscountPercent / 100);
            if (MaxDiscountAmount > 0) and (DiscountAmountIncludingVAT > MaxDiscountAmount) then
                DiscountAmountIncludingVAT := MaxDiscountAmount;

            if not GeneralLedgerSetup.Get() then
                Clear(GeneralLedgerSetup);

            DiscountAmountExcludingVAT := NPRPOSSaleTaxCalc.CalcAmountWithoutVAT(DiscountAmountIncludingVAT, TempSaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

            if TempSaleLinePOS."Price Includes VAT" then
                DiscountAmount := DiscountAmountIncludingVAT
            else
                DiscountAmount := DiscountAmountExcludingVAT;

            if DiscountAmount > 0 then begin
                LineNo := GetNextLineNo(TempSaleLinePOS);
                SaleLinePOSCouponApply.Init();
                SaleLinePOSCouponApply."Register No." := TempSaleLinePOS."Register No.";
                SaleLinePOSCouponApply."Sales Ticket No." := TempSaleLinePOS."Sales Ticket No.";
                SaleLinePOSCouponApply."Sale Date" := TempSaleLinePOS.Date;
                SaleLinePOSCouponApply."Sale Line No." := TempSaleLinePOS."Line No.";
                SaleLinePOSCouponApply."Line No." := LineNo;
                SaleLinePOSCouponApply.Type := SaleLinePOSCouponApply.Type::Discount;
                SaleLinePOSCouponApply."Applies-to Sale Line No." := SaleLinePOSCoupon."Sale Line No.";
                SaleLinePOSCouponApply."Applies-to Coupon Line No." := SaleLinePOSCoupon."Line No.";
                SaleLinePOSCouponApply."Coupon Type" := SaleLinePOSCoupon."Coupon Type";
                SaleLinePOSCouponApply."Coupon No." := SaleLinePOSCoupon."Coupon No.";
                SaleLinePOSCouponApply.Description := SaleLinePOSCoupon.Description;
                SaleLinePOSCouponApply."Discount Amount" := DiscountAmount;
                SaleLinePOSCouponApply."Discount Amount Including VAT" := DiscountAmountIncludingVAT;
                SaleLinePOSCouponApply."Discount Amount Excluding VAT" := DiscountAmountExcludingVAT;
                SaleLinePOSCouponApply.Insert(true);


                AppliedQuantity += QuantityToApply;
                RemainingQuantity -= QuantityToApply;
            end;
        until (TempSaleLinePOS.Next() = 0) or (RemainingQuantity <= 0);
    end;

    local procedure ApplyCouponDiscountAmount(var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; MaxDiscountAmount: Decimal)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        AppliedQuantity: Decimal;
        LineDiscountAmount: Decimal;
        DiscountAmountIncludingVAT: Decimal;
        DiscountAmountExcludingVAT: Decimal;
        MaxQuantityToApply: Decimal;
        RemainingQuantity: Decimal;
        LineNo: Integer;
        QuantityToApply: Integer;
        TemporarySalesLineParamErrorLbl: Label 'TempSalesLinePOS must be a temporary parameter.';
    begin
        if not TempSaleLinePOS.IsTemporary then
            Error(TemporarySalesLineParamErrorLbl);

        if not TempSaleLinePOS.FindSet(false) then
            exit;

        MaxQuantityToApply := 1;
        RemainingQuantity := 1;

        repeat
            QuantityToApply := TempSaleLinePOS.Quantity;
            if (AppliedQuantity + QuantityToApply > MaxQuantityToApply) then
                QuantityToApply := MaxQuantityToApply - AppliedQuantity;

            if (QuantityToApply > RemainingQuantity) and (RemainingQuantity >= 0) then
                QuantityToApply := RemainingQuantity;

            if TempSaleLinePOS."Amount Including VAT" > MaxDiscountAmount then
                DiscountAmountIncludingVAT := MaxDiscountAmount
            else
                DiscountAmountIncludingVAT := TempSaleLinePOS."Amount Including VAT";


            if not GeneralLedgerSetup.Get() then
                Clear(GeneralLedgerSetup);

            DiscountAmountExcludingVAT := NPRPOSSaleTaxCalc.CalcAmountWithoutVAT(DiscountAmountIncludingVAT, TempSaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

            if TempSaleLinePOS."Price Includes VAT" then
                LineDiscountAmount := DiscountAmountIncludingVAT
            else
                LineDiscountAmount := DiscountAmountExcludingVAT;

            if LineDiscountAmount > 0 then begin
                LineNo := GetNextLineNo(TempSaleLinePOS);
                SaleLinePOSCouponApply.Init();
                SaleLinePOSCouponApply."Register No." := TempSaleLinePOS."Register No.";
                SaleLinePOSCouponApply."Sales Ticket No." := TempSaleLinePOS."Sales Ticket No.";
                SaleLinePOSCouponApply."Sale Date" := TempSaleLinePOS.Date;
                SaleLinePOSCouponApply."Sale Line No." := TempSaleLinePOS."Line No.";
                SaleLinePOSCouponApply."Line No." := LineNo;
                SaleLinePOSCouponApply.Type := SaleLinePOSCouponApply.Type::Discount;
                SaleLinePOSCouponApply."Applies-to Sale Line No." := SaleLinePOSCoupon."Sale Line No.";
                SaleLinePOSCouponApply."Applies-to Coupon Line No." := SaleLinePOSCoupon."Line No.";
                SaleLinePOSCouponApply."Coupon Type" := SaleLinePOSCoupon."Coupon Type";
                SaleLinePOSCouponApply."Coupon No." := SaleLinePOSCoupon."Coupon No.";
                SaleLinePOSCouponApply.Description := SaleLinePOSCoupon.Description;
                SaleLinePOSCouponApply."Discount Amount" := LineDiscountAmount;
                SaleLinePOSCouponApply."Discount Amount Including VAT" := DiscountAmountIncludingVAT;
                SaleLinePOSCouponApply."Discount Amount Excluding VAT" := DiscountAmountExcludingVAT;
                SaleLinePOSCouponApply.Insert(true);

                LineDiscountAmount := 0;
                RemainingQuantity -= QuantityToApply;
            end;
        until (TempSaleLinePOS.Next() = 0) or (RemainingQuantity <= 0) or (LineDiscountAmount <= 0);
    end;

    procedure CalcDiscountAmount(Coupon: Record "NPR NpDc Coupon"; TotalPOSSaleAmountForCoupons: Decimal) DiscountAmount: Decimal
    begin
        case Coupon."Discount Type" of
            Coupon."Discount Type"::"Discount %":
                begin
                    DiscountAmount := TotalPOSSaleAmountForCoupons * (Coupon."Discount %" / 100);
                    if (Coupon."Max. Discount Amount" > 0) and (DiscountAmount > Coupon."Max. Discount Amount") then
                        DiscountAmount := Coupon."Max. Discount Amount";
                end;
            Coupon."Discount Type"::"Discount Amount":
                DiscountAmount := Coupon."Discount Amount";
        end;
    end;

    local procedure GetCouponListItems(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; var NpDcCouponListItem: Record "NPR NpDc Coupon List Item"): Boolean
    begin
        Clear(NpDcCouponListItem);
        NpDcCouponListItem.SetRange("Coupon Type", SaleLinePOSCoupon."Coupon Type");
        NpDcCouponListItem.SetFilter("No.", '<>%1', '');
        exit(NpDcCouponListItem.FindFirst());
    end;

    local procedure GetCouponListSettings(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; var NpDcCouponListItem: Record "NPR NpDc Coupon List Item") Found: Boolean
    begin
        NpDcCouponListItem.Reset();
        NpDcCouponListItem.SetRange("Coupon Type", SaleLinePOSCoupon."Coupon Type");
        NpDcCouponListItem.SetRange("Line No.", -1);
        Found := NpDcCouponListItem.FindFirst();
    end;


    local procedure FillPosSalesLineBuffers(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; var CouponListItem: Record "NPR NpDc Coupon List Item"; var TempPosSaleLineForApplication: Record "NPR POS Sale Line" temporary; var TempAllPosSaleLineForCoupon: Record "NPR POS Sale Line" temporary) Found: Boolean
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        TempAppliedSaleLinePOS: Record "NPR POS Sale Line" temporary;
        CouponCanBeApplied: Boolean;
        TemporaryParameterTempAllPosSaleLineForCouponErrorLbl: Label 'The provided parameter TempAllPosSaleLineForCoupon must be temporary.';
        TemporaryParameterTempPosSaleLineForApplicationErrorLbl: Label 'The provided parameter TempPosSaleLineForApplication must be temporary.';
    begin
        if not CouponListItem.FindSet(false) then
            exit;

        if not TempPosSaleLineForApplication.IsTemporary then
            Error(TemporaryParameterTempPosSaleLineForApplicationErrorLbl);

        TempPosSaleLineForApplication.Reset();
        if not TempPosSaleLineForApplication.IsEmpty then
            TempPosSaleLineForApplication.DeleteAll();

        if not TempAllPosSaleLineForCoupon.IsTemporary then
            Error(TemporaryParameterTempAllPosSaleLineForCouponErrorLbl);

        TempAllPosSaleLineForCoupon.Reset();
        if not TempAllPosSaleLineForCoupon.IsEmpty then
            TempAllPosSaleLineForCoupon.DeleteAll();

        GetPosSalesLinesWithCouponApplication(SaleLinePOSCoupon, TempAppliedSaleLinePOS);

        repeat
            SaleLinePOS.Reset();
            SaleLinePOS.SetRange("Register No.", SaleLinePOSCoupon."Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", SaleLinePOSCoupon."Sales Ticket No.");
            SaleLinePOS.SetRange(Date, SaleLinePOSCoupon."Sale Date");
            SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
            SaleLinePOS.SetRange("Benefit Item", false);
            SaleLinePOS.SetRange("Shipment Fee", false);
            SaleLinePOS.SetFilter(Quantity, '>%1', 0);
            case CouponListItem.Type of
                CouponListItem.Type::Item:
                    SaleLinePOS.SetRange("No.", CouponListItem."No.");
                CouponListItem.Type::"Item Categories":
                    SaleLinePOS.SetRange("Item Category Code", CouponListItem."No.");
                CouponListItem.Type::"Item Disc. Group":
                    SaleLinePOS.SetRange("Item Disc. Group", CouponListItem."No.");
                CouponListItem.Type::"Magento Brand":
                    SaleLinePOS.SetRange("Magento Brand", CouponListItem."No.");
            end;
            SetSaleLinePOSLoadFields(SaleLinePOS);
            if SaleLinePOS.FindSet(false) then
                repeat
                    if not TempAllPosSaleLineForCoupon.Get(SaleLinePOS.RecordId) then begin
                        TempAllPosSaleLineForCoupon.Init();
                        TempAllPosSaleLineForCoupon := SaleLinePOS;
                        TempAllPosSaleLineForCoupon.Insert();
                    end;

                    if not TempAppliedSaleLinePOS.Get(SaleLinePOS.RecordId) then begin
                        CouponCanBeApplied := SaleLinePOS."Serial No." = '';
                        if not CouponCanBeApplied then begin
                            TempAppliedSaleLinePOS.Reset();
                            TempAppliedSaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
                            TempAppliedSaleLinePOS.SetRange("Benefit Item", false);
                            TempAppliedSaleLinePOS.SetRange("Shipment Fee", false);
                            TempAppliedSaleLinePOS.SetRange("No.", SaleLinePOS."No.");
                            TempAppliedSaleLinePOS.SetFilter("Serial No.", SaleLinePOS."Serial No.");
                            CouponCanBeApplied := TempAppliedSaleLinePOS.IsEmpty();
                        end;
                        if CouponCanBeApplied then begin
                            TempPosSaleLineForApplication.Init();
                            TempPosSaleLineForApplication := SaleLinePOS;
                            TempPosSaleLineForApplication.Insert();

                            TempAppliedSaleLinePOS.Init();
                            TempAppliedSaleLinePOS := SaleLinePOS;
                            TempAppliedSaleLinePOS.Insert();
                            Found := true;
                        end;
                    end;
                until SaleLinePOS.Next() = 0;
        until CouponListItem.Next() = 0;
    end;

    local procedure SetSaleLinePOSLoadFields(var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        SaleLinePOS.SetLoadFields("Register No.", "Sales Ticket No.", Date, "Line Type", "Benefit Item", "Shipment Fee", "No.", "Serial No.", "Item Category Code", "Item Disc. Group", "Magento Brand", Quantity, Amount, "Amount Including VAT", "Unit Price", "Line No.");
    end;

    local procedure GetPosSalesLinesWithCouponApplication(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; var TempAppliedSaleLinePOS: Record "NPR POS Sale Line" temporary)
    var
        SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon";
        SaleLinePOS: Record "NPR POS Sale Line";
        TemporaryParameterTempAppliedSaleLinePOSErrorLbl: Label 'The provided parameter TempAppliedSaleLinePOS must be temporary.';
    begin
        if not TempAppliedSaleLinePOS.IsTemporary then
            Error(TemporaryParameterTempAppliedSaleLinePOSErrorLbl);

        TempAppliedSaleLinePOS.Reset();
        if not TempAppliedSaleLinePOS.IsEmpty then
            TempAppliedSaleLinePOS.DeleteAll();

        SaleLinePOSCouponApply.Reset();
        SaleLinePOSCouponApply.SetRange("Register No.", SaleLinePOSCoupon."Register No.");
        SaleLinePOSCouponApply.SetRange("Sales Ticket No.", SaleLinePOSCoupon."Sales Ticket No.");
        SaleLinePOSCouponApply.SetRange("Coupon Type", SaleLinePOSCoupon."Coupon Type");
        SaleLinePOSCouponApply.SetRange("Coupon No.", SaleLinePOSCoupon."Coupon No.");
        SaleLinePOSCouponApply.SetRange(Type, SaleLinePOSCouponApply.Type::Discount);
        if not SaleLinePOSCouponApply.FindSet(false) then
            exit;

        repeat
            if not TempAppliedSaleLinePOS.Get(SaleLinePOSCouponApply."Register No.", SaleLinePOSCouponApply."Sales Ticket No.", SaleLinePOSCouponApply."Sale Date", TempAppliedSaleLinePOS."Sale Type"::Sale, SaleLinePOSCouponApply."Sale Line No.") then begin
                SetSaleLinePOSLoadFields(SaleLinePOS);
                SaleLinePOS.Get(SaleLinePOSCouponApply."Register No.", SaleLinePOSCouponApply."Sales Ticket No.", SaleLinePOSCouponApply."Sale Date", SaleLinePOS."Sale Type"::Sale, SaleLinePOSCouponApply."Sale Line No.");
                TempAppliedSaleLinePOS.Init();
                TempAppliedSaleLinePOS := SaleLinePOS;
                TempAppliedSaleLinePOS.Insert();
            end;
        until SaleLinePOSCouponApply.Next() = 0;
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
    var
        CouponDescriptionLbl: Label 'Apply Activity Discount';
    begin
        if CouponModule.Get(CouponModule.Type::"Apply Discount", ModuleCode()) then
            exit;

        CouponModule.Init();
        CouponModule.Type := CouponModule.Type::"Apply Discount";
        CouponModule.Code := ModuleCode();
        CouponModule.Description := CouponDescriptionLbl;
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
        PAGE.Run(PAGE::"NPR NpDc Act. Coup. Item List", NpDcCouponListItem);
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
        exit(CODEUNIT::"NPR Np Dc Module ApplyActivity");
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
        exit('Activity');
    end;
}

