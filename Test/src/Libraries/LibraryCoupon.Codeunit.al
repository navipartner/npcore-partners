codeunit 85051 "NPR Library Coupon"
{
    Access = Internal;

    procedure ScanCouponReferenceCode(POSSession: Codeunit "NPR POS Session"; CouponReferenceNo: Text)
    var
        CouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
    begin
        CouponMgt.ScanCoupon(POSSession, CouponReferenceNo);
    end;

    procedure IssueCouponDefaultHandler(CouponType: Record "NPR NpDc Coupon Type"; Quantity: Integer; var TempCoupon: Record "NPR NpDc Coupon" temporary)
    var
        Coupon: Record "NPR NpDc Coupon";
        CouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
        i: Integer;
    begin
        for i := 1 to Quantity do begin
            Coupon.Init();
            Coupon.Validate("Coupon Type", CouponType.Code);
            Coupon."No." := '';
            Coupon.Insert(true);

            CouponMgt.PostIssueCoupon(Coupon);

            TempCoupon.Init();
            TempCoupon := Coupon;
            TempCoupon.Insert();
        end;
    end;

    procedure IssueCouponMultipleQuantity(CouponCode: Code[20]; CouponType: Record "NPR NpDc Coupon Type"; Quantity: Integer; var TempCoupon: Record "NPR NpDc Coupon" temporary)
    var
        Coupon: Record "NPR NpDc Coupon";
        CouponMgt: Codeunit "NPR NpDc Coupon Mgt.";

    begin
        Coupon.Init();
        Coupon.Validate("Coupon Type", CouponType.Code);
        Coupon."No." := CouponCode;
        Coupon.Insert(true);

        CouponMgt.PostIssueCoupon2(Coupon, Quantity, CouponType."Discount Amount");

        TempCoupon.Init();
        TempCoupon := Coupon;
        TempCoupon.Insert();

    end;

    procedure IssueCouponMultipleQuantity(CouponType: Record "NPR NpDc Coupon Type"; Quantity: Integer; var TempCoupon: Record "NPR NpDc Coupon" temporary)
    begin
        IssueCouponMultipleQuantity('', CouponType, Quantity, TempCoupon);
    end;

    procedure CreateDiscountPctCouponType(CouponTypeCode: Code[20]; DiscountPct: Decimal): Code[20]
    var
        NpDcCouponType: Record "NPR NpDc Coupon Type";
    begin
        exit(CreateDiscountPctCouponType(CouponTypeCode, NpDcCouponType, DiscountPct, '[S]'));
    end;

    procedure CreateDiscountPctCouponType(CouponTypeCode: Code[20]; var CouponType: Record "NPR NpDc Coupon Type"; DiscountPct: Decimal): Code[20]
    begin
        exit(CreateDiscountPctCouponType(CouponTypeCode, CouponType, DiscountPct, '[S]'));
    end;

    procedure CreateDiscountPctCouponType(CouponTypeCode: Code[20]; var CouponType: Record "NPR NpDc Coupon Type"; DiscountPct: Decimal; ReferenceNoPattern: Code[20]): Code[20]
    begin
        CreateCouponType(CouponTypeCode, CouponType);
        CouponType."Reference No. Pattern" := ReferenceNoPattern;
        CouponType."Discount Type" := CouponType."Discount Type"::"Discount %";
        CouponType."Discount %" := DiscountPct;
        CouponType.Enabled := true;
        CouponType.Modify(true);

        exit(CouponType.Code);
    end;

    procedure CreateDiscountAmountCouponType(CouponTypeCode: Code[20]; var CouponType: Record "NPR NpDc Coupon Type"; DiscountAmount: Decimal): Code[20]
    begin
        exit(CreateDiscountAmountCouponType(CouponTypeCode, CouponType, DiscountAmount, '[S]'));
    end;

    procedure CreateDiscountAmountCouponType(CouponTypeCode: Code[20]; var CouponType: Record "NPR NpDc Coupon Type"; DiscountAmount: Decimal; ReferenceNoPattern: Code[20]): Code[20]
    begin
        CreateCouponType(CouponTypeCode, CouponType);
        CouponType."Reference No. Pattern" := ReferenceNoPattern;
        CouponType."Discount Type" := CouponType."Discount Type"::"Discount Amount";
        CouponType."Discount Amount" := DiscountAmount;
        CouponType.Enabled := true;
        CouponType.Modify(true);

        exit(CouponType.Code);
    end;

    procedure SetExtraItemCoupon(var CouponType: Record "NPR NpDc Coupon Type"; ExtraItemNo: Code[20])
    var
        ExtraCouponItem: Record "NPR NpDc Extra Coupon Item";
        Item: Record "Item";
    begin
        CouponType."Apply Discount Module" := 'EXTRA_ITEM';
        CouponType.Modify();

        if (not ExtraCouponItem.Get(CouponType.Code, 10000)) then begin
            ExtraCouponItem.Init();
            ExtraCouponItem."Coupon Type" := CouponType.Code;
            ExtraCouponItem."Line No." := 10000;
            ExtraCouponItem.Insert();
        end;

        ExtraCouponItem."Discount Type" := CouponType."Discount Type";
        ExtraCouponItem."Discount Amount" := CouponType."Discount Amount";
        ExtraCouponItem."Discount %" := CouponType."Discount %";

        Item.Get(ExtraItemNo);
        ExtraCouponItem."Item No." := ExtraItemNo;
        ExtraCouponItem."Item Description" := Item.Description;
        ExtraCouponItem."Unit Price" := Item."Unit Price";
        ExtraCouponItem."Profit %" := Item."Profit %";
        ExtraCouponItem.Modify();
    end;

    procedure SetExtraQtyItemCoupon(var CouponType: Record "NPR NpDc Coupon Type";
                                    ExtraItem: Record Item;
                                    DiscountedItem: Record Item;
                                    ValidationQty: Decimal)
    var
        NPRNpDcExtraCouponItem: Record "NPR NpDc Extra Coupon Item";
        NPRNpDcCouponListItem: Record "NPR NpDc Coupon List Item";
        NPRNpDcApplyExtraItemQty: Codeunit "NPR NpDc Apply: Extra ItemQty.";
    begin
        CouponType."Apply Discount Module" := NPRNpDcApplyExtraItemQty.ModuleCode();
        CouponType.Modify();

        if (not NPRNpDcExtraCouponItem.Get(CouponType.Code, 10000)) then begin
            NPRNpDcExtraCouponItem.Init();
            NPRNpDcExtraCouponItem."Coupon Type" := CouponType.Code;
            NPRNpDcExtraCouponItem."Line No." := 10000;
            NPRNpDcExtraCouponItem.Insert();
        end;

        NPRNpDcExtraCouponItem."Discount Type" := CouponType."Discount Type";
        NPRNpDcExtraCouponItem."Discount Amount" := CouponType."Discount Amount";
        NPRNpDcExtraCouponItem."Discount %" := CouponType."Discount %";


        NPRNpDcExtraCouponItem."Item No." := DiscountedItem."No.";
        NPRNpDcExtraCouponItem."Item Description" := DiscountedItem.Description;
        NPRNpDcExtraCouponItem."Unit Price" := DiscountedItem."Unit Price";
        NPRNpDcExtraCouponItem."Profit %" := DiscountedItem."Profit %";
        NPRNpDcExtraCouponItem.Modify();

        NPRNpDcCouponListItem.Init();
        NPRNpDcCouponListItem."Coupon Type" := CouponType.Code;
        NPRNpDcCouponListItem."Line No." := 10000;
        NPRNpDcCouponListItem.Validate(Type, NPRNpDcCouponListItem.Type::Item);
        NPRNpDcCouponListItem.Validate("No.", ExtraItem."No.");
        NPRNpDcCouponListItem.Insert(true);

        NPRNpDcCouponListItem.Init();
        NPRNpDcCouponListItem."Coupon Type" := CouponType.Code;
        NPRNpDcCouponListItem.Validate(Type, NPRNpDcCouponListItem.Type::Item);
        NPRNpDcCouponListItem."Line No." := -1;
        NPRNpDcCouponListItem.Validate("Validation Quantity", ValidationQty);
        NPRNpDcCouponListItem.Insert(true);

    end;

    procedure SetItemListCoupon(var CouponType: Record "NPR NpDc Coupon Type";
                                DiscountedItem: Record Item;
                                ValidationQty: Decimal)
    var
        NPRNpDcCouponListItem: Record "NPR NpDc Coupon List Item";
        NPRNpDcModuleApplyItemList: Codeunit "NPR NpDc Module Apply ItemList";
    begin
        CouponType."Apply Discount Module" := NPRNpDcModuleApplyItemList.ModuleCode();
        CouponType.Modify();

        NPRNpDcCouponListItem.Init();
        NPRNpDcCouponListItem."Coupon Type" := CouponType.Code;
        NPRNpDcCouponListItem."Line No." := 10000;
        NPRNpDcCouponListItem.Validate(Type, NPRNpDcCouponListItem.Type::Item);
        NPRNpDcCouponListItem.Validate("No.", DiscountedItem."No.");
        NPRNpDcCouponListItem.Insert(true);

        NPRNpDcCouponListItem.Init();
        NPRNpDcCouponListItem."Coupon Type" := CouponType.Code;
        NPRNpDcCouponListItem.Validate(Type, NPRNpDcCouponListItem.Type::Item);
        NPRNpDcCouponListItem."Line No." := -1;
        NPRNpDcCouponListItem.Validate("Max. Quantity", ValidationQty);
        NPRNpDcCouponListItem.Insert(true);

    end;

    local procedure CreateCouponType(CouponTypeCode: Code[20]; var CouponType: Record "NPR NpDc Coupon Type"): Code[20]
    begin
        CreateCouponSetup();
        if (not CouponType.Get(CouponTypeCode)) then begin
            CouponType.Init();
            CouponType.Code := CouponTypeCode;
            CouponType."Issue Coupon Module" := 'DEFAULT';
            CouponType.Insert(true);
        end;
        exit(CouponType.Code);
    end;

    procedure CreateCouponSetup()
    var
        CouponSetup: Record "NPR NpDc Coupon Setup";
        LibNoSeries: Codeunit "NPR Library - No. Series";
    begin
        if (CouponSetup.Get()) then
            CouponSetup.Delete();

        CouponSetup.Init();
        CouponSetup."Coupon No. Series" := LibNoSeries.GenerateNoSeries();
        CouponSetup."Arch. Coupon No. Series" := LibNoSeries.GenerateNoSeries();
        CouponSetup."Reference No. Pattern" := '[S]'; // Same as no. series number
        CouponSetup.Insert();
    end;

    procedure SetItemListActivityCoupon(var CouponType: Record "NPR NpDc Coupon Type";
                                      DiscountedItem: Record Item;
                                      ValidationQty: Decimal)
    var
        NPRNpDcCouponListItem: Record "NPR NpDc Coupon List Item";
    begin
        SetApplyActivityDiscountModule(CouponType);

        NPRNpDcCouponListItem.Init();
        NPRNpDcCouponListItem."Coupon Type" := CouponType.Code;
        NPRNpDcCouponListItem."Line No." := 10000;
        NPRNpDcCouponListItem.Validate(Type, NPRNpDcCouponListItem.Type::Item);
        NPRNpDcCouponListItem.Validate("No.", DiscountedItem."No.");
        NPRNpDcCouponListItem.Insert(true);

        NPRNpDcCouponListItem.Init();
        NPRNpDcCouponListItem."Coupon Type" := CouponType.Code;
        NPRNpDcCouponListItem."Line No." := -1;
        NPRNpDcCouponListItem.Validate(Type, NPRNpDcCouponListItem.Type::Item);
        NPRNpDcCouponListItem.Validate("Max. Quantity", ValidationQty);
        NPRNpDcCouponListItem.Insert(true);

    end;

    procedure SetItemListActivityCouponTwice(var CouponType: Record "NPR NpDc Coupon Type";
                                  DiscountedItem1: Record Item;
                                  DiscountedItem2: Record Item)
    var
        NPRNpDcCouponListItem: Record "NPR NpDc Coupon List Item";
    begin
        SetApplyActivityDiscountModule(CouponType);

        NPRNpDcCouponListItem.Init();
        NPRNpDcCouponListItem."Coupon Type" := CouponType.Code;
        NPRNpDcCouponListItem."Line No." := 10000;
        NPRNpDcCouponListItem.Validate(Type, NPRNpDcCouponListItem.Type::Item);
        NPRNpDcCouponListItem.Validate("No.", DiscountedItem1."No.");
        NPRNpDcCouponListItem.Insert(true);

        NPRNpDcCouponListItem.Init();
        NPRNpDcCouponListItem."Coupon Type" := CouponType.Code;
        NPRNpDcCouponListItem."Line No." := 20000;
        NPRNpDcCouponListItem.Validate(Type, NPRNpDcCouponListItem.Type::Item);
        NPRNpDcCouponListItem.Validate("No.", DiscountedItem2."No.");
        NPRNpDcCouponListItem.Insert(true);

        NPRNpDcCouponListItem.Init();
        NPRNpDcCouponListItem."Coupon Type" := CouponType.Code;
        NPRNpDcCouponListItem."Line No." := -1;
        NPRNpDcCouponListItem.Insert(true);
    end;

    internal procedure SetApplyActivityDiscountModule(var CouponType: Record "NPR NpDc Coupon Type")
    var
        NPRNpDcModuleApplyActivity: Codeunit "NPR Np Dc Module ApplyActivity";
    begin
        CouponType."Validate Coupon Module" := 'DEFAULT';
        CouponType."Apply Discount Module" := NPRNpDcModuleApplyActivity.ModuleCode();
        CouponType."Max Use per Sale" := 1000000;
        CouponType."Multi-Use Qty." := 1000000;
        CouponType."Multi-Use Coupon" := true;
        CouponType.Modify();
    end;

    internal procedure CreateItemTrackingAndAssignToItem(var Item: Record Item; var ItemTrackingCode: Record "Item Tracking Code")
    begin
        if ItemTrackingCode.Get('ACTIVITY') then
            ItemTrackingCode.Delete();
        ItemTrackingCode.Init();
        ItemTrackingCode.Code := 'ACTIVITY';
        ItemTrackingCode."SN Sales Inbound Tracking" := true;
        ItemTrackingCode."SN Sales Outbound Tracking" := true;
        ItemTrackingCode.Insert();
        Item."Item Tracking Code" := ItemTrackingCode.Code;
        Item.Modify();
    end;

    internal procedure CreateTwoItemTrackingAndAssignToItem(var Item: Record Item; var Item1: Record Item; var ItemTrackingCode: Record "Item Tracking Code")
    begin
        if ItemTrackingCode.Get('ACTIVITY') then
            ItemTrackingCode.Delete();
        ItemTrackingCode.Init();
        ItemTrackingCode.Code := 'ACTIVITY';
        ItemTrackingCode."SN Sales Inbound Tracking" := true;
        ItemTrackingCode."SN Sales Outbound Tracking" := true;
        ItemTrackingCode.Insert();
        Item."Item Tracking Code" := ItemTrackingCode.Code;
        Item.Modify();
        Item1."Item Tracking Code" := ItemTrackingCode.Code;
        Item1.Modify();
    end;
}