table 6059780 "NPR Companies in Profile"
{
    Access = Internal;
    Caption = 'Companies in Profile';
    DataPerCompany = false;
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Not used';

    fields
    {
        field(1; "Synchronisation profile"; Code[20])
        {
            Caption = 'Synchronisation Profile';
            DataClassification = CustomerContent;
        }
        field(2; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
        }
        field(3; ReplicationDirection; Option)
        {
            Caption = 'Replication Direction';
            OptionCaption = 'Both,To,From';
            OptionMembers = Both,"To",From;
            DataClassification = CustomerContent;
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

