﻿table 6151604 "NPR NpDc Item Buffer"
{
    Access = Internal;
    Caption = 'Discount Item Buffer';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Item Group is obsolete, new table with Item Category Code as part of primary key is created.';

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(5; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(10; "Item Group"; Code[10])
        {
            Caption = 'Item Group';
            DataClassification = CustomerContent;
        }
        field(15; "Item Disc. Group"; Code[20])
        {
            Caption = 'Item Disc. Group';
            DataClassification = CustomerContent;
        }
        field(20; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
        }
        field(25; "Discount Type"; Integer)
        {
            Caption = 'Discount Type';
            DataClassification = CustomerContent;
        }
        field(30; "Discount Code"; Code[20])
        {
            Caption = 'Discount Code';
            DataClassification = CustomerContent;
        }
        field(32; "Discount %"; Decimal)
        {
            Caption = 'Discount %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(35; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            DataClassification = CustomerContent;
        }
        field(50; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(60; "Line Amount"; Decimal)
        {
            Caption = 'Line Amount';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Variant Code", "Item Group", "Item Disc. Group", "Unit Price", "Discount Type", "Discount Code", "Discount %")
        {
        }
    }
}

