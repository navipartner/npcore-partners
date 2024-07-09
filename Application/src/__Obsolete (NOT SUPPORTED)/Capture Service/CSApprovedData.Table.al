﻿table 6151366 "NPR CS Approved Data"
{
    Access = Internal;
    Caption = 'CS Approved Data';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Object moved to NP Warehouse App.';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(3; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(4; "Qty."; Integer)
        {
            Caption = 'Qty.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

