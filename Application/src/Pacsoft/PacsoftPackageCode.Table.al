﻿table 6014471 "NPR Pacsoft Package Code"
{
    Access = Internal;

    Caption = 'Pacsoft Package Codes';
    DrillDownPageID = "NPR Pacsoft Package Codes";
    LookupPageID = "NPR Pacsoft Package Codes";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }
}

