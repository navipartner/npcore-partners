table 6059952 "Display Content Lines"
{
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to Object

    Caption = 'Display Content Lines';
    DrillDownPageID = "Display Content Lines";
    LookupPageID = "Display Content Lines";

    fields
    {
        field(1;"Content Code";Code[10])
        {
            Caption = 'Content Code';
            TableRelation = "Display Content".Code;
        }
        field(2;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(11;Url;Text[250])
        {
            Caption = 'Url';
        }
        field(12;Image;BLOB)
        {
            Caption = 'Image';
            SubType = Bitmap;
        }
    }

    keys
    {
        key(Key1;"Content Code","Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

