table 6014470 "NPR Pacsoft Shipm. Doc. Serv."
{

    Caption = 'Pacsoft Shipment Document Services';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";
            DataClassification = CustomerContent;
        }
        field(3; "Shipping Agent Service Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code WHERE("Shipping Agent Code" = FIELD("Shipping Agent Code"));
            DataClassification = CustomerContent;
        }
        field(20; Description; Text[100])
        {
            CalcFormula = Lookup("Shipping Agent Services".Description WHERE("Shipping Agent Code" = FIELD("Shipping Agent Code"),
                                                                              Code = FIELD("Shipping Agent Service Code")));
            Caption = 'Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(21; Amount; Decimal)
        {
            Caption = 'Amount';
            Enabled = false;
            DataClassification = CustomerContent;
        }
        field(22; Reference; Text[50])
        {
            Caption = 'Reference';
            Enabled = false;
            DataClassification = CustomerContent;
        }
        field(23; "Reference Type"; Option)
        {
            Caption = 'Reference Type';
            Enabled = false;
            OptionCaption = ' ,TXT,OCR';
            OptionMembers = " ",TXT,OCR;
            DataClassification = CustomerContent;
        }
        field(24; Miscellaneous; Text[80])
        {
            Caption = 'Miscellaneous';
            Enabled = false;
            DataClassification = CustomerContent;
        }
        field(25; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            Enabled = false;
            DataClassification = CustomerContent;
        }
        field(26; "Account Type"; Text[5])
        {
            Caption = 'Account Type';
            Enabled = false;
            ValuesAllowed = 'ACCDK', 'BG', 'PG', 'KONTO';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.", "Shipping Agent Code", "Shipping Agent Service Code")
        {
        }
    }

    fieldgroups
    {
    }
}

