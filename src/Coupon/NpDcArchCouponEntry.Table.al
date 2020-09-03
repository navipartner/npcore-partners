table 6151598 "NPR NpDc Arch.Coupon Entry"
{
    // NPR5.34/MHA /20170720  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon
    // NPR5.37/MHA /20171012  CASE 293232 Object renamed from "NpDc Posted Coupon Entry" to "NpDc Arch. Coupon Entry" and updated OptionString of Field 10 "Entry Type"
    // NPR5.51/MHA /20190724  CASE 343352 Added field 70 "Document Type" and changed field 55 "Sales Ticket No." to "Document No."
    // NPR5.52/MHA /20191021  CASE 343352 Added Caption to field 70 "Document Type"

    Caption = 'Archived Coupon Entry';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpDc Arch.Coupon Entries";
    LookupPageID = "NPR NpDc Arch.Coupon Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; "Arch. Coupon No."; Code[20])
        {
            Caption = 'Arch. Coupon No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.37';
            TableRelation = "NPR NpDc Arch. Coupon";
        }
        field(10; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.37';
            OptionCaption = ',Issue Coupon,Discount Application,Manual Archive';
            OptionMembers = ,"Issue Coupon","Discount Application","Manual Archive";
        }
        field(15; "Coupon Type"; Code[20])
        {
            Caption = 'Coupon Type';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpDc Coupon Type";
        }
        field(17; Positive; Boolean)
        {
            Caption = 'Positive';
            DataClassification = CustomerContent;
        }
        field(20; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(25; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(30; Open; Boolean)
        {
            Caption = 'Open';
            DataClassification = CustomerContent;
        }
        field(35; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(40; "Remaining Quantity"; Decimal)
        {
            Caption = 'Remaining Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(45; "Amount per Qty."; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount per Qty.';
            DataClassification = CustomerContent;
        }
        field(50; "Register No."; Code[10])
        {
            Caption = 'Register No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR Register"."Register No.";
        }
        field(55; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
            TableRelation = IF ("Document Type" = CONST("POS Entry")) "NPR POS Entry"."Document No." WHERE("POS Unit No." = FIELD("Register No."))
            ELSE
            IF ("Document Type" = CONST("Sales Order")) "Sales Header"."No." WHERE("Document Type" = CONST(Order))
            ELSE
            IF ("Document Type" = CONST("Sales Invoice")) "Sales Header"."No." WHERE("Document Type" = CONST(Invoice))
            ELSE
            IF ("Document Type" = CONST("Posted Sales Invoice")) "Sales Invoice Header"
            ELSE
            IF ("Document Type" = CONST("Sales Return Order")) "Sales Header"."No." WHERE("Document Type" = CONST("Return Order"))
            ELSE
            IF ("Document Type" = CONST("Sales Credit Memo")) "Sales Header"."No." WHERE("Document Type" = CONST("Credit Memo"))
            ELSE
            IF ("Document Type" = CONST("Posted Sales Credit Memo")) "Sales Cr.Memo Header";
        }
        field(65; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(70; "Closed by Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Closed by Entry No.';
            DataClassification = CustomerContent;
        }
        field(75; "Document Type"; Option)
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
            OptionCaption = ' ,POS Entry,Sales Order,Sales Invoice,Posted Sales Invoice,Sales Return Order,Sales Credit Memo,Posted Sales Credit Memo';
            OptionMembers = " ","POS Entry","Sales Order","Sales Invoice","Posted Sales Invoice","Sales Return Order","Sales Credit Memo","Posted Sales Credit Memo";
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Arch. Coupon No.")
        {
            SumIndexFields = Amount, Quantity;
        }
    }

    fieldgroups
    {
    }
}

