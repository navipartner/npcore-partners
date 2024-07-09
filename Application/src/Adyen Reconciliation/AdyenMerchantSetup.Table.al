table 6150829 "NPR Adyen Merchant Setup"
{
    Access = Internal;

    Caption = 'Adyen Merchant Account Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Primary Key';
        }
        field(10; "Merchant Account"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Merchant Account';
            TableRelation = "NPR Adyen Merchant Account".Name;
        }
        field(20; "Deposit G/L Account"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Deposit G/L Account';
            TableRelation = "G/L Account";
        }
        field(30; "Fee G/L Account"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Fee G/L Account';
            TableRelation = "G/L Account";
        }
        field(40; "Markup G/L Account"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Markup G/L Account';
            TableRelation = "G/L Account";
        }
        field(50; "Other commissions G/L Account"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Other commissions G/L Account';
            TableRelation = "G/L Account";
        }
        field(60; "Invoice Deduction G/L Account"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Invoice Deduction G/L Account';
            TableRelation = "G/L Account";
        }
        field(65; "Merchant Payout Acc. Type"; Enum "Gen. Journal Account Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Merchant Payout Account Type';
            ValuesAllowed = "G/L Account", "Bank Account";
        }
        field(70; "Merchant Payout G/L Account"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Merchant Payout G/L Account';
            TableRelation = "G/L Account";
            ObsoleteState = Pending;
            ObsoleteTag = '2024-06-28';
            ObsoleteReason = 'Replaced with Merchant Payout Account No.';
        }
        field(75; "Merchant Payout Acc. No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Merchant Payout Account No.';
            TableRelation = if ("Merchant Payout Acc. Type" = const("G/L Account")) "G/L Account"
            else
            if ("Merchant Payout Acc. Type" = const("Bank Account")) "Bank Account";
        }
        field(80; "Chargeback Fees G/L Account"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Chargeback Fees G/L Account';
            TableRelation = "G/L Account";
        }
        field(85; "Acquirer Payout Acc. Type"; Enum "Gen. Journal Account Type")
        {
            DataClassification = CustomerContent;
            Caption = 'External Merchant Payout Account Type';
            ValuesAllowed = "G/L Account", "Bank Account";
        }
        field(86; "Acquirer Payout Acc. No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'External Merchant Payout Account No.';
            TableRelation = if ("Acquirer Payout Acc. Type" = const("G/L Account")) "G/L Account"
            else
            if ("Acquirer Payout Acc. Type" = const("Bank Account")) "Bank Account";
        }
        field(90; "Reconciled Payment Acc. Type"; Enum "Gen. Journal Account Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Reconciled Payment Account Type';
            ValuesAllowed = "G/L Account", "Bank Account";
        }
        field(100; "Reconciled Payment Acc. No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Reconciled Payment Account No.';
            TableRelation = if ("Reconciled Payment Acc. Type" = const("G/L Account")) "G/L Account"
            else
            if ("Reconciled Payment Acc. Type" = const("Bank Account")) "Bank Account";
        }
        field(110; "Advancement EC G/L Account"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Advancement External Commission G/L Account';
            TableRelation = "G/L Account";
        }
        field(120; "Refunded EC G/L Account"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Refunded External Commission G/L Account';
            TableRelation = "G/L Account";
        }
        field(130; "Settled EC G/L Account"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Settled External Commission G/L Account';
            TableRelation = "G/L Account";
        }
        field(135; "Missing Transaction Acc. Type"; Enum "Gen. Journal Account Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Missing Transaction Account Type';
            ValuesAllowed = "G/L Account", "Bank Account";
        }
        field(136; "Missing Transaction Acc. No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Missing Transaction Account No.';
            TableRelation = if ("Missing Transaction Acc. Type" = const("G/L Account")) "G/L Account"
            else
            if ("Missing Transaction Acc. Type" = const("Bank Account")) "Bank Account";
        }

        field(140; "Posting Source Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Posting Source Code';
            TableRelation = "Source Code";
        }
    }
    keys
    {
        key(PK; "Merchant Account")
        {
            Clustered = true;
        }
    }
}
