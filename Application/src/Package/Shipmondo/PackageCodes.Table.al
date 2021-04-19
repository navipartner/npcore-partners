table 6014587 "NPR Package Code"
{

    Caption = 'NPR Package Codes';
    DrillDownPageID = "NPR Pacsoft Package Codes";
    LookupPageID = "NPR Pacsoft Package Codes";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent".Code;
            DataClassification = CustomerContent;
        }
        field(4; Id; Integer)
        {
            Caption = 'ID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Shipping Agent Code", "Code")
        {
        }
    }

    fieldgroups
    {
    }
}

