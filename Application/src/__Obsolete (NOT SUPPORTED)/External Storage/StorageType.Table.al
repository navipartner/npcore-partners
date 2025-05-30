﻿table 6184890 "NPR Storage Type"
{
    Access = Internal;
    Caption = 'Storage Types';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Not used';
    fields
    {
        field(1; "Storage Type"; Code[20])
        {
            Caption = 'Storage Type';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Codeunit"; Integer)
        {
            Caption = 'Codeunit ID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Storage Type")
        {
        }
    }

    fieldgroups
    {
    }
}

