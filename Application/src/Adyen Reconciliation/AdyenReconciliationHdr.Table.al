table 6150788 "NPR Adyen Reconciliation Hdr"
{
    Access = Internal;

    Caption = 'NP Pay Reconciliation Header';
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
        field(35; "Transactions Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Transactions Date';
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
            Caption = 'External Merchant Commission';
        }
        field(70; "Adyen Acc. Currency Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Acquirer Account Currency Code';
            TableRelation = Currency.Code;
        }
        field(80; "Total Transactions Amount"; Decimal)
        {
            Caption = 'Total Transactions Amount (AAC)';
            FieldClass = FlowField;
            CalcFormula = sum("NPR Adyen Recon. Line"."Amount(AAC)" where("Document No." = field("Document No."),
                                                                            "Batch Number" = field("Batch Number"),
                                                                            "Transaction Type" = filter(<> MerchantPayout | AcquirerPayout)));
        }
        field(90; "Total Posted Amount"; Decimal)
        {
            Caption = 'Total Posted Amount (AAC)';
            FieldClass = FlowField;
            CalcFormula = sum("NPR Adyen Recon. Line"."Amount(AAC)" where("Document No." = field("Document No."),
                                                                            "Batch Number" = field("Batch Number"),
                                                                            "Transaction Type" = filter(<> MerchantPayout | AcquirerPayout),
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

            ObsoleteState = Pending;
            ObsoleteTag = '2024-08-26';
            ObsoleteReason = 'Replaced with Status.';
        }
        field(120; "Merchant Account"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Merchant Account';
        }
        field(130; "Merchant Payout"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Merchant Payout';
        }
        field(140; Status; Enum "NPR Adyen Rec. Header Status")
        {
            DataClassification = CustomerContent;
            Caption = 'Status';
            InitValue = Unmatched;
        }
        field(150; "Failed Lines Exist"; Boolean)
        {
            Caption = 'Failed Lines Exist';
            DataClassification = CustomerContent;
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
        key(Key3; "Failed Lines Exist")
        {
        }
    }

    trigger OnDelete()
    var
        AdyenManagement: Codeunit "NPR Adyen Management";
        DocumentIsPostedLbl: Label 'Document %1 cannot be deleted because it has already been posted.';
        DocumentIsReconciledLbl: Label 'Document %1 cannot be deleted because it has already been reconciled.';
        DocumentIsPartiallyPostedLbl: Label 'The document %1 cannot be deleted because it is partially posted.\\You can try to "Recreate" the current document. The posted lines will remain intact.';
        DocumentIsPartiallyReconciledLbl: Label 'The document %1 cannot be deleted because it is partially reconciled.\\You can try to "Recreate" the current document. The posted lines will remain intact.';
        RecLine: Record "NPR Adyen Recon. Line";
    begin
        case Rec.Status of
            Rec.Status::Posted:
                Error(DocumentIsPostedLbl, Rec."Document No.");
            Rec.Status::Reconciled:
                Error(DocumentIsReconciledLbl, Rec."Document No.");
        end;

        RecLine.Reset();
        RecLine.SetRange("Document No.", Rec."Document No.");
        RecLine.SetFilter(Status, '%1|%2', RecLine.Status::Posted, RecLine.Status::"Posted Failed to Match");
        if not RecLine.IsEmpty() then
            Error(DocumentIsPartiallyPostedLbl, Rec."Document No.");
        RecLine.SetRange(Status, RecLine.Status::Reconciled);
        if not RecLine.IsEmpty() then
            Error(DocumentIsPartiallyReconciledLbl, Rec."Document No.");

        AdyenManagement.DeleteReconciliationLines("Document No.");
    end;
}
