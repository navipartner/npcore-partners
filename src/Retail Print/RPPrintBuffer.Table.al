table 6014541 "NPR RP Print Buffer"
{
    Caption = 'Print Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(2; "Column No."; Integer)
        {
            Caption = 'Column No.';
            DataClassification = CustomerContent;
        }
        field(3; X; Integer)
        {
            Caption = 'X';
            DataClassification = CustomerContent;
        }
        field(4; Y; Integer)
        {
            Caption = 'Y';
            DataClassification = CustomerContent;
        }
        field(5; "Text"; Text[100])
        {
            Caption = 'Text';
            DataClassification = CustomerContent;
        }
        field(7; Width; Integer)
        {
            Caption = 'Width';
            DataClassification = CustomerContent;
        }
        field(10; Font; Text[50])
        {
            Caption = 'Font';
            DataClassification = CustomerContent;
        }
        field(21; Bold; Boolean)
        {
            Caption = 'Bold';
            DataClassification = CustomerContent;
        }
        field(22; Underline; Boolean)
        {
            Caption = 'Underline';
            DataClassification = CustomerContent;
        }
        field(23; DoubleStrike; Boolean)
        {
            Caption = 'DoubleStrike';
            DataClassification = CustomerContent;
        }
        field(28; Rotation; Integer)
        {
            Caption = 'Rotation';
            DataClassification = CustomerContent;
        }
        field(30; Align; Option)
        {
            Caption = 'Align';
            OptionCaption = 'Left,Center,Right';
            OptionMembers = Left,Center,Right;
            DataClassification = CustomerContent;
        }
        field(32; Height; Integer)
        {
            Caption = 'Height';
            DataClassification = CustomerContent;
        }
        field(40; Indent; Integer)
        {
            Caption = 'Indent';
            DataClassification = CustomerContent;
        }
        field(42; "Pad Char"; Text[50])
        {
            Caption = 'Pad Char';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Line No.", "Column No.")
        {
        }
    }

    fieldgroups
    {
    }
}

