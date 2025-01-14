table 6150923 "NPR MM Subscr. Request"
{
    Access = Internal;
    Caption = 'Subscription Request';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR MM Subscr. Requests";
    LookupPageId = "NPR MM Subscr. Requests";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(10; Type; Enum "NPR MM Subscr. Request Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(20; Status; Enum "NPR MM Subscr. Request Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if Rec.Status <> xRec.Status then
                    Rec.Validate("Processing Status", Rec."Processing Status"::Pending);

                Modify();
                UpdateSubscriptionPaymentRequestStatus();
            end;
        }
        field(30; "Processing Status"; ENUM "NPR MM Subs Req Proc Status")
        {
            Caption = 'Processing Status';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if Rec."Processing Status" <> xRec."Processing Status" then
                    "Processing Status Change Date" := Today;

            end;
        }
        field(40; "Subscription Entry No."; Integer)
        {
            Caption = 'Subscription Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Subscription"."Entry No.";
        }
        field(50; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(55; "Membership Code"; Code[20])
        {
            Caption = 'Membership Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership Setup".Code;
        }
        field(60; "New Valid From Date"; Date)
        {
            Caption = 'New Valid From Date';
            DataClassification = CustomerContent;
        }
        field(70; "New Valid Until Date"; Date)
        {
            Caption = 'New Valid Until Date';
            DataClassification = CustomerContent;
        }
        field(80; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = "Currency Code";
        }
        field(90; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
        }
        field(100; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";
        }
        field(110; Posted; Boolean)
        {
            Caption = 'Posted';
            DataClassification = CustomerContent;
        }
        field(115; "Posted M/ship Ledg. Entry No."; Integer)
        {
            Caption = 'Posted M/ship Ledg. Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership Entry"."Entry No.";
        }
        field(120; "G/L Entry No."; Integer)
        {
            Caption = 'G/L Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Entry"."Entry No.";
        }
        field(125; "Posting Document Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Posting Document Type';
            DataClassification = CustomerContent;
            ValuesAllowed = " ", Invoice, "Credit Memo";
        }
        field(130; "Posting Document No."; Code[20])
        {
            Caption = 'Posting Document No.';
            DataClassification = CustomerContent;
        }
        field(140; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(145; "Cust. Ledger Entry No."; Integer)
        {
            Caption = 'Cust. Ledger Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "Cust. Ledger Entry"."Entry No.";
        }
        field(150; "Process Try Count"; Integer)
        {
            Caption = 'Process Try Count';
            DataClassification = CustomerContent;
        }
        field(200; Reversed; Boolean)
        {
            Caption = 'Reversed';
            DataClassification = CustomerContent;
        }
        field(210; "Reversed by Entry No."; BigInteger)
        {
            Caption = 'Reversed by Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Subscr. Request"."Entry No.";

            trigger OnValidate()
            begin
                if "Reversed by Entry No." <> 0 then
                    if "Reversed by Entry No." = "Entry No." then
                        FieldError("Reversed by Entry No.");
            end;
        }
        field(220; "Processing Status Change Date"; Date)
        {
            Caption = 'Processing Status Change Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Subscription Entry No.") { }
        key(Key3; "Processing Status", Type, Status) { }
        key(Key4; "Subscription Entry No.", "Processing Status") { }
        key(Key5; "Reversed by Entry No.") { }
    }

    trigger OnDelete()
    var
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        UnfinishedPmtReqestsErr: Label 'The %1 %2 cannot be deleted because it has an unfinished payment request assigned to it. Please wait until a response is received from the PSP and the response is properly processed.', Comment = '%1 - "Subscription Request" table caption, %2 - entry number';
    begin
        SubscrPaymentRequest.SetRange("Subscr. Request Entry No.", "Entry No.");
        if not SubscrPaymentRequest.IsEmpty() then begin
            SubscrPaymentRequest.SetRange(Status, SubscrPaymentRequest.Status::Requested);
            if not SubscrPaymentRequest.IsEmpty() then
                Error(UnfinishedPmtReqestsErr);
            SubscrPaymentRequest.SetRange(Status);
            SubscrPaymentRequest.DeleteAll(true);
        end;
    end;

    local procedure UpdateSubscriptionPaymentRequestStatus()
    var
        SubscrRequestUtils: Codeunit "NPR MM Subscr. Request Utils";
    begin
        SubscrRequestUtils.UpdateUnprocessableStatusInSubscriptionPaymentRequestStatus(Rec);
    end;
}