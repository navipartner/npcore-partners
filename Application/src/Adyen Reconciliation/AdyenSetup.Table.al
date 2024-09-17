table 6150801 "NPR Adyen Setup"
{
    Access = Internal;
    Caption = 'NP Pay Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Primary Key';
        }
        field(10; "Company ID"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Company ID';
            InitValue = 'NavipartnerAfP';
            Editable = false;
        }
        field(20; "Enable Reconciliation"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enable NP Pay Automation';

            trigger OnValidate()
            var
                WebService: Record "Web Service Aggregate";
                WebServiceManagement: Codeunit "Web Service Management";
                AdyenManagement: Codeunit "NPR Adyen Management";
                ProcessReconciliationWebhookLbl: Label 'Process Reconciliation Webhooks';
                WebhookSetup: Record "NPR Adyen Webhook Setup";
                MerchantAccount: Record "NPR Adyen Merchant Account";
                AdyenWebhookType: Enum "NPR Adyen Webhook Type";
                ReportReadyEventFilter: Label 'REPORT_AVAILABLE', Locked = true;
            begin
                TestField("Management API Key");
                if "Enable Reconciliation" then begin
                    WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Codeunit, Codeunit::"NPR AF Rec. API Request", 'AdyenWebhook', true);
                    AdyenManagement.CreateAdyenJob(Codeunit::"NPR Adyen Tr. Matching Session", ProcessReconciliationWebhookLbl, 1440);
                    AdyenManagement.UpdateMerchantList(0);
                    if MerchantAccount.FindSet() then
                        repeat
                            AdyenManagement.InitWebhookSetup(WebhookSetup, ReportReadyEventFilter, MerchantAccount.Name, AdyenWebhookType::standard);
                            AdyenManagement.CreateWebhook(WebhookSetup);
                        until MerchantAccount.Next() = 0;
                    "Enable Automatic Posting" := true;
                    Modify();
                end else begin
                    WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Codeunit, Codeunit::"NPR AF Rec. API Request", 'AdyenWebhook', false);
                    AdyenManagement.CancelAdyenJob(Codeunit::"NPR Adyen Tr. Matching Session");

                end;
            end;
        }
        field(30; "Management Base URL"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Management Base URL';
            ObsoleteState = Removed;
            ObsoleteTag = '2024-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(35; "Environment Type"; Enum "NPR Adyen Environment Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Environment Type';
        }
        field(40; "Management API Key"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Management API Key';
        }
        field(50; "Download Report API Key"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Download Report API Key';
        }
        field(60; "Active Webhooks"; Integer)
        {
            Caption = 'Active Webhooks';
            FieldClass = FlowField;
            CalcFormula = count("NPR Adyen Webhook Setup" where(Active = const(true)));
        }
        field(70; "Enable Automatic Posting"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enable Posting Automation';
            InitValue = true;
        }
        field(80; "Post POS Entries Immediately"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Post POS Entries Immediately';
            InitValue = true;
        }
        field(90; "Reconciliation Document Nos."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Reconciliation Document Nos';
            TableRelation = "No. Series";
        }
        field(95; "Posting Document Nos."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Posting Document Nos.';
            TableRelation = "No. Series";
        }
        field(100; "Report Scheme Docs URL"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Report Scheme Docs URL';
            ObsoleteState = Removed;
            ObsoleteTag = '2024-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(110; "Recon. Integr. Starting Date"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Reconciliation Integration Starting Date';
        }
        field(115; "Recon. Posting Starting Date"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Reconciliation Posting Starting Date';
        }
        field(120; "Post with Transaction Date"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Post with Transaction Date';
            InitValue = true;
        }
        field(130; "Post Chargebacks Automatically"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Post Chargebacks Automatically';
        }
        field(140; "Pay By Link Gateaway Code"; Code[10])
        {
            Caption = 'Pay By Link Gateaway Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Payment Gateway";
        }
        field(150; "Pay By Link E-Mail Template"; Code[20])
        {
            Caption = 'Pay By Link E-Mail Template';
            DataClassification = CustomerContent;
            TableRelation = "NPR E-mail Template Header".Code;
        }
        field(160; "Pay By Link Account Type"; Enum "Payment Balance Account Type")
        {
            Caption = 'Pay By Link Account Type';
            DataClassification = CustomerContent;
        }
        field(170; "Pay By Link Account No."; Code[20])
        {
            Caption = 'Pay By Link Account No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Pay By Link Account Type" = CONST("G/L Account")) "G/L Account"
            ELSE
            IF ("Pay By Link Account Type" = CONST("Bank Account")) "Bank Account";
        }
        field(180; "PayByLink Enable Auto Posting"; Boolean)
        {
            Caption = 'Pay By Link Enable Automatic Posting';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                AdyenManagement: Codeunit "NPR Adyen Management";
                ProccessPostPaymentLine: Label 'Process Posting Payment Lines for posted documents.';
            begin
                if "PayByLink Enable Auto Posting" then
                    AdyenManagement.CreateAutoRescheduleAdyenJob(Codeunit::"NPR Adyen Post Payment Lines", ProccessPostPaymentLine, 1, 600) //Reschedule to run again in 10 minutes on error
                else
                    AdyenManagement.SetOnHoldJob(Codeunit::"NPR Adyen Post Payment Lines");
            end;
        }
        field(190; "Pay By Link Exp. Duration"; Duration)
        {
            Caption = 'Pay by Link Expiration';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                CheckExpDuration("Pay By Link Exp. Duration");
            end;
        }
        field(200; "Pay By Link SMS Template"; Code[10])
        {
            Caption = 'Pay By Link SMS Template';
            DataClassification = CustomerContent;
            TableRelation = "NPR SMS Template Header".Code;
        }
        field(210; "PayByLink Posting Retry Count"; Integer)
        {
            Caption = 'Pay By Link Posting Retry Count';
            DataClassification = CustomerContent;
            InitValue = 3;
        }
        field(220; "Enable Pay by Link"; Boolean)
        {
            Caption = 'Enable Pay by Link';
            DataClassification = CustomerContent;
            InitValue = false;

            trigger OnValidate()
            var
                MagentoPaymentGateway: Record "NPR Magento Payment Gateway";
            begin
                if not MagentoPaymentGateway.Get(Rec."Pay By Link Gateaway Code") then
                    exit;
                If MagentoPaymentGateway."Integration Type" = MagentoPaymentGateway."Integration Type"::Adyen then
                    CreateAdyenJobs();
            end;

        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GetRecordOnce()
    begin
        if _RecordHasBeenRead then
            exit;
        Get();
        _RecordHasBeenRead := true;
    end;

    var
        _RecordHasBeenRead: Boolean;

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
