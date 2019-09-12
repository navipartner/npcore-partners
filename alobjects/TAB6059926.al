table 6059926 "IDS Flow Setup"
{
    // IDS1.18/JDH/20150923 CASE   Removed unused Variables
    // NPR5.20/TTH/20160303 CASE 235900 Created OptionCaption for field 11 Map to Type.
    // NPR5.51/MHA /20190820  CASE 365377 IDS is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'IDS Mapping Setup';

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

