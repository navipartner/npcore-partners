page 6151224 "NPR NO Fiscalization Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'NO Tax Fiscalisation Setup';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR NO Fiscalization Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General Settings';

                field("Enable NO Fiscal"; Rec."Enable NO Fiscal")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Enable NO Fiscalisation field.';
                    trigger OnValidate()
                    begin
                        if xRec."Enable NO Fiscal" <> Rec."Enable NO Fiscal" then
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
                    ToolTip = 'Specifies the value of the Signing Certificate Password field';
                }
                field("Signing Certificate Thumbprint"; Rec."Signing Certificate Thumbprint")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Signing Certificate Thumbprint field';
                }
            }
            group(SAFTCash)
            {
                field("SAF-T Audit File Sender"; Rec."SAF-T Audit File Sender")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the SAF-T Audit File Sender field.';
                }
                field("SAF-T Contact No."; Rec."SAF-T Contact No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the SAF-T Contact No. field.';
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
                ToolTip = 'Executes the Upload Certificate action';

                trigger OnAction()
                var
                    NOAuditMgt: Codeunit "NPR NO Audit Mgt.";
                begin
                    NOAuditMgt.ImportCertificate();
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