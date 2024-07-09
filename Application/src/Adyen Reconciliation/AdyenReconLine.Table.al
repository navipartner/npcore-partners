table 6150874 "NPR Adyen Recon. Line"
{
    Access = Internal;

    Caption = 'Adyen Reconciliation Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document No."; Code[20])
        {
            NotBlank = true;
            Caption = 'Document No.';
            TableRelation = "NPR Adyen Reconciliation Hdr"."Document No.";
            DataClassification = CustomerContent;
        }
        field(5; "Posting No."; Code[20])
        {
            Caption = 'Posting No.';
            DataClassification = CustomerContent;
        }
        field(6; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Posting Date" = 0D then
                    "Posting Date" := Today();
            end;
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
            AutoFormatType = 1;
            Caption = 'Exchange Rate';
            DataClassification = CustomerContent;
        }
        field(110; "Amount (TCY)"; Decimal)
        {
            AutoFormatExpression = "Transaction Currency Code";
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
            AutoFormatType = 1;
            Caption = 'Net Credit';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Amount(AAC)" := ("Net Credit" - "Net Debit") + "Payment Fees (NC)";
            end;
        }
        field(140; "Net Debit"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Net Debit';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Amount(AAC)" := ("Net Credit" - "Net Debit") + "Payment Fees (NC)";
            end;
        }
        field(150; "Amount(AAC)"; Decimal)
        {
            AutoFormatExpression = "Adyen Acc. Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount (AAC)';
            DataClassification = CustomerContent;
        }
        field(160; "Adyen Acc. Currency Code"; Code[10])
        {
            Caption = 'Adyen Account Currency Code';
            TableRelation = Currency.Code;
            DataClassification = CustomerContent;
        }
        field(170; "Markup (NC)"; Decimal)
        {
            Caption = 'Markup (AAC)';
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
            Caption = 'Commission (AAC)';
            DataClassification = CustomerContent;
        }
        field(230; "Scheme Fees (NC)"; Decimal)
        {
            Caption = 'Scheme Fees (AAC)';
            DataClassification = CustomerContent;
        }
        field(240; "Intercharge (NC)"; Decimal)
        {
            Caption = 'Intercharge (AAC)';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2024-06-28';
            ObsoleteReason = 'Replaced with "Interchange (NC)"';
        }
        field(245; "Interchange (NC)"; Decimal)
        {
            Caption = 'Interchange (AAC)';
            DataClassification = CustomerContent;
        }
        field(250; "Payment Fees (NC)"; Decimal)
        {
            Caption = 'Payment Fees (AAC)';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Amount(AAC)" := ("Net Credit" - "Net Debit") + "Payment Fees (NC)";
            end;
        }
        field(260; "Other Commissions (NC)"; Decimal)
        {
            Caption = 'Other Commissions (AAC)';
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
        field(310; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
            DataClassification = CustomerContent;
        }
        field(320; "Markup (LCY)"; Decimal)
        {
            Caption = 'Markup (LCY)';
            DataClassification = CustomerContent;
        }
        field(330; "Payment Fees (LCY)"; Decimal)
        {
            Caption = 'Payment Fees (LCY)';
            DataClassification = CustomerContent;
        }
        field(340; "Commission (LCY)"; Decimal)
        {
            Caption = 'Commission (LCY)';
            DataClassification = CustomerContent;
        }
        field(350; "Scheme Fees (LCY)"; Decimal)
        {
            Caption = 'Scheme Fees (LCY)';
            DataClassification = CustomerContent;
        }
        field(360; "Interchange (LCY)"; Decimal)
        {
            Caption = 'Interchange (LCY)';
            DataClassification = CustomerContent;
        }
        field(370; "Other Commissions (LCY)"; Decimal)
        {
            Caption = 'Other Commissions (LCY)';
            DataClassification = CustomerContent;
        }
        field(380; "Posting allowed"; Boolean)
        {
            Caption = 'Posting allowed';
            DataClassification = CustomerContent;
            InitValue = true;
        }
    }
    keys
    {
        key(Key1; "Document No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "PSP Reference") { }
        key(Key3; "Document No.", Status) { }
    }

    trigger OnInsert()
    begin
        if ("Amount(AAC)" = 0) and ("Transaction Currency Code" = "Adyen Acc. Currency Code") then
            "Amount(AAC)" := "Amount (TCY)";
    end;
}