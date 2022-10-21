﻿table 6151003 "NPR POS Saved Sale Line"
{
    Caption = 'POS Saved Sale Line';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Saved Sale Lines";
    LookupPageID = "NPR POS Saved Sale Lines";

    fields
    {
        field(1; "Quote Entry No."; BigInteger)
        {
            Caption = 'Quote Entry No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "NPR POS Saved Sale Entry";
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            InitValue = Item;
            OptionCaption = 'G/L,Item,Item Group,Repair,,Payment,Open/Close,Inventory,Customer,Comment';
            OptionMembers = "G/L Entry",Item,"Item Group",Repair,,Payment,"Open/Close","BOM List",Customer,Comment;
            ObsoleteState = Removed;
            ObsoleteReason = 'Use Line Type';
        }
        field(11; "Line Type"; Enum "NPR POS Sale Line Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }                
        field(15; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Line Type" = filter("GL Payment" | "Issue Voucher")) "G/L Account"."No."
            ELSE
            IF ("Line Type" = CONST("Item Category")) "Item Category".Code
            ELSE
            IF ("Line Type" = CONST("POS Payment")) "NPR POS Payment Method".Code WHERE("Block POS Payment" = const(false))
            ELSE
            IF ("Line Type" = CONST("Customer Deposit")) Customer."No."
            ELSE
            IF ("Line Type" = CONST(Item)) Item."No.";
            ValidateTableRelation = false;
        }
        field(20; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = IF ("Line Type" = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD("No."));
        }
        field(25; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(27; "Description 2"; Text[80])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
        }
        field(30; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));
        }
        field(35; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MaxValue = 99.999;
        }
        field(40; "Price Includes VAT"; Boolean)
        {
            Caption = 'Price Includes VAT';
            DataClassification = CustomerContent;
        }
        field(45; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = Currency;
        }
        field(50; "Unit Price"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
            Editable = true;
            MaxValue = 9999999;
        }
        field(55; Amount; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
            MaxValue = 1000000;
        }
        field(60; "Amount Including VAT"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount Including VAT';
            DataClassification = CustomerContent;
            MaxValue = 99999999;
        }
        field(65; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            TableRelation = "Customer Price Group";
        }
        field(100; "Discount Type"; Option)
        {
            Caption = 'Discount Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Period,Mixed,Multiple Unit,Salesperson Discount,Inventory,,Rounding,Combination,Customer';
            OptionMembers = " ",Campaign,Mix,Quantity,Manual,"BOM List",,Rounding,Combination,Customer;
        }
        field(105; "Discount %"; Decimal)
        {
            Caption = 'Discount %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 1;
            MaxValue = 100;
            MinValue = 0;
        }
        field(110; "Discount Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Discount';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(115; "Discount Code"; Code[20])
        {
            Caption = 'Discount Code';
            DataClassification = CustomerContent;
        }
        field(120; "Discount Authorised by"; Code[20])
        {
            Caption = 'Discount Authorised by';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser";
        }
        field(200; "Sale Date"; Date)
        {
            Caption = 'Sale Date';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
        }
        field(205; "Sale Type"; Option)
        {
            Caption = 'Sale Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Deposit,Out payment,Comment,Cancelled,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Deposit,"Out payment",Comment,Cancelled,"Open/Close";
            Description = 'This field has been "obsoleted" by removing all reference to it in Np Retail app';
        }
        field(210; "Sale Line No."; Integer)
        {
            Caption = 'Sale Line No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
        }
        field(215; "EFT Approved"; Boolean)
        {
            Caption = 'Electronic Funds Transfer Approved';
            DataClassification = CustomerContent;
        }
        field(220; "Line Retail ID"; Guid)
        {
            Caption = 'Line Retail ID';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Use systemID instead';
        }
    }

    keys
    {
        key(Key1; "Quote Entry No.", "Line No.")
        {
            MaintainSIFTIndex = false;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        If "EFT Approved" then begin
            Error(POSSavedSalesHasApprovedEFTError, FieldCaption("Quote Entry No."), "Quote Entry No.", FieldCaption("Line No."), "Line No.");
        end;
    end;

    var
        POSSavedSalesHasApprovedEFTError: label 'POS Saved Sales %1 ''%2'', %3 ''%4'' has an approved EFT Transaction and cannot be deleted. Either complete this POS Saved Sales or review to ignore temporarily';
}