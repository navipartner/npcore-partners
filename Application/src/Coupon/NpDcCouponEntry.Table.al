table 6151592 "NPR NpDc Coupon Entry"
{
    Caption = 'Coupon Entry';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpDc Coupon Entries";
    LookupPageID = "NPR NpDc Coupon Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; "Coupon No."; Code[20])
        {
            Caption = 'Coupon No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpDc Coupon";
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
        key(Key2; "Coupon No.")
        {
            SumIndexFields = Amount, Quantity;
        }
        key(Key3; "Document Type", "Document No.")
        {
        }
    }

    fieldgroups
    {
    }
}

