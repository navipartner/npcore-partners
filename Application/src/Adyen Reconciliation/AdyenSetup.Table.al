table 6150801 "NPR Adyen Setup"
{
    Access = Internal;

    Caption = 'Adyen Setup';
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
            Caption = 'Enable Adyen Automation';

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
                        until MerchantAccount.Next() = 0;
                    AdyenManagement.CreateWebhook(WebhookSetup);
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
            ObsoleteState = Pending;
            ObsoleteTag = '2024-06-28';
            ObsoleteReason = 'Replaced with .';
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
            Caption = 'Enable Automatic Posting';
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
            ObsoleteState = Pending;
            ObsoleteTag = '2024-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(110; "Recon. Integr. Starting Date"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Reconciliation Integration Starting Date';
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
}
