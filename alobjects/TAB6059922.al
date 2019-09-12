table 6059922 "IDS Profile"
{
    // IDS1.16/JDH/20141111 CASE 196245 "Web service" and "Custom" added as replication types
    // IDS1.18/JDH/20150923 CASE  NAV 2015 enabled
    // IDS1.20/JDH/20160224 CASE 234022 New possibility to avoid replicate Items again, and possible to substitute the vendor no.
    // IDS1.21/JDH/20160325 CASE 234022 Possible to choose how to create item nos.
    // NPR5.51/MHA /20190820  CASE 365377 IDS is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'IDS Profile';

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

