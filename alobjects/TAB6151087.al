table 6151087 "RIS Retail Inventory Buffer"
{
    // NPR5.40/MHA /20180320  CASE 307025 Object created - Retail Inventory Set

    Caption = 'Retail Inventory Buffer';
    DrillDownPageID = "RIS Retail Inventory Buffer";
    LookupPageID = "RIS Retail Inventory Buffer";

    fields
    {
        field(1;"Set Code";Code[20])
        {
            Caption = 'Set Code';
            NotBlank = true;
            TableRelation = "RIS Retail Inventory Set";
        }
        field(5;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(10;"Item Filter";Text[100])
        {
            Caption = 'Item Filter';
        }
        field(15;"Variant Filter";Text[100])
        {
            Caption = 'Variant Filter';
        }
        field(20;"Location Filter";Text[100])
        {
            Caption = 'Location Filter';
        }
        field(100;"Company Name";Text[30])
        {
            Caption = 'Company Name';
            NotBlank = true;
            TableRelation = Company;
        }
        field(105;Inventory;Decimal)
        {
            Caption = 'Inventory';
            DecimalPlaces = 0:5;
        }
        field(110;"Processing Error";Boolean)
        {
            Caption = 'Processing Error';
        }
        field(115;"Processing Error Message";Text[250])
        {
            Caption = 'Processing Error Message';
        }
    }

    keys
    {
        key(Key1;"Set Code","Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

