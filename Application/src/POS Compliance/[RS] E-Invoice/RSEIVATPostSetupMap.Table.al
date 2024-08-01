table 6150878 "NPR RS EI VAT Post. Setup Map."
{
    Access = Internal;
    Caption = 'RS EI VAT Posting Setup Mapping';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR RS VAT Post. Setup Mapping";
    LookupPageId = "NPR RS VAT Post. Setup Mapping";

    fields
    {
        field(1; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
            DataClassification = CustomerContent;
        }
        field(2; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
            DataClassification = CustomerContent;
        }
        field(3; "VAT %"; Decimal)
        {
            CalcFormula = lookup("VAT Posting Setup"."VAT %" where("VAT Bus. Posting Group" = field("VAT Bus. Posting Group"), "VAT Prod. Posting Group" = field("VAT Prod. Posting Group")));
            Caption = 'VAT %';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
            MaxValue = 100;
            MinValue = 0;
        }
        field(4; "NPR RS EI Tax Category"; Enum "NPR RS EI Allowed Tax Categ.")
        {
            Caption = 'RS Tax Category';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "VAT Bus. Posting Group", "VAT Prod. Posting Group")
        {
        }
    }
}