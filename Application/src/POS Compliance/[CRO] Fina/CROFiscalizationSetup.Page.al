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

    var
        EnabledValueChanged: Boolean;
}