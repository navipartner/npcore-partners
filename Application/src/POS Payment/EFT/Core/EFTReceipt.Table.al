﻿table 6014403 "NPR EFT Receipt"
{
    Access = Internal;
    Caption = 'EFT Receipt';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Date"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(3; Type; Integer)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            MaxValue = 3;
            MinValue = 0;
        }
        field(4; "Transaction Time"; Time)
        {
            Caption = 'Transaction Time';
            DataClassification = CustomerContent;
        }
        field(5; "Text"; Text[60])
        {
            Caption = 'Text';
            DataClassification = CustomerContent;
        }
        field(6; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
        }
        field(7; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(8; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser";
        }
        field(9; Telegramtype; Code[2])
        {
            Caption = 'Terminal Type';
            DataClassification = CustomerContent;
        }
        field(10; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(100; "No. Printed"; Integer)
        {
            Caption = 'No. Printed';
            DataClassification = CustomerContent;
        }
        field(110; "EFT Trans. Request Entry No."; Integer)
        {
            Caption = 'EFT Trans. Request Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR EFT Transaction Request";
        }
        field(120; "Receipt No."; Integer)
        {
            Caption = 'Receipt No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.35';
        }
    }

    keys
    {
        key(Key1; "Register No.", "Sales Ticket No.", "Entry No.")
        {
        }
        key(Key2; "Register No.", "Sales Ticket No.", Type)
        {
        }
        key(Key3; "Register No.", "Sales Ticket No.", Date)
        {
        }
        key(Key4; "Register No.", "Sales Ticket No.", Date, Telegramtype)
        {
        }
        key(Key5; Date)
        {
        }
        key(Key6; "EFT Trans. Request Entry No.", "Receipt No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure PrintTerminalReceipt()
    var
        RetailReportSelMgt: Codeunit "NPR Retail Report Select. Mgt.";
        RecRef: RecordRef;
    begin
        if not Rec.FindSet() then
            exit;

        RecRef.GetTable(Rec);
        RetailReportSelMgt.SetRegisterNo(Rec."Register No.");
        RetailReportSelMgt.RunObjects(RecRef, "NPR Report Selection Type"::"Terminal Receipt".AsInteger());
    end;
}

