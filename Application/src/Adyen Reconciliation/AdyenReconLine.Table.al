table 6150874 "NPR Adyen Recon. Line"
{
    Access = Internal;

    Caption = 'NP Pay Reconciliation Line';
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
            Caption = 'Psp Reference';
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
            Caption = 'Acquirer Account Currency Code';
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
        field(205; "Payment Method"; Text[30])
        {
            Caption = 'Payment Method';
            DataClassification = CustomerContent;
        }
        field(210; "Modification Reference"; Text[256])
        {
            Caption = 'Modification Reference';
            DataClassification = CustomerContent;
        }
        field(215; "Payment Method Variant"; Text[50])
        {
            Caption = 'Payment Method Variant';
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
            ObsoleteState = Removed;
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
            if ("Matching Table Name" = const("Subscription Payment")) "NPR MM Subscr. Payment Request".SystemId else
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
        field(390; "Modif. Merchant Reference"; Text[80])
        {
            Caption = 'Modification Merchant Reference';
            DataClassification = CustomerContent;
        }
        field(400; "Authorised Date"; DateTime)
        {
            Caption = 'Authorised Date';
            DataClassification = CustomerContent;
        }
        field(410; "Authorised Date TimeZone"; Code[10])
        {
            Caption = 'Authorised Date TimeZone';
            DataClassification = CustomerContent;
        }
        field(420; "Balance Currency Code"; Code[10])
        {
            Caption = 'Balance Currency Code';
            DataClassification = CustomerContent;
        }
        field(430; "Net Debit (BC)"; Decimal)
        {
            Caption = 'Net Debit (BC)';
            DataClassification = CustomerContent;
        }
        field(440; "Net Credit (BC)"; Decimal)
        {
            Caption = 'Net Credit (BC)';
            DataClassification = CustomerContent;
        }
        field(450; "DCC Markup (NC)"; Decimal)
        {
            Caption = 'DCC Markup (NC)';
            DataClassification = CustomerContent;
        }
        field(460; "Global Card Brand"; Text[100])
        {
            Caption = 'Global Card Brand';
            DataClassification = CustomerContent;
        }
        field(470; "Gratuity Amount"; Decimal)
        {
            Caption = 'Gratuity Amount';
            DataClassification = CustomerContent;
        }
        field(480; "Surcharge Amount"; Decimal)
        {
            Caption = 'Surcharge Amount';
            DataClassification = CustomerContent;
        }
        field(490; "Advanced (NC)"; Decimal)
        {
            Caption = 'Advanced (NC)';
            DataClassification = CustomerContent;
        }
        field(500; "Advancement Code"; Text[50])
        {
            Caption = 'Advancement Code';
            DataClassification = CustomerContent;
        }
        field(510; "Advancement Batch"; Text[50])
        {
            Caption = 'Advancement Batch';
            DataClassification = CustomerContent;
        }
        field(520; "Booking Type"; Code[30])
        {
            Caption = 'Booking Type';
            DataClassification = CustomerContent;
        }
        field(530; Acquirer; Text[100])
        {
            Caption = 'Acquirer';
            DataClassification = CustomerContent;
        }
        field(540; "Split Settlement"; Text[256])
        {
            Caption = 'Split Settlement';
            DataClassification = CustomerContent;
        }
        field(550; "Split Payment Data"; Text[256])
        {
            Caption = 'Split Payment Data';
            DataClassification = CustomerContent;
        }
        field(560; "Funds Destination"; Text[256])
        {
            Caption = 'Funds Destination';
            DataClassification = CustomerContent;
        }
        field(570; "Balance Platform Debit"; Decimal)
        {
            Caption = 'Balance Platform Debit';
            DataClassification = CustomerContent;
        }
        field(580; "Balance Platform Credit"; Decimal)
        {
            Caption = 'Balance Platform Credit';
            DataClassification = CustomerContent;
        }
        field(590; "Booking Date"; DateTime)
        {
            Caption = 'Booking Date';
            DataClassification = CustomerContent;
        }
        field(600; "Booking Date TimeZone"; Code[10])
        {
            Caption = 'Booking Date TimeZone';
            DataClassification = CustomerContent;
        }
        field(610; "Booking Date (AMS)"; DateTime)
        {
            Caption = 'Booking Date (AMS)';
            DataClassification = CustomerContent;
        }
        field(620; AdditionalType; Text[40])
        {
            Caption = 'AdditionalType';
            DataClassification = CustomerContent;
        }
        field(630; Installments; Text[30])
        {
            Caption = 'Installments';
            DataClassification = CustomerContent;
        }
        field(640; "Issuer Country"; Code[2])
        {
            Caption = 'Issuer Country';
            DataClassification = CustomerContent;
        }
        field(650; "Shopper Country"; Code[2])
        {
            Caption = 'Shopper Country';
            DataClassification = CustomerContent;
        }
        field(660; "Clearing Network"; Text[100])
        {
            Caption = 'Clearing Network';
            DataClassification = CustomerContent;
        }
        field(670; "Terminal ID"; Text[50])
        {
            Caption = 'Terminal ID';
            DataClassification = CustomerContent;
        }
        field(680; "Tender Reference"; Text[30])
        {
            Caption = 'Tender Reference';
            DataClassification = CustomerContent;
        }
        field(690; Metadata; Text[2048])
        {
            Caption = 'Metadata';
            DataClassification = CustomerContent;
        }
        field(700; "Pos Transaction Date"; DateTime)
        {
            Caption = 'Pos Transaction Date';
            DataClassification = CustomerContent;
        }
        field(710; "Pos Transaction Date TimeZone"; Code[10])
        {
            Caption = 'Pos Transaction Date TimeZone';
            DataClassification = CustomerContent;
        }
        field(720; Store; Text[100])
        {
            Caption = 'Store';
            DataClassification = CustomerContent;
        }
        field(730; "Dispute Reference"; Code[16])
        {
            Caption = 'Dispute Reference';
            DataClassification = CustomerContent;
        }
        field(740; "Register Booking Type"; Text[50])
        {
            Caption = 'Register Booking Type';
            DataClassification = CustomerContent;
        }
        field(750; ARN; Code[50])
        {
            Caption = 'ARN';
            DataClassification = CustomerContent;
        }
        field(760; "Shopper Reference"; Text[100])
        {
            Caption = 'Shopper Reference';
            DataClassification = CustomerContent;
        }
        field(770; "Payment Transaction Group"; Text[100])
        {
            Caption = 'Payment Transaction Group';
            DataClassification = CustomerContent;
        }
        field(780; "Settlement Flow"; Text[100])
        {
            Caption = 'Settlement Flow';
            DataClassification = CustomerContent;
        }
        field(790; "Authorisation Code"; Text[10])
        {
            Caption = 'Authorisation Code';
            DataClassification = CustomerContent;
        }
        field(800; "Card Number"; Text[16])
        {
            Caption = 'Card Number';
            DataClassification = CustomerContent;
        }
        field(810; MID; Code[50])
        {
            Caption = 'MID';
            DataClassification = CustomerContent;
        }
        field(820; "Acquirer Reference"; Text[80])
        {
            Caption = 'Acquirer Reference';
            DataClassification = CustomerContent;
        }
        field(830; "Store Code"; Text[100])
        {
            Caption = 'Store Code';
            DataClassification = CustomerContent;
        }
        field(840; "Acquirer Auth Code"; Text[100])
        {
            Caption = 'Acquirer Auth Code';
            DataClassification = CustomerContent;
        }
        field(850; "Card BIN"; Code[10])
        {
            Caption = 'Card BIN';
            DataClassification = CustomerContent;
        }
        field(860; "Card Number Summary"; Code[10])
        {
            Caption = 'Card Number Summary';
            DataClassification = CustomerContent;
        }
        field(870; "Submerchant Identifier"; Text[100])
        {
            Caption = 'Submerchant Identifier';
            DataClassification = CustomerContent;
        }
        field(880; "Transaction Posted"; Boolean)
        {
            Caption = 'Transaction Posted';
            FieldClass = FlowField;
            CalcFormula = exist("NPR Adyen Recons.Line Relation" where("Document No." = field("Document No."),
                                                                    "Document Line No." = field("Line No."),
                                                                    Reversed = const(false),
                                                                    "Amount Type" = const(Transaction)));
        }
        field(890; "Markup Posted"; Boolean)
        {
            Caption = 'Markup Posted';
            FieldClass = FlowField;
            CalcFormula = exist("NPR Adyen Recons.Line Relation" where("Document No." = field("Document No."),
                                                                    "Document Line No." = field("Line No."),
                                                                    Reversed = const(false),
                                                                    "Amount Type" = const(Markup)));
        }
        field(900; "Commissions Posted"; Boolean)
        {
            Caption = 'Commissions Posted';
            FieldClass = FlowField;
            CalcFormula = exist("NPR Adyen Recons.Line Relation" where("Document No." = field("Document No."),
                                                                    "Document Line No." = field("Line No."),
                                                                    Reversed = const(false),
                                                                    "Amount Type" = const("Other commissions")));
        }
        field(910; "Realized Gains Posted"; Boolean)
        {
            Caption = 'Realized Gains Posted';
            FieldClass = FlowField;
            CalcFormula = exist("NPR Adyen Recons.Line Relation" where("Document No." = field("Document No."),
                                                                    "Document Line No." = field("Line No."),
                                                                    Reversed = const(false),
                                                                    "Amount Type" = const("Realized Gains")));
        }
        field(920; "Realized Losses Posted"; Boolean)
        {
            Caption = 'Realized Losses Posted';
            FieldClass = FlowField;
            CalcFormula = exist("NPR Adyen Recons.Line Relation" where("Document No." = field("Document No."),
                                                                    "Document Line No." = field("Line No."),
                                                                    Reversed = const(false),
                                                                    "Amount Type" = const("Realized Losses")));
        }
        field(930; "Matched Manually"; Boolean)
        {
            Caption = 'Matched Manually';
            DataClassification = CustomerContent;
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
        key(Key4; "Matching Table Name", "Matching Entry System ID", "Transaction Type") { }
    }

    trigger OnInsert()
    begin
        if ("Amount(AAC)" = 0) and ("Transaction Currency Code" = "Adyen Acc. Currency Code") then
            "Amount(AAC)" := "Amount (TCY)";
    end;

    trigger OnDelete()
    var
        _AdyenTransactionMatching: Codeunit "NPR Adyen Trans. Matching";
    begin
        if Rec.Status in [Rec.Status::Matched, Rec.Status::"Matched Manually", Rec.Status::Reconciled] then
            _AdyenTransactionMatching.RevertPaymentReconciliation(Rec, Rec."Matching Table Name");
    end;

    internal procedure IsPosted(RecalcFlowFields: Boolean): Boolean
    begin
        if RecalcFlowFields then
            CalcFields("Transaction Posted", "Markup Posted", "Commissions Posted", "Realized Gains Posted", "Realized Losses Posted");
        exit("Transaction Posted" and "Markup Posted" and "Commissions Posted");
    end;
}