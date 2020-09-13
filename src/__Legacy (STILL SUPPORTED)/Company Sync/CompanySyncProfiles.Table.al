table 6059777 "NPR Company Sync Profiles"
{
    // NPR5.38/MHA /20180104  CASE 301054 Removed non-existing Page6059777 from LookupPageID

    Caption = 'Company Sync Profiles';
    DataPerCompany = false;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Synchronisation Profile"; Code[20])
        {
            Caption = 'Synchronisation Profile';
            Editable = true;
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

