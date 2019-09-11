table 6059929 "IDS Item Buffer Att Value Set"
{
    // IDS1.21/JDH/20160329 CASE 234022 Added table for handling NPR Attributes
    // NPR5.51/MHA /20190820  CASE 365377 IDS is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'Attribute Value Set';

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

