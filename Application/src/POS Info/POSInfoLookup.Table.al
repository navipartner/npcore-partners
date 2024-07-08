table 6150646 "NPR POS Info Lookup"
{
    Access = Internal;
    Caption = 'POS Info Lookup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
        }
        field(3; "Primary Key"; Text[250])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Field 1"; Text[250])
        {
            Caption = 'Field 1';
            DataClassification = CustomerContent;
        }
        field(11; "Field 2"; Text[250])
        {
            Caption = 'Field 2';
            DataClassification = CustomerContent;
        }
        field(12; "Field 3"; Text[250])
        {
            Caption = 'Field 3';
            DataClassification = CustomerContent;
        }
        field(13; "Field 4"; Text[250])
        {
            Caption = 'Field 4';
            DataClassification = CustomerContent;
        }
        field(14; "Field 5"; Text[250])
        {
            Caption = 'Field 5';
            DataClassification = CustomerContent;
        }
        field(15; "Field 6"; Text[250])
        {
            Caption = 'Field 6';
            DataClassification = CustomerContent;
        }
        field(20; RecID; RecordID)
        {
            Caption = 'RecID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

