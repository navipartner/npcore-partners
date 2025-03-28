﻿table 6184505 "NPR EFT Aux Operation"
{
    Access = Internal;
    // NPR5.46/MMV /20181008 CASE 290734 Created object

    Caption = 'EFT Aux Operation';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR EFT Auxiliary Operations";
    LookupPageID = "NPR EFT Auxiliary Operations";

    fields
    {
        field(1; "Integration Type"; Code[20])
        {
            Caption = 'Integration Type';
            DataClassification = CustomerContent;
        }
        field(2; "Auxiliary ID"; Integer)
        {
            Caption = 'Auxiliary ID';
            DataClassification = CustomerContent;
        }
        field(3; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Integration Type", "Auxiliary ID")
        {
        }
    }

    fieldgroups
    {
    }
}

