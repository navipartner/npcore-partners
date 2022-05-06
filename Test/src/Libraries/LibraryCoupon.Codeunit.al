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


    procedure CreateDiscountPctCouponType(CouponTypeCode: Code[20]; DiscountPct: Decimal): Code[20]
    var
        NpDcCouponType: Record "NPR NpDc Coupon Type";
    begin
        exit(CreateDiscountPctCouponType(CouponTypeCode, NpDcCouponType, DiscountPct));
    end;

    procedure CreateDiscountPctCouponType(CouponTypeCode: Code[20]; var CouponType: Record "NPR NpDc Coupon Type"; DiscountPct: Decimal): Code[20]
    begin
        CreateCouponType(CouponTypeCode, CouponType);
        CouponType."Reference No. Pattern" := '[S]';
        CouponType."Discount Type" := CouponType."Discount Type"::"Discount %";
        CouponType."Discount %" := DiscountPct;
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

    local procedure CreateCouponType(CouponTypeCode: Code[20]; var CouponType: Record "NPR NpDc Coupon Type"): Code[20]
    var
        LibNoSeries: Codeunit "NPR Library - No. Series";
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


}