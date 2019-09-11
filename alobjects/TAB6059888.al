table 6059888 "Npm Page"
{
    // NPR5.33/MHA /20170126  CASE 264348 Object created - Module: Np Page Manager
    // NPR5.38/MHA /20180104  CASE 301054 Removed hidden property, Volatile, from Field 50 and 55
    // NPR5.51/MHA /20190816  CASE 365332 Np Page Manager is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'Npm Page';
    DataPerCompany = false;
    DrillDownPageID = "Npm Pages";
    LookupPageID = "Npm Pages";

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

