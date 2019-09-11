table 6059925 "IDS Setup"
{
    // IDS1.08/JDH/200614 CASE185182 added standard texts for web references
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption for Text004 + removed deprecated Variant model ColorSize from option field
    // NPR5.51/MHA /20190820  CASE 365377 IDS is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'IDS Setup';

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

