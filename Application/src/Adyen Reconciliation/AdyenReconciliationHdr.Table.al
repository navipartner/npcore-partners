table 6150788 "NPR Adyen Reconciliation Hdr"
{
    Access = Internal;

    Caption = 'Adyen Reconciliation Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
            NotBlank = true;
        }
        field(10; "Document Type"; Enum "NPR Adyen Report Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Type';
        }
        field(20; "Document Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Reconciliation Document Date';
        }
        field(25; "Posting Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Posting Date';

            trigger OnValidate()
            begin
                if "Posting Date" = 0D then
                    "Posting Date" := Today();
            end;
        }
        field(30; "Batch Number"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Batch Number';
        }
        field(40; "Opening Balance"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Batch Opening Balance (AAC)';
        }
        field(50; "Closing Balance"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Batch Closing Balance (AAC)';
        }
        field(60; "Acquirer Commission"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Acquirer Commission';
        }
        field(70; "Adyen Acc. Currency Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Adyen Account Currency Code';
            TableRelation = Currency.Code;
        }
        field(80; "Total Transactions Amount"; Decimal)
        {
            Caption = 'Total Transactions Amount (AAC)';
            FieldClass = FlowField;
            CalcFormula = sum("NPR Adyen Recon. Line"."Amount(AAC)" where("Document No." = field("Document No."),
                                                                                "Batch Number" = field("Batch Number"),
                                                                                "Transaction Type" = filter(Settled | SettledExternallyWithInfo)));
        }
        field(90; "Total Posted Amount"; Decimal)
        {
            Caption = 'Total Posted Amount (AAC)';
            FieldClass = FlowField;
            CalcFormula = sum("NPR Adyen Recon. Line"."Amount(AAC)" where("Document No." = field("Document No."),
                                                                                "Batch Number" = field("Batch Number"),
                                                                                Status = const(Posted)));
        }
        field(100; "Webhook Request ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Webhook Request ID';
            TableRelation = "NPR AF Rec. Webhook Request".ID;
        }
        field(110; Posted; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Posted';
        }
        field(120; "Merchant Account"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Merchant Account';
        }
    }
    keys
    {
        key(PK; "Document No.")
        {
            Clustered = true;
        }
        key(Key2; "Batch Number", "Merchant Account")
        {
        }
    }

    trigger OnDelete()
    var
        AdyenManagement: Codeunit "NPR Adyen Management";
    begin
        AdyenManagement.DeleteReconciliationLines("Document No.");
    end;
}
