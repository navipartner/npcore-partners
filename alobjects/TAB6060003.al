table 6060003 "GIM - Mapping Table Line"
{
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj
    // NPR5.51/MHA /20190819  CASE 365377 Generic Import Module is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'GIM - Mapping Table Line';
    LookupPageID = "GIM - Mapping Lines";

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

