table 6184487 "Pepper EFT Transaction Subtype"
{
    // NPR5.46/MMV /20180714 CASE 290734 Renamed

    Caption = 'Pepper EFT Transaction Subtype';

    fields
    {
        field(10;"Integration Type Code";Code[10])
        {
            Caption = 'Integration Type Code';
        }
        field(20;"Transaction Type Code";Code[10])
        {
            Caption = 'Transaction Type Code';
            TableRelation = "Pepper EFT Transaction Type".Code WHERE ("Integration Type"=FIELD("Integration Type Code"));
        }
        field(30;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(40;Description;Text[50])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1;"Integration Type Code","Transaction Type Code","Code")
        {
        }
    }

    fieldgroups
    {
    }
}

