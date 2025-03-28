﻿table 6150626 "NPR POS Entry Comm. Line"
{
    Caption = 'POS Entry Comment Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = CustomerContent;
        }
        field(3; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Entry";
        }
        field(4; "POS Entry Line No."; Integer)
        {
            Caption = 'POS Entry Line No.';
            DataClassification = CustomerContent;
        }
        field(10; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(11; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(12; Comment; Text[250])
        {
            Caption = 'Comment';
            DataClassification = CustomerContent;
        }
        field(20; "POS Sale ID"; Integer)
        {
            Caption = 'POS Sale ID';
            DataClassification = CustomerContent;
        }
        field(21; "POS Line No."; Integer)
        {
            Caption = 'POS Line No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Table ID", "POS Entry No.", "POS Entry Line No.", "Code", "Line No.")
        {
        }
        key(Key3; "POS Sale ID", "POS Line No.", "Code", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

