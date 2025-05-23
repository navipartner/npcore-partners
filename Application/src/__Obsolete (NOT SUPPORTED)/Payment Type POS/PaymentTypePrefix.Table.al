﻿table 6014428 "NPR Payment Type - Prefix"
{
    Access = Internal;
    Caption = 'Prefix-Payment Type';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Replaced with EFT BIN Groups';
    fields
    {
        field(1; "Payment Type"; Code[10])
        {
            Caption = 'Payment Type';
            DataClassification = CustomerContent;
        }
        field(2; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
        }
        field(3; Prefix; Code[20])
        {
            Caption = 'Prefix';
            DataClassification = CustomerContent;
        }
        field(5; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(6; Weight; Decimal)
        {
            Caption = 'Weight';
            DataClassification = CustomerContent;
        }
        field(7; "Global Dimension 1 Code"; Code[20])
        {
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;
        }
        field(8; "Bill y/n"; Boolean)
        {
            Caption = 'Bill y/n';
            DataClassification = CustomerContent;
        }
        field(20; "Global Dimension 2 Code"; Code[20])
        {
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Payment Type", Prefix, "Register No.", Weight, "Global Dimension 1 Code")
        {
        }
    }

    fieldgroups
    {
    }
}

