﻿table 6059777 "NPR Company Sync Profiles"
{
    Access = Internal;
    Caption = 'Company Sync Profiles';
    DataPerCompany = false;
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Not used';

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

