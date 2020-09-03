table 6014484 "NPR RFID Print Log"
{
    // NPR5.55/MMV /20200713 CASE 407265 Created object

    Caption = 'RFID Print Log';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
        }
        field(11; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(12; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
        }
        field(14; "RFID Tag Value"; Text[100])
        {
            Caption = 'RFID Tag Value';
        }
        field(15; Barcode; Text[100])
        {
            Caption = 'Barcode';
        }
        field(16; "Batch ID"; Guid)
        {
            Caption = 'Batch ID';
        }
        field(17; "User ID"; Code[50])
        {
            Caption = 'User ID';
        }
        field(18; "Printed At"; DateTime)
        {
            Caption = 'Printed At';
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

