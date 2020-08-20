table 6150723 "Available POS Keybind"
{
    // NPR5.48/JAVA/20190205  CASE 323835 Transport NPR5.48 - 5 February 2019

    Caption = 'Available POS Keybind';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Key Name"; Text[30])
        {
            Caption = 'Key Name';
            DataClassification = CustomerContent;
        }
        field(20; "Modifier Key Priority"; Integer)
        {
            Caption = 'Modifier Key Priority';
            DataClassification = CustomerContent;
        }
        field(30; Supported; Boolean)
        {
            Caption = 'Supported';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Modifier Key Priority")
        {
        }
    }

    fieldgroups
    {
    }
}

