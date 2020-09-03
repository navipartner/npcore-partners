table 6059780 "NPR Companies in Profile"
{
    Caption = 'Companies in Profile';
    DataPerCompany = false;
    LookupPageID = "NPR Stock-Take Config. Card";

    fields
    {
        field(1; "Synchronisation profile"; Code[20])
        {
            Caption = 'Synchronisation Profile';
        }
        field(2; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            TableRelation = Company.Name;
        }
        field(3; ReplicationDirection; Option)
        {
            Caption = 'Replication Direction';
            OptionCaption = 'Both,To,From';
            OptionMembers = Both,"To",From;
        }
    }

    keys
    {
        key(Key1; "Synchronisation profile", "Company Name")
        {
        }
    }

    fieldgroups
    {
    }
}

