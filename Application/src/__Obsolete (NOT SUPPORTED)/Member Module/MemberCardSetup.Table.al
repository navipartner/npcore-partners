﻿table 6059772 "NPR Member Card Setup"
{
    Access = Internal;

    Caption = 'Point Card Properties';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = 'NPR23.0';
    ObsoleteReason = 'Not used.';
    fields
    {
        field(1; "Card Code"; Code[10])
        {
            Caption = 'Card Code';
            DataClassification = CustomerContent;
        }
        field(2; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Item,Item Group,Gift Voucher';
            OptionMembers = Item,"Item Group","Gift Voucher";
            DataClassification = CustomerContent;
        }
        field(3; "No."; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(5; "Units Per Point"; Decimal)
        {
            Caption = 'Units Per Point';
            DataClassification = CustomerContent;
        }
        field(6; Points; Decimal)
        {
            Caption = 'Points';
            DataClassification = CustomerContent;
        }
        field(7; "Customer Group"; Code[10])
        {
            Caption = 'Customer Group';
            DataClassification = CustomerContent;
        }
        field(9; "Base Calculation On"; Option)
        {
            Caption = 'Base Calculation On';
            OptionCaption = 'Amounts,Quantity';
            OptionMembers = Amounts,Quantity;
            DataClassification = CustomerContent;
        }
        field(10; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            DataClassification = CustomerContent;
        }
        field(11; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Card Code", Type, "No.", Points)
        {
        }
        key(Key2; Points)
        {
        }
    }

    fieldgroups
    {
    }
}

