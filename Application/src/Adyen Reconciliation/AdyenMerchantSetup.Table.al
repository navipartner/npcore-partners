table 6150829 "NPR Adyen Merchant Setup"
{
    Access = Internal;

    Caption = 'Adyen Merchant Setup';
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
        field(70; "Merchant Payout G/L Account"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Merchant Payout G/L Account';
            TableRelation = "G/L Account";
        }
        field(80; "Chargeback Fees G/L Account"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Chargeback Fees G/L Account';
            TableRelation = "G/L Account";
        }
        field(90; "Reconciled Payment Acc. Type"; Enum "Gen. Journal Account Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Reconciled Payment Acc. Type';
            ValuesAllowed = "G/L Account", "Bank Account";
        }
        field(100; "Reconciled Payment Acc. No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Reconciled Payment Acc. No.';
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
