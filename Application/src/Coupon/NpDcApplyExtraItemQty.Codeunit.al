codeunit 6151601 "NPR NpDc Apply: Extra ItemQty."
{
    Access = Internal;
    var
        Text000: Label 'Extra Coupon Item has not been defined for Coupon %1 (%2)';
        Text001: Label 'Extra Item per Validation Qty.';

    local procedure ApplyDiscount(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon")
    var
        CouponType: Record "NPR NpDc Coupon Type";
        ExtraCouponItem: Record "NPR NpDc Extra Coupon Item";
        SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLineOut: Codeunit "NPR POS Sale Line";
        FrontEndMgt: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        POSSetup: Codeunit "NPR POS Setup";
        LineNo: Integer;
        DiscountAmt: Decimal;
        ExtraItemQty: Decimal;
    begin
        if POSSession.IsActiveSession(FrontEndMgt) then begin
            FrontEndMgt.GetSession(POSSession);
            POSSession.GetSaleLine(SaleLineOut);
        end else begin
            SalePOS.Get(SaleLinePOSCoupon."Register No.", SaleLinePOSCoupon."Sales Ticket No.");
            POSSession.GetSale(POSSale);
            POSSale.SetPosition(SalePOS.GetPosition(false));
            POSSession.GetSaleLine(SaleLineOut);
            SaleLineOut.Init(SalePOS."Register No.", SalePOS."Sales Ticket No.", POSSale, POSSetup, FrontEndMgt);
        end;

        CouponType.Get(SaleLinePOSCoupon."Coupon Type");
        if not FindExtraCouponItem(CouponType, ExtraCouponItem) then
            Error(Text000, SaleLinePOSCoupon."Coupon No.", SaleLinePOSCoupon."Coupon Type");

        ExtraItemQty := CalcExtraItemQty(SaleLinePOSCoupon);
        if FindSaleLinePOSCouponApply(SaleLinePOSCoupon, SaleLinePOSCouponApply, SaleLinePOS) then begin
            if ExtraItemQty <= 0 then begin
                SaleLinePOSCouponApply.Delete();
                SaleLineOut.OnBeforeDeletePOSSaleLine(SaleLinePOS);
                SaleLinePOS.Delete();
                SaleLineOut.OnAfterDeletePOSSaleLine(SaleLinePOS);
                exit;
            end;

            DiscountAmt := CalcDiscountAmount(SaleLinePOS, SaleLinePOSCoupon, ExtraItemQty);
            if DiscountAmt > SaleLinePOS."Unit Price" * ExtraItemQty then
                DiscountAmt := SaleLinePOS."Unit Price" * ExtraItemQty;

            if SaleLinePOSCouponApply."Discount Amount" <> DiscountAmt then begin
                SaleLinePOSCouponApply."Discount Amount" := DiscountAmt;
                SaleLinePOSCouponApply.Modify();
            end;
            if SaleLinePOS.Quantity <> ExtraItemQty then begin
                SaleLineOut.OnBeforeSetQuantity(SaleLinePOS, ExtraItemQty);
                SaleLinePOS.Validate(Quantity, ExtraItemQty);
                SaleLineOut.OnAfterSetQuantity(SaleLinePOS);

                SaleLinePOS.UpdateAmounts(SaleLinePOS);
                SaleLinePOS.Modify();
            end;

            exit;
        end;

        if ExtraItemQty <= 0 then
            exit;

        LineNo := GetNextLineNo(SaleLinePOSCoupon);
        SaleLinePOS.SetSkipCalcDiscount(true);
        SaleLinePOS.Init();
        SaleLinePOS."Register No." := SaleLinePOSCoupon."Register No.";
        SaleLinePOS."Sales Ticket No." := SaleLinePOSCoupon."Sales Ticket No.";
        SaleLinePOS.Date := SaleLinePOSCoupon."Sale Date";
        SaleLinePOS."Sale Type" := SaleLinePOSCoupon."Sale Type";
        SaleLinePOS."Line No." := LineNo;
        SaleLinePOS.Type := SaleLinePOS.Type::Item;
        SaleLinePOS.Validate("No.", ExtraCouponItem."Item No.");
        SaleLinePOS.Validate(Quantity, ExtraItemQty);

        SaleLineOut.InvokeOnBeforeInsertSaleLineWorkflow(SaleLinePOS);
        SaleLinePOS.Insert(true);
        SaleLineOut.InvokeOnAfterInsertSaleLineWorkflow(SaleLinePOS);

        DiscountAmt := CalcDiscountAmount(SaleLinePOS, SaleLinePOSCoupon, ExtraItemQty);
        if DiscountAmt > SaleLinePOS."Amount Including VAT" then
            DiscountAmt := SaleLinePOS."Amount Including VAT";

        SaleLinePOSCouponApply.Init();
        SaleLinePOSCouponApply."Register No." := SaleLinePOS."Register No.";
        SaleLinePOSCouponApply."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        SaleLinePOSCouponApply."Sale Type" := SaleLinePOS."Sale Type";
        SaleLinePOSCouponApply."Sale Date" := SaleLinePOS.Date;
        SaleLinePOSCouponApply."Sale Line No." := SaleLinePOS."Line No.";
        SaleLinePOSCouponApply."Line No." := 10000;
        SaleLinePOSCouponApply.Type := SaleLinePOSCouponApply.Type::Discount;
        SaleLinePOSCouponApply."Applies-to Sale Line No." := SaleLinePOSCoupon."Sale Line No.";
        SaleLinePOSCouponApply."Applies-to Coupon Line No." := SaleLinePOSCoupon."Line No.";
        SaleLinePOSCouponApply."Coupon Type" := SaleLinePOSCoupon."Coupon Type";
        SaleLinePOSCouponApply."Coupon No." := SaleLinePOSCoupon."Coupon No.";
        SaleLinePOSCouponApply."Discount Amount" := DiscountAmt;
        SaleLinePOSCouponApply.Insert();
    end;

    procedure CalcDiscountAmount(SaleLinePOS: Record "NPR POS Sale Line"; SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; ExtraItemQty: Decimal) DiscountAmount: Decimal
    var
        Coupon: Record "NPR NpDc Coupon";
        CouponType: Record "NPR NpDc Coupon Type";
        ExtraCouponItem: Record "NPR NpDc Extra Coupon Item";
    begin
        if not Coupon.Get(SaleLinePOSCoupon."Coupon No.") then
            exit(0);
        case Coupon."Discount Type" of
            Coupon."Discount Type"::"Discount %":
                begin
                    if not CouponType.Get(SaleLinePOSCoupon."Coupon Type") then
                        exit(0);
                    if not FindExtraCouponItem(CouponType, ExtraCouponItem) then
                        exit(0);
                    DiscountAmount := SaleLinePOS."Unit Price" * (Coupon."Discount %" / 100) * ExtraItemQty;
                    exit(DiscountAmount);
                end;
            Coupon."Discount Type"::"Discount Amount":
                begin
                    exit(Coupon."Discount Amount" * ExtraItemQty);
                end;
        end;

        exit(0);
    end;

    local procedure CalcExtraItemQty(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon") ExtraItemQty: Decimal
    var
        NpDcCouponListItem: Record "NPR NpDc Coupon List Item";
        ExtraItemPerQty: Decimal;
        SalesQty: Decimal;
        MaxExtraItemQty: Decimal;
    begin
        if not NpDcCouponListItem.Get(SaleLinePOSCoupon."Coupon Type", -1) then
            exit(0);

        MaxExtraItemQty := NpDcCouponListItem."Max. Quantity";
        if NpDcCouponListItem."Lot Validation" then
            ExtraItemQty := CalcExtraItemQtyLot(SaleLinePOSCoupon)
        else begin
            ExtraItemPerQty := NpDcCouponListItem."Validation Quantity";
            if not FindCouponListItems(SaleLinePOSCoupon, NpDcCouponListItem) then
                exit(0);

            repeat
                SalesQty += CalcPOSSalesQty(SaleLinePOSCoupon, NpDcCouponListItem);
            until NpDcCouponListItem.Next() = 0;

            ExtraItemQty := SalesQty div ExtraItemPerQty;
        end;

        if (MaxExtraItemQty > 0) and (ExtraItemQty > MaxExtraItemQty) then
            ExtraItemQty := MaxExtraItemQty;
        exit(ExtraItemQty);
    end;

    local procedure CalcExtraItemQtyLot(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon") MaxLotQty: Decimal
    var
        NpDcCouponListItem: Record "NPR NpDc Coupon List Item";
        LotQty: Decimal;
    begin
        if not FindCouponListItems(SaleLinePOSCoupon, NpDcCouponListItem) then
            exit(0);

        NpDcCouponListItem.SetFilter("Validation Quantity", '>%1', 0);
        if not NpDcCouponListItem.FindSet() then
            exit;

        MaxLotQty := -1;
        repeat
            LotQty := CalcPOSSalesQtyLot(SaleLinePOSCoupon, NpDcCouponListItem);
            if (LotQty < MaxLotQty) or (MaxLotQty = -1) then
                MaxLotQty := LotQty;
        until NpDcCouponListItem.Next() = 0;

        exit(MaxLotQty);
    end;

    local procedure CalcPOSSalesQty(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; NpDcCouponListItem: Record "NPR NpDc Coupon List Item"): Decimal
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.SetRange("Register No.", SaleLinePOSCoupon."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SaleLinePOSCoupon."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SaleLinePOSCoupon."Sale Date");
        SaleLinePOS.SetRange("Sale Type", SaleLinePOSCoupon."Sale Type");
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
        case NpDcCouponListItem.Type of
            NpDcCouponListItem.Type::Item:
                SaleLinePOS.SetRange("No.", NpDcCouponListItem."No.");
            NpDcCouponListItem.Type::"Item Disc. Group":
                SaleLinePOS.SetRange("Item Disc. Group", NpDcCouponListItem."No.");
            NpDcCouponListItem.Type::"Item Categories":
                SaleLinePOS.SetRange("Item Category Code", NpDcCouponListItem."No.");
        end;
        SaleLinePOS.CalcSums(Quantity);
        exit(SaleLinePOS.Quantity);
    end;

    local procedure CalcPOSSalesQtyLot(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; NpDcCouponListItem: Record "NPR NpDc Coupon List Item"): Decimal
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        if NpDcCouponListItem."Validation Quantity" <= 0 then
            exit(0);

        SaleLinePOS.SetRange("Register No.", SaleLinePOSCoupon."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SaleLinePOSCoupon."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SaleLinePOSCoupon."Sale Date");
        SaleLinePOS.SetRange("Sale Type", SaleLinePOSCoupon."Sale Type");
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
        case NpDcCouponListItem.Type of
            NpDcCouponListItem.Type::Item:
                SaleLinePOS.SetRange("No.", NpDcCouponListItem."No.");
            NpDcCouponListItem.Type::"Item Disc. Group":
                SaleLinePOS.SetRange("Item Disc. Group", NpDcCouponListItem."No.");
            NpDcCouponListItem.Type::"Item Categories":
                SaleLinePOS.SetRange("Item Category Code", NpDcCouponListItem."No.");
        end;
        SaleLinePOS.CalcSums(Quantity);
        exit(SaleLinePOS.Quantity div NpDcCouponListItem."Validation Quantity");
    end;

    local procedure FindCouponListItems(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; var NpDcCouponListItem: Record "NPR NpDc Coupon List Item"): Boolean
    begin
        Clear(NpDcCouponListItem);
        NpDcCouponListItem.SetRange("Coupon Type", SaleLinePOSCoupon."Coupon Type");
        NpDcCouponListItem.SetFilter("No.", '<>%1', '');
        exit(NpDcCouponListItem.FindFirst());
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpDc Coupon Type", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeleteCouponType(var Rec: Record "NPR NpDc Coupon Type"; RunTrigger: Boolean)
    var
        ExtraCouponItem: Record "NPR NpDc Extra Coupon Item";
    begin
        if Rec.IsTemporary then
            exit;

        ExtraCouponItem.SetRange("Coupon Type", Rec.Code);
        if ExtraCouponItem.IsEmpty then
            exit;
        ExtraCouponItem.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", 'OnInitCouponModules', '', true, true)]
    local procedure OnInitCouponModules(var CouponModule: Record "NPR NpDc Coupon Module")
    begin
        if CouponModule.Get(CouponModule.Type::"Apply Discount", ModuleCode()) then
            exit;

        CouponModule.Init();
        CouponModule.Type := CouponModule.Type::"Apply Discount";
        CouponModule.Code := ModuleCode();
        CouponModule.Description := Text001;
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
        ExtraCouponItem: Record "NPR NpDc Extra Coupon Item";
        PrevCouponType: Text;
    begin
        if not IsSubscriber(CouponType) then
            exit;

        ExtraCouponItem.FilterGroup(2);
        ExtraCouponItem.SetRange("Coupon Type", CouponType.Code);
        ExtraCouponItem.FilterGroup(0);
        if not FindExtraCouponItem(CouponType, ExtraCouponItem) then begin
            ExtraCouponItem.Init();
            ExtraCouponItem."Coupon Type" := CouponType.Code;
            ExtraCouponItem."Line No." := 10000;
            ExtraCouponItem.Insert(true);
        end;

        Commit();
        PAGE.RunModal(PAGE::"NPR NpDc Extra Item Qty.", ExtraCouponItem);
        Commit();
        if not ExtraCouponItem.Find() then
            exit;

        PrevCouponType := Format(CouponType);
        CouponType."Discount Type" := ExtraCouponItem."Discount Type";
        CouponType."Discount %" := ExtraCouponItem."Discount %";
        CouponType."Max. Discount Amount" := ExtraCouponItem."Max. Discount Amount";
        CouponType."Discount Amount" := ExtraCouponItem."Discount Amount";
        if PrevCouponType <> Format(CouponType) then
            CouponType.Modify(true);
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
        exit(CODEUNIT::"NPR NpDc ModuleApply: Xtr Item");
    end;

    local procedure FindExtraCouponItem(CouponType: Record "NPR NpDc Coupon Type"; var ExtraCouponItem: Record "NPR NpDc Extra Coupon Item"): Boolean
    begin
        exit(ExtraCouponItem.Get(CouponType.Code, 10000));
    end;

    local procedure FindSaleLinePOSCouponApply(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; var SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon"; var SaleLinePOS: Record "NPR POS Sale Line"): Boolean
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
        if not SaleLinePOSCouponApply.FindFirst() then
            exit(false);

        exit(SaleLinePOS.Get(
          SaleLinePOSCouponApply."Register No.", SaleLinePOSCouponApply."Sales Ticket No.", SaleLinePOSCouponApply."Sale Date",
          SaleLinePOSCouponApply."Sale Type", SaleLinePOSCouponApply."Sale Line No."));
    end;

    local procedure GetNextLineNo(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"): Integer
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.SetRange("Register No.", SaleLinePOSCoupon."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SaleLinePOSCoupon."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SaleLinePOSCoupon."Sale Date");
        SaleLinePOS.SetRange("Sale Type", SaleLinePOSCoupon."Sale Type");
        if SaleLinePOS.FindLast() then;
        exit(SaleLinePOS."Line No." + 10000);
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
        exit('EXTRA_ITEM_QTY');
    end;
}

