table 6151029 "NPR HU L VAT Post. Setup Mapp."
{
    Access = Internal;
    Caption = 'HU Laurel VAT Posting Setup Mapping';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR HU L VAT Post. Setup Mapp.";
    LookupPageId = "NPR HU L VAT Post. Setup Mapp.";

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
        field(10; "VAT %"; Decimal)
        {
            CalcFormula = lookup("VAT Posting Setup"."VAT %" where("VAT Bus. Posting Group" = field("VAT Bus. Posting Group"), "VAT Prod. Posting Group" = field("VAT Prod. Posting Group")));
            Caption = 'VAT %';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
            MaxValue = 100;
            MinValue = 0;
        }
        field(15; "Laurel VAT Index"; Enum "NPR HU L VAT Index")
        {
            Caption = 'Laurel VAT Index';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "VAT Bus. Posting Group", "VAT Prod. Posting Group")
        {
        }
    }
}