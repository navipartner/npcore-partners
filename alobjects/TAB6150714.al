table 6150714 "POS Stargate Package Method"
{
    Caption = 'POS Stargate Package Method';
    DataPerCompany = false;
    DrillDownPageID = "POS Stargate Package Method";
    LookupPageID = "POS Stargate Package Method";

    fields
    {
        field(1;"Method Name";Text[250])
        {
            Caption = 'Method Name';
        }
        field(2;"Package Name";Text[80])
        {
            Caption = 'Package Name';
        }
    }

    keys
    {
        key(Key1;"Method Name")
        {
        }
        key(Key2;"Package Name")
        {
        }
    }

    fieldgroups
    {
    }
}

