table 6059930 "IDS - NPR Attribute Mapping"
{
    // IDS1.21/JDH/20160329 CASE 234022 Added table for handling NPR Attributes
    // NPR5.33/ANEN/20170427 CASE 273989 Extending to 40 attributes
    // NPR5.51/MHA /20190820  CASE 365377 IDS is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'IDS - NPR Attribute Mapping';

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

