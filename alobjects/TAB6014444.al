table 6014444 "Touch Screen - Meta F. Trans"
{
    Caption = 'Touch Screen - Meta F. Trans';
    DataCaptionFields = "Language Code",Description;
    DrillDownPageID = "Touch Screen - Meta F. Trans";
    LookupPageID = "Touch Screen - Meta F. Trans";

    fields
    {
        field(1;"On function call";Code[50])
        {
            Caption = 'On function call';
            TableRelation = "Touch Screen - Meta Functions".Code;
        }
        field(2;"Language Code";Code[10])
        {
            Caption = 'Language Code';
            NotBlank = true;
            TableRelation = Language;
        }
        field(3;Description;Text[30])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1;"On function call","Language Code")
        {
        }
    }

    fieldgroups
    {
    }
}

