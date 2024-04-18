codeunit 6151590 "NPR NpDc Coupon Mgt."
{
    var
        Text003: Label 'Coupon Reference No. is too long';
        Text004: Label 'Invalid Coupon Reference No.';
        Text005: Label 'Coupon with Reference No. %1 is archived.';

    internal procedure ResetInUseQty(Coupon: Record "NPR NpDc Coupon")
    var
        NpDcExtCouponSalesLine: Record "NPR NpDc Ext. Coupon Reserv.";
        SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcCouponModuleMgt: Codeunit "NPR NpDc Coupon Module Mgt.";
    begin
        SaleLinePOSCoupon.SetRange("Coupon No.", Coupon."No.");
        if SaleLinePOSCoupon.FindSet() then begin
            Coupon.CalcFields("Issue Coupon Module", "Validate Coupon Module", "Apply Discount Module");
            repeat
                if SaleLinePOSCoupon.Type = SaleLinePOSCoupon.Type::Coupon then
                    NpDcCouponModuleMgt.OnCancelDiscountApplication(Coupon, SaleLinePOSCoupon);
                if SaleLinePOSCoupon.Find() then
                    SaleLinePOSCoupon.Delete();
            until SaleLinePOSCoupon.Next() = 0;
        end;

        NpDcExtCouponSalesLine.SetRange("Coupon No.", Coupon."No.");
        if NpDcExtCouponSalesLine.FindFirst() then
            NpDcExtCouponSalesLine.DeleteAll();
    end;

    #region Issue Coupon

    internal procedure IssueCoupons(CouponType: Record "NPR NpDc Coupon Type")
    var
        NpDcCouponModuleMgt: Codeunit "NPR NpDc Coupon Module Mgt.";
        NpDcModuleIssueDefault: Codeunit "NPR NpDc Module Issue: Default";
        Handled: Boolean;
    begin
        CouponType.TestField(Enabled, true);
        NpDcCouponModuleMgt.OnRunIssueCoupon(CouponType, Handled);
        if Handled then
            exit;

        NpDcModuleIssueDefault.IssueCoupons(CouponType, 0);
    end;

    local procedure InitialEntryExists(Coupon: Record "NPR NpDc Coupon"): Boolean
    var
        CouponEntry: Record "NPR NpDc Coupon Entry";
    begin
        CouponEntry.SetRange("Coupon No.", Coupon."No.");
        CouponEntry.SetRange("Entry Type", CouponEntry."Entry Type"::"Issue Coupon");
        exit(CouponEntry.FindFirst());
    end;

    #endregion Issue Coupon
    #region Validate Coupon

    internal procedure ValidateCoupon(POSSession: Codeunit "NPR POS Session"; ReferenceNo: Text; var Coupon: Record "NPR NpDc Coupon")
    var
        CouponType: Record "NPR NpDc Coupon Type";
        SalePOS: Record "NPR POS Sale";
        NpDcCouponModuleMgt: Codeunit "NPR NpDc Coupon Module Mgt.";
        NpDcModuleValidateDefault: Codeunit "NPR NpDc ModuleValid.: Defa.";
        SaleOut: Codeunit "NPR POS Sale";
        Handled: Boolean;
        NpDcArchCoupon: Record "NPR NpDc Arch. Coupon";
    begin
        NpDcCouponModuleMgt.OnBeforeValidateCoupon(ReferenceNo);

        if StrLen(ReferenceNo) > MaxStrLen(Coupon."Reference No.") then
            Error(Text003);
        Coupon.SetRange("Reference No.", UpperCase(ReferenceNo));
        if not Coupon.FindFirst() then begin
            NpDcArchCoupon.SetRange("Reference No.", UpperCase(ReferenceNo));
            if NpDcArchCoupon.FindFirst() then
                Error(Text005, ReferenceNo)
            else
                Error(Text004);
        end;


        CouponType.Get(Coupon."Coupon Type");
        CouponType.TestField(Enabled, true);
        POSSession.GetSale(SaleOut);
        SaleOut.GetCurrentSale(SalePOS);
        Coupon.CalcFields("Issue Coupon Module", "Validate Coupon Module", "Apply Discount Module");
        NpDcCouponModuleMgt.OnRunValidateCoupon(SalePOS, Coupon, Handled);
        if Handled then
            exit;

        NpDcModuleValidateDefault.ValidateCoupon(SalePOS, Coupon);
    end;

    #endregion Validate Coupon
    #region Apply Discount

    internal procedure ApplyDiscount(SalePOS: Record "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        SaleLinePOSCoupon2: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcModuleApplyDefault: Codeunit "NPR NpDc Module Apply: Default";
        NpDcCouponModuleMgt: Codeunit "NPR NpDc Coupon Module Mgt.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
        Handled: Boolean;
        DiscountType: Integer;
    begin
        SaleLinePOSCoupon.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOSCoupon.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOSCoupon.SetRange("Sale Date", SalePOS.Date);
        SaleLinePOSCoupon.SetRange(Type, SaleLinePOSCoupon.Type::Coupon);
        if SaleLinePOSCoupon.IsEmpty then
            exit;

        SaleLinePOSCoupon.SetCurrentKey("Register No.", "Sales Ticket No.", "Sale Date", "Application Sequence No.");
        SaleLinePOSCoupon.FindSet();
        repeat
            Handled := false;
            NpDcCouponModuleMgt.OnRunApplyDiscount(SaleLinePOSCoupon, Handled);
            if not Handled then
                NpDcModuleApplyDefault.ApplyDiscount(SaleLinePOSCoupon);

            SaleLinePOSCoupon2.SetRange("Register No.", SaleLinePOSCoupon."Register No.");
            SaleLinePOSCoupon2.SetRange("Sales Ticket No.", SaleLinePOSCoupon."Sales Ticket No.");
            SaleLinePOSCoupon2.SetRange(Type, SaleLinePOSCoupon2.Type::Discount);
            SaleLinePOSCoupon2.SetRange("Coupon No.", SaleLinePOSCoupon."Coupon No.");
            if FeatureFlagsManagement.IsEnabled('couponsVatAmountCalculationFix_v2') then begin
                SaleLinePOSCoupon2.SetRange("Applies-to Sale Line No.", SaleLinePOSCoupon."Sale Line No.");
                SaleLinePOSCoupon2.SetRange("Applies-to Coupon Line No.", SaleLinePOSCoupon."Line No.");
                SaleLinePOSCoupon2.CalcSums("Discount Amount", "Discount Amount Excluding VAT", "Discount Amount Including VAT");

                if SaleLinePOSCoupon."Discount Amount" <> SaleLinePOSCoupon2."Discount Amount" then begin
                    SaleLinePOSCoupon."Discount Amount" := SaleLinePOSCoupon2."Discount Amount";
                    SaleLinePOSCoupon."Discount Amount Excluding VAT" := SaleLinePOSCoupon2."Discount Amount Excluding VAT";
                    SaleLinePOSCoupon."Discount Amount Including VAT" := SaleLinePOSCoupon2."Discount Amount Including VAT";
                    if (not SaleLinePOSCoupon.Modify()) then; // Note: A subscriber in ApplyDiscount might have deleted the coupon line
                end;
            end else begin
                SaleLinePOSCoupon2.CalcSums("Discount Amount");
                if SaleLinePOSCoupon."Discount Amount" <> SaleLinePOSCoupon2."Discount Amount" then begin
                    SaleLinePOSCoupon."Discount Amount" := SaleLinePOSCoupon2."Discount Amount";
                    if (not SaleLinePOSCoupon.Modify()) then; // Note: A subscriber in ApplyDiscount might have deleted the coupon line
                end;
            end;
        until SaleLinePOSCoupon.Next() = 0;

        SaleLinePOS.SetSkipCalcDiscount(true);
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        SaleLinePOS.SetFilter("Line Type", '=%1|=%2', SaleLinePOS."Line Type"::"Issue Voucher", SaleLinePOS."Line Type"::Item);
        SaleLinePOS.SetFilter("Coupon Discount Amount", '>%1', 0);
        if SaleLinePOS.IsEmpty then
            exit;

        SaleLinePOS.FindSet();
        repeat
            DiscountType := SaleLinePOS."Discount Type";

            SaleLinePOS.CalcFields("Coupon Discount Amount");

            SaleLinePOS."Discount %" := 0;
            SaleLinePOS."Discount Amount" += SaleLinePOS."Coupon Discount Amount";
            if SaleLinePOS."Discount Amount" > (SaleLinePOS."Unit Price" * SaleLinePOS.Quantity) then
                SaleLinePOS."Discount %" := 100;
            SaleLinePOS.UpdateAmounts(SaleLinePOS);
            SaleLinePOS."Coupon Applied" := true;
            SaleLinePOS."Discount Type" := DiscountType;
            SaleLinePOS.Modify();
        until SaleLinePOS.Next() = 0;
        POSSaleLine.OnUpdateLine(SaleLinePOS);
    end;

    internal procedure RemoveDiscount(SalePOS: Record "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
        DiscountType: Integer;
    begin
        SaleLinePOSCoupon.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOSCoupon.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOSCoupon.SetRange("Sale Date", SalePOS.Date);
        if SaleLinePOSCoupon.IsEmpty then
            exit;

        SaleLinePOS.SetSkipCalcDiscount(true);
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        SaleLinePOS.SetFilter("Coupon Discount Amount", '>%1', 0);
        if SaleLinePOS.IsEmpty then
            exit;

        SaleLinePOS.FindSet();
        repeat
            DiscountType := SaleLinePOS."Discount Type";

            if FeatureFlagsManagement.IsEnabled('couponsVatAmountCalculationFix_v2') then begin
                SaleLinePOS.CalcFields("Coupon Disc. Amount Excl. VAT", "Coupon Disc. Amount Incl. VAT");

                SaleLinePOS."Discount %" := 0;
                if SaleLinePOS."Price Includes VAT" then
                    SaleLinePOS."Discount Amount" -= SaleLinePOS."Coupon Disc. Amount Incl. VAT"
                else
                    SaleLinePOS."Discount Amount" -= SaleLinePOS."Coupon Disc. Amount Excl. VAT";

                if SaleLinePOS."Discount Amount" < 0 then
                    SaleLinePOS."Discount Amount" := 0;

                if SaleLinePOS."Discount Amount" > (SaleLinePOS."Unit Price" * SaleLinePOS.Quantity) then
                    SaleLinePOS."Discount %" := 100;
            end else begin
                SaleLinePOS.CalcFields("Coupon Discount Amount");

                SaleLinePOS."Discount %" := 0;
                SaleLinePOS."Discount Amount" := 0;
            end;
            SaleLinePOS.UpdateAmounts(SaleLinePOS);
            SaleLinePOS."Coupon Applied" := false;
            SaleLinePOS."Discount Type" := DiscountType;
            SaleLinePOS.Modify();
        until SaleLinePOS.Next() = 0;

        Clear(SaleLinePOSCoupon);
        SaleLinePOSCoupon.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOSCoupon.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOSCoupon.SetRange("Sale Date", SalePOS.Date);
        SaleLinePOSCoupon.ModifyAll("Discount Amount", 0);
        if FeatureFlagsManagement.IsEnabled('couponsVatAmountCalculationFix_v2') then begin
            SaleLinePOSCoupon.ModifyAll("Discount Amount Including VAT", 0);
            SaleLinePOSCoupon.ModifyAll("Discount Amount Excluding VAT", 0);
        end;
    end;

    #endregion Apply Discount
    #region Archivation

    local procedure ApplyEntry(var CouponEntry: Record "NPR NpDc Coupon Entry")
    var
        CouponEntryApply: Record "NPR NpDc Coupon Entry";
    begin
        if CouponEntry.IsTemporary then
            exit;
        if not CouponEntry.Find() then
            exit;
        if not CouponEntry.Open then
            exit;

        CouponEntryApply.SetRange("Coupon No.", CouponEntry."Coupon No.");
        CouponEntryApply.SetRange(Open, true);
        CouponEntryApply.SetRange(Positive, not CouponEntry.Positive);
        if not CouponEntryApply.FindSet() then
            exit;

        repeat
            if Abs(CouponEntryApply."Remaining Quantity") >= Abs(CouponEntry."Remaining Quantity") then begin
                CouponEntryApply."Remaining Quantity" += CouponEntry."Remaining Quantity";
                if CouponEntryApply."Remaining Quantity" = 0 then begin
                    CouponEntryApply."Closed by Entry No." := CouponEntry."Entry No.";
                    CouponEntryApply.Open := false;
                end;

                CouponEntry."Remaining Quantity" := 0;
                CouponEntry."Closed by Entry No." := CouponEntryApply."Entry No.";
                CouponEntry.Open := false;
            end else begin
                CouponEntry."Remaining Quantity" += CouponEntryApply."Remaining Quantity";
                if CouponEntry."Remaining Quantity" = 0 then begin
                    CouponEntry."Closed by Entry No." := CouponEntryApply."Entry No.";
                    CouponEntry.Open := false;
                end;

                CouponEntryApply."Remaining Quantity" := 0;
                CouponEntryApply."Closed by Entry No." := CouponEntry."Entry No.";
                CouponEntryApply.Open := false;
            end;

            CouponEntry.Modify();
            CouponEntryApply.Modify();
        until (CouponEntryApply.Next() = 0) or not CouponEntry.Open;
    end;

    internal procedure ArchiveCoupons(var CouponFilter: Record "NPR NpDc Coupon")
    var
        Coupon: Record "NPR NpDc Coupon";
    begin
        Coupon.Copy(CouponFilter);
        if Coupon.GetFilters = '' then
            Coupon.SetRecFilter();

        if not Coupon.FindSet() then
            exit;

        repeat
            ArchiveCoupon(Coupon);
        until Coupon.Next() = 0;
    end;

    local procedure ArchiveCoupon(var Coupon: Record "NPR NpDc Coupon")
    var
        CouponEntry: Record "NPR NpDc Coupon Entry";
    begin
        Coupon.CalcFields("Remaining Quantity");
        if Coupon."Remaining Quantity" <> 0 then begin
            CouponEntry.Init();
            CouponEntry."Entry No." := 0;
            CouponEntry."Coupon No." := Coupon."No.";
            CouponEntry."Entry Type" := CouponEntry."Entry Type"::"Manual Archive";
            CouponEntry."Coupon Type" := Coupon."Coupon Type";
            CouponEntry.Quantity := -Coupon."Remaining Quantity";
            CouponEntry."Remaining Quantity" := -Coupon."Remaining Quantity";
            CouponEntry."Amount per Qty." := 0;
            CouponEntry.Amount := 0;
            CouponEntry.Positive := CouponEntry.Quantity > 0;
            CouponEntry."Posting Date" := Today();
            CouponEntry.Open := true;
            CouponEntry."Register No." := '';
            CouponEntry."Document Type" := CouponEntry."Document Type"::" ";
            CouponEntry."Document No." := '';
            CouponEntry."User ID" := CopyStr(UserId, 1, MaxStrLen(CouponEntry."User ID"));
            CouponEntry."Closed by Entry No." := 0;
            CouponEntry.Insert();

            ApplyEntry(CouponEntry);
        end;

        ArchiveClosedCoupon(Coupon);
    end;

    procedure PostIssueCoupon(Coupon: Record "NPR NpDc Coupon")
    var
        CouponEntry: Record "NPR NpDc Coupon Entry";
        CouponType: Record "NPR NpDc Coupon Type";
    begin
        if InitialEntryExists(Coupon) then
            exit;

        CouponType.Get(Coupon."Coupon Type");

        CouponEntry.Init();
        CouponEntry."Entry No." := 0;
        CouponEntry."Coupon No." := Coupon."No.";
        CouponEntry."Entry Type" := CouponEntry."Entry Type"::"Issue Coupon";
        CouponEntry."Coupon Type" := Coupon."Coupon Type";
        CouponEntry."Amount per Qty." := CouponType."Discount Amount";
        CouponEntry.Quantity := 1;
        if CouponType."Multi-Use Coupon" and (CouponType."Multi-Use Qty." > 0) then
            CouponEntry.Quantity := CouponType."Multi-Use Qty.";
        CouponEntry."Remaining Quantity" := CouponEntry.Quantity;
        CouponEntry.Amount := CouponEntry."Amount per Qty." * CouponEntry.Quantity;
        CouponEntry.Positive := CouponEntry.Quantity > 0;
        CouponEntry."Posting Date" := Today();
        CouponEntry.Open := true;
        CouponEntry."Register No." := '';
        CouponEntry."Document Type" := CouponEntry."Document Type"::" ";
        CouponEntry."Document No." := '';
        CouponEntry."User ID" := CopyStr(UserId, 1, MaxStrLen(CouponEntry."User ID"));
        CouponEntry."Closed by Entry No." := 0;
        CouponEntry.Insert();
    end;

    internal procedure PostIssueCoupon2(Coupon: Record "NPR NpDc Coupon"; Quantity: Decimal; AmountPerQty: Decimal)
    var
        CouponEntry: Record "NPR NpDc Coupon Entry";
    begin
        if InitialEntryExists(Coupon) then
            exit;

        CouponEntry.Init();
        CouponEntry."Entry No." := 0;
        CouponEntry."Coupon No." := Coupon."No.";
        CouponEntry."Entry Type" := CouponEntry."Entry Type"::"Issue Coupon";
        CouponEntry."Coupon Type" := Coupon."Coupon Type";
        CouponEntry."Amount per Qty." := AmountPerQty;
        CouponEntry.Quantity := Quantity;
        CouponEntry."Remaining Quantity" := CouponEntry.Quantity;
        CouponEntry.Amount := CouponEntry."Amount per Qty." * CouponEntry.Quantity;
        CouponEntry.Positive := CouponEntry.Quantity > 0;
        CouponEntry."Posting Date" := Today();
        CouponEntry.Open := true;
        CouponEntry."Register No." := '';
        CouponEntry."Document Type" := CouponEntry."Document Type"::" ";
        CouponEntry."Document No." := '';
        CouponEntry."User ID" := CopyStr(UserId, 1, MaxStrLen(CouponEntry."User ID"));
        CouponEntry."Closed by Entry No." := 0;
        CouponEntry.Insert();
    end;

    internal procedure PostDiscountApplication(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; Quantity: Decimal)
    var
        Coupon: Record "NPR NpDc Coupon";
        CouponEntry: Record "NPR NpDc Coupon Entry";
        NpDcCouponModuleMgt: Codeunit "NPR NpDc Coupon Module Mgt.";
    begin
        if not Coupon.Get(SaleLinePOSCoupon."Coupon No.") then
            exit;

        CheckCouponQuantity(Coupon, Quantity);

        InsertCouponEntry(SaleLinePOSCoupon, Quantity, Coupon, CouponEntry);

        ApplyEntry(CouponEntry);
        Coupon.CalcFields("Issue Coupon Module", "Validate Coupon Module", "Apply Discount Module");
        NpDcCouponModuleMgt.OnPostDiscountApplication(SaleLinePOSCoupon, Coupon, CouponEntry);
        ArchiveClosedCoupon(Coupon);
    end;

    internal procedure PostSaleLinePOS(var SaleLinePos: Record "NPR POS Sale Line")
    var
        SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
    begin
        SaleLinePOSCoupon.SetSkipCalcDiscount(true);
        SaleLinePOSCoupon.SetRange("Register No.", SaleLinePos."Register No.");
        SaleLinePOSCoupon.SetRange("Sales Ticket No.", SaleLinePos."Sales Ticket No.");
        SaleLinePOSCoupon.SetRange("Sale Date", SaleLinePos.Date);
        SaleLinePOSCoupon.SetRange("Sale Line No.", SaleLinePos."Line No.");
        SaleLinePOSCoupon.SetRange(Type, SaleLinePOSCoupon.Type::Coupon);
        if SaleLinePOSCoupon.IsEmpty then
            exit;

        SaleLinePOSCoupon.FindSet();
        repeat
            PostDiscountApplication(SaleLinePOSCoupon, SaleLinePos.Quantity);
            SaleLinePOSCoupon.Delete();
        until SaleLinePOSCoupon.Next() = 0;
    end;

    local procedure PostExtCouponReservations(SalesHeader: Record "Sales Header")
    var
        NpDcExtCouponReservation: Record "NPR NpDc Ext. Coupon Reserv.";
    begin
        NpDcExtCouponReservation.SetRange("Document Type", SalesHeader."Document Type");
        NpDcExtCouponReservation.SetRange("Document No.", SalesHeader."No.");
        if NpDcExtCouponReservation.IsEmpty then
            exit;

        NpDcExtCouponReservation.FindSet();
        repeat
            PostExtCouponReservation(SalesHeader, NpDcExtCouponReservation);
            NpDcExtCouponReservation.Delete();
        until NpDcExtCouponReservation.Next() = 0;
    end;

    internal procedure PostExtCouponReservation(SalesHeader: Record "Sales Header"; NpDcExtCouponReservation: Record "NPR NpDc Ext. Coupon Reserv.")
    var
        Coupon: Record "NPR NpDc Coupon";
        CouponEntry: Record "NPR NpDc Coupon Entry";
    begin
        if not Coupon.Get(NpDcExtCouponReservation."Coupon No.") then
            exit;

        CouponEntry.Init();
        CouponEntry."Entry No." := 0;
        CouponEntry."Coupon No." := Coupon."No.";
        CouponEntry."Entry Type" := CouponEntry."Entry Type"::"Discount Application";
        CouponEntry."Coupon Type" := Coupon."Coupon Type";
        CouponEntry.Quantity := -1;
        CouponEntry."Remaining Quantity" := -1;
        CouponEntry."Amount per Qty." := 0;
        CouponEntry.Amount := 0;
        CouponEntry.Positive := CouponEntry.Quantity > 0;
        CouponEntry."Posting Date" := SalesHeader."Posting Date";
        CouponEntry.Open := true;
        CouponEntry."Register No." := '';
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order:
                begin
                    CouponEntry."Document Type" := CouponEntry."Document Type"::"Sales Order";
                end;
            SalesHeader."Document Type"::Invoice:
                begin
                    CouponEntry."Document Type" := CouponEntry."Document Type"::"Sales Invoice";
                end;
            SalesHeader."Document Type"::"Return Order":
                begin
                    CouponEntry."Document Type" := CouponEntry."Document Type"::"Sales Return Order";
                end;
            SalesHeader."Document Type"::"Credit Memo":
                begin
                    CouponEntry."Document Type" := CouponEntry."Document Type"::"Sales Credit Memo";
                end;
        end;
        CouponEntry."Document No." := SalesHeader."No.";
        CouponEntry."User ID" := CopyStr(UserId, 1, MaxStrLen(CouponEntry."User ID"));
        CouponEntry."Closed by Entry No." := 0;
        CouponEntry.Insert();

        ApplyEntry(CouponEntry);

        Coupon.CalcFields("Issue Coupon Module", "Validate Coupon Module", "Apply Discount Module");

        ArchiveClosedCoupon(Coupon);
    end;

    local procedure UpdatePostedDocInfo(SalesHeader: Record "Sales Header"; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20])
    var
        NpDcCouponEntry: Record "NPR NpDc Coupon Entry";
        NpDcArchCouponEntry: Record "NPR NpDc Arch.Coupon Entry";
    begin
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order:
                begin
                    NpDcCouponEntry.SetRange("Document Type", NpDcCouponEntry."Document Type"::"Sales Order");
                    NpDcCouponEntry.SetRange("Document No.", SalesHeader."No.");
                    if NpDcCouponEntry.FindSet() then
                        repeat
                            NpDcCouponEntry."Document Type" := NpDcCouponEntry."Document Type"::"Posted Sales Invoice";
                            NpDcCouponEntry."Document No." := SalesInvHdrNo;
                            NpDcCouponEntry.Modify();
                        until NpDcCouponEntry.Next() = 0;

                    NpDcArchCouponEntry.SetRange("Document Type", NpDcArchCouponEntry."Document Type"::"Sales Order");
                    NpDcArchCouponEntry.SetRange("Document No.", SalesHeader."No.");
                    if NpDcArchCouponEntry.FindSet() then
                        repeat
                            NpDcArchCouponEntry."Document Type" := NpDcArchCouponEntry."Document Type"::"Posted Sales Invoice";
                            NpDcArchCouponEntry."Document No." := SalesInvHdrNo;
                            NpDcArchCouponEntry.Modify();
                        until NpDcArchCouponEntry.Next() = 0;
                end;
            SalesHeader."Document Type"::Invoice:
                begin
                    NpDcCouponEntry.SetRange("Document Type", NpDcCouponEntry."Document Type"::"Sales Invoice");
                    NpDcCouponEntry.SetRange("Document No.", SalesHeader."No.");
                    if NpDcCouponEntry.FindSet() then
                        repeat
                            NpDcCouponEntry."Document Type" := NpDcCouponEntry."Document Type"::"Posted Sales Invoice";
                            NpDcCouponEntry."Document No." := SalesInvHdrNo;
                            NpDcCouponEntry.Modify();
                        until NpDcCouponEntry.Next() = 0;

                    NpDcArchCouponEntry.SetRange("Document Type", NpDcArchCouponEntry."Document Type"::"Sales Invoice");
                    NpDcArchCouponEntry.SetRange("Document No.", SalesHeader."No.");
                    if NpDcArchCouponEntry.FindSet() then
                        repeat
                            NpDcArchCouponEntry."Document Type" := NpDcArchCouponEntry."Document Type"::"Posted Sales Invoice";
                            NpDcArchCouponEntry."Document No." := SalesInvHdrNo;
                            NpDcArchCouponEntry.Modify();
                        until NpDcArchCouponEntry.Next() = 0;
                end;
            SalesHeader."Document Type"::"Return Order":
                begin
                    NpDcCouponEntry.SetRange("Document Type", NpDcCouponEntry."Document Type"::"Sales Return Order");
                    NpDcCouponEntry.SetRange("Document No.", SalesHeader."No.");
                    if NpDcCouponEntry.FindSet() then
                        repeat
                            NpDcCouponEntry."Document Type" := NpDcCouponEntry."Document Type"::"Posted Sales Credit Memo";
                            NpDcCouponEntry."Document No." := SalesCrMemoHdrNo;
                            NpDcCouponEntry.Modify();
                        until NpDcCouponEntry.Next() = 0;

                    NpDcArchCouponEntry.SetRange("Document Type", NpDcArchCouponEntry."Document Type"::"Sales Return Order");
                    NpDcArchCouponEntry.SetRange("Document No.", SalesHeader."No.");
                    if NpDcArchCouponEntry.FindSet() then
                        repeat
                            NpDcArchCouponEntry."Document Type" := NpDcArchCouponEntry."Document Type"::"Posted Sales Credit Memo";
                            NpDcArchCouponEntry."Document No." := SalesCrMemoHdrNo;
                            NpDcArchCouponEntry.Modify();
                        until NpDcArchCouponEntry.Next() = 0;
                end;
            SalesHeader."Document Type"::"Credit Memo":
                begin
                    NpDcCouponEntry.SetRange("Document Type", NpDcCouponEntry."Document Type"::"Sales Credit Memo");
                    NpDcCouponEntry.SetRange("Document No.", SalesHeader."No.");
                    if NpDcCouponEntry.FindSet() then
                        repeat
                            NpDcCouponEntry."Document Type" := NpDcCouponEntry."Document Type"::"Posted Sales Credit Memo";
                            NpDcCouponEntry."Document No." := SalesCrMemoHdrNo;
                            NpDcCouponEntry.Modify();
                        until NpDcCouponEntry.Next() = 0;

                    NpDcArchCouponEntry.SetRange("Document Type", NpDcArchCouponEntry."Document Type"::"Sales Credit Memo");
                    NpDcArchCouponEntry.SetRange("Document No.", SalesHeader."No.");
                    if NpDcArchCouponEntry.FindSet() then
                        repeat
                            NpDcArchCouponEntry."Document Type" := NpDcArchCouponEntry."Document Type"::"Posted Sales Credit Memo";
                            NpDcArchCouponEntry."Document No." := SalesCrMemoHdrNo;
                            NpDcArchCouponEntry.Modify();
                        until NpDcArchCouponEntry.Next() = 0;
                end;
            else
                exit;
        end;
    end;

    local procedure ArchiveClosedCoupon(var Coupon: Record "NPR NpDc Coupon")
    var
        CouponEntry: Record "NPR NpDc Coupon Entry";
        CouponSetup: Record "NPR NpDc Coupon Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        Coupon.CalcFields(Open);
        if Coupon.Open then
            exit;

        CouponSetup.Get();
        CouponSetup.TestField("Arch. Coupon No. Series");
        Coupon."Arch. No." := Coupon."No.";
        if Coupon."No. Series" <> CouponSetup."Arch. Coupon No. Series" then
            Coupon."Arch. No." := NoSeriesMgt.GetNextNo(CouponSetup."Arch. Coupon No. Series", Today, true);

        InsertArchivedCoupon(Coupon);
        CouponEntry.SetRange("Coupon No.", Coupon."No.");
        if not CouponEntry.IsEmpty then begin
            CouponEntry.FindSet();
            repeat
                InsertArchivedCouponEntry(Coupon, CouponEntry);
            until CouponEntry.Next() = 0;
            CouponEntry.DeleteAll();
        end;

        Coupon.Delete();
    end;

    local procedure InsertArchivedCoupon(var Coupon: Record "NPR NpDc Coupon")
    var
        ArchCoupon: Record "NPR NpDc Arch. Coupon";
    begin
        ArchCoupon.Init();
        ArchCoupon."No." := Coupon."Arch. No.";
        ArchCoupon."Coupon Type" := Coupon."Coupon Type";
        ArchCoupon.Description := Coupon.Description;
        ArchCoupon."Reference No." := Coupon."Reference No.";
        ArchCoupon."Discount Type" := Coupon."Discount Type";
        ArchCoupon."Discount %" := Coupon."Discount %";
        ArchCoupon."Max. Discount Amount" := Coupon."Max. Discount Amount";
        ArchCoupon."Discount Amount" := Coupon."Discount Amount";
        ArchCoupon."Starting Date" := Coupon."Starting Date";
        ArchCoupon."Ending Date" := Coupon."Ending Date";
        ArchCoupon."No. Series" := Coupon."No. Series";
        ArchCoupon."Customer No." := Coupon."Customer No.";
        ArchCoupon."Max Use per Sale" := Coupon."Max Use per Sale";
        ArchCoupon."Print Template Code" := Coupon."Print Template Code";
        ArchCoupon."POS Store Group" := Coupon."POS Store Group";
        ArchCoupon.Insert();
    end;

    local procedure InsertArchivedCouponEntry(Coupon: Record "NPR NpDc Coupon"; CouponEntry: Record "NPR NpDc Coupon Entry")
    var
        ArchCouponEntry: Record "NPR NpDc Arch.Coupon Entry";
    begin
        ArchCouponEntry.Init();
        ArchCouponEntry."Entry No." := CouponEntry."Entry No.";
        ArchCouponEntry."Arch. Coupon No." := Coupon."Arch. No.";
        ArchCouponEntry."Entry Type" := CouponEntry."Entry Type";
        ArchCouponEntry."Coupon Type" := CouponEntry."Coupon Type";
        ArchCouponEntry.Positive := CouponEntry.Positive;
        ArchCouponEntry.Amount := CouponEntry.Amount;
        ArchCouponEntry."Posting Date" := CouponEntry."Posting Date";
        ArchCouponEntry.Open := CouponEntry.Open;
        ArchCouponEntry.Quantity := CouponEntry.Quantity;
        ArchCouponEntry."Remaining Quantity" := CouponEntry."Remaining Quantity";
        ArchCouponEntry."Amount per Qty." := CouponEntry."Amount per Qty.";
        ArchCouponEntry."Register No." := CouponEntry."Register No.";
        ArchCouponEntry."Document Type" := CouponEntry."Document Type";
        ArchCouponEntry."Document No." := CouponEntry."Document No.";
        ArchCouponEntry."User ID" := CouponEntry."User ID";
        ArchCouponEntry."Closed by Entry No." := CouponEntry."Closed by Entry No.";
        ArchCouponEntry.Insert();
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnAfterSetQuantity', '', true, true)]
    local procedure NPRPOSSaleLineOnAfterSetQuantityCoupons(var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        ChangeConnectedLines(SaleLinePOS);
    end;

    #endregion Archivation
    #region Pos Functionality

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale Line", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeletePOSSaleLine(var Rec: Record "NPR POS Sale Line"; RunTrigger: Boolean)
    var
        Coupon: Record "NPR NpDc Coupon";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcCouponModuleMgt: Codeunit "NPR NpDc Coupon Module Mgt.";
    begin
        if Rec.IsTemporary then
            exit;
        if not SalePOS.Get(Rec."Register No.", Rec."Sales Ticket No.") then
            exit;
        RemoveDiscount(SalePOS);

        SaleLinePOSCoupon.SetRange("Register No.", Rec."Register No.");
        SaleLinePOSCoupon.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
        SaleLinePOSCoupon.SetRange("Sale Date", Rec.Date);
        SaleLinePOSCoupon.SetRange("Applies-to Sale Line No.", Rec."Line No.");
        if not SaleLinePOSCoupon.IsEmpty then
            SaleLinePOSCoupon.DeleteAll();

        SaleLinePOSCoupon.Reset();
        SaleLinePOSCoupon.SetRange("Register No.", Rec."Register No.");
        SaleLinePOSCoupon.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
        SaleLinePOSCoupon.SetRange("Sale Date", Rec.Date);
        SaleLinePOSCoupon.SetRange("Sale Line No.", Rec."Line No.");
        if SaleLinePOSCoupon.FindSet() then
            repeat
                if SaleLinePOSCoupon.Type = SaleLinePOSCoupon.Type::Coupon then begin
                    if Coupon.Get(SaleLinePOSCoupon."Coupon No.") then
                        Coupon.CalcFields("Issue Coupon Module", "Validate Coupon Module", "Apply Discount Module");
                    NpDcCouponModuleMgt.OnCancelDiscountApplication(Coupon, SaleLinePOSCoupon);
                end;
                if SaleLinePOSCoupon.Find() then
                    SaleLinePOSCoupon.Delete();
            until SaleLinePOSCoupon.Next() = 0;

        if (Rec.Find()) then;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale Line", 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDeletePOSSaleLine(var Rec: Record "NPR POS Sale Line"; RunTrigger: Boolean)
    var
        SalePOS: Record "NPR POS Sale";
    begin
        if Rec.IsTemporary then
            exit;
        if not SalePOS.Get(Rec."Register No.", Rec."Sales Ticket No.") then
            exit;

        ApplyDiscount(SalePOS);

        if Rec.Find() then;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Create Entry", 'OnAfterInsertPOSSalesLine', '', true, false)]
    local procedure OnAfterInsertPOSSalesLine(SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line"; POSEntry: Record "NPR POS Entry"; var POSSalesLine: Record "NPR POS Entry Sales Line")
    begin
        SaleLinePos.CalcFields("Coupon Qty.");
        if SaleLinePos."Coupon Qty." <= 0 then
            exit;

        PostSaleLinePOS(SaleLinePos);
    end;

    internal procedure ScanCoupon(POSSession: Codeunit "NPR POS Session"; CouponReferenceNo: Text)
    var
        Coupon: Record "NPR NpDc Coupon";
        GeneralLedgerSetup: Record "General Ledger Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        POSSale: Codeunit "NPR POS Sale";
        SaleLineOut: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        ValidateCoupon(POSSession, CouponReferenceNo, Coupon);

        POSSession.GetSaleLine(SaleLineOut);

        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Comment;
        SaleLinePOS.Description := Coupon.Description;
        SaleLinePOS.Quantity := 1;
        SaleLineOut.InsertLine(SaleLinePOS);

        SaleLinePOSCoupon.Init();
        SaleLinePOSCoupon."Register No." := SaleLinePOS."Register No.";
        SaleLinePOSCoupon."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        SaleLinePOSCoupon."Sale Date" := SaleLinePOS.Date;
        SaleLinePOSCoupon."Sale Line No." := SaleLinePOS."Line No.";
        SaleLinePOSCoupon."Line No." := 10000;
        SaleLinePOSCoupon.Type := SaleLinePOSCoupon.Type::Coupon;
        SaleLinePOSCoupon.Validate("Coupon Type", Coupon."Coupon Type");
        SaleLinePOSCoupon."Coupon No." := Coupon."No.";
        SaleLinePOSCoupon.Description := Coupon.Description;
        SaleLinePOSCoupon."Discount Amount" := GetAmountPerQty(Coupon);
        if FeatureFlagsManagement.IsEnabled('couponsVatAmountCalculationFix_v2') then
            if SaleLinePOS."Price Includes VAT" then begin
                SaleLinePOSCoupon."Discount Amount Including VAT" := SaleLinePOSCoupon."Discount Amount";
                SaleLinePOSCoupon."Discount Amount Excluding VAT" := NPRPOSSaleTaxCalc.CalcAmountWithoutVAT(SaleLinePOSCoupon."Discount Amount", SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");
            end else begin
                SaleLinePOSCoupon."Discount Amount Including VAT" := NPRPOSSaleTaxCalc.CalcAmountWithVAT(SaleLinePOSCoupon."Discount Amount", SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");
                SaleLinePOSCoupon."Discount Amount Excluding VAT" := SaleLinePOSCoupon."Discount Amount";
            end;

        SaleLinePOSCoupon.Insert(true);
        POSSalesDiscountCalcMgt.OnAfterInsertSaleLinePOSCoupon(SaleLinePOSCoupon);

        POSSession.GetSale(POSSale);
        POSSale.RefreshCurrent();
        SaleLineOut.SetPosition(SaleLinePOS.GetPosition(false));
    end;

    #endregion Pos Functionality
    #region Sale Document Functionality

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeleteSalesHeader(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    var
        NpDcExtCouponSalesLine: Record "NPR NpDc Ext. Coupon Reserv.";
    begin
        if Rec.IsTemporary then
            exit;
        if not RunTrigger then
            exit;

        NpDcExtCouponSalesLine.SetRange("Document Type", Rec."Document Type");
        NpDcExtCouponSalesLine.SetRange("Document No.", Rec."No.");
        if NpDcExtCouponSalesLine.IsEmpty then
            exit;

        NpDcExtCouponSalesLine.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesLines', '', true, false)]
    local procedure OnAfterPostSalesLines(var SalesHeader: Record "Sales Header")
    begin
        if not SalesHeader.Invoice then
            exit;

        PostExtCouponReservations(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', true, true)]
    local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20])
    begin
        if not SalesHeader.Invoice then
            exit;

        UpdatePostedDocInfo(SalesHeader, SalesInvHdrNo, SalesCrMemoHdrNo);
    end;

    #endregion Sale Document Functionality
    #region Generate Reference No

    internal procedure GetAmountPerQty(Coupon: Record "NPR NpDc Coupon"): Decimal
    var
        NpDcCouponEntry: Record "NPR NpDc Coupon Entry";
    begin
        NpDcCouponEntry.SetRange("Coupon No.", Coupon."No.");
        NpDcCouponEntry.SetRange(Open, true);
        NpDcCouponEntry.SetFilter("Remaining Quantity", '>%1', 0);
        if NpDcCouponEntry.IsEmpty then
            exit(0);

        NpDcCouponEntry.FindFirst();
        exit(NpDcCouponEntry."Amount per Qty.");
    end;

    local procedure CheckCouponQuantity(Coupon: Record "NPR NpDc Coupon"; Quantity: Decimal)
    var
        QtyErr: Label 'Coupon quantity is %1 but you want to use %2. Action aborted.';
    begin
        Coupon.CalcFields("Remaining Quantity");
        if Quantity > Coupon."Remaining Quantity" then
            Error(QtyErr, Coupon."Remaining Quantity", Quantity);
    end;

    local procedure ChangeConnectedLines(var SaleLinePOS: Record "NPR POS Sale Line")
    var
        CouponLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcCoupon: Record "NPR NpDc Coupon";
    begin
        if not FindCouponLine(SaleLinePOS, CouponLinePOSCoupon) then
            exit;

        NpDcCoupon.Get(CouponLinePOSCoupon."Coupon No.");
        CheckCouponQuantity(NpDcCoupon, SaleLinePOS.Quantity);

        ChangeDiscountedLines(CouponLinePOSCoupon, SaleLinePOS.Quantity);
    end;

    local procedure FindCouponLine(SaleLinePOS: Record "NPR POS Sale Line"; var CouponLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"): Boolean
    begin
        CouponLinePOSCoupon.SetRange("Register No.", SaleLinePOS."Register No.");
        CouponLinePOSCoupon.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        CouponLinePOSCoupon.SetRange("Sale Date", SaleLinePOS.Date);
        CouponLinePOSCoupon.SetRange("Sale Line No.", SaleLinePOS."Line No.");
        CouponLinePOSCoupon.SetRange(Type, CouponLinePOSCoupon.Type::Coupon);
        exit(CouponLinePOSCoupon.FindFirst());
    end;

    local procedure ChangeDiscountedLines(CouponLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; Quantity: Decimal)
    var
        DisountLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
    begin
        DisountLinePOSCoupon.SetRange("Register No.", CouponLinePOSCoupon."Register No.");
        DisountLinePOSCoupon.SetRange("Sales Ticket No.", CouponLinePOSCoupon."Sales Ticket No.");
        DisountLinePOSCoupon.SetRange("Sale Type", CouponLinePOSCoupon."Sale Type");
        DisountLinePOSCoupon.SetRange("Sale Date", CouponLinePOSCoupon."Sale Date");
        DisountLinePOSCoupon.SetRange("Applies-to Coupon Line No.", CouponLinePOSCoupon."Line No.");
        DisountLinePOSCoupon.SetRange(Type, CouponLinePOSCoupon.Type::Discount);
        if DisountLinePOSCoupon.FindSet() then
            repeat
                ApplyQtyChange(DisountLinePOSCoupon, Quantity);
            until DisountLinePOSCoupon.Next() = 0;
    end;

    local procedure ApplyQtyChange(DisountLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; parQuantity: Decimal)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        if not SaleLinePOS.Get(DisountLinePOSCoupon."Register No.", DisountLinePOSCoupon."Sales Ticket No.", DisountLinePOSCoupon."Sale Date", DisountLinePOSCoupon."Sale Type", DisountLinePOSCoupon."Sale Line No.") then
            exit;

        SaleLinePOS.Validate(Quantity, parQuantity);
        SaleLinePOS.Modify();
    end;

    local procedure InsertCouponEntry(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; Quantity: Decimal; Coupon: Record "NPR NpDc Coupon"; var CouponEntry: Record "NPR NpDc Coupon Entry")
    var
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        CouponEntry.Init();
        CouponEntry."Entry No." := 0;
        CouponEntry."Coupon No." := Coupon."No.";
        CouponEntry."Entry Type" := CouponEntry."Entry Type"::"Discount Application";
        CouponEntry."Coupon Type" := Coupon."Coupon Type";
        CouponEntry.Quantity := -Quantity;
        CouponEntry."Remaining Quantity" := -Quantity;
        if FeatureFlagsManagement.IsEnabled('couponsVatAmountCalculationFix_v2') then
            CouponEntry."Amount per Qty." := SaleLinePOSCoupon."Discount Amount Including VAT"
        else
            CouponEntry."Amount per Qty." := SaleLinePOSCoupon."Discount Amount";
        CouponEntry.Amount := CouponEntry."Amount per Qty." * CouponEntry.Quantity;
        CouponEntry.Positive := CouponEntry.Quantity > 0;
        CouponEntry."Posting Date" := SaleLinePOSCoupon."Sale Date";
        CouponEntry.Open := true;
        CouponEntry."Register No." := SaleLinePOSCoupon."Register No.";
        CouponEntry."Document Type" := CouponEntry."Document Type"::"POS Entry";
        CouponEntry."Document No." := SaleLinePOSCoupon."Sales Ticket No.";
        CouponEntry."User ID" := CopyStr(UserId, 1, MaxStrLen(CouponEntry."User ID"));
        CouponEntry."Closed by Entry No." := 0;
        CouponEntry.Insert();
    end;

    internal procedure GenerateReferenceNo(Coupon: Record "NPR NpDc Coupon") ReferenceNo: Text
    var
        Coupon2: Record "NPR NpDc Coupon";
        CouponType: Record "NPR NpDc Coupon Type";
        i: Integer;
        NpRegEx: Codeunit "NPR RegEx";
    begin
        CouponType.Get(Coupon."Coupon Type");

        for i := 1 to 100 do begin
            ReferenceNo := CouponType."Reference No. Pattern";
            ReferenceNo := NpRegEx.RegExReplaceAN(ReferenceNo);
            ReferenceNo := NpRegEx.RegExReplaceS(ReferenceNo, Coupon."No.");
            ReferenceNo := UpperCase(CopyStr(ReferenceNo, 1, MaxStrLen(Coupon."Reference No.")));

            Coupon2.SetFilter("No.", '<>%1', Coupon."No.");
            Coupon2.SetRange("Reference No.", ReferenceNo);
            if Coupon2.IsEmpty then
                exit(ReferenceNo);

            if ReferenceNo = CouponType."Reference No. Pattern" then
                exit(ReferenceNo);
        end;

        exit(ReferenceNo);
    end;

    #endregion Generate Reference No
    #region Init

    internal procedure InitCouponType(var CouponType: Record "NPR NpDc Coupon Type")
    var
        CouponSetup: Record "NPR NpDc Coupon Setup";
    begin
        CouponSetup.Get();
        if CouponType."Reference No. Pattern" = '' then
            CouponType."Reference No. Pattern" := CouponSetup."Reference No. Pattern";
        if CouponType."Print Template Code" = '' then
            CouponType."Print Template Code" := CouponSetup."Print Template Code";
        CouponType."Print on Issue" := CouponSetup."Print on Issue";
    end;

    #endregion Init
    #region Print

    procedure PrintCoupon(Coupon: Record "NPR NpDc Coupon")
    var
        RPTemplateMgt: Codeunit "NPR RP Template Mgt.";
    begin
        case Coupon."Print Object Type" of
            Coupon."Print Object Type"::Template:
                begin
                    Coupon.TestField("Print Template Code");
                    Coupon.SetRecFilter();
                    RPTemplateMgt.PrintTemplate(Coupon."Print Template Code", Coupon, 0);
                end;
            Coupon."Print Object Type"::Report:
                begin
                    Coupon.TestField("Print Object ID", Report::"NPR NpDc Coupon");
                    Coupon.SetRecFilter();
                    Report.Run(Report::"NPR NpDc Coupon", true, false, Coupon);
                end;
        end;
    end;

    #endregion Print
}
