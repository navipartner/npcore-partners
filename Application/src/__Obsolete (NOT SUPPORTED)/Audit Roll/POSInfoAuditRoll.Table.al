﻿table 6150643 "NPR POS Info Audit Roll"
{
    Access = Internal;
    Caption = 'POS Info Audit Roll';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = '"Audit Roll" related functionality is not used anymore (replaced by POS Entry). This table has been replaced with table 6150647 "NPR POS Info POS Entry"';

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
        }
        field(2; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(3; "Sales Line No."; Integer)
        {
            Caption = 'Sales Line No.';
            DataClassification = CustomerContent;
        }
        field(4; "Sale Date"; Date)
        {
            Caption = 'Sale Date';
            DataClassification = CustomerContent;
        }
        field(5; "Receipt Type"; Option)
        {
            Caption = 'Receipt Type';
            DataClassification = CustomerContent;
            OptionCaption = 'G/L,Item,Payment,Open/Close,Customer,Debit Sale,Cancelled,Comment';
            OptionMembers = "G/L",Item,Payment,"Open/Close",Customer,"Debit Sale",Cancelled,Comment;
        }
        field(6; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "POS Info Code"; Code[20])
        {
            Caption = 'POS Info Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Info";
        }
        field(11; "POS Info"; Text[250])
        {
            Caption = 'POS Info';
            DataClassification = CustomerContent;
        }
        field(20; "No."; Code[30])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(21; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(22; Price; Decimal)
        {
            Caption = 'Price';
            DataClassification = CustomerContent;
        }
        field(23; "Net Amount"; Decimal)
        {
            Caption = 'Net Amount';
            DataClassification = CustomerContent;
        }
        field(24; "Gross Amount"; Decimal)
        {
            Caption = 'Gross Amount';
            DataClassification = CustomerContent;
        }
        field(25; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "POS Info Code", "Register No.", "Sales Ticket No.", "Sales Line No.", "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}