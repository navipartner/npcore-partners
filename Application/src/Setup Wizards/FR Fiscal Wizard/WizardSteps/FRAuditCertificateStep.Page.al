page 6184818 "NPR FR Audit Certificate Step"
{
    Caption = 'FR Audit Certificate Setup';
    Extensible = false;
    PageType = ListPart;
    SourceTable = "NPR FR Audit Setup";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(CertificateInfo)
            {
                Caption = 'Certificate Information';

                field(FiscalVersion; FRAuditMgt.GetFiscalVersion())
                {
                    ToolTip = 'Specifies the value of the NP Retail Fiscal Version field';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Caption = 'NPRetail Fiscal Version';
                }

                field(ComplianceVersion; FRAuditMgt.GetComplianceVersion())
                {
                    ToolTip = 'Specifies the value of the Infocert NF525 compliance targeted by current NPRetail Fiscal version';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Caption = 'Infocert Compliance Version';
                }

                field(CertificationNumber; FRAuditMgt.GetCertificationNumber())
                {
                    ToolTip = 'Specifies the value of the NP Retail certification number';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Caption = 'NP Retail Certification Number';
                }

                field("Signing Certificate Password"; Rec."Signing Certificate Password")
                {
                    ToolTip = 'Specifies the value of the Signing Certificate Password field';
                    ApplicationArea = NPRRetail;
                }

                field("Signing Certificate Thumbprint"; Rec."Signing Certificate Thumbprint")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Signing Certificate Thumbprint field';
                    ApplicationArea = NPRRetail;
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
                ToolTip = 'Uploads the signing certificate.';
                Image = Import;

                trigger OnAction()
                begin
                    FRAuditMgt.ImportCertificate();
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
        if not FRAuditSetup.Get() then
            exit;
        Rec.TransferFields(FRAuditSetup);
        if not Rec.Insert() then
            Rec.Modify();
    end;

    internal procedure CreateFRAuditCertificateData()
    begin
        if not Rec.Get() then
            exit;
        if not FRAuditSetup.Get() then
            FRAuditSetup.Init();
        if Rec."Signing Certificate Password" <> xRec."Signing Certificate Password" then
            FRAuditSetup."Signing Certificate Password" := Rec."Signing Certificate Password";
        if Rec."Signing Certificate Thumbprint" <> xRec."Signing Certificate Thumbprint" then
            FRAuditSetup."Signing Certificate Thumbprint" := Rec."Signing Certificate Thumbprint";
        if not FRAuditSetup.Insert() then
            FRAuditSetup.Modify();
    end;

    internal procedure CheckIsDataPopulated(): Boolean
    begin
        if not Rec.Get() then
            exit(false);
        exit((Rec."Signing Certificate Password" <> '') and (Rec."Signing Certificate Thumbprint" <> ''));
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        exit(CheckIsDataPopulated());
    end;

    var
        FRAuditSetup: Record "NPR FR Audit Setup";
        FRAuditMgt: Codeunit "NPR FR Audit Mgt.";
}
