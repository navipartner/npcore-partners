page 6184577 "NPR SE Fiscalization Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'SE CleanCash Fiscalisation Setup';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR SE Fiscalization Setup.";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General Settings';

                field("Enable SE Fiscal"; Rec."Enable SE Fiscal")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Enable SE Fiscalisation field.';
                    trigger OnValidate()
                    begin
                        if xRec."Enable SE Fiscal" <> Rec."Enable SE Fiscal" then
                            EnabledValueChanged := true;
                    end;
                }
            }
            group(Certified)
            {
                Caption = 'Certification Details';

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
                field(Manufacturer; CertifiedSoftwareDesignation)
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Manufacturer field.';
                    Caption = 'Certified Software Designation';
                }
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
        CertifiedModelLbl: Label 'NP Retail SE', Locked = true;
        CertifiedVersionLbl: Label '1.00', Locked = true;
        CertifiedSoftwareDesignationLbl: Label 'Microsoft Business Central', Locked = true;
    begin
        CertificationModel := CertifiedModelLbl;
        CertificationVersion := CertifiedVersionLbl;
        CertifiedSoftwareDesignation := CertifiedSoftwareDesignationLbl;
    end;

    var
        EnabledValueChanged: Boolean;
        CertificationModel: Text;
        CertificationVersion: Text;
        CertifiedSoftwareDesignation: Text;
}