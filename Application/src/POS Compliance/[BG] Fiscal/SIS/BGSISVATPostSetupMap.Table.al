table 6060089 "NPR BG SIS VAT Post. Setup Map"
{
    Access = Internal;
    Caption = 'BG SIS VAT Posting Setup Mapping';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR BG SIS VAT Post. Setup Map";
    LookupPageId = "NPR BG SIS VAT Post. Setup Map";

    fields
    {
        field(1; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
        }
        field(2; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Product Posting Group";
        }
        field(20; "BG SIS VAT Category"; Enum "NPR BG SIS VAT Category")
        {
            Caption = 'BG SIS VAT Category';
            DataClassification = CustomerContent;
            InitValue = " ";
        }
    }

    keys
    {
        key(Key1; "VAT Bus. Posting Group", "VAT Prod. Posting Group")
        {
        }
    }

    internal procedure CheckIsBGSISVATCategoryPopulated()
    var
        NotPopulatedErr: Label '%1 must be populated for %2 %3 VAT Posting Setup.', Comment = '%1 - BG SIS VAT Category field caption, %2 - VAT Bus. Posting Group field caption, %3 - VAT Prod. Posting Group field caption';
    begin
        if "BG SIS VAT Category" = "BG SIS VAT Category"::" " then
            Error(NotPopulatedErr, FieldCaption("BG SIS VAT Category"), "VAT Bus. Posting Group", "VAT Prod. Posting Group");
    end;
}