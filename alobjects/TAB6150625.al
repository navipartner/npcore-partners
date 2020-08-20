table 6150625 "POS Bin Entry"
{
    // NPR5.36/NPKNAV/20171003  CASE 282251 Transport NPR5.36 - 3 October 2017
    // NPR5.40/TSA /20180301 CASE 306858 Added POS Store Code and POS Unit No.
    // NPR5.40/TSA /20180301 CASE 306858 Added referece to pos payment line, unit and store fields
    // NPR5.40/TSA /20180301 CASE 306858 Added key Payment Bin No.,POS Unit No.,Payment Method Code
    // NPR5.43/TSA /20180604 CASE 311964 Added 4 Transfer Type, to be able to determine the directions of transfers.

    Caption = 'POS Bin Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(3; "Bin Checkpoint Entry No."; Integer)
        {
            Caption = 'Bin Checkpoint Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "POS Payment Bin Checkpoint";
        }
        field(5; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = CustomerContent;
        }
        field(8; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            DataClassification = CustomerContent;
            TableRelation = "POS Store";
        }
        field(9; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "POS Unit";
        }
        field(10; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Out-Payment,In-Payment,Checkpoint,Transfer to Bank,Adjustment,Difference,Transfer to Bin,Float,Bank Transfer (Out),Bank Transfer (In),Bin Transfer (Out),Bin Transfer (In)';
            OptionMembers = OUTPAYMENT,INPAYMENT,CHECKPOINT,BANK_TRANSFER,ADJUSTMENT,DIFFERENCE,BIN_TRANSFER,FLOAT,BANK_TRANSFER_OUT,BANK_TRANSFER_IN,BIN_TRANSFER_OUT,BIN_TRANSFER_IN;
        }
        field(20; "Payment Bin No."; Code[10])
        {
            Caption = 'Payment Bin No.';
            DataClassification = CustomerContent;
            TableRelation = "POS Payment Bin";
        }
        field(21; "Register No."; Code[10])
        {
            Caption = 'Register No.';
            DataClassification = CustomerContent;
            Description = 'This field should be dropped when new audit roll creates these entries';
            TableRelation = Register;
        }
        field(30; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "POS Payment Method";
        }
        field(31; "Payment Type Code"; Code[10])
        {
            Caption = 'Payment Type Code';
            DataClassification = CustomerContent;
            Description = 'This field should be dropped when new audit roll creates these entries';
            TableRelation = "Payment Type POS";
        }
        field(40; "Transaction Date"; Date)
        {
            Caption = 'Transaction Date';
            DataClassification = CustomerContent;
        }
        field(45; "Transaction Time"; Time)
        {
            Caption = 'Transaction Time';
            DataClassification = CustomerContent;
        }
        field(50; "Accounting Period Code"; Code[10])
        {
            Caption = 'Accounting Period Code';
            DataClassification = CustomerContent;
        }
        field(60; "Transaction Amount"; Decimal)
        {
            Caption = 'Transaction Amount';
            DataClassification = CustomerContent;
        }
        field(70; "Transaction Currency Code"; Code[10])
        {
            Caption = 'Transaction Currency Code';
            DataClassification = CustomerContent;
        }
        field(80; "Transaction Amount (LCY)"; Decimal)
        {
            Caption = 'Transaction Amount (LCY)';
            DataClassification = CustomerContent;
        }
        field(100; "External Transaction No."; Text[50])
        {
            Caption = 'External Transaction No.';
            DataClassification = CustomerContent;
        }
        field(110; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "POS Entry";
        }
        field(120; "POS Payment Line No."; Integer)
        {
            Caption = 'POS Payment Line No.';
            DataClassification = CustomerContent;
        }
        field(200; Comment; Text[50])
        {
            Caption = 'Comment';
            DataClassification = CustomerContent;
        }
        field(300; "Counting Status"; Option)
        {
            Caption = 'Counting Status';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Missing,Unexpected';
            OptionMembers = NA,MISSING,UNEXPECTED;
        }
        field(310; "Counted Amount"; Decimal)
        {
            Caption = 'Counted Amount';
            DataClassification = CustomerContent;
        }
        field(320; "Counted Qty"; Decimal)
        {
            Caption = 'Counted Qty';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Payment Bin No.", "POS Unit No.", "Payment Method Code")
        {
        }
    }

    fieldgroups
    {
    }
}

