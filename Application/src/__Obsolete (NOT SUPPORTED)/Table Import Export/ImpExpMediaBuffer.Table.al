﻿table 6014450 "NPR Imp. Exp. Media Buffer"
{
    Access = Internal;
    Caption = 'Import Export Media Buffer';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = 'NPR23.0';
    ObsoleteReason = 'Not used';

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            AutoIncrement = true;
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; Media; Media)
        {
            Caption = 'Media';
            DataClassification = CustomerContent;
        }
        field(3; MediaSet; MediaSet)
        {
            Caption = 'MediaSet';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}

