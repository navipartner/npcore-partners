table 6060001 "GIM - Import Document"
{
    // GIM1.00/MH/20150814  CASE 210725 Added xml to ParseFile()
    // NPR5.51/MHA /20190819  CASE 365377 Generic Import Module is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'GIM - Import Document';
    LookupPageID = "GIM - Import Document List";

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

