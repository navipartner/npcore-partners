page 6151224 "NPR NO Fiscalization Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'NO Tax Fiscalisation Setup';
    ContextSensitiveHelpPage = 'docs/fiscalization/norway/how-to/setup/';
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
                    ToolTip = 'Specifies the value of the Signing Certificate Password field.';
                }
                field("Signing Certificate Thumbprint"; Rec."Signing Certificate Thumbprint")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Signing Certificate Thumbprint field.';
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
            group(Certified)
            {
                Caption = 'Certified Cash Register System';

                field("Certified Model"; CertificationModel)
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Certification Model field.';
                    Caption = 'Certification Model';
                }
                field("Certified Version"; CertificationVersion)
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Certification Version field.';
                    Caption = 'Certification Version';
                }
                field(Manufacturer; Manufacturer)
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Manufacturer field.';
                    Caption = 'Manufacturer';
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
                ToolTip = 'Executes the Upload Certificate action.';

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

    trigger OnAfterGetRecord()
    begin
        InsertCertificatinDetails();
    end;

    trigger OnClosePage()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if EnabledValueChanged then
            ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;

    local procedure InsertCertificatinDetails()
    var
        CertifiedModelLbl: Label 'NP Retail', Locked = true;
        CertifiedVersionLbl: Label '2017', Locked = true;
        ManufacturerLbl: Label 'NaviPartner', Locked = true;
    begin
        CertificationModel := CertifiedModelLbl;
        CertificationVersion := CertifiedVersionLbl;
        Manufacturer := ManufacturerLbl;
    end;

    var
        EnabledValueChanged: Boolean;
        CertificationModel: Text;
        CertificationVersion: Text;
        Manufacturer: Text;
}