table 6014627 "NPR Lookup Template Line"
{
    Caption = 'Lookup Template Line';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    fields
    {
        field(1; "Lookup Template Table No."; Integer)
        {
            Caption = 'Lookup Template Table No.';
            DataClassification = CustomerContent;
        }
        field(2; "Row No."; Integer)
        {
            Caption = 'Row No.';
            DataClassification = CustomerContent;
        }
        field(3; "Col No."; Integer)
        {
            Caption = 'Col No.';
            DataClassification = CustomerContent;
        }
        field(4; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = CustomerContent;
        }
        field(11; Class; Text[30])
        {
            Caption = 'Class';
            DataClassification = CustomerContent;
        }
        field(12; "Caption Type"; Option)
        {
            Caption = 'Caption Type';
            OptionCaption = 'Text,Field Caption,Table Caption';
            OptionMembers = Text,"Field","Table";
            DataClassification = CustomerContent;
        }
        field(13; "Caption Table No."; Integer)
        {
            BlankZero = true;
            Caption = 'Caption Table No.';
            DataClassification = CustomerContent;
        }
        field(14; "Caption Field No."; Integer)
        {
            BlankZero = true;
            Caption = 'Caption Field No.';
            DataClassification = CustomerContent;
        }
        field(15; "Caption Text"; Text[30])
        {
            Caption = 'Caption Text';
            DataClassification = CustomerContent;
        }
        field(17; "Text Align"; Option)
        {
            Caption = 'Text Align';
            OptionCaption = 'None,Left,Right,Center,Justify';
            OptionMembers = "None",Left,Right,Center,Justify;
            DataClassification = CustomerContent;
        }
        field(18; "Font Size (pt)"; Integer)
        {
            Caption = 'Font Size (pt)';
            DataClassification = CustomerContent;
        }
        field(19; "Width (CSS)"; Text[30])
        {
            Caption = 'Width (CSS)';
            DataClassification = CustomerContent;
        }
        field(20; "Number Format"; Option)
        {
            Caption = 'Number Format';
            OptionCaption = 'None,Number,Percentage,Integer,IntegerThousand';
            OptionMembers = "None",Number,Percentage,"Integer",IntegerThousand;
            DataClassification = CustomerContent;
        }
        field(21; Searchable; Boolean)
        {
            Caption = 'Searchable';
            DataClassification = CustomerContent;
        }
        field(22; "Related Table No."; Integer)
        {
            Caption = 'Related Table No.';
            DataClassification = CustomerContent;
        }
        field(24; "Related Field No."; Integer)
        {
            Caption = 'Related Field No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Lookup Template Table No.", "Row No.", "Col No.")
        {
        }
    }

    fieldgroups
    {
    }
}

