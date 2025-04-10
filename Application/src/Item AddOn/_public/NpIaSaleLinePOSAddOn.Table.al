﻿table 6151127 "NPR NpIa SaleLinePOS AddOn"
{
    Caption = 'Sale Line POS AddOn';
    DataClassification = CustomerContent;
    Extensible = false;

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR POS Unit";
        }
        field(5; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
            Editable = false;
            NotBlank = true;
        }
        field(10; "Sale Type"; Option)
        {
            Caption = 'Sale Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Deposit,Out payment,Comment,Cancelled,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Deposit,"Out payment",Comment,Cancelled,"Open/Close";
        }
        field(15; "Sale Date"; Date)
        {
            Caption = 'Sale Date';
            DataClassification = CustomerContent;
        }
        field(20; "Sale Line No."; Integer)
        {
            Caption = 'Sale Line No.';
            DataClassification = CustomerContent;
        }
        field(25; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(30; "Applies-to Line No."; Integer)
        {
            Caption = 'Applies-to Line No.';
            DataClassification = CustomerContent;
        }
        field(32; "AddOn No."; Code[20])
        {
            Caption = 'AddOn No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpIa Item AddOn";
        }
        field(35; "AddOn Line No."; Integer)
        {
            Caption = 'AddOn Line No.';
            DataClassification = CustomerContent;
        }
        field(40; "Fixed Quantity"; Boolean)
        {
            Caption = 'Fixed Quantity';
            DataClassification = CustomerContent;
        }
        field(50; "Per Unit"; Boolean)
        {
            Caption = 'Per unit';
            DataClassification = CustomerContent;
        }
        field(55; DiscountPercent; Decimal)
        {
            BlankZero = true;
            Caption = 'Discount %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 1;
            MaxValue = 100;
            MinValue = 0;
        }
        field(58; DiscountAmount; Decimal)
        {
            Caption = 'Discount Amount';
            DataClassification = CustomerContent;
            BlankZero = true;
        }
        field(60; Mandatory; Boolean)
        {
            Caption = 'Mandatory';
            DataClassification = CustomerContent;
        }
        field(70; "Copy Serial No."; Boolean)
        {
            Caption = 'Copy Serial No.';
            DataClassification = CustomerContent;
        }
        field(160; AddToWallet; Boolean)
        {
            Caption = 'Add to Wallet';
            DataClassification = CustomerContent;
        }
        field(165; AddOnItemNo; Code[20])
        {
            Caption = 'AddOn Item No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Register No.", "Sales Ticket No.", "Sale Type", "Sale Date", "Sale Line No.", "Line No.")
        {
        }
        key(Key2; "Applies-to Line No.")
        {
        }
    }
}
