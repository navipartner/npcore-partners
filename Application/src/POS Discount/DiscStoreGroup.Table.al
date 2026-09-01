table 6059936 "NPR Disc. Store Group"
{
    Access = Internal;
    Caption = 'Discount Store Group';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Disc. Store Groups";
    LookupPageID = "NPR Disc. Store Groups";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
        key(Key2; SystemRowVersion)
        {
        }
    }

    var
        CannotRenameErr: Label 'You cannot rename a %1.', Comment = '%1 = Table caption';

    trigger OnRename()
    begin
        Error(CannotRenameErr, TableCaption);
    end;

    trigger OnDelete()
    var
        DiscStoreGroupLine: Record "NPR Disc. Store Group Line";
    begin
        CheckNotReferencedByDiscounts();

        DiscStoreGroupLine.SetRange("Disc. Store Group Code", "Code");
        if not DiscStoreGroupLine.IsEmpty() then
            DiscStoreGroupLine.DeleteAll();
    end;

    local procedure CheckNotReferencedByDiscounts()
    var
        PeriodDiscount: Record "NPR Period Discount";
        MixedDiscount: Record "NPR Mixed Discount";
        QuantityDiscountHeader: Record "NPR Quantity Discount Header";
        TotalDiscountHeader: Record "NPR Total Discount Header";
        CannotDeleteErr: Label 'You cannot delete %1 %2 because it is assigned to one or more discounts.', Comment = '%1 = Table caption, %2 = Code value';
    begin
        PeriodDiscount.SetRange("Disc. Store Group Code", "Code");
        if not PeriodDiscount.IsEmpty() then
            Error(CannotDeleteErr, TableCaption, "Code");

        MixedDiscount.SetRange("Disc. Store Group Code", "Code");
        if not MixedDiscount.IsEmpty() then
            Error(CannotDeleteErr, TableCaption, "Code");

        QuantityDiscountHeader.SetRange("Disc. Store Group Code", "Code");
        if not QuantityDiscountHeader.IsEmpty() then
            Error(CannotDeleteErr, TableCaption, "Code");

        TotalDiscountHeader.SetRange("Disc. Store Group Code", "Code");
        if not TotalDiscountHeader.IsEmpty() then
            Error(CannotDeleteErr, TableCaption, "Code");
    end;
}
