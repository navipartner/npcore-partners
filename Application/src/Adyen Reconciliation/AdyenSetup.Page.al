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
                field("Post POS Entries Immediately"; Rec."Post POS Entries Immediately")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the Reversed Refund/Chargeback POS Entries are posted immediately or the posting is deferred to a later procedure.';
                }
                field("Reconciliation Document Nos."; Rec."Reconciliation Document Nos.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the No. Series code for Reconciliation Documents.';
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
            action("Configure Webhooks")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Configure Webhooks';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Setup;
                ToolTip = 'Running this action will open Webhook Setup List.';

                trigger OnAction()
                begin
                    Page.Run(Page::"NPR Adyen Webhook Setup List");
                end;
            }
            action("Create Azure AD App")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Create Azure AD App';
                ToolTip = 'Running this action will create an Azure AD App and a accompaning client secret.';
                Image = Setup;

                trigger OnAction()
                begin
                    Clear(_AdyenManagement);
                    _AdyenManagement.CreateAzureADApplication();
                end;
            }
            action("Create Azure AD App Secret")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Create Azure AD App Secret';
                ToolTip = 'Running this action will create a client secret for an existing Azure AD App.';
                Image = Setup;

                trigger OnAction()
                begin
                    Clear(_AdyenManagement);
                    _AdyenManagement.CreateAzureADApplicationSecret();
                end;
            }
        }
        area(Navigation)
        {
            action("Open Merchant Account Setup")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Open Merchant Account Setup';
                Image = Setup;
                RunObject = Page "NPR Adyen Merchant Setup";
                ToolTip = 'Running this action will open Merchant Account Setup.';
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        _AdyenGenericSetup := Rec;
        Rec.CalcFields("Active Webhooks");
    end;

    var
        _AdyenGenericSetup: Record "NPR Adyen Setup";
        _AdyenManagement: Codeunit "NPR Adyen Management";
}
