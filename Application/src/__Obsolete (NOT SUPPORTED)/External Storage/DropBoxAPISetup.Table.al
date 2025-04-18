﻿table 6184870 "NPR DropBox API Setup"
{
    Access = Internal;
    Caption = 'DropBox API Setup';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Not used';

    fields
    {
        field(1; "Account Code"; Code[10])
        {
            Caption = 'DropBox Account Code';
            DataClassification = CustomerContent;
        }
        field(5; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; Token; Guid)
        {
            Caption = 'Token';
            DataClassification = CustomerContent;
        }
        field(20; Timeout; Integer)
        {
            Caption = 'Timeout';
            DataClassification = CustomerContent;
            Description = 'Miliseconds';
        }
        field(30; "Storage On Server"; Text[250])
        {
            Caption = 'Server files location';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Account Code")
        {
        }
    }

    fieldgroups
    {
    }
}

