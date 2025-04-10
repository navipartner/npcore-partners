﻿table 6014479 "NPR Dynamic Module"
{
    Caption = 'Dynamic Module';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Not used';

    fields
    {
        field(1; "Module Guid"; Guid)
        {
            Caption = 'Module Guid';
            DataClassification = CustomerContent;
        }
        field(10; "Module Name"; Text[50])
        {
            Caption = 'Module Name';
            DataClassification = CustomerContent;
        }
        field(20; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Module Guid")
        {
        }
    }

    fieldgroups
    {
    }
}

