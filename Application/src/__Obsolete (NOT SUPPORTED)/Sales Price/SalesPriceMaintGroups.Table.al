﻿table 6059782 "NPR Sales Price Maint. Groups"
{
    Access = Internal;
    Caption = 'Sales Price Maintenance Groups';
    DrillDownPageID = "NPR Sales Price Maint. Groups";
    LookupPageID = "NPR Sales Price Maint. Groups";
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = 'NPR23.0';
    ObsoleteReason = 'Item Group is obsoleted, Item Category used instead. New table created with Item Category in primary key.';

    fields
    {
        field(1; Id; Integer)
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
        }
        field(2; "Item Group"; Code[10])
        {
            Caption = 'Item Group';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            Editable = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
            end;
        }
    }

    keys
    {
        key(Key1; Id, "Item Group")
        {
        }
    }

    fieldgroups
    {
    }
}

