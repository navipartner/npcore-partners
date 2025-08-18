codeunit 6014455 "NPR POS Sales Disc. Calc. Mgt."
{
    // This module is invoked by the sale line wrapper codeunit in transcendence inside insert,modify,delete functions.
    // It is specifically not invoked from table field validations or table subscribers to prevent unnecessary cascading.
    // 
    // The execution flow inside this module is:
    // 1. Event OnFindActiveSaleLineDiscounts() :
    //    This is meant for each discount type to do the most performance friendly check possible on whether a sale line is in scope or not.
    //    This means checking "static setup" (item no, variant no., date etc.) ideally via fully indexed table field checks.
    //    Any "dynamic setup" (advanced logic checks across lines, for example 2 of those, 3 of those, but not 5 of these) is not supposed to be checked at this time.
    //    To put it shortly the intention is for a discount type to possibly go "out of scope" asap.
    // 
    // 2. SetupTempSalesLines() copies all sale lines to a temp buffer without any discount values.
    // 
    // 3. Event ApplyDiscount() is fired with the temp buffer in discount priority order for all discount types that signalled in-scope in 1).
    //    This is where each discount type can do all the heavy checks & apply any resulting discount to the temp buffer lines.
    // 
    // 4. Fuction UpdateDiscOnSalesLine() compares physical record discount values to buffer discount values and updates physical records accordingly.
    //    NOTE: "Discount Calculated" (bool) should be set to true on all lines for which the static setup checks of a discount type passed succcesfully even if the dynamic setup checks failed later.
    //    The idea is to prevent as many discount checks/recalculations as possible while still supporting moving from a "discount is active" to "discount is inactive" state, ie. when
    //    deleting a line or reducing quantity.
    //    Example: Customer Discount only checks the most recent line touched - it will set "Discount Calculated" = true straight away since static checks passed (ie. the item no. does exist
    //    somewhere in a customer discount), but the dynamic check (the quantity is too low to trigger it) might prevent any further changes.
    //    The "Discount Calculated" = true causes the framework to compare buffer values with current record values, a mismatch is detected (previous state had higher quantity and active discount)
    //    and discount is removed on physical record.
    //    Since all other lines in the sale has "Discount Calculated" = false, the module immediately skips comparison for these.

    var
        _FeatureFlag: Codeunit "NPR Feature Flags Management";
        _RefreshRecFeatureTok: Label 'discountModuleRefreshRec', Locked = true;

    internal procedure RecalculateAllSaleLinePOS(SalePOS: Record "NPR POS Sale")
    var
        TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
        TempDiscountPriority: Record "NPR Discount Priority" temporary;
        StartTime: DateTime;
        SaleLinePOS: Record "NPR POS Sale Line";
        CouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
    begin
        StartTime := CurrentDateTime;

        CouponMgt.RemoveDiscount(SalePOS);

        SetupTempSalesLines(SalePOS, TempSaleLinePOS);
        if not TempSaleLinePOS.FindLast() then begin
            CouponMgt.ApplyDiscount(SalePOS);
            exit;
        end;

        FindAllActiveSaleLineDiscounts(TempDiscountPriority);

        //LineOperation & Rec is set as if the last line was just inserted.
        SaleLinePOS.Get(TempSaleLinePOS."Register No.", TempSaleLinePOS."Sales Ticket No.", TempSaleLinePOS.Date, TempSaleLinePOS."Sale Type", TempSaleLinePOS."Line No.");
        ApplyDiscounts(SalePOS, TempSaleLinePOS, TempDiscountPriority, SaleLinePOS, SaleLinePOS, 0, true);
        CouponMgt.ApplyDiscount(SalePOS);

        LogStopwatch('DISCOUNT_RECALCULATE', CurrentDateTime - StartTime);
    end;

    internal procedure OnAfterInsertSaleLinePOS(var Rec: Record "NPR POS Sale Line")
    var
        SalePOS: Record "NPR POS Sale";
        TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
        TempDiscountPriority: Record "NPR Discount Priority" temporary;
        NpDcCouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
        StartTime: DateTime;
        DiscountCalculated: Boolean;
    begin
        if not CheckDiscTrigger(Rec) then
            exit;
        if not SalePOS.Get(Rec."Register No.", Rec."Sales Ticket No.") then
            exit;

        StartTime := CurrentDateTime;

        NpDcCouponMgt.RemoveDiscount(SalePOS);

        if FindRelevantSaleLineDiscounts(SalePOS, Rec, Rec, TempDiscountPriority, 0) then begin
            SetupTempSalesLines(SalePOS, TempSaleLinePOS);
            if HasActiveCrossLineDiscount(TempDiscountPriority) then begin
                FindAllActiveSaleLineDiscounts(TempDiscountPriority);
                ApplyDiscounts(SalePOS, TempSaleLinePOS, TempDiscountPriority, Rec, Rec, 0, true);
            end else
                ApplyDiscounts(SalePOS, TempSaleLinePOS, TempDiscountPriority, Rec, Rec, 0, false);

            DiscountCalculated := true;
        end;

        NpDcCouponMgt.ApplyDiscount(SalePOS);

        if (_FeatureFlag.IsEnabled(_RefreshRecFeatureTok)) then begin
            // The individual discuont modules can change Rec with out using this particular instance.
            // Refresh the record to get latest data.
            if (not Rec.Get(Rec.RecordId())) then;
        end else begin
            if TempSaleLinePOS.Get(Rec."Register No.", Rec."Sales Ticket No.", Rec.Date, Rec."Sale Type", Rec."Line No.") then
                Rec.TransferFields(TempSaleLinePOS, false);
        end;

        if DiscountCalculated then
            LogStopwatch('DISCOUNT_ON_INSERT', CurrentDateTime - StartTime);
    end;

    internal procedure OnAfterModifySaleLinePOS(var Rec: Record "NPR POS Sale Line"; var xRec: Record "NPR POS Sale Line")
    var
        SalePOS: Record "NPR POS Sale";
        TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
        TempDiscountPriority: Record "NPR Discount Priority" temporary;
        NpDcCouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
        StartTime: DateTime;
        DiscountCalculated: Boolean;
    begin
        if not CheckDiscTrigger(Rec) then
            exit;
        if not SalePOS.Get(Rec."Register No.", Rec."Sales Ticket No.") then
            exit;

        StartTime := CurrentDateTime;

        NpDcCouponMgt.RemoveDiscount(SalePOS);

        if FindRelevantSaleLineDiscounts(SalePOS, Rec, xRec, TempDiscountPriority, 1) then begin
            SetupTempSalesLines(SalePOS, TempSaleLinePOS);
            if HasActiveCrossLineDiscount(TempDiscountPriority) then begin
                FindAllActiveSaleLineDiscounts(TempDiscountPriority);
                ApplyDiscounts(SalePOS, TempSaleLinePOS, TempDiscountPriority, Rec, xRec, 1, true);
            end else
                ApplyDiscounts(SalePOS, TempSaleLinePOS, TempDiscountPriority, Rec, xRec, 1, false);
            DiscountCalculated := true;
        end;

        NpDcCouponMgt.ApplyDiscount(SalePOS);

        if (_FeatureFlag.IsEnabled(_RefreshRecFeatureTok)) then begin
            // The individual discuont modules can change Rec with out using this particular instance.
            // Refresh the record to get latest data.
            if (not Rec.Get(Rec.RecordId())) then;
        end else begin
            if TempSaleLinePOS.Get(Rec."Register No.", Rec."Sales Ticket No.", Rec.Date, Rec."Sale Type", Rec."Line No.") then
                Rec.TransferFields(TempSaleLinePOS, false);
        end;

        if DiscountCalculated then
            LogStopwatch('DISCOUNT_ON_MODIFY', CurrentDateTime - StartTime);
    end;

    internal procedure OnAfterDeleteSaleLinePOS(var Rec: Record "NPR POS Sale Line")
    var
        SalePOS: Record "NPR POS Sale";
        TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
        TempDiscountPriority: Record "NPR Discount Priority" temporary;
        NpDcCouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
        StartTime: DateTime;
        DiscountCalculated: Boolean;
    begin
        if (Rec."Discount Amount" = 0) and (Rec."Discount Type" = Rec."Discount Type"::" ") and (Rec."Discount Code" = Rec."Discount Code") and (Rec."Total Discount Code" = '') then
            exit;
        if not CheckDiscTrigger(Rec) then
            exit;
        if not SalePOS.Get(Rec."Register No.", Rec."Sales Ticket No.") then
            exit;

        StartTime := CurrentDateTime;

        NpDcCouponMgt.RemoveDiscount(SalePOS);

        if FindRelevantSaleLineDiscounts(SalePOS, Rec, Rec, TempDiscountPriority, 2) then begin
            SetupTempSalesLines(SalePOS, TempSaleLinePOS);
            if HasActiveCrossLineDiscount(TempDiscountPriority) then begin
                FindAllActiveSaleLineDiscounts(TempDiscountPriority);
                ApplyDiscounts(SalePOS, TempSaleLinePOS, TempDiscountPriority, Rec, Rec, 2, true);
            end else
                ApplyDiscounts(SalePOS, TempSaleLinePOS, TempDiscountPriority, Rec, Rec, 2, false);

            DiscountCalculated := true;
        end;

        NpDcCouponMgt.ApplyDiscount(SalePOS);

        if DiscountCalculated then
            LogStopwatch('DISCOUNT_ON_DELETE', CurrentDateTime - StartTime);
    end;

    internal procedure OnAfterInsertSaleLinePOSCoupon(var Rec: Record "NPR NpDc SaleLinePOS Coupon")
    var
        SalePOS: Record "NPR POS Sale";
        NpDcCouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
    begin
        if not CheckDiscTriggerCoupon(Rec) then
            exit;
        if not SalePOS.Get(Rec."Register No.", Rec."Sales Ticket No.") then
            exit;

        NpDcCouponMgt.RemoveDiscount(SalePOS);
        NpDcCouponMgt.ApplyDiscount(SalePOS);
    end;

    internal procedure OnAfterTotalPressedPOS(var Rec: Record "NPR POS Sale Line")
    var
        SalePOS: Record "NPR POS Sale";
        TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
        TempDiscountPriority: Record "NPR Discount Priority" temporary;
        StartTime: DateTime;
        DiscountCalculated: Boolean;
    begin
        if not CheckDiscTriggerTotal(Rec) then
            exit;

        if not SalePOS.Get(Rec."Register No.", Rec."Sales Ticket No.") then
            exit;

        StartTime := CurrentDateTime;

        if FindRelevantSaleLineDiscountsTotal(SalePOS, Rec, Rec, TempDiscountPriority, 3) then begin
            SetupTempSalesLines(SalePOS, TempSaleLinePOS, true);
            ApplyDiscountsTotal(SalePOS, TempSaleLinePOS, TempDiscountPriority, Rec, Rec, 3, false);

            DiscountCalculated := true;
        end;

        if DiscountCalculated then
            LogStopwatch('DISCOUNT_ON_TOTALPRESSED', CurrentDateTime - StartTime);
    end;

    internal procedure ApplyDiscounts(SalePOS: Record "NPR POS Sale"; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; var tmpDiscountPriority: Record "NPR Discount Priority" temporary; Rec: Record "NPR POS Sale Line"; xRec: Record "NPR POS Sale Line"; LineOperation: Option Insert,Modify,Delete,Total; RecalculateAllLines: Boolean)
    begin

        tmpDiscountPriority.SetCurrentKey(Priority);
        if tmpDiscountPriority.FindSet() then begin
            repeat
                TempSaleLinePOS.Reset();
                ApplyDiscount(tmpDiscountPriority, SalePOS, TempSaleLinePOS, Rec, xRec, LineOperation, RecalculateAllLines);
            until tmpDiscountPriority.Next() = 0;

            UpdateDiscOnSalesLine(TempSaleLinePOS, RecalculateAllLines);
        end;
    end;

    local procedure ApplyDiscountsTotal(SalePOS: Record "NPR POS Sale"; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; var tmpDiscountPriority: Record "NPR Discount Priority" temporary; Rec: Record "NPR POS Sale Line"; xRec: Record "NPR POS Sale Line"; LineOperation: Option Insert,Modify,Delete,Total; RecalculateAllLines: Boolean)
    begin

        tmpDiscountPriority.SetCurrentKey(Priority);
        if tmpDiscountPriority.FindSet() then begin
            repeat
                TempSaleLinePOS.Reset();
                ApplyDiscountTotal(tmpDiscountPriority, SalePOS, TempSaleLinePOS, Rec, xRec, LineOperation, RecalculateAllLines);
            until tmpDiscountPriority.Next() = 0;

            UpdateDiscOnSalesLine(TempSaleLinePOS, RecalculateAllLines);
        end;
    end;

    local procedure UpdateDiscOnSalesLine(var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; RecalculateAllLines: Boolean)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
    begin
        Clear(TempSaleLinePOS);
        if TempSaleLinePOS.IsEmpty then
            exit;

        SaleLinePOS.SetSkipCalcDiscount(true);
        TempSaleLinePOS.Reset();
        TempSaleLinePOS.FindSet();
        repeat
            if TempSaleLinePOS."Discount Calculated" or RecalculateAllLines then begin
                TempSaleLinePOS."Discount Calculated" := false;
                if SaleLinePOS.Get(TempSaleLinePOS."Register No.", TempSaleLinePOS."Sales Ticket No.", TempSaleLinePOS.Date, TempSaleLinePOS."Sale Type", TempSaleLinePOS."Line No.") then begin
                    if (SaleLinePOS."Discount Type" <> TempSaleLinePOS."Discount Type")
                        or (SaleLinePOS."Discount %" <> TempSaleLinePOS."Discount %")
                        or (SaleLinePOS."Discount Amount" <> TempSaleLinePOS."Discount Amount")
                        or (SaleLinePOS.Quantity <> TempSaleLinePOS.Quantity)
                        or (SaleLinePOS."Total Discount Code" <> TempSaleLinePOS."Total Discount Code")
                        or (SaleLinePOS."Total Discount Step" <> TempSaleLinePOS."Total Discount Step")
                    then begin
                        SaleLinePOS.TransferFields(TempSaleLinePOS, false);
                        UpdateTicketRequestQuantity(SaleLinePOS);
                    end;
                end else begin
                    SaleLinePOS.Init();
                    SaleLinePOS := TempSaleLinePOS;
                    SaleLinePOS.Insert(false);
                    CreateCloneTicketRequest(SaleLinePOS);
                end;

                OnCheckSalesLineUpdateDisc(SaleLinePOS, TempSaleLinePOS);
                TempSaleLinePOS.Delete();
                SaleLinePOS.UpdateAmounts(SaleLinePOS);

                if POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId) then
                    if POSSaleTax."Calculated Amount Excl. Tax" = 0 then
                        POSSaleTaxCalc.DeleteAllLines(POSSaleTax);
                SaleLinePOS.CreateDimFromDefaultDim(SaleLinePOS.FieldNo("No."));
                SaleLinePOS.Modify();
            end;
        until TempSaleLinePOS.Next() = 0;
    end;

    local procedure CheckDiscTrigger(var SaleLinePOS: Record "NPR POS Sale Line"): Boolean
    begin
        if SaleLinePOS.IsTemporary then
            exit(false);
        if SaleLinePOS.GetSkipCalcDiscount() then
            exit(false);
        if SaleLinePOS."Coupon Applied" then
            exit(true);
        if SaleLinePOS."Line Type" <> SaleLinePOS."Line Type"::Item then
            exit(false);
        if SaleLinePOS.Quantity < 0 then
            exit;
        if SaleLinePOS."Benefit Item" then
            exit(false);
        if SaleLinePOS."Shipment Fee" then
            exit(false);

        exit(true);
    end;

    local procedure CheckDiscTriggerTotal(var SaleLinePOS: Record "NPR POS Sale Line"): Boolean
    begin
        if SaleLinePOS.IsTemporary then
            exit(false);
        if SaleLinePOS.GetSkipCalcDiscount() then
            exit(false);

        exit(true);
    end;

    local procedure CheckDiscTriggerCoupon(var SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"): Boolean
    begin
        if SaleLinePOSCoupon.IsTemporary then
            exit(false);

        if SaleLinePOSCoupon.GetSkipCalcDiscount() then
            exit(false);

        exit(SaleLinePOSCoupon.Type = SaleLinePOSCoupon.Type::Coupon);
    end;

    local procedure FindRelevantSaleLineDiscounts(SalePOS: Record "NPR POS Sale"; Rec: Record "NPR POS Sale Line"; xRec: Record "NPR POS Sale Line"; var tmpDiscountPriority: Record "NPR Discount Priority" temporary; LineOperation: Option Insert,Modify,Delete,Total): Boolean
    var
        DiscountPriority: Record "NPR Discount Priority";
    begin
        if DiscountPriority.IsEmpty then
            InitDiscountPriority(DiscountPriority);

        tmpDiscountPriority.Reset();
        tmpDiscountPriority.DeleteAll();

        OnFindActiveSaleLineDiscounts(tmpDiscountPriority, SalePOS, Rec, xRec, LineOperation);
        exit(not tmpDiscountPriority.IsEmpty());
    end;

    local procedure FindRelevantSaleLineDiscountsTotal(SalePOS: Record "NPR POS Sale"; Rec: Record "NPR POS Sale Line"; xRec: Record "NPR POS Sale Line"; var tmpDiscountPriority: Record "NPR Discount Priority" temporary; LineOperation: Option Insert,Modify,Delete,Total): Boolean
    var
        DiscountPriority: Record "NPR Discount Priority";
    begin
        if DiscountPriority.IsEmpty then
            InitDiscountPriority(DiscountPriority);

        tmpDiscountPriority.Reset();
        tmpDiscountPriority.DeleteAll();

        OnFindActiveSaleLineDiscountsTotal(tmpDiscountPriority, SalePOS, Rec, xRec, LineOperation);
        exit(not tmpDiscountPriority.IsEmpty());
    end;

    internal procedure FindAllActiveSaleLineDiscounts(var tmpDiscountPriority: Record "NPR Discount Priority" temporary)
    var
        DiscountPriority: Record "NPR Discount Priority";
    begin
        tmpDiscountPriority.Reset();
        tmpDiscountPriority.DeleteAll();

        DiscountPriority.SetRange(Disabled, false);
        if DiscountPriority.FindSet() then
            repeat
                tmpDiscountPriority.Init();
                tmpDiscountPriority := DiscountPriority;
                tmpDiscountPriority.Insert();
            until DiscountPriority.Next() = 0;
    end;

    local procedure HasActiveCrossLineDiscount(var tmpDiscountPriority: Record "NPR Discount Priority" temporary): Boolean
    var
        Result: Boolean;
    begin
        tmpDiscountPriority.SetRange("Cross Line Calculation", true);
        Result := not tmpDiscountPriority.IsEmpty();
        tmpDiscountPriority.SetRange("Cross Line Calculation");
        exit(Result);
    end;

    internal procedure SetupTempSalesLines(SalePOS: Record "NPR POS Sale"; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary)
    begin
        SetupTempSalesLines(SalePOS, TempSaleLinePOS, false);
    end;

    internal procedure SetupTempSalesLines(SalePOS: Record "NPR POS Sale"; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; SetupLinesForTotalDiscount: Boolean)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        TotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        if not TempSaleLinePOS.IsTemporary() then
            exit;

        SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", Date, "Sale Type", "Line Type", "Discount Type");
        SaleLinePOS.SetFilter("Discount Type", '<>%1&<>%2&<>%3', SaleLinePOS."Discount Type"::Manual, SaleLinePOS."Discount Type"::Combination, SaleLinePOS."Discount Type"::"BOM List");
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        SaleLinePOS.SetFilter(Quantity, '>%1', 0);
        SaleLinePOS.SetRange("Benefit Item", false);
        SaleLinePOS.SetRange("Shipment Fee", false);
        if SaleLinePOS.FindSet() then
            repeat
                SaleLinePOS.TestField("Price Includes VAT", SalePOS."Prices Including VAT");
                TempSaleLinePOS := SaleLinePOS;

                if not SetupLinesForTotalDiscount then begin
                    TempSaleLinePOS."Discount Calculated" := false;
                    TempSaleLinePOS."Discount Type" := TempSaleLinePOS."Discount Type"::" ";
                    TempSaleLinePOS."Discount Code" := '';
                    TempSaleLinePOS."Discount %" := 0;
                    TempSaleLinePOS."Discount Amount" := 0;
                    TotalDiscountManagement.ClearTotalDiscountFromSaleLine(TempSaleLinePOS);
                    TempSaleLinePOS."MR Anvendt antal" := 0;
                    TempSaleLinePOS."Custom Disc Blocked" := false;
                end;
                TempSaleLinePOS.Insert();
            until SaleLinePOS.Next() = 0;
    end;

    local procedure LogStopwatch(Keyword: Text; Duration: Duration)
    var
        POSSession: Codeunit "NPR POS Session";
        FrontEnd: Codeunit "NPR POS Front End Management";
    begin
        if not POSSession.IsActiveSession(FrontEnd) then
            exit;
        FrontEnd.GetSession(POSSession);
        POSSession.AddServerStopwatch(Keyword, Duration);
    end;

    procedure InitializeDiscountPriority()
    var
        DiscountPriority: Record "NPR Discount Priority";
    begin
        InitDiscountPriority(DiscountPriority);
    end;

    procedure PeriodDiscountLineisValid(var PeriodDiscountLine: Record "NPR Period Discount Line"; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; SalePOS: Record "NPR POS Sale"): Boolean
    var
        PeriodDiscountMgmt: Codeunit "NPR Period Discount Management";
    begin
        exit(PeriodDiscountMgmt.PeriodDiscountLineIsValid(PeriodDiscountLine, TempSaleLinePOS, SalePOS));
    end;

    procedure DeleteAllDiscountPriorities()
    var
        DiscountPriority: Record "NPR Discount Priority";
    begin
        if not DiscountPriority.IsEmpty() then
            DiscountPriority.DeleteAll();
    end;

    local procedure UpdateTicketRequestQuantity(var SaleLinePOS: Record "NPR POS Sale Line")
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
    begin
        TicketRequestManager.POS_OnModifyQuantity(SaleLinePOS);
    end;

    local procedure CreateCloneTicketRequest(var SaleLinePOS: Record "NPR POS Sale Line")
    var
        DerivedFromSaleLinePOS: Record "NPR POS Sale Line";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        CloneTicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TMTicketRetailMgt: Codeunit "NPR TM Ticket Retail Mgt.";
        Token, NewToken : Text[100];
    begin
        if SaleLinePOS.Quantity <= 0 then
            exit;
        if IsNullGuid(SaleLinePOS."Derived from Line") then
            exit;
        if not DerivedFromSaleLinePOS.GetBySystemId(SaleLinePOS."Derived from Line") then
            exit;
        if not TicketRequestManager.GetTokenFromReceipt(DerivedFromSaleLinePOS."Sales Ticket No.", DerivedFromSaleLinePOS."Line No.", Token) then
            exit;
        NewToken := TicketRequestManager.GetNewToken();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Receipt No.", '=%1', DerivedFromSaleLinePOS."Sales Ticket No.");
        TicketReservationRequest.SetFilter("Line No.", '=%1', DerivedFromSaleLinePOS."Line No.");
        TicketReservationRequest.FindSet(true);
        repeat
            CloneTicketReservationRequest.TransferFields(TicketReservationRequest);
            CloneTicketReservationRequest."Entry No." := 0;
            CloneTicketReservationRequest."Receipt No." := SaleLinePOS."Sales Ticket No.";
            CloneTicketReservationRequest."Line No." := SaleLinePOS."Line No.";
            CloneTicketReservationRequest."Session Token ID" := NewToken;
            CloneTicketReservationRequest.Quantity := 0;
            CloneTicketReservationRequest.Insert(true);
        until TicketReservationRequest.Next() = 0;
        TicketRequestManager.POS_OnModifyQuantity(SaleLinePOS);
        TMTicketRetailMgt.AdjustPriceOnSalesLine(SaleLinePOS, SaleLinePOS.Quantity, CloneTicketReservationRequest."Session Token ID", TicketReservationRequest."Ext. Line Reference No.");
    end;

    [IntegrationEvent(false, false)]
    internal procedure InitDiscountPriority(var DiscountPriority: Record "NPR Discount Priority")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure ApplyDiscount(DiscountPriority: Record "NPR Discount Priority"; SalePOS: Record "NPR POS Sale"; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; Rec: Record "NPR POS Sale Line"; xRec: Record "NPR POS Sale Line"; LineOperation: Option Insert,Modify,Delete,Total; RecalculateAllLines: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure ApplyDiscountTotal(DiscountPriority: Record "NPR Discount Priority"; SalePOS: Record "NPR POS Sale"; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; Rec: Record "NPR POS Sale Line"; xRec: Record "NPR POS Sale Line"; LineOperation: Option Insert,Modify,Delete,Total; RecalculateAllLines: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnFindActiveSaleLineDiscounts(var tmpDiscountPriority: Record "NPR Discount Priority" temporary; SalePOS: Record "NPR POS Sale"; Rec: Record "NPR POS Sale Line"; xRec: Record "NPR POS Sale Line"; LineOperation: Option Insert,Modify,Delete,Total)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnFindActiveSaleLineDiscountsTotal(var tmpDiscountPriority: Record "NPR Discount Priority" temporary; SalePOS: Record "NPR POS Sale"; Rec: Record "NPR POS Sale Line"; xRec: Record "NPR POS Sale Line"; LineOperation: Option Insert,Modify,Delete,Total)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckSalesLineUpdateDisc(var SaleLinePOS: Record "NPR POS Sale Line"; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary)
    begin
    end;
}
