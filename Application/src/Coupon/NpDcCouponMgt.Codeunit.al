codeunit 6151590 "NPR NpDc Coupon Mgt."
{
    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'This action handles Scan Discount Coupon.';
        Text001: Label 'Scan Coupon';
        Text002: Label 'Discount Coupon';
        Text003: Label 'Coupon Reference No. is too long';
        Text004: Label 'Invalid Coupon Reference No.';

    procedure ResetInUseQty(Coupon: Record "NPR NpDc Coupon")
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

    procedure IssueCoupons(CouponType: Record "NPR NpDc Coupon Type")
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

    procedure ValidateCoupon(POSSession: Codeunit "NPR POS Session"; ReferenceNo: Text; var Coupon: Record "NPR NpDc Coupon")
    var
        CouponType: Record "NPR NpDc Coupon Type";
        SalePOS: Record "NPR POS Sale";
        NpDcCouponModuleMgt: Codeunit "NPR NpDc Coupon Module Mgt.";
        NpDcModuleValidateDefault: Codeunit "NPR NpDc ModuleValid.: Defa.";
        SaleOut: Codeunit "NPR POS Sale";
        Handled: Boolean;
    begin
        if StrLen(ReferenceNo) > MaxStrLen(Coupon."Reference No.") then
            Error(Text003);
        Coupon.SetRange("Reference No.", UpperCase(ReferenceNo));
        if not Coupon.FindFirst() then
            Error(Text004);

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

    procedure ApplyDiscount(SalePOS: Record "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        SaleLinePOSCoupon2: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcModuleApplyDefault: Codeunit "NPR NpDc Module Apply: Default";
        NpDcCouponModuleMgt: Codeunit "NPR NpDc Coupon Module Mgt.";
        Handled: Boolean;
        DiscountType: Integer;
    begin
        SaleLinePOSCoupon.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOSCoupon.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOSCoupon.SetRange("Sale Type", SalePOS."Sale type");
        SaleLinePOSCoupon.SetRange("Sale Date", SalePOS.Date);
        if SaleLinePOSCoupon.IsEmpty then
            exit;

        SaleLinePOSCoupon.SetRange(Type, SaleLinePOSCoupon.Type::Coupon);
        if SaleLinePOSCoupon.IsEmpty then begin
            SaleLinePOSCoupon.SetRange(Type, SaleLinePOSCoupon.Type::Discount);
            if not SaleLinePOSCoupon.IsEmpty then begin
                SaleLinePOSCoupon.SetSkipCalcDiscount(true);
                SaleLinePOSCoupon.FindSet();
                repeat
                    SaleLinePOSCoupon.Delete();
                until SaleLinePOSCoupon.Next() = 0;
            end;
            exit;
        end;

        SaleLinePOSCoupon.SetCurrentKey("Register No.", "Sales Ticket No.", "Sale Type", "Sale Date", "Application Sequence No.");
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
            SaleLinePOSCoupon2.CalcSums("Discount Amount");
            if SaleLinePOSCoupon."Discount Amount" <> SaleLinePOSCoupon2."Discount Amount" then begin
                SaleLinePOSCoupon."Discount Amount" := SaleLinePOSCoupon2."Discount Amount";
                SaleLinePOSCoupon.Modify();
            end;
        until SaleLinePOSCoupon.Next() = 0;

        SaleLinePOS.SetSkipCalcDiscount(true);
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        SaleLinePOS.SetRange("Sale Type", SalePOS."Sale type");
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
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
    end;

    procedure RemoveDiscount(SalePOS: Record "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        DiscountType: Integer;
    begin
        SaleLinePOSCoupon.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOSCoupon.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOSCoupon.SetRange("Sale Type", SalePOS."Sale type");
        SaleLinePOSCoupon.SetRange("Sale Date", SalePOS.Date);
        if SaleLinePOSCoupon.IsEmpty then
            exit;

        SaleLinePOSCoupon.SetRange(Type, SaleLinePOSCoupon.Type::Coupon);
        if SaleLinePOSCoupon.IsEmpty then begin
            SaleLinePOSCoupon.SetRange(Type, SaleLinePOSCoupon.Type::Discount);
            if not SaleLinePOSCoupon.IsEmpty then begin
                SaleLinePOSCoupon.SetSkipCalcDiscount(true);
                SaleLinePOSCoupon.FindSet();
                repeat
                    SaleLinePOSCoupon.Delete();
                until SaleLinePOSCoupon.Next() = 0;
            end;
            exit;
        end;

        SaleLinePOS.SetSkipCalcDiscount(true);
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        SaleLinePOS.SetRange("Sale Type", SalePOS."Sale type");
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
        SaleLinePOS.SetFilter("Coupon Discount Amount", '>%1', 0);
        if SaleLinePOS.IsEmpty then
            exit;

        SaleLinePOS.FindSet();
        repeat
            DiscountType := SaleLinePOS."Discount Type";

            SaleLinePOS.CalcFields("Coupon Discount Amount");

            SaleLinePOS."Discount %" := 0;
            SaleLinePOS."Discount Amount" -= SaleLinePOS."Coupon Discount Amount";
            if SaleLinePOS."Discount Amount" > (SaleLinePOS."Unit Price" * SaleLinePOS.Quantity) then
                SaleLinePOS."Discount %" := 100;
            SaleLinePOS.UpdateAmounts(SaleLinePOS);
            SaleLinePOS."Coupon Applied" := false;
            SaleLinePOS."Discount Type" := DiscountType;
            SaleLinePOS.Modify();
        until SaleLinePOS.Next() = 0;

        Clear(SaleLinePOSCoupon);
        SaleLinePOSCoupon.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOSCoupon.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOSCoupon.SetRange("Sale Type", SalePOS."Sale type");
        SaleLinePOSCoupon.SetRange("Sale Date", SalePOS.Date);
        SaleLinePOSCoupon.ModifyAll("Discount Amount", 0);
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

    procedure ArchiveCoupons(var CouponFilter: Record "NPR NpDc Coupon")
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
            CouponEntry."User ID" := UserId;
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
        CouponEntry."User ID" := UserId;
        CouponEntry."Closed by Entry No." := 0;
        CouponEntry.Insert();
    end;

    procedure PostIssueCoupon2(Coupon: Record "NPR NpDc Coupon"; Quantity: Decimal; AmountPerQty: Decimal)
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
        CouponEntry."User ID" := UserId;
        CouponEntry."Closed by Entry No." := 0;
        CouponEntry.Insert();
    end;

    procedure PostDiscountApplication(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon")
    var
        Coupon: Record "NPR NpDc Coupon";
        CouponEntry: Record "NPR NpDc Coupon Entry";
        NpDcCouponModuleMgt: Codeunit "NPR NpDc Coupon Module Mgt.";
    begin
        if not Coupon.Get(SaleLinePOSCoupon."Coupon No.") then
            exit;

        CouponEntry.Init();
        CouponEntry."Entry No." := 0;
        CouponEntry."Coupon No." := Coupon."No.";
        CouponEntry."Entry Type" := CouponEntry."Entry Type"::"Discount Application";
        CouponEntry."Coupon Type" := Coupon."Coupon Type";
        CouponEntry.Quantity := -1;
        CouponEntry."Remaining Quantity" := -1;
        CouponEntry."Amount per Qty." := SaleLinePOSCoupon."Discount Amount";
        CouponEntry.Amount := CouponEntry."Amount per Qty." * CouponEntry.Quantity;
        CouponEntry.Positive := CouponEntry.Quantity > 0;
        CouponEntry."Posting Date" := SaleLinePOSCoupon."Sale Date";
        CouponEntry.Open := true;
        CouponEntry."Register No." := SaleLinePOSCoupon."Register No.";
        CouponEntry."Document Type" := CouponEntry."Document Type"::"POS Entry";
        CouponEntry."Document No." := SaleLinePOSCoupon."Sales Ticket No.";
        CouponEntry."User ID" := UserId;
        CouponEntry."Closed by Entry No." := 0;
        CouponEntry.Insert();

        ApplyEntry(CouponEntry);
        Coupon.CalcFields("Issue Coupon Module", "Validate Coupon Module", "Apply Discount Module");
        NpDcCouponModuleMgt.OnPostDiscountApplication(SaleLinePOSCoupon, Coupon, CouponEntry);
        ArchiveClosedCoupon(Coupon);
    end;

    local procedure PostSaleLinePOS(var SaleLinePos: Record "NPR POS Sale Line")
    var
        SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
    begin
        SaleLinePOSCoupon.SetSkipCalcDiscount(true);
        SaleLinePOSCoupon.SetRange("Register No.", SaleLinePos."Register No.");
        SaleLinePOSCoupon.SetRange("Sales Ticket No.", SaleLinePos."Sales Ticket No.");
        SaleLinePOSCoupon.SetRange("Sale Type", SaleLinePos."Sale Type");
        SaleLinePOSCoupon.SetRange("Sale Date", SaleLinePos.Date);
        SaleLinePOSCoupon.SetRange("Sale Line No.", SaleLinePos."Line No.");
        SaleLinePOSCoupon.SetRange(Type, SaleLinePOSCoupon.Type::Coupon);
        if SaleLinePOSCoupon.IsEmpty then
            exit;

        SaleLinePOSCoupon.FindSet();
        repeat
            PostDiscountApplication(SaleLinePOSCoupon);
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

    procedure PostExtCouponReservation(SalesHeader: Record "Sales Header"; NpDcExtCouponReservation: Record "NPR NpDc Ext. Coupon Reserv.")
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
        CouponEntry."User ID" := UserId;
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
        ArchCoupon.Open := Coupon.Open;
        ArchCoupon."Remaining Quantity" := Coupon."Remaining Quantity";
        ArchCoupon."Issue Coupon Module" := Coupon."Issue Coupon Module";
        ArchCoupon."Validate Coupon Module" := Coupon."Validate Coupon Module";
        ArchCoupon."Apply Discount Module" := Coupon."Apply Discount Module";
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

    #endregion Archivation
    #region Pos Functionality

    local procedure ActionCode(): Text
    begin
        exit('SCAN_COUPON');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverActions(var Sender: Record "NPR POS Action")
    begin
        if not Sender.DiscoverAction(
          ActionCode(),
          Text000,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple) then
            exit;

        Sender.RegisterWorkflowStep('init', 'windowTitle = labels.CouponTitle;');
        Sender.RegisterWorkflowStep('coupon_input', 'if (!param.ReferenceNo) {' +
                                                    '  input ({caption: labels.ScanCouponPrompt, title: windowTitle, value: param.ReferenceNo}).store("CouponCode").cancel(abort);' +
                                                    '} else {' +
                                                    '  context.CouponCode = param.ReferenceNo;' +
                                                    '}');
        Sender.RegisterWorkflowStep('validate_coupon', 'respond ();');
        Sender.RegisterWorkflow(false);

        Sender.RegisterTextParameter('ReferenceNo', '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'ScanCouponPrompt', Text001);
        Captions.AddActionCaption(ActionCode(), 'CouponTitle', Text002);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', true, true)]
    local procedure OnScanCoupon("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        CouponReferenceNo: Text;
        ReadingScanCouponErr: Label 'reading from OnScanCoupon subscriber';
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;
        JSON.InitializeJObjectParser(Context, FrontEnd);
        CouponReferenceNo := JSON.GetStringOrFail('CouponCode', ReadingScanCouponErr);
        ScanCoupon(POSSession, CouponReferenceNo);
    end;

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
        SaleLinePOSCoupon.SetRange("Sale Type", Rec."Sale Type");
        SaleLinePOSCoupon.SetRange("Sale Date", Rec.Date);
        SaleLinePOSCoupon.SetRange("Applies-to Sale Line No.", Rec."Line No.");
        if not SaleLinePOSCoupon.IsEmpty then
            SaleLinePOSCoupon.DeleteAll();

        SaleLinePOSCoupon.Reset();
        SaleLinePOSCoupon.SetRange("Register No.", Rec."Register No.");
        SaleLinePOSCoupon.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
        SaleLinePOSCoupon.SetRange("Sale Type", Rec."Sale Type");
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

    procedure ScanCoupon(POSSession: Codeunit "NPR POS Session"; CouponReferenceNo: Text)
    var
        Coupon: Record "NPR NpDc Coupon";
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        POSSale: Codeunit "NPR POS Sale";
        SaleLineOut: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
    begin
        ValidateCoupon(POSSession, CouponReferenceNo, Coupon);

        POSSession.GetSaleLine(SaleLineOut);

        SaleLinePOS.Type := SaleLinePOS.Type::Comment;
        SaleLinePOS.Description := Coupon.Description;
        SaleLineOut.InsertLine(SaleLinePOS);
        POSSession.RequestRefreshData();

        SaleLinePOSCoupon.Init();
        SaleLinePOSCoupon."Register No." := SaleLinePOS."Register No.";
        SaleLinePOSCoupon."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        SaleLinePOSCoupon."Sale Type" := SaleLinePOS."Sale Type";
        SaleLinePOSCoupon."Sale Date" := SaleLinePOS.Date;
        SaleLinePOSCoupon."Sale Line No." := SaleLinePOS."Line No.";
        SaleLinePOSCoupon."Line No." := 10000;
        SaleLinePOSCoupon.Type := SaleLinePOSCoupon.Type::Coupon;
        SaleLinePOSCoupon.Validate("Coupon Type", Coupon."Coupon Type");
        SaleLinePOSCoupon."Coupon No." := Coupon."No.";
        SaleLinePOSCoupon.Description := Coupon.Description;
        SaleLinePOSCoupon."Discount Amount" := GetAmountPerQty(Coupon);
        SaleLinePOSCoupon.Insert(true);
        POSSalesDiscountCalcMgt.OnAfterInsertSaleLinePOSCoupon(SaleLinePOSCoupon);

        POSSession.GetSale(POSSale);
        POSSale.RefreshCurrent();
        SaleLineOut.SetPosition(SaleLinePOS.GetPosition(false));
        POSSession.RequestRefreshData();
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
    #region Ean Box Event Handling

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        NpDcCoupon: Record "NPR NpDc Coupon";
    begin
        if not EanBoxEvent.Get(EventCodeRefNo()) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := EventCodeRefNo();
            EanBoxEvent."Module Name" := Text002;
            EanBoxEvent.Description := CopyStr(NpDcCoupon.FieldCaption("Reference No."), 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR POS Input Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin
        case EanBoxEvent.Code of
            EventCodeRefNo():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'ReferenceNo', true, '');
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Evt Handler", 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeRefNo(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        NpDcCoupon: Record "NPR NpDc Coupon";
    begin
        if EanBoxSetupEvent."Event Code" <> EventCodeRefNo() then
            exit;
        if StrLen(EanBoxValue) > MaxStrLen(NpDcCoupon."Reference No.") then
            exit;

        NpDcCoupon.SetRange("Reference No.", EanBoxValue);
        if NpDcCoupon.FindFirst() then
            InScope := true;
    end;

    local procedure EventCodeRefNo(): Code[20]
    begin
        exit('DISCOUNT_COUPON');
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpDc Coupon Mgt.");
    end;

    #endregion Ean Box Event Handling
    #region Generate Reference No

    local procedure GetAmountPerQty(Coupon: Record "NPR NpDc Coupon"): Decimal
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

    procedure GenerateReferenceNo(Coupon: Record "NPR NpDc Coupon") ReferenceNo: Text
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

    procedure InitCouponType(var CouponType: Record "NPR NpDc Coupon Type")
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
        Coupon.TestField("Print Template Code");
        Coupon.SetRecFilter();
        RPTemplateMgt.PrintTemplate(Coupon."Print Template Code", Coupon, 0);
    end;

    #endregion Print
}