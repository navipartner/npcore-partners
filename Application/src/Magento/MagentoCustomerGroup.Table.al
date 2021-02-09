table 6151432 "NPR Magento Customer Group"
{
    Caption = 'Magento Customer Group';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Magento Customer Groups";
    LookupPageID = "NPR Magento Customer Groups";

    fields
    {
        field(1; "Code"; Text[30])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(6059810; "Magento Tax Class"; Text[250])
        {
            Caption = 'Magento Tax Class';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Tax Class" WHERE(Type = CONST(Customer));
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }
}