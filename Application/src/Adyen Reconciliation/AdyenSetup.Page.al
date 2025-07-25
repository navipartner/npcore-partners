page 6184531 "NPR Adyen Setup"
{
    Extensible = false;
    RefreshOnActivate = true;
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    Caption = 'NP Pay Setup';
    PageType = Card;
    SourceTable = "NPR Adyen Setup";
    AdditionalSearchTerms = 'NP Pay setup,NP Pay reconciliation setup';
    ContextSensitiveHelpPage = 'docs/np_pay/how-to/perform_reconciliation/';
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Active Webhooks"; Rec."Active Webhooks")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Active Webhook Count.';
                }
                field("Enable Adyen Automation"; Rec."Enable Reconciliation")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Creates/Enables NP Pay Automation Web Service which allows receiving NP Pay Webhooks.';
                }
            }
            group(Management)
            {
                Caption = 'Management';
                field("Environment Type"; Rec."Environment Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Environment Type.';
                }
                field(ManagementAPIKey; _APIManagementSecretKey)
                {
                    Caption = 'API Key';
                    ToolTip = 'Specifies the value of the Management API Key field';
                    ApplicationArea = NPRRetail;
                    ExtendedDatatype = Masked;
                    trigger OnValidate()
                    begin
                        if (_APIManagementSecretKey = '') then
                            Rec.DeleteManagementAPIKey()
                        else begin
                            Rec.SetManagementAPIKey(_APIManagementSecretKey);
                            Rec.Modify();
                            if Rec.HasManagementAPIKey() then begin
                                if not _AdyenManagement.TestApiKey(Rec."Environment Type") then
                                    ShowError(GetLastErrorText())
                                else begin
                                    if not IsNullGuid(_ManagementAPIKeyNotValidNotification.Id) then
                                        _ManagementAPIKeyNotValidNotification.Recall();
                                end;
                            end;
                        end;
                    end;
                }
            }
            group(Reconciliation)
            {
                Caption = 'Reconciliation';
                field("Enable Reconcil. Automation"; Rec."Enable Reconcil. Automation")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Creates/Enables NP Pay Reconciliation Automation, also setting up a processing job queue to handle reconciliation tasks automatically.';
                }
                field("Enable Automatic Posting"; Rec."Enable Automatic Posting")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the System should post Reconciliation document lines during the automatic Reconciliation process. If not enabled, the automatic Reconciliation process ends after the matching stage.';
                }
                field("Recon. Integr. Starting Date"; Rec."Recon. Integr. Starting Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Indicates when the NP Pay Reconciliation Integration went into operation.';
                }
                field("Recon. Posting Starting Date"; Rec."Recon. Posting Starting Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Indicates the date and time when the reconciliation posting process began operation.';
                }
                field(DownloadReportAPIKey; _APIDownloadReportSecretKey)
                {
                    Caption = 'Download Report API Key';
                    ToolTip = 'Specifies the value of the API Key field';
                    ApplicationArea = NPRRetail;
                    ExtendedDatatype = Masked;
                    trigger OnValidate()
                    begin
                        if (_APIDownloadReportSecretKey = '') then
                            Rec.DeleteDownloadReportAPIKey()
                        else
                            Rec.SetDownloadReportAPIKey(_APIDownloadReportSecretKey);
                    end;

                }
                field("Post Chargebacks Automatically"; Rec."Post Chargebacks Automatically")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the Chargeback Journal Type Reconciliation Lines are posted automatically or are required a confirmation before being able to be posted.';
                }
                field("Post with Transaction Date"; Rec."Post with Transaction Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the reconciled Transaction are posted with the same date as the transaction was created/captured.';
                }
                field("Reconciliation Document Nos."; Rec."Reconciliation Document Nos.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the No. Series code for Reconciliation Documents.';
                }
                field("Posting Document Nos."; Rec."Posting Document Nos.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the No. Series Code for Reconciliation Posting Entries.';
                }
            }
            group(PayByLink)
            {
                Caption = 'Pay By Link';
                field("Enable Pay by Link"; Rec."Enable Pay by Link")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Enable Pay by Link field.';
                    Caption = 'Enable Pay by Link';
                }
                field("Payment Gateaway Code"; Rec."Pay By Link Gateaway Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Pay By Link Payment Gateaway Code field.';
                    Caption = 'Payment Gateaway Code';
                }
                field("Pay by Link Exp. Duration"; Rec."Pay By Link Exp. Duration")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Pay by Link Expiration field.';
                    Caption = 'Pay by Link Expiration';
                }
                field("E-Mail Template"; Rec."Pay By Link E-Mail Template")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Pay By Link E-Mail Template field.';
                    Caption = 'E-Mail Template';
                }
                field("SMS Template"; Rec."Pay By Link SMS Template")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Pay By Link SMS Template field.';
                    Caption = 'SMS Template';
                }
                field("Account Type"; Rec."Pay By Link Account Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Pay By Link Account Type field.';
                    Caption = 'Default Account Type';
                }
                field("Account No."; Rec."Pay By Link Account No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Pay By Link Account No. field.';
                    Caption = 'Default Account No.';
                }
                field("PayByLink Enable Auto Posting"; Rec."PayByLink Enable Auto Posting")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Pay By Link Enable Automatic Posting field.';
                    Caption = 'Enable Automatic Posting';
                }
                field("Posting Retry Count"; Rec."PayByLink Posting Retry Count")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Pay By Link Posting Retry Count field.';
                    Caption = 'Posting Retry Count';
                }
            }
            group(EndlessAisle)
            {
                Caption = 'Endless Aisle';
                field("EFT Res. Payment Gateway Code"; Rec."EFT Res. Payment Gateway Code")
                {
                    Caption = 'Payment Gateway Code';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the EFT Res. Payment Gateway Code field.';
                }
                field("EFT Res. Account Type"; Rec."EFT Res. Account Type")
                {
                    Caption = 'Account Type';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the EFT Res. Account Type field.';
                }
                field("EFT Res. Account No."; Rec."EFT Res. Account No.")
                {
                    Caption = 'Account No.';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the EFT Res. Account No. field.';
                }
            }

            group(Subscriptions)
            {
                Caption = 'Subscriptions';
                field("Active Subs. Payment Gateways"; Rec."Active Subs. Payment Gateways")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'The number of the active subscription payment gateways';
                }
                field("Max Sub Req Process Try Count"; Rec."Max Sub Req Process Try Count")
                {
                    BlankZero = true;
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Max. Subscription Request Processing Try Count field.';
                }
                field("Auto Process Subs Req Errors"; Rec."Auto Process Subs Req Errors")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Auto Process Subscription Request Errors field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group("Additional Setup")
            {
                Caption = 'Additional Setup';

                action("Configure Webhooks")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Configure Webhooks';
                    Image = Setup;
                    ToolTip = 'Running this action will open Webhook Setup List.';
                    RunObject = Page "NPR Adyen Webhook Setup List";
                }
                action("Open Merchant Account Setup")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Open Merchant Account Setup';
                    Image = Setup;
                    ToolTip = 'Running this action will open Merchant Account Setup.';
                    RunObject = Page "NPR Adyen Merchant Setup";
                }
                action("Open Subscription Payment Gateways")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Caption = 'Open Subscription Payment Gateways';
                    Image = Setup;
                    ToolTip = 'Running this action will open the Subscription Payment Gateways.';
                    RunObject = Page "NPR MM Subs. Payment Gateways";
                }
            }
            group(Configurations)
            {
                Caption = 'Configurations';

                action(CreateSaaSSetup)
                {
                    Caption = 'Create Setup (Admin)';
                    Visible = _IsSaaS;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Creates the NP Pay Entra app, with custom permissions. Needs Admin.';
                    Image = Action;

                    trigger OnAction()
                    begin
                        _AdyenManagement.CreateSaaSSetup();
                    end;
                }
                action("Upgrade EFT & EC Records")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Upgrade Payment Lines';
                    Image = Setup;
                    ToolTip = 'Running this action will start the EFT Transaction Request and Magento Payment Line tables'' upgrade.';

                    trigger OnAction()
                    begin
                        _AdyenManagement.SetReconciledEFTMagentoUpgrade();
                    end;
                }
                action("Recreate Recon. Docs")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Recreate unposted Recon. Docs';
                    Image = Create;
                    ToolTip = 'This action will recreate all unposted reconciliation documents and try to match them.';

                    trigger OnAction()
                    var
                        ReconHeader: Record "NPR Adyen Reconciliation Hdr";
                        AdyenRecreateRecDoc: Codeunit "NPR Adyen Recreate Rec. Doc.";
                    begin
                        // Recreate all not-yet-posted Reconciliation Documents to import missing Transaction Fee lines
                        ReconHeader.Reset();
                        ReconHeader.SetCurrentKey(Status);
                        ReconHeader.SetFilter(Status, '<>%1', ReconHeader.Status::Posted);
                        if ReconHeader.FindSet() then begin
                            repeat
                                Clear(AdyenRecreateRecDoc);
                                AdyenRecreateRecDoc.Run(ReconHeader);
                            until ReconHeader.Next() = 0;
                        end;
                    end;
                }
            }
        }
    }
    trigger OnOpenPage()
    var
        EnvironmentInformation: Codeunit "Environment Information";
        AdyenSetupInit: Record "NPR Adyen Setup";
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            if not EnvironmentInformation.IsSandbox() then
                Rec."Environment Type" := Rec."Environment Type"::Live;
            Rec.Insert();
        end else
            if Rec."Company ID" = '' then begin
                AdyenSetupInit.Init();
                if Rec."Company ID" <> AdyenSetupInit."Company ID" then begin
                    Rec."Company ID" := AdyenSetupInit."Company ID";
                    Rec.Modify();
                end;
            end;

        _AdyenGenericSetup := Rec;
        Rec.CalcFields("Active Webhooks");
        _IsSaaS := not EnvironmentInformation.IsOnPrem();

        if (Rec.HasDownloadReportAPIKey()) then
            _APIDownloadReportSecretKey := '***';

        if Rec.HasManagementAPIKey() then begin
            _APIManagementSecretKey := '***';
            if not _AdyenManagement.TestApiKey(Rec."Environment Type") then
                ShowError(GetLastErrorText());
        end;
    end;

    local procedure ShowError(ErrorText: Text)
    begin
        _ManagementAPIKeyNotValidNotification.Id := CreateGuid();
        _ManagementAPIKeyNotValidNotification.Message := ErrorText;
        _ManagementAPIKeyNotValidNotification.Scope := NotificationScope::LocalScope;
        _ManagementAPIKeyNotValidNotification.Send();
    end;

    var
        _AdyenGenericSetup: Record "NPR Adyen Setup";
        _AdyenManagement: Codeunit "NPR Adyen Management";
        _ManagementAPIKeyNotValidNotification: Notification;
        _IsSaaS: Boolean;
        _APIManagementSecretKey: Text;
        _APIDownloadReportSecretKey: Text;
}
