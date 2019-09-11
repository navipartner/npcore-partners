table 6059917 "IDS Order"
{
    // NPR5.51/MHA /20190820  CASE 365377 IDS is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'Inbox Header';

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

