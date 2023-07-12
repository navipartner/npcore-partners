﻿table 6150723 "NPR Available POS Keybind"
{
    Access = Internal;
    Caption = 'Available POS Keybind';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = 'NPR23.0';
    ObsoleteReason = 'Almost zero usage since the module was introduced, but caused significant performance issues';

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
}
