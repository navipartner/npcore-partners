table 6150789 "NPR Adyen Reconciliation Line"
{
    Access = Internal;

    Caption = 'NP Pay Reconciliation Line';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = '2024-06-28';
    ObsoleteReason = 'Replaced with NPR Adyen Recon. Line.';

    fields
    {
        field(1; "Document No."; Code[20])
        {
            NotBlank = true;
            Caption = 'Document No.';
            TableRelation = "NPR Adyen Reconciliation Hdr"."Document No.";
            DataClassification = CustomerContent;
        }
        field(10; "Line No."; Integer)
        {
            NotBlank = true;
            Caption = 'Document Line No.';
            DataClassification = CustomerContent;
        }
        field(20; "Merchant Order Reference"; Text[40])
        {
            NotBlank = true;
            Caption = 'Merchant Order Reference';
            DataClassification = CustomerContent;
        }
        field(30; "Batch Number"; Integer)
        {
            Caption = 'Batch Number';
            DataClassification = CustomerContent;
        }

        field(40; "Transaction Date"; DateTime)
        {
            Caption = 'Transaction Date';
            DataClassification = CustomerContent;
        }
        field(50; "Company Account"; Text[80])
        {
            Caption = 'Company Account';
            DataClassification = CustomerContent;
        }
        field(60; "Merchant Account"; Text[80])
        {
            Caption = 'Merchant Account';
            DataClassification = CustomerContent;
        }
        field(70; "PSP Reference"; Code[16])
        {
            Caption = 'PSP Reference';
            DataClassification = CustomerContent;
        }
        field(80; "Gross Credit"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            Caption = 'Gross Credit';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                "Amount (TCY)" := "Gross Credit" - "Gross Debit";
            end;
        }
        field(90; "Gross Debit"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            Caption = 'Gross Debit';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                "Amount (TCY)" := "Gross Credit" - "Gross Debit";
            end;
        }
        field(100; "Exchange Rate"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            Caption = 'Exchange Rate';
            DataClassification = CustomerContent;
        }
        field(110; "Amount (TCY)"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            Caption = 'Amount (TCY)';
            DataClassification = CustomerContent;
        }
        field(120; "Transaction Currency Code"; Code[10])
        {
            Caption = 'Transaction Currency Code';
            TableRelation = Currency.Code;
            DataClassification = CustomerContent;
        }
        field(130; "Net Credit"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            Caption = 'Net Credit';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Amount(AAC)" := "Net Credit" - "Net Debit";
            end;
        }
        field(140; "Net Debit"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            Caption = 'Net Debit';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Amount(AAC)" := "Net Credit" - "Net Debit";
            end;
        }
        field(150; "Amount(AAC)"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            Caption = 'Amount (AAC)';
            DataClassification = CustomerContent;
        }
        field(160; "Adyen Acc. Currency Code"; Code[10])
        {
            Caption = 'Acquirer Account Currency Code';
            TableRelation = Currency.Code;
            DataClassification = CustomerContent;
        }
        field(170; "Markup (NC)"; Decimal)
        {
            Caption = 'Markup (NC)';
            DataClassification = CustomerContent;
        }
        field(180; "Realized Gains or Losses"; Decimal)
        {
            Caption = 'Realized Gains or Losses';
            DataClassification = CustomerContent;
        }
        field(190; "Transaction Type"; Enum "NPR Adyen Rec. Trans. Type")
        {
            Caption = 'Transaction Type';
            DataClassification = CustomerContent;
        }
        field(200; "Merchant Reference"; Code[80])
        {
            Caption = 'Merchant Reference';
            DataClassification = CustomerContent;
        }
        field(210; "Modification Reference"; Text[256])
        {
            Caption = 'Modification Reference';
            DataClassification = CustomerContent;
        }
        field(220; "Commission (NC)"; Decimal)
        {
            Caption = 'Commission (NC)';
            DataClassification = CustomerContent;
        }
        field(230; "Scheme Fees (NC)"; Decimal)
        {
            Caption = 'Scheme Fees (NC)';
            DataClassification = CustomerContent;
        }
        field(240; "Intercharge (NC)"; Decimal)
        {
            Caption = 'Intercharge (NC)';
            DataClassification = CustomerContent;
        }
        field(250; "Payment Fees (NC)"; Decimal)
        {
            Caption = 'Payment Fees (NC)';
            DataClassification = CustomerContent;
        }
        field(260; "Other Commissions (NC)"; Decimal)
        {
            Caption = 'Other Commissions (NC)';
            DataClassification = CustomerContent;
        }
        field(270; "Matching Table Name"; Enum "NPR Adyen Trans. Rec. Table")
        {
            Caption = 'Matching Table Name';
            DataClassification = CustomerContent;
        }
        field(280; "Matching Entry System ID"; Guid)
        {
            Caption = 'Matching Entry System ID';
            DataClassification = CustomerContent;
            TableRelation =
                if ("Matching Table Name" = const("EFT Transaction")) "NPR EFT Transaction Request".SystemId else
            if ("Matching Table Name" = const("Magento Payment Line")) "NPR Magento Payment Line".SystemId else
            if ("Matching Table Name" = const("G/L Entry")) "G/L Entry".SystemId;
        }
        field(290; Status; Enum "NPR Adyen Rec. Line Status")
        {
            InitValue = " ";
            DataClassification = CustomerContent;
        }
        field(300; "Webhook Request ID"; Integer)
        {
            Caption = 'Webhook Request ID';
            DataClassification = CustomerContent;
            TableRelation = "NPR AF Rec. Webhook Request".ID;
        }
    }
    keys
    {
        key(Key1; "Document No.", "Line No.", "Merchant Order Reference", "Batch Number")
        {
            Clustered = true;
        }
        key(Key2; "Batch Number", "Merchant Account")
        {
        }
        key(Key3; "PSP Reference")
        {
        }
    }

    trigger OnInsert()
    begin
        if ("Amount(AAC)" = 0) and ("Transaction Currency Code" = "Adyen Acc. Currency Code") then
            "Amount(AAC)" := "Amount (TCY)";
    end;

    procedure GetCurrencyCode(): Code[10]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if GeneralLedgerSetup.Get() then
            exit(GeneralLedgerSetup."LCY Code");
        exit('');
    end;
}
