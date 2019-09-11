table 6059923 "Item Wizard Mapping Setup"
{
    // IDS1.20/JDH/20160224 CASE 234022 Possible to map to Item Worksheet
    // NPR5.51/MHA /20190820  CASE 365377 IDS is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'Item Wizard Mapping Setup';

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

