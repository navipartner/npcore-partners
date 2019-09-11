table 6014616 "Item Wizard Template"
{
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj
    // NPR5.51/MHA /20190820  CASE 365377 IDS is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'Item Wizard Template';

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

