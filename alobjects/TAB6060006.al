table 6060006 "GIM - Import Buffer"
{
    // NPR5.51/MHA /20190819  CASE 365377 Generic Import Module is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'GIM - Import Buffer';
    LookupPageID = "GIM - Mapping";

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }
}

