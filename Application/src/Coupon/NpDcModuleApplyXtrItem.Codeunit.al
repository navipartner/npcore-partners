codeunit 6151595 "NPR NpDc ModuleApply: Xtr Item"
{
    // NPR5.34/MHA /20170720  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon
    // NPR5.42/MHA /20180409  CASE 310148 Changed ResendAllOnAfterInsertPOSSaleLine() to single OnAfterInsertPOSSaleLine() in ApplyDiscount()
    // NPR5.43/MHA /20180629  CASE 319425 Updated Insert Line Event to use new InvokeOnBeforeInsertSaleLineWorkflow() in ApplyDiscount()
    // NPR5.47/MHA /20181022  CASE 332655 Discount should be calculated based on SaleLinePOS."Unit Price" instead of Item."Unit Price"
    // NPR5.50/TSA /20190507 CASE 345348 Added the OnAfterInsertPOSSaleLine() again, moved InvokeOnBeforeInsertSaleLineWorkflow() to before insert
    // NPR5.51/MHA /20190724  CASE 343352 Added initiation of POSSession without GUI in ApplyDiscount()
    // NPR5.51/MHA /20190725  CASE 355406 Applied Discount Amount cannot be more than 100%


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Extra Coupon Item has not been defined for Coupon %1 (%2)';
        Text001: Label 'Apply Discount - Extra Item';

    local procedure ApplyDiscount(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon")
    var
        CouponType: Record "NPR NpDc Coupon Type";
        ExtraCouponItem: Record "NPR NpDc Extra Coupon Item";
        SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon";
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        POSSale: Codeunit "NPR POS Sale";
        SaleLineOut: Codeunit "NPR POS Sale Line";
        POSSetup: Codeunit "NPR POS Setup";
        FrontEndMgt: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        LineNo: Integer;
        DiscountAmt: Decimal;
    begin
        CouponType.Get(SaleLinePOSCoupon."Coupon Type");
        if not FindExtraCouponItem(CouponType, ExtraCouponItem) then
            Error(Text000, SaleLinePOSCoupon."Coupon No.", SaleLinePOSCoupon."Coupon Type");

        //-NPR5.47 [332655]
        // DiscountAmt := CalcDiscountAmount(SaleLinePOSCoupon);
        //
        // IF FindSaleLinePOSCouponApply(SaleLinePOSCoupon,SaleLinePOSCouponApply) THEN BEGIN
        //  IF SaleLinePOSCouponApply."Discount Amount" <> DiscountAmt THEN BEGIN
        //    SaleLinePOSCouponApply."Discount Amount" := DiscountAmt;
        //    SaleLinePOSCouponApply.MODIFY;
        //  END;
        //
        //  EXIT;
        // END;
        if FindSaleLinePOSCouponApply(SaleLinePOSCoupon, SaleLinePOSCouponApply, SaleLinePOS) then begin
            DiscountAmt := CalcDiscountAmount(SaleLinePOS, SaleLinePOSCoupon);
            //-NPR5.51 [355406]
            if DiscountAmt > SaleLinePOS."Amount Including VAT" then
                DiscountAmt := SaleLinePOS."Amount Including VAT";
            //+NPR5.51 [355406]

            if SaleLinePOSCouponApply."Discount Amount" <> DiscountAmt then begin
                SaleLinePOSCouponApply."Discount Amount" := DiscountAmt;
                SaleLinePOSCouponApply.Modify;
            end;

            exit;
        end;
        //+NPR5.47 [332655]

        //-NPR5.51 [343352]
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
        //+NPR5.51 [343352]

        LineNo := GetNextLineNo(SaleLinePOSCoupon);
        SaleLinePOS.SetSkipCalcDiscount(true);
        SaleLinePOS.Init;
        SaleLinePOS."Register No." := SaleLinePOSCoupon."Register No.";
        SaleLinePOS."Sales Ticket No." := SaleLinePOSCoupon."Sales Ticket No.";
        SaleLinePOS.Date := SaleLinePOSCoupon."Sale Date";
        SaleLinePOS."Sale Type" := SaleLinePOSCoupon."Sale Type";
        SaleLinePOS."Line No." := LineNo;
        SaleLinePOS.Type := SaleLinePOS.Type::Item;
        SaleLinePOS.Validate("No.", ExtraCouponItem."Item No.");
        SaleLinePOS.Validate(Quantity, 1);

        //-NPR5.50 [345348]
        // SaleLinePOS.INSERT(TRUE);
        SaleLineOut.InvokeOnBeforeInsertSaleLineWorkflow(SaleLinePOS);
        SaleLinePOS.Insert(true);
        SaleLineOut.InvokeOnAfterInsertSaleLineWorkflow(SaleLinePOS);
        //+NPR5.50 [345348]

        //-NPR5.47 [332655]
        DiscountAmt := CalcDiscountAmount(SaleLinePOS, SaleLinePOSCoupon);
        //+NPR5.47 [332655]

        //-NPR5.51 [355406]
        if DiscountAmt > SaleLinePOS."Amount Including VAT" then
            DiscountAmt := SaleLinePOS."Amount Including VAT";
        //+NPR5.51 [355406]

        SaleLinePOSCouponApply.Init;
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
        SaleLinePOSCouponApply.Insert;

        //-NPR5.50 [345348]
        // POSSession.IsActiveSession(FrontEndMgt);
        // FrontEndMgt.GetSession(POSSession);
        // POSSession.GetSaleLine(SaleLineOut);
        // //-NPR5.43 [319425]
        // //-NPR5.42 [310148]
        // ////SaleLineOut.ResendAllOnAfterInsertPOSSaleLine();
        // //SaleLineOut.OnAfterInsertPOSSaleLine(SaleLinePOS);
        // ////+NPR5.42 [310148]
        // SaleLineOut.InvokeOnBeforeInsertSaleLineWorkflow(SaleLinePOS);
        // //+NPR5.43 [319425]
        //+NPR5.50 [345348]
    end;

    local procedure "--- Calc"()
    begin
    end;

    procedure CalcDiscountAmount(SaleLinePOS: Record "NPR Sale Line POS"; SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon") DiscountAmount: Decimal
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
                    //-NPR5.47 [332655]
                    // IF NOT Item.GET(ExtraCouponItem."Item No.") THEN
                    //   EXIT(0);
                    // DiscountAmount := Item."Unit Price" * (Coupon."Discount %" / 100);
                    DiscountAmount := SaleLinePOS."Unit Price" * (Coupon."Discount %" / 100);
                    //+NPR5.47 [332655]
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

    local procedure "--- Coupon Interface"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6151590, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeleteCouponType(var Rec: Record "NPR NpDc Coupon Type"; RunTrigger: Boolean)
    var
        ExtraCouponItem: Record "NPR NpDc Extra Coupon Item";
    begin
        if Rec.IsTemporary then
            exit;

        ExtraCouponItem.SetRange("Coupon Type", Rec.Code);
        if ExtraCouponItem.IsEmpty then
            exit;
        ExtraCouponItem.DeleteAll;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnInitCouponModules', '', true, true)]
    local procedure OnInitCouponModules(var CouponModule: Record "NPR NpDc Coupon Module")
    begin
        if CouponModule.Get(CouponModule.Type::"Apply Discount", ModuleCode()) then
            exit;

        CouponModule.Init;
        CouponModule.Type := CouponModule.Type::"Apply Discount";
        CouponModule.Code := ModuleCode();
        CouponModule.Description := Text001;
        CouponModule."Event Codeunit ID" := CurrCodeunitId();
        CouponModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnHasApplyDiscountSetup', '', true, true)]
    local procedure OnHasApplyDiscountSetup(CouponType: Record "NPR NpDc Coupon Type"; var HasApplySetup: Boolean)
    begin
        if not IsSubscriber(CouponType) then
            exit;

        HasApplySetup := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnSetupApplyDiscount', '', true, true)]
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
            ExtraCouponItem.Init;
            ExtraCouponItem."Coupon Type" := CouponType.Code;
            ExtraCouponItem."Line No." := 10000;
            ExtraCouponItem.Insert(true);
        end;

        Commit;
        PAGE.RunModal(PAGE::"NPR NpDc Extra Coupon Item", ExtraCouponItem);
        Commit;
        if not ExtraCouponItem.Find then
            exit;

        PrevCouponType := Format(CouponType);
        CouponType."Discount Type" := ExtraCouponItem."Discount Type";
        CouponType."Discount %" := ExtraCouponItem."Discount %";
        CouponType."Max. Discount Amount" := ExtraCouponItem."Max. Discount Amount";
        CouponType."Discount Amount" := ExtraCouponItem."Discount Amount";
        if PrevCouponType <> Format(CouponType) then
            CouponType.Modify(true);
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

    local procedure "--- Aux"()
    begin
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpDc ModuleApply: Xtr Item");
    end;

    local procedure FindExtraCouponItem(CouponType: Record "NPR NpDc Coupon Type"; var ExtraCouponItem: Record "NPR NpDc Extra Coupon Item"): Boolean
    begin
        exit(ExtraCouponItem.Get(CouponType.Code, 10000));
    end;

    local procedure FindSaleLinePOSCouponApply(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"; var SaleLinePOSCouponApply: Record "NPR NpDc SaleLinePOS Coupon"; var SaleLinePOS: Record "NPR Sale Line POS"): Boolean
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
        //-NPR5.47 [332655]
        // EXIT(SaleLinePOSCouponApply.FINDFIRST);
        if not SaleLinePOSCouponApply.FindFirst then
            exit(false);

        exit(SaleLinePOS.Get(
          SaleLinePOSCouponApply."Register No.", SaleLinePOSCouponApply."Sales Ticket No.", SaleLinePOSCouponApply."Sale Date",
          SaleLinePOSCouponApply."Sale Type", SaleLinePOSCouponApply."Sale Line No."));
        //+NPR5.47 [332655]
    end;

    local procedure GetNextLineNo(SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon"): Integer
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        SaleLinePOS.SetRange("Register No.", SaleLinePOSCoupon."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SaleLinePOSCoupon."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SaleLinePOSCoupon."Sale Date");
        SaleLinePOS.SetRange("Sale Type", SaleLinePOSCoupon."Sale Type");
        if SaleLinePOS.FindLast then;
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
        exit('EXTRA_ITEM');
    end;
}

