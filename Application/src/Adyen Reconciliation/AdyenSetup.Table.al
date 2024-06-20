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
                WebhookSetup: Record "NPR Adyen Webhook Setup";
                MerchantAccount: Record "NPR Adyen Merchant Account";
                ReportReadyEventFilter: Label 'REPORT_AVAILABLE', Locked = true;
            begin
                TestField("Management API Key");
                if "Enable Reconciliation" then begin
                    WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Codeunit, Codeunit::"NPR AF Rec. API Request", 'AdyenWebhook', true);
                    AdyenManagement.CreateReconciliationJob(Codeunit::"NPR Adyen Tr. Matching Session");
                    AdyenManagement.UpdateMerchantList(0);
                    if MerchantAccount.FindSet() then
                        repeat
                            AdyenManagement.InitReportReadyWebhookSetup(WebhookSetup, ReportReadyEventFilter, MerchantAccount.Name);
                        until MerchantAccount.Next() = 0;
                    AdyenManagement.CreateWebhook(WebhookSetup);
                    "Enable Automatic Posting" := true;
                    Modify();
                end else begin
                    WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Codeunit, Codeunit::"NPR AF Rec. API Request", 'AdyenWebhook', false);
                    AdyenManagement.CancelReconciliationJob(Codeunit::"NPR Adyen Tr. Matching Session");
                end;
            end;
        }
        field(30; "Management Base URL"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Management Base URL';
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR35.0';
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
            ObsoleteTag = 'NPR35.0';
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
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
