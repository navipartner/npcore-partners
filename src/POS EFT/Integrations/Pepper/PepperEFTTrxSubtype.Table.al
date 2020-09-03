table 6184487 "NPR Pepper EFT Trx Subtype"
{
    // NPR5.46/MMV /20180714 CASE 290734 Renamed

    Caption = 'Pepper EFT Transaction Subtype';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Integration Type Code"; Code[10])
        {
            Caption = 'Integration Type Code';
            DataClassification = CustomerContent;
        }
        field(20; "Transaction Type Code"; Code[10])
        {
            Caption = 'Transaction Type Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Pepper EFT Trx Type".Code WHERE("Integration Type" = FIELD("Integration Type Code"));
        }
        field(30; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(40; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Integration Type Code", "Transaction Type Code", "Code")
        {
        }
    }

    fieldgroups
    {
    }
}

