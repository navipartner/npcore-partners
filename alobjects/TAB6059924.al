table 6059924 "IDS Packages"
{
    // IDS1.16/JDH/20141111 CASE 196245 Web service added as exchange possibility
    // IDS1.17/JDH/20150417 CASE 211583 Delete data in subtables when package is deleted
    // IDS1.18/JC/20150827  CASE 220397 Option should be integer not text
    // IDS1.20/TTH/20150121 CASE 231917 Adding the SQL position to the Package
    // IDS1.20/TTH/09022016 CASE 234015 Enabling BLOB Fields for IDS
    // NPR5.51/MHA /20190820  CASE 365377 IDS is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'IDS Packages';

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

