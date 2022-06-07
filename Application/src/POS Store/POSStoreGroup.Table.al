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
    }

    var
        CannotRenameErr: Label 'You cannot rename a %1.';

    trigger OnDelete()
    begin
        UpdateCoupons();
        UpdateCouponType();
        UpdateLines();
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
}