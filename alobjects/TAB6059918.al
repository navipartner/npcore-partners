table 6059918 "IDS Order Line"
{
    // NPK1.00/LJ/20131024  CASE 164281 Added code to update Shortcutdimensions
    // NPR5.51/MHA /20190820  CASE 365377 IDS is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'Inbox Line';

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

