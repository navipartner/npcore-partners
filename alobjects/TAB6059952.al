table 6059952 "Display Content Lines"
{
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to Object

    Caption = 'Display Content Lines';
    DataClassification = CustomerContent;
    DrillDownPageID = "Display Content Lines";
    LookupPageID = "Display Content Lines";

    fields
    {
        field(1; "Content Code"; Code[10])
        {
            Caption = 'Content Code';
            DataClassification = CustomerContent;
            TableRelation = "Display Content".Code;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(11; Url; Text[250])
        {
            Caption = 'Url';
            DataClassification = CustomerContent;
        }
        field(12; Image; BLOB)
        {
            Caption = 'Image';
            DataClassification = CustomerContent;
            SubType = Bitmap;
        }
    }

    keys
    {
        key(Key1; "Content Code", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

