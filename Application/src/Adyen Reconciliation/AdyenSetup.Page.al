page 6184531 "NPR Adyen Setup"
{
    Extensible = false;

    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    Caption = 'Adyen Setup';
    PageType = Card;
    SourceTable = "NPR Adyen Setup";
    AdditionalSearchTerms = 'adyen setup,adyen reconciliation setup';
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Company ID"; Rec."Company ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Company ID.';
                }
                field("Active Webhooks"; Rec."Active Webhooks")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Active Webhook Count.';
                }
            }
            group(Management)
            {
                Caption = 'Management';
                field("Management Base URL"; Rec."Management Base URL")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Management Base URL.';
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
                field("Enable Reconciliation"; Rec."Enable Reconciliation")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Creates/Enables a Reconciliation Web Service which allow receiving Adyen Webhooks.';
                }
                field("Recon. Integr. Starting Date"; Rec."Recon. Integr. Starting Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Indicates when the Adyen Reconciliation Integration went into operation.';
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
                    ToolTip = 'Specifies if Posting is automatically performed during a Reconciliation process.';
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
                field("Report Scheme Docs URL"; Rec."Report Scheme Docs URL")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the URL to a valid Report Scheme example.';
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
                    ToolTip = 'Creates the Adyen Entra app, with user permissions. Needs Admin.';
                    Image = Action;

                    trigger OnAction()
                    begin
                        _AdyenManagement.CreateSaaSSetup();
                    end;
                }
                action("Upgrade EFT & EC Records")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Upgrade EFT & E-Commerce Records';
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
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
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
