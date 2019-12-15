table 6014541 "RP Print Buffer"
{
    Caption = 'Print Buffer';

    fields
    {
        field(1;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(2;"Column No.";Integer)
        {
            Caption = 'Column No.';
        }
        field(3;X;Integer)
        {
            Caption = 'X';
        }
        field(4;Y;Integer)
        {
            Caption = 'Y';
        }
        field(5;Text;Text[100])
        {
            Caption = 'Text';
        }
        field(7;Width;Integer)
        {
            Caption = 'Width';
        }
        field(10;Font;Text[50])
        {
            Caption = 'Font';
        }
        field(21;Bold;Boolean)
        {
            Caption = 'Bold';
        }
        field(22;Underline;Boolean)
        {
            Caption = 'Underline';
        }
        field(23;DoubleStrike;Boolean)
        {
            Caption = 'DoubleStrike';
        }
        field(28;Rotation;Integer)
        {
            Caption = 'Rotation';
        }
        field(30;Align;Option)
        {
            Caption = 'Align';
            OptionCaption = 'Left,Center,Right';
            OptionMembers = Left,Center,Right;
        }
        field(32;Height;Integer)
        {
            Caption = 'Height';
        }
        field(40;Indent;Integer)
        {
            Caption = 'Indent';
        }
        field(42;"Pad Char";Text[50])
        {
            Caption = 'Pad Char';
        }
    }

    keys
    {
        key(Key1;"Line No.","Column No.")
        {
        }
    }

    fieldgroups
    {
    }
}

