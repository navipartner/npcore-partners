table 6150892 "NPR Pay by Link Setup"
{
    Caption = 'NP Pay By Link Setup';
    DataClassification = CustomerContent;
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2024-09-13';
    ObsoleteReason = 'Table marked for removal. Reason: All the fields are transfered to "NPR Adyen Setup" table.';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Primary Key';
        }
        field(5; "Payment Gateaway Code"; Code[10])
        {
            Caption = 'Payment Gateaway Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Payment Gateway";
        }
        field(10; "E-Mail Template"; Code[20])
        {
            Caption = 'E-Mail Template';
            DataClassification = CustomerContent;
            TableRelation = "NPR E-mail Template Header".Code;
        }
        field(20; "Account Type"; Enum "Payment Balance Account Type")
        {
            Caption = 'Account Type';
            DataClassification = CustomerContent;
        }
        field(30; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Account Type" = CONST("G/L Account")) "G/L Account"
            ELSE
            IF ("Account Type" = CONST("Bank Account")) "Bank Account";
        }
        field(40; "Enable Automatic Posting"; Boolean)
        {
            Caption = 'Enable Automatic Posting';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                AdyenManagement: Codeunit "NPR Adyen Management";
                ProccessPostPaymentLine: Label 'Process Posting Payment Lines for posted documents.';
            begin
                if "Enable Automatic Posting" then
                    AdyenManagement.CreateAutoRescheduleAdyenJob(Codeunit::"NPR Adyen Post Payment Lines", ProccessPostPaymentLine, 1, 600) //Reschedule to run again in 10 minutes on error
                else
                    AdyenManagement.SetOnHoldJob(Codeunit::"NPR Adyen Post Payment Lines");
            end;
        }
        field(50; "Pay by Link Exp. Duration"; Duration)
        {
            Caption = 'Pay by Link Expiration';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                CheckExpDuration("Pay by Link Exp. Duration");
            end;
        }
        field(60; "SMS Template"; Code[10])
        {
            Caption = 'SMS Template';
            DataClassification = CustomerContent;
            TableRelation = "NPR SMS Template Header".Code;
        }
        field(70; "Posting Retry Count"; Integer)
        {
            Caption = 'Posting Retry Count';
            DataClassification = CustomerContent;
            InitValue = 3;
        }
        field(80; "Enable Pay by Link"; Boolean)
        {
            Caption = 'Enable Pay by Link';
            DataClassification = CustomerContent;
            InitValue = false;

            trigger OnValidate()
            var
                MagentoPaymentGateway: Record "NPR Magento Payment Gateway";
            begin
                if not MagentoPaymentGateway.Get(Rec."Payment Gateaway Code") then
                    exit;
                If MagentoPaymentGateway."Integration Type" = MagentoPaymentGateway."Integration Type"::Adyen then
                    CreateAdyenJobs();
            end;

        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    procedure CheckExpDuration(ExpDuration: Duration)
    var
        MaxDurationTxt: Text;
        MaxDuration: Duration;
        ExperationErr: Label 'The expiration duration cannot be more than %1';
    begin
        MaxDurationTxt := '70 days';
        Evaluate(MaxDuration, MaxDurationTxt);

        if ExpDuration > MaxDuration then
            Error(ExperationErr, MaxDurationTxt);
    end;

    local procedure CreateAdyenJobs()
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        MerchantAccount: Record "NPR Adyen Merchant Account";
        AdyenWebhookType: Enum "NPR Adyen Webhook Type";
        AdyenManagement: Codeunit "NPR Adyen Management";
        ProccessPaymentStatus: Label 'Process Payment Status for Adyen Pay by Link.';
        AuthorisationEventFilter: Label 'AUTHORISATION', Locked = true;
    begin
        if Rec."Enable Pay by Link" then begin
            AdyenManagement.CreateAutoRescheduleAdyenJob(Codeunit::"NPR Adyen PayByLink Status JQ", ProccessPaymentStatus, 1, 30); //Reschedule to run again in 30 seconds on error
            AdyenManagement.UpdateMerchantList(0);
            if MerchantAccount.FindSet() then
                repeat
                    AdyenManagement.InitWebhookSetup(WebhookSetup, AuthorisationEventFilter, MerchantAccount.Name, AdyenWebhookType::standard);
                until MerchantAccount.Next() = 0;
            AdyenManagement.CreateWebhook(WebhookSetup);
        end else begin
            AdyenManagement.SetOnHoldJob(Codeunit::"NPR Adyen PayByLink Status JQ");
            AdyenManagement.SetOnHoldJob(Codeunit::"NPR Adyen Post Payment Lines");
        end;
    end;

}