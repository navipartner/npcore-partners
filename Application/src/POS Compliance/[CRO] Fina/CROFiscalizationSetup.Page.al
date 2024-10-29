page 6151214 "NPR CRO Fiscalization Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'CRO Tax Fiscalization Setup';
    ContextSensitiveHelpPage = 'docs/fiscalization/croatia/how-to/setup/';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR CRO Fiscalization Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(Enabling)
            {
                Caption = 'Enable Fiscalization';

                field("Enable CRO Fiscal"; Rec."Enable CRO Fiscal")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the CRO Fiscalization is enabled.';
                    trigger OnValidate()
                    begin
                        if xRec."Enable CRO Fiscal" <> Rec."Enable CRO Fiscal" then
                            EnabledValueChanged := true;

                        if EnabledValueChanged and (not Rec."Enable CRO Fiscal") then
                            DisableCustLedgerEntryPosting();
                    end;
                }
            }

            group(CertificateInfo)
            {
                Caption = 'Digital Certificate Information';

                field("Signing Certificate Password"; Rec."Signing Certificate Password")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the password of the Signing Certificate.';
                }
                field("Signing Certificate Thumbprint"; Rec."Signing Certificate Thumbprint")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the Thumbprint of the Signing Certificate.';
                }
                field("Certificate Subject OIB"; Rec."Certificate Subject OIB")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the Certificate Subject OIB of the uploaded Certificate.';
                }
            }

            group(FiscEnvironmentInfo)
            {
                Caption = 'Fiscalization Environment Setup';

                field("Environment URL"; Rec."Environment URL")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the URL of the Fiscalization Environment.';
                }
            }

            group(NoSeries)
            {
                Caption = 'No. Series Setup';

                field("Bill No. Series"; Rec."Bill No. Series")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Fiscal Bill No. Series.';
                }
            }

            group("Customer Ledger Entry Posting Setup")
            {
                Caption = 'Customer Ledger Entry Posting Setup';

                field("Enable POS Entry CLE Posting"; Rec."Enable POS Entry CLE Posting")
                {
                    Caption = 'Enable Posting';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Enable posting Customer Ledger Entries from POS Entry when customer is selected on POS.';
                    Enabled = Rec."Enable CRO Fiscal";
                }
                field("Customer Posting Group Filter"; Rec."Customer Posting Group Filter")
                {
                    ToolTip = 'Set the Customer Posting Group for which Customer Ledger Entries Filter will be posted.';
                    ApplicationArea = NPRRetail;
                    Enabled = Rec."Enable POS Entry CLE Posting";
                }
                field("Enable Legal Ent. CLE Posting"; Rec."Enable Legal Ent. CLE Posting")
                {
                    Caption = 'Post Only for Legal Entites';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Enable posting Customer Ledger Entries for customers that are Legal Entities - have VAT Registration No. set on their Customer Card.';
                    Enabled = Rec."Enable POS Entry CLE Posting";
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Upload Certificate")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Upload Certificate';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Opens the page for Certificate upload.';
                trigger OnAction()
                var
                    CROAuditMgt: Codeunit "NPR CRO Audit Mgt.";
                begin
                    CROAuditMgt.ImportCertificate();
                end;
            }
            action(POSPaymentMethod)
            {
                ApplicationArea = NPRRetail;
                Caption = 'POS Payment Methods';
                Image = SetupPayment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = page "NPR CRO POS Paym. Method Mapp.";
                ToolTip = 'Opens POS Payment Method list page.';
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

    trigger OnClosePage()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if EnabledValueChanged then
            ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;

    local procedure DisableCustLedgerEntryPosting()
    begin
        Clear(Rec."Enable POS Entry CLE Posting");
        Clear(Rec."Enable Legal Ent. CLE Posting");
        Clear(Rec."Customer Posting Group Filter");
    end;

    var
        EnabledValueChanged: Boolean;
}