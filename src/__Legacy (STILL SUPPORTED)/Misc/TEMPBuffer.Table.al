table 6014449 "NPR TEMP Buffer"
{
    Caption = 'NPR - TEMP Buffer';

    fields
    {
        field(1; Template; Code[50])
        {
            Caption = 'Template';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; Description; Text[250])
        {
            Caption = 'Description';
        }
        field(4; "Description 2"; Text[250])
        {
            Caption = 'Description 2';
        }
        field(5; "Description 3"; Text[250])
        {
            Caption = 'Description 3';
        }
        field(6; "Description 4"; Text[250])
        {
            Caption = 'Description 4';
        }
        field(7; "Description 5"; Text[250])
        {
            Caption = 'Description 5';
        }
        field(8; Color; Integer)
        {
            Caption = 'Color';
        }
        field(9; "Color 2"; Integer)
        {
            Caption = 'Color 2';
        }
        field(10; "Color 3"; Integer)
        {
            Caption = 'Color 3';
        }
        field(11; "Color 4"; Integer)
        {
            Caption = 'Color 4';
        }
        field(12; "Color 5"; Integer)
        {
            Caption = 'Color 5';
        }
        field(13; Bold; Boolean)
        {
            Caption = 'Bold';
        }
        field(14; "Bold 2"; Boolean)
        {
            Caption = 'Bold 2';
        }
        field(15; "Bold 3"; Boolean)
        {
            Caption = 'Bold 3';
        }
        field(16; "Bold 4"; Boolean)
        {
            Caption = 'Bold 4';
        }
        field(17; "Bold 5"; Boolean)
        {
            Caption = 'Bold 5';
        }
        field(18; Sel; Boolean)
        {
            Caption = 'Sel';
        }
        field(19; "Sel 2"; Boolean)
        {
            Caption = 'Sel 2';
        }
        field(20; "Sel 3"; Boolean)
        {
            Caption = 'Sel 3';
        }
        field(21; "Sel 4"; Boolean)
        {
            Caption = 'Sel 4';
        }
        field(22; "Sel 5"; Boolean)
        {
            Caption = 'Sel 5';
        }
        field(23; Indent; Integer)
        {
            Caption = 'Indent';
        }
        field(24; "Indent 2"; Integer)
        {
            Caption = 'Indent 2';
        }
        field(25; "Indent 3"; Integer)
        {
            Caption = 'Indent 3';
        }
        field(26; "Indent 4"; Integer)
        {
            Caption = 'Indent 4';
        }
        field(27; "Indent 5"; Integer)
        {
            Caption = 'Indent 5';
        }
        field(28; "Code 1"; Code[250])
        {
            Caption = 'Code 1';
        }
        field(29; "Code 2"; Code[250])
        {
            Caption = 'Code 2';
        }
        field(30; "Code 3"; Code[250])
        {
            Caption = 'Code 3';
        }
        field(31; "Code 4"; Code[250])
        {
            Caption = 'Code 4';
        }
        field(32; "Code 5"; Code[250])
        {
            Caption = 'Code 5';
        }
        field(33; "Short Code 1"; Code[20])
        {
            Caption = 'Short Code 1';
        }
        field(34; "Short Code 2"; Code[20])
        {
            Caption = 'Short Code 2';
        }
        field(35; "Short Code 3"; Code[20])
        {
            Caption = 'Short Code 3';
        }
        field(36; "Short Code 4"; Code[20])
        {
            Caption = 'Short Code 4';
        }
        field(37; "Short Code 5"; Code[20])
        {
            Caption = 'Short Code 5';
        }
        field(38; "Decimal 1"; Decimal)
        {
            Caption = 'Decimal 1';
        }
        field(39; "Decimal 2"; Decimal)
        {
            Caption = 'Decimal 2';
        }
        field(40; "Decimal 3"; Decimal)
        {
            Caption = 'Decimal 3';
        }
        field(41; "Decimal 4"; Decimal)
        {
            Caption = 'Decimal 4';
        }
        field(42; "Decimal 5"; Decimal)
        {
            Caption = 'Decimal 5';
        }
    }

    keys
    {
        key(Key1; Template, "Line No.")
        {
        }
        key(Key2; Indent)
        {
        }
        key(Key3; Template, "Short Code 1")
        {
        }
        key(Key4; "Short Code 1")
        {
        }
        key(Key5; "Decimal 1", "Short Code 1")
        {
        }
    }

    fieldgroups
    {
    }
}

