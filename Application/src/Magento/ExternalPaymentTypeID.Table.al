table 6151189 "NPR External Payment Type ID"
{
    Access = Internal;
    Caption = 'External Payment Type Identifier';
    DataClassification = CustomerContent;
    LookupPageId = "NPR External Payment Type IDs";
    DrillDownPageId = "NPR External Payment Type IDs";

    fields
    {
        field(10; "External Payment Type ID"; Text[50])
        {
            Caption = 'External Payment Type ID';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(20; "Store Code"; Code[20])
        {
            Caption = 'Store Code';
            DataClassification = CustomerContent;
#if not BC17
            TableRelation = "NPR Spfy Store".Code;
#endif
        }
        field(30; "Payment Gateway"; Text[250])
        {
            Caption = 'Payment Gateway';
            DataClassification = CustomerContent;
        }
        field(40; "Credit Card Company"; Text[100])
        {
            Caption = 'Credit Card Company';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "External Payment Type ID")
        {
            Clustered = true;
        }
        key(Key2; "Store Code", "Payment Gateway", "Credit Card Company") { }
    }

    trigger OnInsert()
    begin
        CheckNoDuplicates();
    end;

    trigger OnModify()
    begin
        CheckNoDuplicates();
    end;

    local procedure CheckNoDuplicates()
    var
        ExternalPaymentTypeID: Record "NPR External Payment Type ID";
        DuplicateEntryErr: Label 'Another entry with the same %1, %2, and %3 already exists. The duplicate entry ID is %4.', Comment = '%1, %2, %3 - Store code, Payment Gateway, Credit Card Company field captions, %4 - External Payment Type ID of the duplicate entry.';
    begin
        if ("Store Code" = '') and ("Payment Gateway" = '') and ("Credit Card Company" = '') then
            exit;
        ExternalPaymentTypeID.SetCurrentKey("Store Code", "Payment Gateway", "Credit Card Company");
        ExternalPaymentTypeID.SetRange("Store Code", "Store Code");
        ExternalPaymentTypeID.SetRange("Payment Gateway", "Payment Gateway");
        ExternalPaymentTypeID.SetRange("Credit Card Company", "Credit Card Company");
        ExternalPaymentTypeID.SetFilter("External Payment Type ID", '<>%1', "External Payment Type ID");
        if ExternalPaymentTypeID.FindFirst() then
            Error(DuplicateEntryErr, FieldCaption("Store Code"), FieldCaption("Payment Gateway"), FieldCaption("Credit Card Company"), ExternalPaymentTypeID."External Payment Type ID");
    end;
}
