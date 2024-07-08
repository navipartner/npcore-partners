page 6151569 "NPR SI Upload Cert. Step"
{
    Extensible = False;
    Caption = 'SI Upload Certificate Setup';
    PageType = CardPart;
    SourceTable = "NPR SI Fiscalization Setup";
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
                        if not SIFiscalizationSetup.Get() then
                            SIFiscalizationSetup.Init();
                        SIFiscalizationSetup."Signing Certificate Password" := Rec."Signing Certificate Password";
                        if not SIFiscalizationSetup.Insert() then
                            SIFiscalizationSetup.Modify();
                    end;
                }
                field("Signing Certificate Thumbprint"; Rec."Signing Certificate Thumbprint")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the thumbprint of the signing certificate.';
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
                        if not SIFiscalizationSetup.Get() then
                            SIFiscalizationSetup.Init();
                        SIFiscalizationSetup."Environment URL" := Rec."Environment URL";
                        if not SIFiscalizationSetup.Insert() then
                            SIFiscalizationSetup.Modify();
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
                    SIAuditMgt: Codeunit "NPR SI Audit Mgt.";
                begin
                    SIAuditMgt.ImportCertificate();
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
        if not SIFiscalizationSetup.Get() then
            exit;
        Rec.TransferFields(SIFiscalizationSetup);
        if not Rec.Insert() then
            Rec.Modify();
    end;

    internal procedure SICertificateToModify(): Boolean
    begin
        exit(Rec."Signing Certificate Thumbprint" <> '');
    end;

    internal procedure CreateSIFiscalCertificateData()
    begin
        if not Rec.FindFirst() then
            exit;
        if not SIFiscalizationSetup.Get() then
            SIFiscalizationSetup.Init();
        if Rec."Signing Certificate Password" <> xRec."Signing Certificate Password" then
            SIFiscalizationSetup."Signing Certificate Password" := Rec."Signing Certificate Password";
        if Rec."Signing Certificate Thumbprint" <> xRec."Signing Certificate Thumbprint" then
            SIFiscalizationSetup."Signing Certificate Thumbprint" := Rec."Signing Certificate Thumbprint";
        if Rec."Environment URL" <> xRec."Environment URL" then
            SIFiscalizationSetup."Environment URL" := Rec."Environment URL";
        if not SIFiscalizationSetup.Insert() then
            SIFiscalizationSetup.Modify();
    end;

    var
        SIFiscalizationSetup: Record "NPR SI Fiscalization Setup";
}