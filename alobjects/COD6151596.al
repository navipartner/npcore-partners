codeunit 6151596 "NpDc Module Apply - Item List"
{
    // NPR5.34/MHA /20170720  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon
    // NPR5.38/MHA /20180105  CASE 301053 Corrected CASE for "Item Disc. Group" in FindSaleLinePOSItems()
    // NPR5.41/MHA /20180426  CASE 313062 Discount Type "Discount %" should distribute Discount evenly on all lines
    // NPR5.45/MHA /20180820  CASE 312991 Added "Max Quantity" functionality


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Apply Discount - Item List';

    local procedure ApplyDiscount(SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon")
    var
        Coupon: Record "NpDc Coupon";
        NpDcCouponListItem: Record "NpDc Coupon List Item";
        SaleLinePOSCouponApply: Record "NpDc Sale Line POS Coupon";
        DiscountAmt: Decimal;
        RemainingDiscountAmt: Decimal;
        RemainingQty: Decimal;
        TotalAmt: Decimal;
    begin
        if FindSaleLinePOSCouponApply(SaleLinePOSCoupon,SaleLinePOSCouponApply) then
          SaleLinePOSCouponApply.DeleteAll;

        TotalAmt := CalcTotalAmt(SaleLinePOSCoupon);
        if TotalAmt <= 0 then
          exit;

        DiscountAmt := CalcDiscountAmount(SaleLinePOSCoupon,TotalAmt);
        if DiscountAmt <= 0 then
          exit;
        RemainingDiscountAmt := DiscountAmt;
        if not FindCouponListItems(SaleLinePOSCoupon,NpDcCouponListItem) then
          exit;

        //-NPR5.45 [312991]
        RemainingQty := -1;
        if NpDcCouponListItem.Get(SaleLinePOSCoupon."Coupon Type",-1) then
          RemainingQty := NpDcCouponListItem."Max. Quantity";
        //+NPR5.45 [312991]
        NpDcCouponListItem.SetCurrentKey(Priority);
        NpDcCouponListItem.FindSet;
        //-NPR5.41 [313062]
        Coupon.Get(SaleLinePOSCoupon."Coupon No.");
        if Coupon."Discount Type" = Coupon."Discount Type"::"Discount %" then begin
          repeat
            //-NPR5.45 [312991]
            //ApplyDiscountListItemPct(SaleLinePOSCoupon,Coupon."Discount %",TotalAmt,NpDcCouponListItem,RemainingDiscountAmt);
            ApplyDiscountListItemPct(SaleLinePOSCoupon,Coupon."Discount %",TotalAmt,NpDcCouponListItem,RemainingDiscountAmt,RemainingQty);
            //+NPR5.45 [312991]
          until NpDcCouponListItem.Next = 0;
          exit;
        end;
        //+NPR5.41 [313062]
        repeat
          //-NPR5.45 [312991]
          //ApplyDiscountListItem(SaleLinePOSCoupon,DiscountAmt,TotalAmt,NpDcCouponListItem,RemainingDiscountAmt);
          ApplyDiscountListItem(SaleLinePOSCoupon,DiscountAmt,TotalAmt,NpDcCouponListItem,RemainingDiscountAmt,RemainingQty);
          //+NPR5.45 [312991]
        until (NpDcCouponListItem.Next = 0) or (DiscountAmt <= 0);
    end;

    local procedure ApplyDiscountListItem(SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon";DiscountAmt: Decimal;TotalAmt: Decimal;NpDcCouponListItem: Record "NpDc Coupon List Item";var RemainingDiscountAmt: Decimal;RemainingQty: Decimal)
    var
        SaleLinePOS: Record "Sale Line POS";
        AppliedListItemDiscAmt: Decimal;
        AppliedQty: Decimal;
    begin
        if DiscountAmt <= 0 then
          exit;

        if not FindSaleLinePOSItems(SaleLinePOSCoupon,NpDcCouponListItem,SaleLinePOS) then
          exit;

        AppliedListItemDiscAmt := 0;
        SaleLinePOS.FindSet;
        //-NPR5.45 [312991]
        // REPEAT
        //  ApplyDiscountSaleLinePOS(SaleLinePOSCoupon,DiscountAmt,TotalAmt,NpDcCouponListItem,SaleLinePOS,AppliedListItemDiscAmt,RemainingDiscountAmt);
        // UNTIL (SaleLinePOS.NEXT = 0) OR (RemainingDiscountAmt <= 0);
        repeat
          ApplyDiscountSaleLinePOS(SaleLinePOSCoupon,DiscountAmt,TotalAmt,NpDcCouponListItem,SaleLinePOS,AppliedListItemDiscAmt,RemainingDiscountAmt,AppliedQty,RemainingQty);
        until (SaleLinePOS.Next = 0) or (RemainingDiscountAmt <= 0) or (RemainingQty = 0);
        //+NPR5.45 [312991]
    end;

    local procedure ApplyDiscountListItemPct(SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon";DiscountPct: Decimal;TotalAmt: Decimal;NpDcCouponListItem: Record "NpDc Coupon List Item";var RemainingDiscountAmt: Decimal;var RemainingQty: Decimal)
    var
        SaleLinePOS: Record "Sale Line POS";
        SaleLinePOSCouponApply: Record "NpDc Sale Line POS Coupon";
        AppliedListItemDiscAmt: Decimal;
        AppliedQty: Decimal;
        DiscountAmt: Decimal;
        MaxQty: Decimal;
        QtyToApply: Integer;
        LineNo: Integer;
    begin
        //-NPR5.41 [313062]
        if not FindSaleLinePOSItems(SaleLinePOSCoupon,NpDcCouponListItem,SaleLinePOS) then
          exit;

        AppliedListItemDiscAmt := 0;
        SaleLinePOS.FindSet;
        //-NPR5.45 [312991]
        repeat
          if not HasAppliedCouponDiscount(SaleLinePOS) then begin
            QtyToApply := SaleLinePOS.Quantity;
            if (NpDcCouponListItem."Max. Quantity" > 0) and (AppliedQty + QtyToApply > NpDcCouponListItem."Max. Quantity") then
              QtyToApply := NpDcCouponListItem."Max. Quantity" - AppliedQty;
            if (QtyToApply > RemainingQty) and (RemainingQty >= 0) then
              QtyToApply := RemainingQty;

            SaleLinePOS."Amount Including VAT" := (SaleLinePOS."Amount Including VAT" / SaleLinePOS.Quantity) * QtyToApply;
            DiscountAmt := SaleLinePOS."Amount Including VAT" * (DiscountPct / 100);
            if (NpDcCouponListItem."Max. Discount Amount" > 0) and (DiscountAmt > NpDcCouponListItem."Max. Discount Amount") then
              DiscountAmt := NpDcCouponListItem."Max. Discount Amount";

            if DiscountAmt > 0 then begin
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
              SaleLinePOSCouponApply."Discount Amount" := DiscountAmt;
              SaleLinePOSCouponApply.Insert(true);

              AppliedListItemDiscAmt += DiscountAmt;
              RemainingDiscountAmt -= DiscountAmt;
              AppliedQty += QtyToApply;
              RemainingQty -= QtyToApply;
            end;
          end;
        until (SaleLinePOS.Next = 0) or (RemainingDiscountAmt <= 0) or (RemainingQty = 0);
        //+NPR5.45 [312991]
        //+NPR5.41 [313062]
    end;

    local procedure ApplyDiscountSaleLinePOS(SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon";DiscountAmt: Decimal;TotalAmt: Decimal;NpDcCouponListItem: Record "NpDc Coupon List Item";SaleLinePOS: Record "Sale Line POS";var AppliedListItemDiscAmt: Decimal;var RemainingDiscountAmt: Decimal;var AppliedQty: Decimal;var RemainingQty: Decimal)
    var
        SaleLinePOSCouponApply: Record "NpDc Sale Line POS Coupon";
        SalePOS: Record "Sale POS";
        LineNo: Integer;
        PotentialDiscAmt: Decimal;
        LineDiscountAmt: Decimal;
        LineDiscountPct: Decimal;
        MaxQty: Decimal;
        QtyToApply: Integer;
    begin
        //-NPR5.45 [312991]
        // IF HasAppliedCouponDiscount(SaleLinePOSCoupon,SaleLinePOS) THEN
        //  EXIT;
        if HasAppliedCouponDiscount(SaleLinePOS) then
          exit;

        QtyToApply := SaleLinePOS.Quantity;
        if (NpDcCouponListItem."Max. Quantity" > 0) and (AppliedQty + QtyToApply > NpDcCouponListItem."Max. Quantity") then
          QtyToApply := NpDcCouponListItem."Max. Quantity" - AppliedQty;
        if (QtyToApply > RemainingQty) and (RemainingQty >= 0) then
          QtyToApply := RemainingQty;
        //+NPR5.45 [312991]

        LineDiscountAmt := SaleLinePOS."Amount Including VAT" - CalcAppliedDiscount(SaleLinePOS);
        if LineDiscountAmt > RemainingDiscountAmt then
          LineDiscountAmt := RemainingDiscountAmt;
        if (NpDcCouponListItem."Max. Discount Amount" > 0) and (LineDiscountAmt + AppliedListItemDiscAmt > NpDcCouponListItem."Max. Discount Amount") then
          LineDiscountAmt := NpDcCouponListItem."Max. Discount Amount" - AppliedListItemDiscAmt;
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

        AppliedListItemDiscAmt += LineDiscountAmt;
        RemainingDiscountAmt -= LineDiscountAmt;
        //-NPR5.45 [312991]
        RemainingQty -= QtyToApply;
        //+NPR5.45 [312991]
    end;

    local procedure "--- Calc"()
    begin
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

    local procedure CalcTotalAmt(SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon") TotalAmt: Decimal
    var
        NpDcCouponListItem: Record "NpDc Coupon List Item";
        SaleLinePOS: Record "Sale Line POS";
        LineAmt: Decimal;
    begin
        if not FindCouponListItems(SaleLinePOSCoupon,NpDcCouponListItem) then
          exit(0);

        TotalAmt := 0;
        NpDcCouponListItem.FindSet;
        repeat
          if FindSaleLinePOSItems(SaleLinePOSCoupon,NpDcCouponListItem,SaleLinePOS) then begin
            SaleLinePOS.CalcSums("Amount Including VAT");
            LineAmt := SaleLinePOS."Amount Including VAT";
            if LineAmt < 0 then
              LineAmt := 0;

            TotalAmt += LineAmt;
          end;
        until NpDcCouponListItem.Next = 0;

        TotalAmt -= CalcAppliedDiscountTotal(SaleLinePOSCoupon);
        exit(TotalAmt);
    end;

    local procedure "--- Find"()
    begin
    end;

    local procedure FindCouponListItems(SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon";var NpDcCouponListItem: Record "NpDc Coupon List Item"): Boolean
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        Clear(NpDcCouponListItem);
        NpDcCouponListItem.SetRange("Coupon Type",SaleLinePOSCoupon."Coupon Type");
        NpDcCouponListItem.SetFilter("No.",'<>%1','');
        exit(NpDcCouponListItem.FindFirst);
    end;

    local procedure FindSaleLinePOSItems(SaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon";NpDcCouponListItem: Record "NpDc Coupon List Item";var SaleLinePOS: Record "Sale Line POS"): Boolean
    begin
        Clear(SaleLinePOS);
        SaleLinePOS.SetRange("Register No.",SaleLinePOSCoupon."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.",SaleLinePOSCoupon."Sales Ticket No.");
        SaleLinePOS.SetRange(Date,SaleLinePOSCoupon."Sale Date");
        SaleLinePOS.SetRange("Sale Type",SaleLinePOSCoupon."Sale Type");
        SaleLinePOS.SetRange(Type,SaleLinePOS.Type::Item);
        case NpDcCouponListItem.Type of
          NpDcCouponListItem.Type::Item:
            begin
              SaleLinePOS.SetRange("No.",NpDcCouponListItem."No.");
            end;
          NpDcCouponListItem.Type::"Item Group":
            begin
              SaleLinePOS.SetFilter("No.",'<>%1','');
              SaleLinePOS.SetRange("Item Group",NpDcCouponListItem."No.");
            end;
          //-NPR5.38 [301053]
          //NpDcCouponListItem.Type::Item:
          NpDcCouponListItem.Type::"Item Disc. Group":
          //+NPR5.38 [301053]
            begin
              SaleLinePOS.SetFilter("No.",'<>%1','');
              SaleLinePOS.SetRange("Item Disc. Group",NpDcCouponListItem."No.");
            end;
        end;
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

    local procedure HasAppliedCouponDiscount(SaleLinePOS: Record "Sale Line POS"): Boolean
    var
        SaleLinePOSCouponApply: Record "NpDc Sale Line POS Coupon";
    begin
        SaleLinePOSCouponApply.SetRange("Register No.",SaleLinePOS."Register No.");
        SaleLinePOSCouponApply.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        SaleLinePOSCouponApply.SetRange("Sale Type",SaleLinePOS."Sale Type");
        SaleLinePOSCouponApply.SetRange("Sale Date",SaleLinePOS.Date);
        SaleLinePOSCouponApply.SetRange("Sale Line No.",SaleLinePOS."Line No.");
        SaleLinePOSCouponApply.SetRange(Type,SaleLinePOSCouponApply.Type::Discount);
        //-NPR5.45 [312991]
        // SaleLinePOSCouponApply.SETRANGE("Applies-to Sale Line No.",SaleLinePOSCoupon."Sale Line No.");
        // SaleLinePOSCouponApply.SETRANGE("Applies-to Coupon Line No.",SaleLinePOSCoupon."Line No.");
        // SaleLinePOSCouponApply.SETRANGE("Coupon Type",SaleLinePOSCoupon."Coupon Type");
        // SaleLinePOSCouponApply.SETRANGE("Coupon No.",SaleLinePOSCoupon."Coupon No.");
        //+NPR5.45 [312991]
        exit(SaleLinePOSCouponApply.FindFirst);
    end;

    local procedure "--- Coupon Interface"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6151590, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeleteCouponType(var Rec: Record "NpDc Coupon Type";RunTrigger: Boolean)
    var
        NpDcCouponListItem: Record "NpDc Coupon List Item";
    begin
        if Rec.IsTemporary then
          exit;

        NpDcCouponListItem.SetRange("Coupon Type",Rec.Code);
        if NpDcCouponListItem.IsEmpty then
          exit;
        NpDcCouponListItem.DeleteAll;
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

        HasApplySetup := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnSetupApplyDiscount', '', true, true)]
    local procedure OnSetupApplyDiscount(var CouponType: Record "NpDc Coupon Type")
    var
        NpDcCouponListItem: Record "NpDc Coupon List Item";
    begin
        if not IsSubscriber(CouponType) then
          exit;

        NpDcCouponListItem.FilterGroup(2);
        NpDcCouponListItem.SetRange("Coupon Type",CouponType.Code);
        NpDcCouponListItem.FilterGroup(0);
        PAGE.Run(PAGE::"NpDc Coupon List Items",NpDcCouponListItem);
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
        exit(CODEUNIT::"NpDc Module Apply - Item List");
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
        exit('ITEM_LIST');
    end;
}

