table 6059921 "Order Link"
{
    // NPR5.31/JLK /20170331  CASE 268274 Changed ENU Caption
    // NPR5.51/MHA /20190820  CASE 365377 IDS is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'Order Link';

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

