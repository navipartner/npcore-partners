page 6151343 "NPR CRO Upload Cert. Step"
{
    Extensible = False;
    Caption = 'CRO Upload Certificate Setup';
    PageType = CardPart;
    SourceTable = "NPR CRO Fiscalization Setup";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(CertificateInfo)
            {
                Caption = 'Digital Certificate Information';
                ShowCaption = false;

                field("Signing Certificate Password"; Rec."Signing Certificate Password")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the password of the signing certificate.';
                    trigger OnValidate()
                    begin
                        if not CROFiscalizationSetup.Get() then
                            CROFiscalizationSetup.Init();
                        CROFiscalizationSetup."Signing Certificate Password" := Rec."Signing Certificate Password";
                        if not CROFiscalizationSetup.Insert() then
                            CROFiscalizationSetup.Modify();
                    end;
                }
                field("Signing Certificate Thumbprint"; Rec."Signing Certificate Thumbprint")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the thumbprint of the signing certificate.';
                }
                field("Certificate Subject OIB"; Rec."Certificate Subject OIB")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the subject OIB of the signing certificate.';
                }
            }

            group(FiscEnvironmentInfo)
            {
                Caption = 'Fiscalization Environment Setup';

                field("Environment URL"; Rec."Environment URL")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies URL of the Tax Authorities'' fiscalization environment';
                    trigger OnValidate()
                    begin
                        if not CROFiscalizationSetup.Get() then
                            CROFiscalizationSetup.Init();
                        CROFiscalizationSetup."Environment URL" := Rec."Environment URL";
                        if not CROFiscalizationSetup.Insert() then
                            CROFiscalizationSetup.Modify();
                    end;
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
                ToolTip = 'Opens the page for uploading the certificate.';
                trigger OnAction()
                var
                    CROAuditMgt: Codeunit "NPR CRO Audit Mgt.";
                begin
                    CROAuditMgt.ImportCertificate();
                    CopyRealToTemp();
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

    internal procedure CopyRealToTemp()
    begin
        if not CROFiscalizationSetup.Get() then
            exit;
        Rec.TransferFields(CROFiscalizationSetup);
        if not Rec.Insert() then
            Rec.Modify();
    end;

    internal procedure CROCertificateToModify(): Boolean
    begin
        exit(Rec."Certificate Subject OIB" <> '');
    end;

    internal procedure CreateCROFiscalCertificateData()
    begin
        if not Rec.FindFirst() then
            exit;
        if not CROFiscalizationSetup.Get() then
            CROFiscalizationSetup.Init();
        if Rec."Signing Certificate Password" <> xRec."Signing Certificate Password" then
            CROFiscalizationSetup."Signing Certificate Password" := Rec."Signing Certificate Password";
        if Rec."Certificate Subject OIB" <> xRec."Certificate Subject OIB" then
            CROFiscalizationSetup."Certificate Subject OIB" := Rec."Certificate Subject OIB";
        if Rec."Signing Certificate Thumbprint" <> xRec."Signing Certificate Thumbprint" then
            CROFiscalizationSetup."Signing Certificate Thumbprint" := Rec."Signing Certificate Thumbprint";
        if Rec."Environment URL" <> xRec."Environment URL" then
            CROFiscalizationSetup."Environment URL" := Rec."Environment URL";
        if not CROFiscalizationSetup.Insert() then
            CROFiscalizationSetup.Modify();
    end;

    var
        CROFiscalizationSetup: Record "NPR CRO Fiscalization Setup";
}