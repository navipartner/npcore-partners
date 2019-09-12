table 6059913 "IDS Data Package (Record)"
{
    // IDS1.20/TTH/09022016 CASE 234015 Enabling BLOB Fields for IDS
    // NPR5.51/MHA /20190820  CASE 365377 IDS is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'IDS Data Package (Record)';

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

