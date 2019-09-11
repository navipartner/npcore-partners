table 6060007 "GIM - Supported Data Type"
{
    // NPR5.51/MHA /20190819  CASE 365377 Generic Import Module is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'GIM - Supported Data Type';
    LookupPageID = "GIM - Supported Data Types";

    fields
    {
        field(1;"Entry No.";Code[10])
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

