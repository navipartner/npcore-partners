﻿table 6184503 "NPR CleanCash Register"
{
    Access = Internal;

    Caption = 'CleanCash Cash Register';
    DataClassification = CustomerContent;
    ObsoleteReason = 'This table is not used anymore';
    ObsoleteState = Removed;
    ObsoleteTag = '2023-06-28';
    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
        }
        field(2; "CleanCash No. Series"; Code[20])
        {
            Caption = 'CleanCash No. Series';
            DataClassification = CustomerContent;
        }
        field(3; "CleanCash Integration"; Boolean)
        {
            Caption = 'CleanCash Integration';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Register No.")
        {
        }
    }

    fieldgroups
    {
    }
}

