﻿table 6014437 "NPR Payment Type - Detailed"
{
    Access = Internal;
    Caption = 'Payment Type - Detailed';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Not used';

    fields
    {
        field(1; "Payment No."; Code[10])
        {
            Caption = 'Payment Type';
            DataClassification = CustomerContent;
        }
        field(2; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
        }
        field(3; Weight; Decimal)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(4; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Quantity := Amount / Weight;
            end;
        }
        field(5; Quantity; Integer)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Amount := Quantity * Weight;
            end;
        }
    }

    keys
    {
        key(Key1; "Payment No.", "Register No.", Weight)
        {
            SumIndexFields = Amount;
        }
    }

    fieldgroups
    {
    }
}

