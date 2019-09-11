table 6059890 "Npm Field"
{
    // NPR5.33/MHA /20170126  CASE 264348 Object created - Module: Np Page Manager
    // NPR5.51/MHA /20190816  CASE 365332 Np Page Manager is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'Npm Field';
    DataPerCompany = false;
    DrillDownPageID = "Npm Fields";
    LookupPageID = "Npm Fields";

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

