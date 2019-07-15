codeunit 6151590 "NpDc Coupon Mgt."
{
    // NPR5.34/MHA /20170720  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon
    // NPR5.36/MHA /20170831  CASE 288641 Added  SaleLinePOSCoupon.SetSkipCalcDiscount() in ApplyDiscount() and PostSaleLinePOS()
    // NPR5.37/MHA /20171006  CASE 292741 Added RecFilter to PrintCoupon() and PostSaleLinePOS()
    // NPR5.37/MHA /20171012  CASE 293232 Function "Posted Coupon" renamed to "Archived Coupon"
    // NPR5.39/MHA /20180214  CASE 305146 CouponType must be Enabled in IssueCoupons() and ValidateCoupon()
    // NPR5.40/MHA /20180323  CASE 305859 Added function InitCouponType()
    // NPR5.41/MHA /20180412  CASE 307048 Added function PostIssueCoupon2() which is an overload of PostIssueCoupon() to enable pre definition of Quantity and Amount per Qty.
    // NPR5.41/MHA /20180426  CASE 313062 Added function RemoveDiscount()
    // NPR5.42/TSA /20180502  CASE 313644 Added a test for Rec.Find() in OnBeforeDeletePOSSaleLine subscriber
    // NPR5.42/MMV /20180504  CASE 313062 Added field for tracking attached coupons.
    // NPR5.42/MHA /20180521  CASE 305859 Added "Print on Issue" to InitCouponType()
    // NPR5.45/MHA /20180814  CASE 323626 POS Discount Calculation is invoked explicitly
    // NPR5.45/MHA /20180817  CASE 319706 Added Ean Box Event Handler functions
    // NPR5.46/MHA /20180928  CASE 329523 Added POSSale.RefreshCurrent() in ScanCoupon()
    // NPR5.47/MHA /20181026  CASE 332655 Moved Discount Application from OnBeforeDelete to OnAfterDelete
    // NPR5.49/MHA /20190328  CASE 350374 Added MaxStrLen to EanBox.Description in DiscoverEanBoxEvents()


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'This action handles Scan Discount Coupon.';
        Text001: Label 'Scan Coupon:';
        Text002: Label 'Discount Coupon';
        Text003: Label 'Coupon Reference No. is too long';
        Text004: Label 'Invalid Coupon Reference No.';

    procedure ResetInUseQty(Coupon: Record "NpDc Coupon")
    var
        SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon";
    begin
        SaleLinePOSCoupon.SetRange("Coupon No.",Coupon."No.");
        if SaleLinePOSCoupon.IsEmpty then
          exit;

        SaleLinePOSCoupon.DeleteAll;
    end;

    local procedure "--- Issue Coupon"()
    begin
    end;

    procedure IssueCoupons(CouponType: Record "NpDc Coupon Type")
    var
        NpDcCouponModuleMgt: Codeunit "NpDc Coupon Module Mgt.";
        NpDcModuleIssueDefault: Codeunit "NpDc Module Issue - Default";
        Handled: Boolean;
    begin
        //-NPR5.39 [305146]
        CouponType.TestField(Enabled,true);
        //+NPR5.39 [305146]
        NpDcCouponModuleMgt.OnRunIssueCoupon(CouponType,Handled);
        if Handled then
          exit;

        NpDcModuleIssueDefault.IssueCoupons(CouponType);
    end;

    local procedure InitialEntryExists(Coupon: Record "NpDc Coupon"): Boolean
    var
        CouponEntry: Record "NpDc Coupon Entry";
    begin
        CouponEntry.SetRange("Coupon No.",Coupon."No.");
        CouponEntry.SetRange("Entry Type",CouponEntry."Entry Type"::"Issue Coupon");
        exit(CouponEntry.FindFirst);
    end;

    local procedure "--- Validate Coupon"()
    begin
    end;

    procedure ValidateCoupon(POSSession: Codeunit "POS Session";ReferenceNo: Text;var Coupon: Record "NpDc Coupon")
    var
        CouponType: Record "NpDc Coupon Type";
        SalePOS: Record "Sale POS";
        NpDcCouponModuleMgt: Codeunit "NpDc Coupon Module Mgt.";
        NpDcModuleValidateDefault: Codeunit "NpDc Module Validate - Default";
        SaleOut: Codeunit "POS Sale";
        Handled: Boolean;
    begin
        if StrLen(ReferenceNo) > MaxStrLen(Coupon."Reference No.") then
          Error(Text003);
        Coupon.SetRange("Reference No.",UpperCase(ReferenceNo));
        if not Coupon.FindFirst then
          Error(Text004);

        //-NPR5.39 [305146]
        CouponType.Get(Coupon."Coupon Type");
        CouponType.TestField(Enabled,true);
        //+NPR5.39 [305146]
        POSSession.GetSale(SaleOut);
        SaleOut.GetCurrentSale(SalePOS);
        NpDcCouponModuleMgt.OnRunValidateCoupon(SalePOS,Coupon,Handled);
        if Handled then
          exit;

        NpDcModuleValidateDefault.ValidateCoupon(SalePOS,Coupon);
    end;

    local procedure "--- Apply Discount"()
    begin
    end;

    procedure ApplyDiscount(SalePOS: Record "Sale POS")
    var
        SaleLinePOS: Record "Sale Line POS";
        SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon";
        NpDcModuleApplyDefault: Codeunit "NpDc Module Apply - Default";
        NpDcCouponModuleMgt: Codeunit "NpDc Coupon Module Mgt.";
        Handled: Boolean;
        DiscountType: Integer;
    begin
        SaleLinePOSCoupon.SetRange("Register No.",SalePOS."Register No.");
        SaleLinePOSCoupon.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        SaleLinePOSCoupon.SetRange("Sale Type",SalePOS."Sale type");
        SaleLinePOSCoupon.SetRange("Sale Date",SalePOS.Date);
        if SaleLinePOSCoupon.IsEmpty then
          exit;

        SaleLinePOSCoupon.SetRange(Type,SaleLinePOSCoupon.Type::Coupon);
        if SaleLinePOSCoupon.IsEmpty then begin
          SaleLinePOSCoupon.SetRange(Type,SaleLinePOSCoupon.Type::Discount);
          if not SaleLinePOSCoupon.IsEmpty then begin
            //-NPR5.36 [288641]
            //SaleLinePOSCoupon.DELETEALL;
            SaleLinePOSCoupon.SetSkipCalcDiscount(true);
            SaleLinePOSCoupon.FindSet;
            repeat
              SaleLinePOSCoupon.Delete;
            until SaleLinePOSCoupon.Next = 0;
            //+NPR5.36 [288641]
          end;
          exit;
        end;

        SaleLinePOSCoupon.FindSet;
        repeat
          Handled := false;
          NpDcCouponModuleMgt.OnRunApplyDiscount(SaleLinePOSCoupon,Handled);
          if not Handled then
            NpDcModuleApplyDefault.ApplyDiscount(SaleLinePOSCoupon);
        until SaleLinePOSCoupon.Next = 0;

        SaleLinePOS.SetSkipCalcDiscount(true);
        SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date,SalePOS.Date);
        SaleLinePOS.SetRange("Sale Type",SalePOS."Sale type");
        SaleLinePOS.SetRange(Type,SaleLinePOS.Type::Item);
        SaleLinePOS.SetFilter("Coupon Discount Amount",'>%1',0);
        if SaleLinePOS.IsEmpty then
          exit;

        SaleLinePOS.FindSet;
        repeat
          DiscountType := SaleLinePOS."Discount Type";

        //-NPR5.42 [313062]
        //  CLEAR(Item);
        //  IF Item.GET(SaleLinePOS."No.") THEN;
        //+NPR5.42 [313062]
          SaleLinePOS.CalcFields("Coupon Discount Amount");

          SaleLinePOS."Discount %" := 0;
          SaleLinePOS."Discount Amount" += SaleLinePOS."Coupon Discount Amount";
          if SaleLinePOS."Discount Amount" > (SaleLinePOS."Unit Price" * SaleLinePOS.Quantity) then
            SaleLinePOS."Discount %" := 100;
        //-NPR5.42 [313062]
        //  SaleLinePOS.GetAmount(SaleLinePOS,Item,SaleLinePOS."Unit Price");
          SaleLinePOS.UpdateAmounts(SaleLinePOS);
          SaleLinePOS."Coupon Applied" := true;
        //+NPR5.42 [313062]
          SaleLinePOS."Discount Type" := DiscountType;
          SaleLinePOS.Modify;
        until SaleLinePOS.Next = 0;
    end;

    procedure RemoveDiscount(SalePOS: Record "Sale POS")
    var
        SaleLinePOS: Record "Sale Line POS";
        SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon";
        NpDcModuleApplyDefault: Codeunit "NpDc Module Apply - Default";
        NpDcCouponModuleMgt: Codeunit "NpDc Coupon Module Mgt.";
        Handled: Boolean;
        DiscountType: Integer;
    begin
        //-NPR5.41 [313062]
        SaleLinePOSCoupon.SetRange("Register No.",SalePOS."Register No.");
        SaleLinePOSCoupon.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        SaleLinePOSCoupon.SetRange("Sale Type",SalePOS."Sale type");
        SaleLinePOSCoupon.SetRange("Sale Date",SalePOS.Date);
        if SaleLinePOSCoupon.IsEmpty then
          exit;

        SaleLinePOSCoupon.SetRange(Type,SaleLinePOSCoupon.Type::Coupon);
        if SaleLinePOSCoupon.IsEmpty then begin
          SaleLinePOSCoupon.SetRange(Type,SaleLinePOSCoupon.Type::Discount);
          if not SaleLinePOSCoupon.IsEmpty then begin
            SaleLinePOSCoupon.SetSkipCalcDiscount(true);
            SaleLinePOSCoupon.FindSet;
            repeat
              SaleLinePOSCoupon.Delete;
            until SaleLinePOSCoupon.Next = 0;
          end;
          exit;
        end;

        SaleLinePOS.SetSkipCalcDiscount(true);
        SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date,SalePOS.Date);
        SaleLinePOS.SetRange("Sale Type",SalePOS."Sale type");
        SaleLinePOS.SetRange(Type,SaleLinePOS.Type::Item);
        SaleLinePOS.SetFilter("Coupon Discount Amount",'>%1',0);
        if SaleLinePOS.IsEmpty then
          exit;

        SaleLinePOS.FindSet;
        repeat
          DiscountType := SaleLinePOS."Discount Type";

        //-NPR5.42 [313062]
        //  CLEAR(Item);
        //  IF Item.GET(SaleLinePOS."No.") THEN;
        //+NPR5.42 [313062]
          SaleLinePOS.CalcFields("Coupon Discount Amount");

          SaleLinePOS."Discount %" := 0;
          SaleLinePOS."Discount Amount" -= SaleLinePOS."Coupon Discount Amount";
          if SaleLinePOS."Discount Amount" > (SaleLinePOS."Unit Price" * SaleLinePOS.Quantity) then
            SaleLinePOS."Discount %" := 100;
        //-NPR5.42 [313062]
        //  SaleLinePOS.GetAmount(SaleLinePOS,Item,SaleLinePOS."Unit Price");
          SaleLinePOS.UpdateAmounts(SaleLinePOS);
          SaleLinePOS."Coupon Applied" := false;
        //+NPR5.42 [313062]
          SaleLinePOS."Discount Type" := DiscountType;
          SaleLinePOS.Modify;
        until SaleLinePOS.Next = 0;
        //+NPR5.41 [313062]
    end;

    local procedure "--- Archivation"()
    begin
    end;

    local procedure ApplyEntry(var CouponEntry: Record "NpDc Coupon Entry")
    var
        CouponEntryApply: Record "NpDc Coupon Entry";
    begin
        if CouponEntry.IsTemporary then
          exit;
        if not CouponEntry.Find then
          exit;
        if not CouponEntry.Open then
          exit;

        CouponEntryApply.SetRange("Coupon No.",CouponEntry."Coupon No.");
        CouponEntryApply.SetRange(Open,true);
        CouponEntryApply.SetRange(Positive,not CouponEntry.Positive);
        if not CouponEntryApply.FindSet then
          exit;

        repeat
          //-NPR5.37 [292741]
          //IF CouponEntryApply."Remaining Quantity" >= CouponEntry."Remaining Quantity" THEN BEGIN
          if Abs(CouponEntryApply."Remaining Quantity") >= Abs(CouponEntry."Remaining Quantity") then begin
          //+NPR5.37 [292741]
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

          CouponEntry.Modify;
          CouponEntryApply.Modify;
        until (CouponEntryApply.Next = 0) or not CouponEntry.Open;
    end;

    procedure ArchiveCoupons(var CouponFilter: Record "NpDc Coupon")
    var
        Coupon: Record "NpDc Coupon";
    begin
        Coupon.Copy(CouponFilter);
        if Coupon.GetFilters = '' then
          Coupon.SetRecFilter;

        if not Coupon.FindSet then
          exit;

        repeat
          //-NPR5.37 [293232]
          //ManualPostCoupon(Coupon);
          ArchiveCoupon(Coupon);
          //+NPR5.37 [293232]
        until Coupon.Next = 0;
    end;

    local procedure ArchiveCoupon(var Coupon: Record "NpDc Coupon")
    var
        CouponEntry: Record "NpDc Coupon Entry";
    begin
        Coupon.CalcFields("Remaining Quantity");
        if Coupon."Remaining Quantity" <> 0 then begin
          CouponEntry.Init;
          CouponEntry."Entry No." := 0;
          CouponEntry."Coupon No." := Coupon."No.";
          CouponEntry."Entry Type" := CouponEntry."Entry Type"::"Manual Archive";
          CouponEntry."Coupon Type" := Coupon."Coupon Type";
          CouponEntry.Quantity := -Coupon."Remaining Quantity";
          CouponEntry."Remaining Quantity" := -Coupon."Remaining Quantity";
          CouponEntry."Amount per Qty." := 0;
          CouponEntry.Amount := 0;
          CouponEntry.Positive := CouponEntry.Quantity > 0;
          CouponEntry."Posting Date" := Today;
          CouponEntry.Open := true;
          CouponEntry."Register No." := '';
          CouponEntry."Sales Ticket No." := '';
          CouponEntry."User ID" := UserId;
          CouponEntry."Closed by Entry No." := 0;
          CouponEntry.Insert;

          ApplyEntry(CouponEntry);
        end;

        //-NPR5.37 [293232]
        //PostClosedCoupon(Coupon);
        ArchiveClosedCoupon(Coupon);
        //+NPR5.37 [293232]
    end;

    procedure PostIssueCoupon(Coupon: Record "NpDc Coupon")
    var
        CouponEntry: Record "NpDc Coupon Entry";
        CouponType: Record "NpDc Coupon Type";
    begin
        if InitialEntryExists(Coupon) then
          exit;

        CouponType.Get(Coupon."Coupon Type");

        CouponEntry.Init;
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
        CouponEntry."Posting Date" := Today;
        CouponEntry.Open := true;
        CouponEntry."Register No." := '';
        CouponEntry."Sales Ticket No." := '';
        CouponEntry."User ID" := UserId;
        CouponEntry."Closed by Entry No." := 0;
        CouponEntry.Insert;
    end;

    procedure PostIssueCoupon2(Coupon: Record "NpDc Coupon";Quantity: Decimal;AmountPerQty: Decimal)
    var
        CouponEntry: Record "NpDc Coupon Entry";
    begin
        //-NPR5.41 [307048]
        if InitialEntryExists(Coupon) then
          exit;

        CouponEntry.Init;
        CouponEntry."Entry No." := 0;
        CouponEntry."Coupon No." := Coupon."No.";
        CouponEntry."Entry Type" := CouponEntry."Entry Type"::"Issue Coupon";
        CouponEntry."Coupon Type" := Coupon."Coupon Type";
        CouponEntry."Amount per Qty." := AmountPerQty;
        CouponEntry.Quantity := Quantity;
        CouponEntry."Remaining Quantity" := CouponEntry.Quantity;
        CouponEntry.Amount := CouponEntry."Amount per Qty." * CouponEntry.Quantity;
        CouponEntry.Positive := CouponEntry.Quantity > 0;
        CouponEntry."Posting Date" := Today;
        CouponEntry.Open := true;
        CouponEntry."Register No." := '';
        CouponEntry."Sales Ticket No." := '';
        CouponEntry."User ID" := UserId;
        CouponEntry."Closed by Entry No." := 0;
        CouponEntry.Insert;
        //+NPR5.41 [307048]
    end;

    procedure PostDiscountApplication(SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon")
    var
        Coupon: Record "NpDc Coupon";
        CouponEntry: Record "NpDc Coupon Entry";
    begin
        if not Coupon.Get(SaleLinePOSCoupon."Coupon No.") then
          exit;

        CouponEntry.Init;
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
        CouponEntry."Sales Ticket No." := SaleLinePOSCoupon."Sales Ticket No.";
        CouponEntry."User ID" := UserId;
        CouponEntry."Closed by Entry No." := 0;
        CouponEntry.Insert;

        ApplyEntry(CouponEntry);
        //-NPR5.37 [293232]
        //PostClosedCoupon(Coupon);
        ArchiveClosedCoupon(Coupon);
        //+NPR5.37 [293232]
    end;

    local procedure PostSaleLinePOS(var SaleLinePos: Record "Sale Line POS")
    var
        SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon";
    begin
        //-NPR5.36 [288641]
        SaleLinePOSCoupon.SetSkipCalcDiscount(true);
        //+NPR5.36 [288641]
        SaleLinePOSCoupon.SetRange("Register No.",SaleLinePos."Register No.");
        SaleLinePOSCoupon.SetRange("Sales Ticket No.",SaleLinePos."Sales Ticket No.");
        SaleLinePOSCoupon.SetRange("Sale Type",SaleLinePos."Sale Type");
        SaleLinePOSCoupon.SetRange("Sale Date",SaleLinePos.Date);
        SaleLinePOSCoupon.SetRange("Sale Line No.",SaleLinePos."Line No.");
        SaleLinePOSCoupon.SetRange(Type,SaleLinePOSCoupon.Type::Coupon);
        if SaleLinePOSCoupon.IsEmpty then
          exit;

        SaleLinePOSCoupon.FindSet;
        repeat
          PostDiscountApplication(SaleLinePOSCoupon);
          //-NPR5.36 [288641]
          SaleLinePOSCoupon.Delete;
          //+NPR5.36 [288641]
        until SaleLinePOSCoupon.Next = 0;
        //-NPR5.36 [288641]
        //SaleLinePOSCoupon.DELETEALL;
        //+NPR5.36 [288641]
    end;

    local procedure ArchiveClosedCoupon(var Coupon: Record "NpDc Coupon")
    var
        CouponEntry: Record "NpDc Coupon Entry";
        CouponSetup: Record "NpDc Coupon Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        Coupon.CalcFields(Open);
        if Coupon.Open then
          exit;

        CouponSetup.Get;
        CouponSetup.TestField("Arch. Coupon No. Series");
        Coupon."Arch. No." := Coupon."No.";
        if Coupon."No. Series" <> CouponSetup."Arch. Coupon No. Series" then
          Coupon."Arch. No." := NoSeriesMgt.GetNextNo(CouponSetup."Arch. Coupon No. Series",Today,true);

        //-NPR5.37 [293232]
        //InsertArchCoupon(Coupon);
        InsertArchivedCoupon(Coupon);
        //+NPR5.37 [293232]
        CouponEntry.SetRange("Coupon No.",Coupon."No.");
        if not CouponEntry.IsEmpty then begin
          CouponEntry.FindSet;
          repeat
            //-NPR5.37 [293232]
            //InsertArchCouponEntry(Coupon,CouponEntry);
            InsertArchivedCouponEntry(Coupon,CouponEntry);
            //+NPR5.37 [293232]
          until CouponEntry.Next = 0;
          CouponEntry.DeleteAll;
        end;

        Coupon.Delete;
    end;

    local procedure InsertArchivedCoupon(var Coupon: Record "NpDc Coupon")
    var
        ArchCoupon: Record "NpDc Arch. Coupon";
    begin
        //-NPR5.37 [293232]
        ArchCoupon.Init;
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
        ArchCoupon."In-use Quantity" := Coupon."In-use Quantity";
        ArchCoupon."Issue Coupon Module" := Coupon."Issue Coupon Module";
        ArchCoupon."Validate Coupon Module" := Coupon."Validate Coupon Module";
        ArchCoupon."Apply Discount Module" := Coupon."Apply Discount Module";
        ArchCoupon.Insert;
        //+NPR5.37 [293232]
    end;

    local procedure InsertArchivedCouponEntry(Coupon: Record "NpDc Coupon";CouponEntry: Record "NpDc Coupon Entry")
    var
        ArchCouponEntry: Record "NpDc Arch. Coupon Entry";
    begin
        //-NPR5.37 [293232]
        ArchCouponEntry.Init;
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
        ArchCouponEntry."Sales Ticket No." := CouponEntry."Sales Ticket No.";
        ArchCouponEntry."User ID" := CouponEntry."User ID";
        ArchCouponEntry."Closed by Entry No." := CouponEntry."Closed by Entry No.";
        ArchCouponEntry.Insert;
        //+NPR5.37 [293232]
    end;

    local procedure "--- Pos Functionality"()
    begin
    end;

    local procedure ActionCode(): Text
    begin
        exit ('SCAN_COUPON');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverActions(var Sender: Record "POS Action")
    var
        FunctionOptionString: Text;
        JSArr: Text;
        OptionName: Text;
        N: Integer;
    begin
        if not Sender.DiscoverAction(
          ActionCode(),
          Text000,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple) then
         exit;

        Sender.RegisterWorkflowStep ('init','windowTitle = labels.CouponTitle;');
        Sender.RegisterWorkflowStep ('coupon_input','if (!param.ReferenceNo) {' +
                                                    '  input ({caption: labels.ScanCouponPrompt, title: windowTitle, value: param.ReferenceNo}).store("CouponCode").cancel(abort);' +
                                                    '} else {' +
                                                    '  context.CouponCode = param.ReferenceNo;' +
                                                    '}');
        Sender.RegisterWorkflowStep ('validate_coupon','respond ();');
        Sender.RegisterWorkflow(false);

        Sender.RegisterTextParameter('ReferenceNo','');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode,'ScanCouponPrompt',Text001);
        Captions.AddActionCaption(ActionCode,'CouponTitle', Text002);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', true, true)]
    local procedure OnScanCoupon("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        SaleLineOut: Codeunit "POS Sale Line";
        CouponReferenceNo: Text;
    begin
        if not Action.IsThisAction(ActionCode()) then
          exit;

        Handled := true;
        JSON.InitializeJObjectParser(Context, FrontEnd);
        CouponReferenceNo := JSON.GetString('CouponCode',true);
        ScanCoupon(POSSession,CouponReferenceNo);
    end;

    [EventSubscriber(ObjectType::Table, 6014406, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeletePOSSaleLine(var Rec: Record "Sale Line POS";RunTrigger: Boolean)
    var
        SalePOS: Record "Sale POS";
        SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon";
    begin
        if Rec.IsTemporary then
          exit;
        //-NPR5.41 [313062]
        if not SalePOS.Get(Rec."Register No.",Rec."Sales Ticket No.") then
          exit;
        RemoveDiscount(SalePOS);
        //+NPR5.41 [313062]

        SaleLinePOSCoupon.SetRange("Register No.",Rec."Register No.");
        SaleLinePOSCoupon.SetRange("Sales Ticket No.",Rec."Sales Ticket No.");
        SaleLinePOSCoupon.SetRange("Sale Type",Rec."Sale Type");
        SaleLinePOSCoupon.SetRange("Sale Date",Rec.Date);
        SaleLinePOSCoupon.SetRange("Applies-to Sale Line No.",Rec."Line No.");
        if not SaleLinePOSCoupon.IsEmpty then
          SaleLinePOSCoupon.DeleteAll;

        SaleLinePOSCoupon.Reset;
        SaleLinePOSCoupon.SetRange("Register No.",Rec."Register No.");
        SaleLinePOSCoupon.SetRange("Sales Ticket No.",Rec."Sales Ticket No.");
        SaleLinePOSCoupon.SetRange("Sale Type",Rec."Sale Type");
        SaleLinePOSCoupon.SetRange("Sale Date",Rec.Date);
        SaleLinePOSCoupon.SetRange("Sale Line No.",Rec."Line No.");
        if not SaleLinePOSCoupon.IsEmpty then
          SaleLinePOSCoupon.DeleteAll;

        //-NPR5.41 [313062]
        //-NPR5.47 [332655]
        // ApplyDiscount(SalePOS);
        //+NPR5.47 [332655]

        //-NPR5.42 [313644]
        //Rec.FIND;
        if (Rec.Find ()) then ;
        //+NPR5.42 [313644]

        //+NPR5.41 [313062]
    end;

    [EventSubscriber(ObjectType::Table, 6014406, 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDeletePOSSaleLine(var Rec: Record "Sale Line POS";RunTrigger: Boolean)
    var
        SalePOS: Record "Sale POS";
        SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon";
    begin
        //-NPR5.47 [332655]
        if Rec.IsTemporary then
          exit;
        if not SalePOS.Get(Rec."Register No.",Rec."Sales Ticket No.") then
          exit;

        ApplyDiscount(SalePOS);

        if Rec.Find () then ;
        //+NPR5.47 [332655]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014435, 'OnBeforeAuditRoleLineInsertEvent', '', false, false)]
    local procedure OnAuditRollInsert(var SaleLinePos: Record "Sale Line POS")
    begin
        SaleLinePos.CalcFields("Coupon Qty.");
        if SaleLinePos."Coupon Qty." <= 0 then
          exit;

        PostSaleLinePOS(SaleLinePos);
    end;

    procedure ScanCoupon(POSSession: Codeunit "POS Session";CouponReferenceNo: Text)
    var
        Coupon: Record "NpDc Coupon";
        SaleLinePOS: Record "Sale Line POS";
        SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon";
        POSSale: Codeunit "POS Sale";
        SaleLineOut: Codeunit "POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "POS Sales Discount Calc. Mgt.";
    begin
        ValidateCoupon(POSSession,CouponReferenceNo,Coupon);

        POSSession.GetSaleLine(SaleLineOut);

        SaleLinePOS.Type := SaleLinePOS.Type::Comment;
        SaleLinePOS.Description := Coupon.Description;
        SaleLineOut.InsertLine(SaleLinePOS);
        POSSession.RequestRefreshData();
        //-NPR5.46 [329523]
        //SaleLineOut.GetCurrentSaleLine(SaleLinePOS);
        //+NPR5.46 [329523]

        SaleLinePOSCoupon.Init;
        SaleLinePOSCoupon."Register No." := SaleLinePOS."Register No.";
        SaleLinePOSCoupon."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        SaleLinePOSCoupon."Sale Type" := SaleLinePOS."Sale Type";
        SaleLinePOSCoupon."Sale Date" := SaleLinePOS.Date;
        SaleLinePOSCoupon."Sale Line No." := SaleLinePOS."Line No.";
        SaleLinePOSCoupon."Line No." := 10000;
        SaleLinePOSCoupon.Type := SaleLinePOSCoupon.Type::Coupon;
        SaleLinePOSCoupon."Coupon Type" := Coupon."Coupon Type";
        SaleLinePOSCoupon."Coupon No." := Coupon."No.";
        SaleLinePOSCoupon.Description := Coupon.Description;
        SaleLinePOSCoupon."Discount Amount" := GetAmountPerQty(Coupon);
        SaleLinePOSCoupon.Insert(true);
        //-NPR5.45 [323626]
        POSSalesDiscountCalcMgt.OnAfterInsertSaleLinePOSCoupon(SaleLinePOSCoupon);
        //+NPR5.45 [323626]

        //-NPR5.46 [329523]
        POSSession.GetSale(POSSale);
        POSSale.RefreshCurrent();
        SaleLineOut.SetPosition(SaleLinePOS.GetPosition(false));
        POSSession.RequestRefreshData();
        //+NPR5.46 [329523]
    end;

    local procedure "--- Ean Box Event Handling"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "Ean Box Event")
    var
        NpDcCoupon: Record "NpDc Coupon";
    begin
        //-NPR5.45 [319706]
        if not EanBoxEvent.Get(EventCodeRefNo()) then begin
          EanBoxEvent.Init;
          EanBoxEvent.Code := EventCodeRefNo();
          EanBoxEvent."Module Name" := Text002;
          //-NPR5.49 [350374]
          //EanBoxEvent.Description := NpDcCoupon.FIELDCAPTION("Reference No.");
          EanBoxEvent.Description := CopyStr(NpDcCoupon.FieldCaption("Reference No."),1,MaxStrLen(EanBoxEvent.Description));
          //+NPR5.49 [350374]
          EanBoxEvent."Action Code" := ActionCode();
          EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
          EanBoxEvent."Event Codeunit" := CurrCodeunitId();
          EanBoxEvent.Insert(true);
        end;
        //+NPR5.45 [319706]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "Ean Box Setup Mgt.";EanBoxEvent: Record "Ean Box Event")
    begin
        //-NPR5.45 [319706]
        case EanBoxEvent.Code of
          EventCodeRefNo():
            begin
              Sender.SetNonEditableParameterValues(EanBoxEvent,'ReferenceNo',true,'');
            end;
        end;
        //+NPR5.45 [319706]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060107, 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeRefNo(EanBoxSetupEvent: Record "Ean Box Setup Event";EanBoxValue: Text;var InScope: Boolean)
    var
        NpDcCoupon: Record "NpDc Coupon";
    begin
        //-NPR5.45 [319706]
        if EanBoxSetupEvent."Event Code" <> EventCodeRefNo()  then
          exit;
        if StrLen(EanBoxValue) > MaxStrLen(NpDcCoupon."Reference No.") then
          exit;

        NpDcCoupon.SetRange("Reference No.",EanBoxValue);
        if NpDcCoupon.FindFirst then
          InScope := true;
        //+NPR5.45 [319706]
    end;

    local procedure EventCodeRefNo(): Code[20]
    begin
        //-NPR5.45 [319706]
        exit('DISCOUNT_COUPON');
        //+NPR5.45 [319706]
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        //-NPR5.45 [319706]
        exit(CODEUNIT::"NpDc Coupon Mgt.");
        //+NPR5.45 [319706]
    end;

    local procedure "--- Generate Reference No"()
    begin
    end;

    local procedure GetAmountPerQty(Coupon: Record "NpDc Coupon") AmountPerQty: Decimal
    var
        NpDcCouponEntry: Record "NpDc Coupon Entry";
        NpDcSaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon";
    begin
        NpDcCouponEntry.SetRange("Coupon No.",Coupon."No.");
        NpDcCouponEntry.SetRange(Open,true);
        NpDcCouponEntry.SetFilter("Remaining Quantity",'>%1',0);
        if NpDcCouponEntry.IsEmpty then
          exit(0);

        NpDcCouponEntry.FindFirst;
        exit(NpDcCouponEntry."Amount per Qty.");
    end;

    procedure GenerateReferenceNo(Coupon: Record "NpDc Coupon") ReferenceNo: Text
    var
        Coupon2: Record "NpDc Coupon";
        CouponType: Record "NpDc Coupon Type";
        i: Integer;
    begin
        CouponType.Get(Coupon."Coupon Type");

        for i := 1 to 100 do begin
          ReferenceNo := CouponType."Reference No. Pattern";
          ReferenceNo := RegExReplaceAN(ReferenceNo);
          ReferenceNo := RegExReplaceS(ReferenceNo,Coupon."No.");
          ReferenceNo := UpperCase(CopyStr(ReferenceNo,1,MaxStrLen(Coupon."Reference No.")));

          Coupon2.SetFilter("No.",'<>%1',Coupon."No.");
          Coupon2.SetRange("Reference No.",ReferenceNo);
          if Coupon2.IsEmpty then
            exit(ReferenceNo);

          if ReferenceNo = CouponType."Reference No. Pattern" then
            exit(ReferenceNo);
        end;

        exit(ReferenceNo);
    end;

    local procedure RegExReplaceAN(Input: Text) Output: Text
    var
        Match: DotNet npNetMatch;
        RegEx: DotNet npNetRegex;
        Pattern: Text;
        ReplaceString: Text;
        RandomQty: Integer;
        i: Integer;
    begin
        Pattern := '(?<RandomStart>\[AN\*?)' +
                   '(?<RandomQty>\d?)' +
                   '(?<RandomEnd>\])';
        RegEx := RegEx.Regex(Pattern);

        Match := RegEx.Match(Input);
        while Match.Success do begin
          ReplaceString := '';
          RandomQty := 1;
          if Evaluate(RandomQty,Format(Match.Groups.Item('RandomQty'))) then;
          for i := 1 to RandomQty do
            ReplaceString += Format(GenerateRandomChar());
          Input := RegEx.Replace(Input,ReplaceString,1);

          Match := RegEx.Match(Input);
        end;

        Output := Input;
        exit(Output);
    end;

    local procedure RegExReplaceS(Input: Text;SerialNo: Text) Output: Text
    var
        Match: DotNet npNetMatch;
        RegEx: DotNet npNetRegex;
        Pattern: Text;
    begin
        Pattern := '(?<SerialNo>\[S\])';
        RegEx := RegEx.Regex(Pattern);
        Output := RegEx.Replace(Input,SerialNo);
        exit(Output);
    end;

    local procedure GenerateRandomChar() RandomChar: Char
    var
        RandomInt: Integer;
        RandomText: Text[1];
    begin
        RandomInt := Random(9999);

        if Random(35) < 10 then begin
          RandomText := Format(RandomInt mod 10);
          RandomChar := RandomText[1];
          exit(RandomChar);
        end;

        RandomChar := (RandomInt mod 25) + 65;
        RandomText := UpperCase(Format(RandomChar));
        RandomChar := RandomText[1];
        exit(RandomChar);
    end;

    local procedure "--- Init"()
    begin
    end;

    procedure InitCouponType(var CouponType: Record "NpDc Coupon Type")
    var
        CouponSetup: Record "NpDc Coupon Setup";
    begin
        //-NPR5.40 [305859]
        CouponSetup.Get;
        if CouponType."Reference No. Pattern" = '' then
          CouponType."Reference No. Pattern" := CouponSetup."Reference No. Pattern";
        if CouponType."Print Template Code" = '' then
          CouponType."Print Template Code" := CouponSetup."Print Template Code";
        //+NPR5.40 [305859]
        //-NPR5.42 [305859]
        CouponType."Print on Issue" := CouponSetup."Print on Issue";
        //+NPR5.42 [305859]
    end;

    local procedure "--- Print"()
    begin
    end;

    procedure PrintCoupon(Coupon: Record "NpDc Coupon")
    var
        RPTemplateMgt: Codeunit "RP Template Mgt.";
    begin
        Coupon.TestField("Print Template Code");
        //-NPR5.37 [292741]
        Coupon.SetRecFilter;
        //+NPR5.37 [292741]
        RPTemplateMgt.PrintTemplate(Coupon."Print Template Code",Coupon,0);
    end;
}

