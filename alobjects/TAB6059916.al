table 6059916 "IDS Item Buffer Variant"
{
    // NPR5.23/JDH /20160517 CASE 240916 Removed old VariaX Solution
    // NPR5.51/MHA /20190820  CASE 365377 IDS is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'IDS Item Buffer Variant';

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

