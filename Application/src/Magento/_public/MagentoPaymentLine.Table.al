table 6151409 "NPR Magento Payment Line"
{
    Caption = 'Payment Line';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Magento Payment Line List";
    LookupPageID = "NPR Magento Payment Line List";

    fields
    {
        field(1; "Document Table No."; Integer)
        {
            Caption = 'Document Table No.';
            DataClassification = CustomerContent;
        }
        field(5; "Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(10; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(15; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(16; "Payment Type"; enum "NPR Magento Payment Type")
        {
            Caption = 'Payment Type';
            DataClassification = CustomerContent;
            InitValue = "Payment Method";
        }
        field(20; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(24; "Account Type"; Enum "Payment Balance Account Type")
        {
            Caption = 'Account Type';
            DataClassification = CustomerContent;
        }
        field(25; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Account Type" = CONST("G/L Account")) "G/L Account"
            ELSE
            IF ("Account Type" = CONST("Bank Account")) "Bank Account";
        }
        field(30; "No."; Code[50])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(35; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(37; "Allow Adjust Amount"; Boolean)
        {
            Caption = 'Allow Adjust Amount';
            DataClassification = CustomerContent;
        }
        field(40; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(50; "Source Table No."; Integer)
        {
            Caption = 'Source Table No.';
            DataClassification = CustomerContent;
        }
        field(55; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            DataClassification = CustomerContent;
        }
        field(60; Posted; Boolean)
        {
            Caption = 'Posted';
            DataClassification = CustomerContent;
        }
        field(70; "External Reference No."; Code[50])
        {
            Caption = 'External Reference No.';
            DataClassification = CustomerContent;
        }
        field(80; "Payment Gateway Shopper Ref."; Text[50])
        {
            Caption = 'Payment Gateway Shopper Ref.';
            DataClassification = CustomerContent;
        }
        field(100; "Payment Gateway Code"; Code[10])
        {
            Caption = 'Payment Gateway Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Payment Gateway";
        }
        field(105; "Date Captured"; Date)
        {
            Caption = 'Date Captured';
            DataClassification = CustomerContent;
        }
        field(110; "Date Refunded"; Date)
        {
            Caption = 'Date Refunded';
            DataClassification = CustomerContent;
        }
        field(200; "Last Amount"; Decimal)
        {
            Caption = 'Last Amount';
            DataClassification = CustomerContent;
        }
        field(205; "Last Posting No."; Code[20])
        {
            Caption = 'Last Posting No.';
            DataClassification = CustomerContent;
        }
        field(210; "Charge ID"; Code[100])
        {
            Caption = 'Charge ID';
            DataClassification = CustomerContent;
            Description = 'MAG3.00';
        }
        field(220; "Transaction ID"; Text[250])
        {
            Caption = 'Transaction ID';
            DataClassification = CustomerContent;
        }
        field(230; Reconciled; Boolean)
        {
            Caption = 'Reconciled';
            DataClassification = CustomerContent;
        }
        field(240; "Reconciliation Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Reconciliation Date';
        }
        field(250; Reversed; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Reversed';
        }
        field(260; "Reversed by Entry System ID"; Guid)
        {
            Caption = 'Reversed by Entry System ID';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Payment Line".SystemId;
        }
        field(270; "Created by Reconciliation"; Boolean)
        {
            Caption = 'Created by Reconciliation';
            DataClassification = CustomerContent;
        }
        field(280; "Created by Recon. Posting No."; Code[20])
        {
            Caption = 'Created by Reconciliation Posting No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR Adyen Recon. Line"."Posting No.";
        }
        field(290; "Pay by Link URL"; Text[100])
        {
            Caption = 'Pay by Link URL';
            DataClassification = CustomerContent;
        }
        field(300; "Payment ID"; Code[20])
        {
            Caption = 'Payment ID';
            DataClassification = CustomerContent;
        }
        field(310; "Requested Amount"; Decimal)
        {
            Caption = 'Requested Amount';
            DataClassification = CustomerContent;
        }
        field(320; "Date Canceled"; Date)
        {
            Caption = 'Date Canceled';
            DataClassification = CustomerContent;
        }
        field(330; "Date Authorized"; Date)
        {
            Caption = 'Date Authorized';
            DataClassification = CustomerContent;
        }
        field(340; "Manually Canceled Link"; Boolean)
        {
            Caption = 'Manually Canceled Link';
            DataClassification = CustomerContent;
        }
        field(350; "Expires At"; DateTime)
        {
            Caption = 'Expires At';
            DataClassification = CustomerContent;
        }
        field(360; "Posting Error"; Boolean)
        {
            Caption = 'Posting Error';
            DataClassification = CustomerContent;
        }
        field(370; "Skip Posting"; Boolean)
        {
            Caption = 'Skip Posting';
            DataClassification = CustomerContent;
        }
        field(380; "Try Posting Count"; Integer)
        {
            Caption = 'Try Posting Count';
            DataClassification = CustomerContent;
        }
        field(390; "Payment Token"; Text[64])
        {
            Caption = 'Payment Token';
            DataClassification = CustomerContent;
        }
        field(400; "Payment Instrument Type"; Text[30])
        {
            Caption = 'Payment Instrument Type';
            DataClassification = CustomerContent;
        }
        field(410; "Card Summary"; Text[4])
        {
            Caption = 'Card Summary';
            DataClassification = CustomerContent;
        }
        field(420; Brand; Text[30])
        {
            Caption = 'Brand';
            DataClassification = CustomerContent;
        }
        field(430; "Expiry Date Text"; Text[50])
        {
            Caption = 'Expiry Date Text';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Document Table No.", "Document Type", "Document No.", "Line No.")
        {
        }
        key(Key2; "Payment Type", "No.", Amount)
        {
        }
    }

    var
        InvoiceLbl: Label 'Invoice';
        CreditMemoLbl: Label 'Credit Memo';
        DocumentNoLbl: Label 'Document No. %1', Comment = '%1 = document no';

    internal procedure ToRequest(var Request: Record "NPR PG Payment Request")
    var
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        if (Rec."Transaction ID" <> '') then
            Request."Transaction ID" := Rec."Transaction ID"
        else
            Request."Transaction ID" := Rec."No.";
        Request."Request Amount" := Rec.Amount;
        Request."Payment Gateway Code" := Rec."Payment Gateway Code";
        Request."Document Table No." := Rec."Document Table No.";
        Request."Payment Line System Id" := Rec.SystemId;

        case Rec."Document Table No." of
            Database::"Sales Header":
                begin
                    // We wrap in an if statement here because the Sales Header might be
                    // deleted if we are about to cancel the request.
                    if (SalesHeader.Get(Rec."Document Type", Rec."Document No.")) then begin
                        Request."Document System Id" := SalesHeader.SystemId;
                        Request."Request Description" := Format(SalesHeader."Document Type") + ' ' + SalesHeader."No.";
                    end else
                        if (Rec."Document No." <> '') then
                            Request."Request Description" := CopyStr(StrSubstNo(DocumentNoLbl, Rec."Document No."), 1, MaxStrLen(Request."Request Description"));
                end;
            Database::"Sales Invoice Header":
                begin
                    SalesInvHeader.Get(Rec."Document No.");
                    Request."Document System Id" := SalesInvHeader.SystemId;
                    Request."Request Description" := InvoiceLbl + ' ' + SalesInvHeader."No.";
                end;
            Database::"Sales Cr.Memo Header":
                begin
                    SalesCrMemoHeader.Get(Rec."Document No.");
                    Request."Document System Id" := SalesCrMemoHeader.SystemId;
                    Request."Request Description" := CreditMemoLbl + ' ' + SalesCrMemoHeader."No.";
                end;
            else
                if (Rec."Document No." <> '') then
                    Request."Request Description" := CopyStr(StrSubstNo(DocumentNoLbl, Rec."Document No."), 1, MaxStrLen(Request."Request Description"));
        end;

        Request."Last Operation Id" := Rec."Charge ID";
    end;
}
