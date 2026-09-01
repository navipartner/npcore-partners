table 6014685 "NPR POS Store Group"
{
    Access = Internal;
    Caption = 'POS Store Group';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Store Groups";
    LookupPageID = "NPR POS Store Groups";


    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
            NotBlank = true;
        }
        field(10; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; SystemRowVersion)
        {
        }
    }

    var
        CannotRenameErr: Label 'You cannot rename a %1.';

    trigger OnDelete()
    begin
        UpdateCoupons();
        UpdateCouponType();
        UpdateLines();
        DeleteDiscStoreGroups();
    end;

    trigger OnRename()
    begin
        Error(CannotRenameErr, TableCaption);
    end;

    local procedure UpdateCouponType()
    var
        NpDcCouponType: Record "NPR NpDc Coupon Type";
        ToModifyNpDcCouponType: Record "NPR NpDc Coupon Type";
    begin
        NpDcCouponType.SetRange("POS Store Group", Rec."No.");
        if NpDcCouponType.IsEmpty() then
            exit;
        NpDcCouponType.FindSet();
        repeat
            ToModifyNpDcCouponType := NpDcCouponType;
            ToModifyNpDcCouponType."POS Store Group" := '';
            ToModifyNpDcCouponType.Modify();
        until NpDcCouponType.Next() = 0;
    end;

    local procedure UpdateCoupons()
    var
        NpDcCoupon: Record "NPR NpDc Coupon";
        ToModifyNpDcCoupon: Record "NPR NpDc Coupon";
        ConfirmManagement: Codeunit "Confirm Management";
        CouponExistQst: Label 'Store Group is used on issued coupons, if you continue it will be deleted from Coupons also. Do you want to delete this group?';
    begin
        NpDcCoupon.SetRange("POS Store Group", Rec."No.");
        if NpDcCoupon.IsEmpty() then
            exit;
        if not ConfirmManagement.GetResponseOrDefault(CouponExistQst, false) then
            Error('');
        NpDcCoupon.FindSet();
        repeat
            ToModifyNpDcCoupon := NpDcCoupon;
            ToModifyNpDcCoupon."POS Store Group" := '';
            ToModifyNpDcCoupon.Modify();
        until NpDcCoupon.Next() = 0;
    end;

    local procedure UpdateLines()
    var
        POSStoreGroupLine: Record "NPR POS Store Group Line";
    begin
        POSStoreGroupLine.SetRange("No.", Rec."No.");
        if POSStoreGroupLine.IsEmpty() then
            exit;
        POSStoreGroupLine.DeleteAll();
    end;

    local procedure DeleteDiscStoreGroups()
    var
        DiscStoreGroupLine: Record "NPR Disc. Store Group Line";
        RemainingLines: Record "NPR Disc. Store Group Line";
        DiscStoreGroup: Record "NPR Disc. Store Group";
        PeriodDiscount: Record "NPR Period Discount";
        MixedDiscount: Record "NPR Mixed Discount";
        QuantityDiscountHeader: Record "NPR Quantity Discount Header";
        TotalDiscountHeader: Record "NPR Total Discount Header";
        CannotDeleteErr: Label 'You cannot delete %1 %2 because it is the last store in %3 %4, which is assigned to one or more discounts.', Comment = '%1 = POS Store Group caption, %2 = POS Store Group No., %3 = Disc. Store Group caption, %4 = Disc. Store Group Code';
    begin
        DiscStoreGroupLine.SetRange("POS Store Group Code", Rec."No.");
        if DiscStoreGroupLine.IsEmpty() then
            exit;

        DiscStoreGroupLine.FindSet();
        repeat
            RemainingLines.SetRange("Disc. Store Group Code", DiscStoreGroupLine."Disc. Store Group Code");
            RemainingLines.SetFilter("POS Store Group Code", '<>%1', Rec."No.");
            if RemainingLines.IsEmpty() then begin
                PeriodDiscount.SetRange("Disc. Store Group Code", DiscStoreGroupLine."Disc. Store Group Code");
                MixedDiscount.SetRange("Disc. Store Group Code", DiscStoreGroupLine."Disc. Store Group Code");
                QuantityDiscountHeader.SetRange("Disc. Store Group Code", DiscStoreGroupLine."Disc. Store Group Code");
                TotalDiscountHeader.SetRange("Disc. Store Group Code", DiscStoreGroupLine."Disc. Store Group Code");
                if not PeriodDiscount.IsEmpty() or not MixedDiscount.IsEmpty() or
                   not QuantityDiscountHeader.IsEmpty() or not TotalDiscountHeader.IsEmpty()
                then
                    Error(CannotDeleteErr, TableCaption, Rec."No.", DiscStoreGroup.TableCaption, DiscStoreGroupLine."Disc. Store Group Code");
            end;
        until DiscStoreGroupLine.Next() = 0;

        DiscStoreGroupLine.DeleteAll();
    end;
}