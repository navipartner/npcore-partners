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
                AdyenManagement: Codeunit "NPR Adyen Management";
                WebServiceManagement: Codeunit "Web Service Management";
                ManagmentApiKeyErr: Label 'Management API Key must have a value in NP Pay Setup';
            begin
                WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Codeunit, Codeunit::"NPR AF Rec. API Request", 'AdyenWebhook', "Enable Reconciliation");
                if not Rec.HasManagementAPIKey() then
                    Error(ManagmentApiKeyErr);
                AdyenManagement.UpdateMerchantList(0);
            end;
        }
        field(21; "Enable Reconcil. Automation"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enable Reconciliation';

            trigger OnValidate()
            var
                MerchantAccount: Record "NPR Adyen Merchant Account";
                WebhookSetup: Record "NPR Adyen Webhook Setup";
                AdyenManagement: Codeunit "NPR Adyen Management";
                AdyenTrMatchingSession: Codeunit "NPR Adyen Tr. Matching Session";
                EnvironmentInformation: Codeunit "Environment Information";
                ReportReadyEventFilter: Label 'REPORT_AVAILABLE', Locked = true;
                AdyenWebhookType: Enum "NPR Adyen Webhook Type";
                ManagmentApiKeyErr: Label 'Management API Key must have a value in NP Pay Setup';
            begin
                AdyenTrMatchingSession.SetupReconciliationTaskProcessingJobQueue("Enable Reconcil. Automation");
                if "Enable Reconcil. Automation" then begin
                    if not Rec.HasManagementAPIKey() then
                        Error(ManagmentApiKeyErr);
                    AdyenManagement.UpdateMerchantList(0);

                    if not EnvironmentInformation.IsOnPrem() then
                        if MerchantAccount.FindSet() and WebhookSetup.IsEmpty() then
                            repeat
                                AdyenManagement.InitWebhookSetup(WebhookSetup, ReportReadyEventFilter, MerchantAccount.Name, AdyenWebhookType::standard);
                                AdyenManagement.CreateWebhook(WebhookSetup);
                            until MerchantAccount.Next() = 0;
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
            ObsoleteState = Pending;
            ObsoleteTag = '2025-04-02';
            ObsoleteReason = 'Replaced with Isolated Storage Management API Key Token';
        }
        field(45; "Management API Key Token"; Guid)
        {
            Caption = 'Management API Key';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(50; "Download Report API Key"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Download Report API Key';
            ObsoleteState = Pending;
            ObsoleteTag = '2025-04-02';
            ObsoleteReason = 'Replaced with Isolated Storage Download Report API Key Token';
        }
        field(55; "Download Report API Key Token"; Guid)
        {
            Caption = 'Download Report API Key';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
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
            begin
                if "PayByLink Enable Auto Posting" then
                    AdyenManagement.SchedulePostPaymentLinesJQ()
                else
                    AdyenManagement.SetOnHoldPostPaymentLinesJQ();
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
                    SetupPayByLink();
            end;

        }
        field(230; "EFT Res. Payment Gateway Code"; Code[10])
        {
            Caption = 'EFT Res. Payment Gateway Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Payment Gateway".Code;
        }
        field(240; "EFT Res. Account Type"; Enum "Payment Balance Account Type")
        {
            Caption = 'EFT Res. Account Type';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if Rec."EFT Res. Account Type" <> xRec."EFT Res. Account Type" then
                    Rec."EFT Res. Account No." := '';
            end;

        }
        field(250; "EFT Res. Account No."; Code[20])
        {
            Caption = 'EFT Res. Account No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("EFT Res. Account Type" = CONST("G/L Account")) "G/L Account" where("Account Type" = const(Posting), "Direct Posting" = const(true))
            ELSE
            IF ("EFT Res. Account Type" = CONST("Bank Account")) "Bank Account";
        }

        field(260; "Active Subs. Payment Gateways"; Integer)
        {
            Caption = 'Active Subs. Payment Gateways';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count("NPR MM Subs. Payment Gateway" where(Status = const(Enabled)));
        }
        field(270; "Max Sub Req Process Try Count"; Integer)
        {
            Caption = 'Max. Subscription Request Processing Try Count';
            DataClassification = CustomerContent;
            InitValue = 2;
        }
        field(280; "Auto Process Subs Req Errors"; boolean)
        {
            Caption = 'Auto Process Subscription Request Errors';
            DataClassification = CustomerContent;
        }
        field(290; "Def Auto Renew Pay Method Code"; Code[10])
        {
            Caption = 'Default Auto-Renew Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "Payment Method".Code;
            ObsoleteState = Pending;
            ObsoleteTag = '2025-03-05';
            ObsoleteReason = 'Not used.';
        }
        field(300; "Subscr. Reference Prefix"; Code[10])
        {
            Caption = 'Subscription Payment Reference Prefix';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateAllowedChars(Rec."Subscr. Reference Prefix");
            end;
        }
        field(310; "Subscr. Reference No.Series"; Code[20])
        {
            Caption = 'Subscription Payment Reference No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
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
        if not Get() then
            exit;
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

    local procedure SetupPayByLink()
    var
        MerchantAccount: Record "NPR Adyen Merchant Account";
        AdyenWebhookType: Enum "NPR Adyen Webhook Type";
        AdyenManagement: Codeunit "NPR Adyen Management";
        AuthorisationEventFilter: Label 'AUTHORISATION', Locked = true;
    begin
        if Rec."Enable Pay by Link" then begin
            AdyenManagement.SchedulePayByLinkStatusJQ();

            if Rec."PayByLink Enable Auto Posting" then
                AdyenManagement.SchedulePostPaymentLinesJQ();

            AdyenManagement.UpdateMerchantList(0);
            if MerchantAccount.FindSet() then
                repeat
                    AdyenManagement.EnsureAdyenWebhookSetup(AuthorisationEventFilter, MerchantAccount.Name, AdyenWebhookType::standard);
                until MerchantAccount.Next() = 0;
        end else begin
            if not AdyenManagement.IsSubsPGEnabled() then
                AdyenManagement.SetOnHoldPayByLinkStatusJQ();
            AdyenManagement.SetOnHoldPostPaymentLinesJQ();
        end;
    end;

    trigger OnDelete()
    var
    begin
        DeleteManagementAPIKey();
        DeleteDownloadReportAPIKey();
    end;

    [NonDebuggable]
    internal procedure GetManagementApiKey() ApiKeyValue: Text
    begin
        IsolatedStorage.Get("Management API Key Token", DataScope::Company, ApiKeyValue);
    end;

    [NonDebuggable]
    internal procedure SetManagementAPIKey(NewApiKeyValue: Text)
    begin
        if (IsNullGuid(Rec."Management API Key Token")) then
            Rec."Management API Key Token" := CreateGuid();

        if (EncryptionEnabled()) then
            IsolatedStorage.SetEncrypted(Rec."Management API Key Token", NewApiKeyValue, DataScope::Company)
        else
            IsolatedStorage.Set(Rec."Management API Key Token", NewApiKeyValue, DataScope::Company);
    end;

    internal procedure DeleteManagementAPIKey()
    begin
        if (IsNullGuid(Rec."Management API Key Token")) then
            exit;

        IsolatedStorage.Delete(Rec."Management API Key Token", DataScope::Company);
    end;

    internal procedure HasManagementAPIKey(): Boolean
    begin
        if (IsNullGuid(Rec."Management API Key Token")) then
            exit(false);

        exit(IsolatedStorage.Contains(Rec."Management API Key Token", DataScope::Company));
    end;

    [NonDebuggable]
    internal procedure GetDownloadReportApiKey() ApiKeyValue: Text
    begin
        IsolatedStorage.Get("Download Report API Key Token", DataScope::Company, ApiKeyValue);
    end;

    [NonDebuggable]
    internal procedure SetDownloadReportAPIKey(NewApiKeyValue: Text)
    begin
        if (IsNullGuid(Rec."Download Report API Key Token")) then
            Rec."Download Report API Key Token" := CreateGuid();

        if (EncryptionEnabled()) then
            IsolatedStorage.SetEncrypted(Rec."Download Report API Key Token", NewApiKeyValue, DataScope::Company)
        else
            IsolatedStorage.Set(Rec."Download Report API Key Token", NewApiKeyValue, DataScope::Company);
    end;

    internal procedure DeleteDownloadReportAPIKey()
    begin
        if (IsNullGuid(Rec."Download Report API Key Token")) then
            exit;

        IsolatedStorage.Delete(Rec."Download Report API Key Token", DataScope::Company);
    end;

    internal procedure HasDownloadReportAPIKey(): Boolean
    begin
        if (IsNullGuid(Rec."Download Report API Key Token")) then
            exit(false);

        exit(IsolatedStorage.Contains(Rec."Download Report API Key Token", DataScope::Company));
    end;

    local procedure ValidateAllowedChars(InputTxt: Text)
    var
        AllowedCharPatternLbl: Label '^[A-Za-z0-9.,''_?+* -]+$', Locked = true;
        LabelInvalidChars: Label '%1 contains unsupported characters. Allowed: letters (A-Z, a-z), digits (0-9), and . , '' _ - ? + * or space.', Comment = '%1 - input text';
        RegEx: Codeunit "NPR RegEx";
    begin
        if InputTxt = '' then
            exit;

        if not RegEx.IsMatch(InputTxt, AllowedCharPatternLbl) then
            Error(LabelInvalidChars, InputTxt);
    end;
}
