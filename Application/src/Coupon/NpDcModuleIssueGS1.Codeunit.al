codeunit 6060028 "NPR NpDc Module Issue GS1"
{
    Access = Internal;

    var
        ModuleLbl: Label 'GS1 Issue Module';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", 'OnInitCouponModules', '', true, true)]
    local procedure OnInitCouponModules(var CouponModule: Record "NPR NpDc Coupon Module")
    begin
        if CouponModule.Get(CouponModule.Type::"Issue Coupon", ModuleCode()) then
            exit;

        CouponModule.Init();
        CouponModule.Type := CouponModule.Type::"Issue Coupon";
        CouponModule.Code := ModuleCode();
        CouponModule.Description := ModuleLbl;
        CouponModule."Event Codeunit ID" := CurrCodeunitId();
        CouponModule.Insert(true);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR NpDc Module Issue GS1");
    end;

    local procedure ModuleCode(): Code[20]
    begin
        exit('GS1');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", 'OnBeforeValidateCoupon', '', true, true)]
    local procedure NPRNpDcCouponModuleMgtOnBeforeValidateCoupon(var ReferenceNo: Text)
    var
        CouponType: Record "NPR NpDc Coupon Type";
        Coupon: Record "NPR NpDc Coupon";
        DiscountAmount: Decimal;
        DiscountType: Option "Discount Amount","Discount %";
    begin
        if not IsGS1Coupon(ReferenceNo, DiscountAmount, DiscountType) then
            exit;


        if not GetGS1CouponType(CouponType, DiscountType) then
            CreateGS1CouponType(CouponType, DiscountType);

        if FindCoupon(ReferenceNo, Coupon) then
            IssueCouponQty(Coupon)
        else
            IssueGS1Coupon(ReferenceNo, CouponType, DiscountAmount);
    end;

    local procedure GetGS1CouponType(var CouponType: Record "NPR NpDc Coupon Type"; DiscountType: Option): Boolean
    begin
        CouponType.SetRange("Issue Coupon Module", ModuleCode());
        CouponType.SetRange("Discount Type", DiscountType);
        exit(CouponType.FindFirst());
    end;

    procedure CreateGS1CouponType(var CouponType: Record "NPR NpDc Coupon Type"; DiscountType: Option)
    begin
        CouponType.Init();
        CouponType.Code := ModuleCode() + '-' + Format(DiscountType);
        CouponType."Issue Coupon Module" := ModuleCode();
        CouponType.Description := ModuleCode();
        CouponType."Issue Coupon Module" := ModuleCode();
        CouponType."Validate Coupon Module" := 'DEFAULT';
        CouponType."Apply Discount Module" := 'DEFAULT';
        CouponType."Discount Type" := DiscountType;
        CouponType."Starting Date" := CreateDateTime(Today(), 0T);
        CouponType.Enabled := true;
        CouponType.Insert();
    end;

    local procedure IssueGS1Coupon(ReferenceNo: Text; CouponType: Record "NPR NpDc Coupon Type"; DiscountAmount: Decimal)
    var
        Coupon: Record "NPR NpDc Coupon";
    begin
        Coupon.Init();
        Coupon."Reference No." := ReferenceNo;
        Coupon.Validate("Coupon Type", CouponType.Code);
        if CouponType."Discount Type" = CouponType."Discount Type"::"Discount %" then
            Coupon."Discount %" := DiscountAmount
        else
            Coupon."Discount Amount" := DiscountAmount;
        Coupon."No." := '';
        Coupon.Insert(true);

        IssueCouponQty(Coupon);
    end;

    local procedure IsGS1Coupon(ReferenceNo: Text; var DiscountAmount: Decimal; var DiscountType: Option): Boolean
    begin
        if StrLen(ReferenceNo) > 23 then
            exit(ParseComplex(ReferenceNo, DiscountAmount, DiscountType))
        else
            exit(ParseSimple(ReferenceNo, DiscountAmount, DiscountType));
    end;

    local procedure ParseSimple(Barcode: Text; var DiscountAmount: Decimal; var DiscountType: Option): Boolean
    var
        DiscountTxt, DiscountAmountTxt : Text;
    begin
        DiscountTxt := CopyStr(Barcode, 17, 4);
        DiscountAmountTxt := CopyStr(Barcode, 21, 3);
        ProcessNumbers(DiscountTxt, DiscountAmountTxt, DiscountAmount, DiscountType);
        exit(ProcessDiscountAmount(DiscountTxt));
    end;

    local procedure ParseComplex(Barcode: Text; var DiscountAmount: Decimal; var DiscountType: Option): Boolean
    var
        DiscountTxt, DiscountAmountTxt : Text;
    begin
        DiscountTxt := CopyStr(Barcode, 28, 4);
        DiscountAmountTxt := CopyStr(Barcode, 32, 3);
        if not ProcessNumbers(DiscountTxt, DiscountAmountTxt, DiscountAmount, DiscountType) then
            exit(false);
        exit(ProcessDiscountAmount(DiscountTxt));
    end;

    local procedure ProcessDiscountAmount(Discount: Text): Boolean
    var
        NotSupportedErr: Label 'GS1 discount % currently not supported';
    begin
        case CopyStr(Discount, 1, 3) of
            '390':
                exit(true);
            '394':
                Error(NotSupportedErr);
            else
                exit(false);
        end;
    end;

    local procedure ProcessNumbers(Discount: Text; DiscountAmount: Text; var DiscountNumeric: Decimal; var DiscountType: Option): Boolean
    var
        Number: Integer;
        Decimals: Integer;
    begin
        if not Evaluate(Decimals, CopyStr(Discount, 4, 1)) then
            exit(false);
        if not Evaluate(Number, DiscountAmount) then
            exit(false);

        if Number = 0 then begin
            DiscountNumeric := 100;
            DiscountType := 1;
        end else begin
            DiscountNumeric := Number / (Power(10, Decimals));
            DiscountType := 0;
        end;
        exit(true);
    end;

    local procedure FindCoupon(ReferenceNo: Text; var Coupon: Record "NPR NpDc Coupon"): Boolean
    begin
        Coupon.SetRange("Reference No.", ReferenceNo);
        exit(Coupon.FindFirst());
    end;

    local procedure IssueCouponQty(Coupon: Record "NPR NpDc Coupon")
    var
        CouponEntry: Record "NPR NpDc Coupon Entry";
    begin
        CouponEntry.Init();
        CouponEntry."Entry No." := 0;
        CouponEntry."Coupon No." := Coupon."No.";
        CouponEntry."Entry Type" := CouponEntry."Entry Type"::"Issue Coupon";
        CouponEntry."Coupon Type" := Coupon."Coupon Type";
        CouponEntry."Amount per Qty." := Coupon."Discount Amount";
        CouponEntry.Quantity := 1;
        CouponEntry."Remaining Quantity" := CouponEntry.Quantity;
        CouponEntry.Amount := CouponEntry."Amount per Qty." * CouponEntry.Quantity;
        CouponEntry.Positive := CouponEntry.Quantity > 0;
        CouponEntry."Posting Date" := WorkDate();
        CouponEntry.Open := true;
        CouponEntry."Register No." := '';
        CouponEntry."Document Type" := CouponEntry."Document Type"::" ";
        CouponEntry."Document No." := '';
        CouponEntry."User ID" := CopyStr(UserId, 1, MaxStrLen(CouponEntry."User ID"));
        CouponEntry."Closed by Entry No." := 0;
        CouponEntry.Insert();
    end;
}
