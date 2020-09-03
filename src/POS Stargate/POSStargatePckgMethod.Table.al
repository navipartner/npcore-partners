table 6150714 "NPR POS Stargate Pckg. Method"
{
    Caption = 'POS Stargate Package Method';
    DataClassification = CustomerContent;
    DataPerCompany = false;
    DrillDownPageID = "NPR POS Stargate Pckg Method";
    LookupPageID = "NPR POS Stargate Pckg Method";

    fields
    {
        field(1; "Method Name"; Text[250])
        {
            Caption = 'Method Name';
            DataClassification = CustomerContent;
        }
        field(2; "Package Name"; Text[80])
        {
            Caption = 'Package Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Method Name")
        {
        }
        key(Key2; "Package Name")
        {
        }
    }

    fieldgroups
    {
    }
}

