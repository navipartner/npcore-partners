page 6184830 "NPR DK Cert Upload Step"
{
    Caption = 'DK Certificate Upload';
    PageType = CardPart;
    SourceTable = "NPR DK Fiscalization Setup";
    SourceTableTemporary = true;
    Extensible = false;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(SignCertificate)
            {
                Caption = 'Sign Certificate';
                field("Signing Certificate Password"; Rec."Signing Certificate Password")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Provide the password for the signing certificate.';
                }
                field("Signing Certificate Thumbprint"; Rec."Signing Certificate Thumbprint")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'The thumbprint of the signing certificate.';
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

    internal procedure CopyRealToTemp()
    begin
        if not DKFiscalizationSetup.Get() then
            exit;
        Rec.TransferFields(DKFiscalizationSetup);
        if not Rec.Insert() then
            Rec.Modify();
    end;

    internal procedure CreateCertificateData()
    begin
        if not Rec.Get() then
            exit;
        if not DKFiscalizationSetup.Get() then
            DKFiscalizationSetup.Init();
        if Rec."Signing Certificate Password" <> xRec."Signing Certificate Password" then
            DKFiscalizationSetup."Signing Certificate Password" := Rec."Signing Certificate Password";
        if Rec."Signing Certificate Thumbprint" <> xRec."Signing Certificate Thumbprint" then
            DKFiscalizationSetup."Signing Certificate Thumbprint" := Rec."Signing Certificate Thumbprint";
        if not DKFiscalizationSetup.Insert() then
            DKFiscalizationSetup.Modify();
    end;

    local procedure CheckIsDataPopulated(): Boolean
    begin
        if not Rec.Get() then
            exit(false);
        exit((Rec."Signing Certificate Password" <> '') and ((Rec."Signing Certificate Thumbprint") <> ''));
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        exit(CheckIsDataPopulated());
    end;

    var
        DKFiscalizationSetup: Record "NPR DK Fiscalization Setup";
}
