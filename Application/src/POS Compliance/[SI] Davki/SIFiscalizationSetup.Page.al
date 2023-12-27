page 6150767 "NPR SI Fiscalization Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'SI Tax Fiscalisation Setup';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR SI Fiscalization Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General Settings';

                field("Enable SI Fiscal"; Rec."Enable SI Fiscal")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the SI Fiscalization is enabled.';
                    trigger OnValidate()
                    begin
                        if xRec."Enable SI Fiscal" <> Rec."Enable SI Fiscal" then
                            EnabledValueChanged := true;
                    end;
                }
            }
            group(Certificates)
            {
                Caption = 'Signing Certificate Setup';

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
                field("Certificate Subject Ident."; Rec."Certificate Subject Ident.")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the identification of the Certificate Issuer.';
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

                field("Receipt No. Series"; Rec."Receipt No. Series")
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
                    SIAuditMgt: Codeunit "NPR SI Audit Mgt.";
                begin
                    SIAuditMgt.ImportCertificate();
                end;
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