﻿table 6014511 "NPR Saved Export Wizard"
{
    Access = Internal;
    Caption = 'Saved Export Wizard';
    DataCaptionFields = "Code", Description;
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Not used';

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(100; "Saved Data"; BLOB)
        {
            Caption = 'Saved Data';
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

