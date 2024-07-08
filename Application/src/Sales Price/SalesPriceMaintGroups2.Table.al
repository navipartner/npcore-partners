﻿table 6014490 "NPR Sales Price Maint. Groups2"
{
    Access = Internal;
    Caption = 'Sales Price Maintenance Groups';
    DrillDownPageID = "NPR Sales Price Maint. Groups";
    LookupPageID = "NPR Sales Price Maint. Groups";
    DataClassification = CustomerContent;

    fields
    {
        field(1; Id; Integer)
        {
            Caption = 'Id';
            TableRelation = "NPR Sales Price Maint. Setup";
            DataClassification = CustomerContent;
        }
        field(2; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            TableRelation = "Item Category";
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Id, "Item Category Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if "Item Category Code" <> '' then begin
            Clear(ItemCategory);
            ItemCategory.Get("Item Category Code");
            Description := ItemCategory.Description;
        end;
    end;

    var
        ItemCategory: Record "Item Category";
}
