table 6150921 "NPR MM Subscr. Payment Request"
{
    Access = Public;
    Caption = 'Subscription Payment Request';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR MM Subscr.Payment Requests";
    LookupPageId = "NPR MM Subscr.Payment Requests";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(2; "Batch No."; Integer)
        {
            Caption = 'Batch No.';
            DataClassification = CustomerContent;
        }
        field(10; Status; Enum "NPR MM Payment Request Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                CheckSubscrPaymentRequestStatusCanBeChanged();
            end;
        }
        field(30; "Subscr. Request Entry No."; BigInteger)
        {
            Caption = 'Subscription Request Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Subscr. Request"."Entry No.";
        }
        field(40; PSP; Enum "NPR MM Subscription PSP")
        {
            Caption = 'PSP';
            DataClassification = CustomerContent;
        }
        field(50; "Payment Token"; Text[64])
        {
            Caption = 'Payment Token';
            DataClassification = CustomerContent;
        }
        field(60; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = "Currency Code";
        }
        field(70; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
        }
        field(80; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(100; "External Transaction ID"; Text[50])
        {
            Caption = 'External Transaction ID';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "External Transaction ID".Split('.').Count = 2 then
                    "PSP Reference" := CopyStr("External Transaction ID".Split('.').Get(2), 1, MaxStrLen("PSP Reference"));
            end;
        }
        field(110; "PSP Reference"; Code[16])
        {
            Caption = 'PSP Reference';
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
            TableRelation = "NPR MM Subscr. Payment Request"."Entry No.";
        }
        field(220; "Process Try Count"; Integer)
        {
            Caption = 'Process Try Count';
            DataClassification = CustomerContent;
        }
        field(230; "Result Code"; Text[50])
        {
            Caption = 'Result Code';
            DataClassification = CustomerContent;
        }
        field(240; "Rejected Reason Code"; Text[50])
        {
            Caption = 'Rejected Reason Code';
            DataClassification = CustomerContent;
        }
        field(250; "Rejected Reason Description"; Text[250])
        {
            Caption = 'Rejected Reason Description';
            DataClassification = CustomerContent;
        }
        field(260; Posted; Boolean)
        {
            Caption = 'Posted';
            DataClassification = CustomerContent;
        }
        field(270; "G/L Entry No."; Integer)
        {
            Caption = 'G/L Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Entry"."Entry No.";
        }
        field(280; "Posting Document No."; Code[20])
        {
            Caption = 'Posting Document No.';
            DataClassification = CustomerContent;
        }
        field(290; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Subscr. Request Entry No.", Status) { }
        key(Key3; "Batch No.") { }
        key(Key4; PSP, "Batch No.") { }
    }
    internal procedure CheckSubscrPaymentRequestStatusCanBeChanged()
    var
        StatusErrorLbl: Label 'Subscription payment request no. %1 must not be with status %2.', Comment = '%1 - entry no., %2 - status';
    begin
        if not (Rec.Status in [Rec.Status::Cancelled, Rec.Status::Rejected]) then
            exit;

        if xRec.Status in [xRec.Status::Authorized, xRec.Status::Captured] then
            Error(StatusErrorLbl, xRec."Entry No.", xRec.Status);
    end;
}