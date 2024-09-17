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
                    ToolTip = 'Creates/Enables Processing Job Queue and an NP Pay Automation Web Service which allows receiving NP Pay Webhooks.';
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
                field("Management API Key"; Rec."Management API Key")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Management API Key.';
                    ExtendedDatatype = Masked;
                }
            }
            group(Reconciliation)
            {
                Caption = 'Reconciliation';
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
                field("Download Report API Key"; Rec."Download Report API Key")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Download Report API Key.';
                    ExtendedDatatype = Masked;
                }
                field("Enable Automatic Posting"; Rec."Enable Automatic Posting")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the System should post Reconciliation document lines during the automatic Reconciliation process. If not enabled, the automatic Reconciliation process ends after the matching stage.';
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
                    Caption = 'Account Type';
                }
                field("Account No."; Rec."Pay By Link Account No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Pay By Link Account No. field.';
                    Caption = 'Account No.';
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
    end;

    var
        _AdyenGenericSetup: Record "NPR Adyen Setup";
        _AdyenManagement: Codeunit "NPR Adyen Management";
        _IsSaaS: Boolean;
}
