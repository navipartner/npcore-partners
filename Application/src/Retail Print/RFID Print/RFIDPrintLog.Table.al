﻿table 6014484 "NPR RFID Print Log"
{
    Access = Internal;
    // NPR5.55/MMV /20200713 CASE 407265 Created object

    Caption = 'RFID Print Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(11; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(12; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(14; "RFID Tag Value"; Text[100])
        {
            Caption = 'RFID Tag Value';
            DataClassification = CustomerContent;
        }
        field(15; Barcode; Text[100])
        {
            Caption = 'Barcode';
            DataClassification = CustomerContent;
        }
        field(16; "Batch ID"; Guid)
        {
            Caption = 'Batch ID';
            DataClassification = CustomerContent;
        }
        field(17; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18; "Printed At"; DateTime)
        {
            Caption = 'Printed At';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Batch ID")
        {
        }
    }

    fieldgroups
    {
    }
}

