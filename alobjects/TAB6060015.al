table 6060015 "GIM - Mail Header"
{
    // NPR5.51/MHA /20190819  CASE 365377 Generic Import Module is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'GIM - Mail Header';
    LookupPageID = "GIM - Mail List";

    fields
    {
        field(1;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

