table 6059915 "IDS Item Buffer"
{
    // IDS1.18/JDH/20150924  CASE  Description made 50 as std nav
    // NPR5.23/JDH /20160517 CASE 240916 Removed old VariaX Solution
    // NPR5.48/TJ  /20190102 CASE 340615 Commented out usage of field Item."Product Group Code"
    // NPR5.49/BHR /20190218 CASE 341465 Increase size of Variety Tables from code 20 to code 40
    // NPR5.51/MHA /20190820  CASE 365377 IDS is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'IDS Item Buffer';

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

