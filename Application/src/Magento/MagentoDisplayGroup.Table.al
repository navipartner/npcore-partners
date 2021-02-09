table 6151436 "NPR Magento Display Group"
{
    Caption = 'Magento Display Group';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Magento Display Groups";
    LookupPageID = "NPR Magento Display Groups";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }
}