table 6059777 "NPR Company Sync Profiles"
{
    Caption = 'Company Sync Profiles';
    DataPerCompany = false;
    DataClassification = CustomerContent;
    ObsoleteState = Removed;

    fields
    {
        field(1; "Synchronisation Profile"; Code[20])
        {
            Caption = 'Synchronisation Profile';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Synchronisation Profile")
        {
        }
    }

    fieldgroups
    {
    }
}

