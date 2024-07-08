page 6151325 "NPR DK Fiscalization Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'DK Fiscalization Setup';
    ContextSensitiveHelpPage = 'docs/fiscalization/denmark/how-to/setup/';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR DK Fiscalization Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General Settings';

                field("Enable DK Fiscal"; Rec."Enable DK Fiscal")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Enable DK Fiscalization field.';
                    trigger OnValidate()
                    begin
                        if xRec."Enable DK Fiscal" <> Rec."Enable DK Fiscal" then
                            EnabledValueChanged := true;
                    end;
                }
            }
            group(SignCertificate)
            {
                Caption = 'Sign Certificate';
                field("Signing Certificate Password"; Rec."Signing Certificate Password")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Password for the certificate that should be uploaded.';
                }
                field("Signing Certificate Thumbprint"; Rec."Signing Certificate Thumbprint")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the Signing Certificate Thumbprint.';
                }
            }
            group(SAFTCash)
            {
                field("SAF-T Audit File Sender"; Rec."SAF-T Audit File Sender")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the SAF-T Audit File Sender.';
                }
                field("SAF-T Contact No."; Rec."SAF-T Contact No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the SAF-T Export contact person.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(UploadCertificate)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Upload Certificate';
                Image = ImportCodes;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Click here to Upload Certificate.';

                trigger OnAction()
                var
                    DKAuditMgt: Codeunit "NPR DK Audit Mgt.";
                begin
                    DKAuditMgt.ImportCertificate();
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