table 6060000 "GIM - Document Type"
{
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj -field
    // NPR5.51/MHA /20190819  CASE 365377 Generic Import Module is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'GIM - Document Type';
    LookupPageID = "GIM - Document Types";

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

