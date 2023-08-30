page 6150854 "NPR RS Fiscalisation Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'RS Tax Fiscalisation Setup';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR RS Fiscalisation Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General Settings';

                field("Enable RS Fiscal"; Rec."Enable RS Fiscal")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Enable RS Fiscalisation field.';

                    trigger OnValidate()
                    begin
                        if xRec."Enable RS Fiscal" <> Rec."Enable RS Fiscal" then
                            EnabledValueChanged := true;
                    end;
                }
                field("Allow Offline Use"; Rec."Allow Offline Use")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Allow Offline Use field.';
                }
                field(Training; Rec.Training)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Training field.';
                }
            }
            group(FiscalBillEMailing)
            {
                Caption = 'Fiscal Bill E-Mailing';
                field("Report Mail Selection"; Rec."Report E-Mail Selection")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Report E-Mail Selection field.';
                }
                field("E-Mail Subject"; Rec."E-Mail Subject")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the E-Mail Subject field.';
                }
            }
            group(LPRFAccess)
            {
                Caption = 'L-PRF Access Parameters';
                field("Sandbox URL"; Rec."Sandbox URL")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Sandbox URL field.';
                }
            }
            group(SUFConfiguration)
            {
                Caption = 'API Sandbox Configuration';

                field("Configuration URL"; Rec."Configuration URL")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Configuration URL field.';
                }
                field("Organization Name"; Rec."Organization Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Organization Name field.';
                }
                field("Server Time Zone"; Rec."Server Time Zone")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Server Time Zone field.';
                }
                field(Country; Rec.Country)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Country field.';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the City field.';
                }
                field(Street; Rec.Street)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Street field.';
                }
                field("Environment Name"; Rec."Environment Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Environment Name field.';
                }
                field("NPT Server URL"; Rec."NPT Server URL")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the NPT Server URL field.';
                }
                group(Endpoints)
                {
                    Caption = 'Endpoints';
                    field("TaxPayer Admin Portal URL"; Rec."TaxPayer Admin Portal URL")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the TaxPayer Admin Portal URL field.';
                    }
                    field("TaxCore API URL"; Rec."TaxCore API URL")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the TaxCore API URL field.';
                    }
                    field("VSDC URL"; Rec."VSDC URL")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the VSDC URL field.';
                    }
                    field("Root URL"; Rec."Root URL")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Root URL field.';
                    }
                }
            }
            group(CertificationDetails)
            {
                Caption = 'Certification Details';
                field(CertificationVendor; CertificationVendor)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Vendor Name';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Vendor Name field.';
                }
                field(CertificationApp; CertificationApp)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Certified App Name';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Certified App Name field.';
                }
                field(CertificationIBNo; CertificationIBNo)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Certified IB Number';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Certified IB Number field.';
                }
                field(CertificationVersion; CertificationVersion)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Certified Version';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Certified Version field.';
                }
                field(CertificationDate; CertificationDate)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Certification Date';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Certification Date field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(FillSUFConfiguration)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Fill SUF Configuration';
                Image = ApprovalSetup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Executing this action, a SUF configuration is pulled from Tax Authority.';
                trigger OnAction()
                var
                    RSTaxCommunicationMgt: Codeunit "NPR RS Tax Communication Mgt.";
                begin
                    RSTaxCommunicationMgt.PullAndFillSUFConfiguration();
                end;
            }
            action(AllowedTaxRates)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Allowed Tax Rates List';
                Image = ValidateEmailLoggingSetup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = page "NPR RS Allowed Tax Rates List";
                ToolTip = 'Opens Allowed Tax Rates List page.';
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
    var
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
    begin
        RSAuditMgt.FillCertificationData(Certification);
        Certification.Get('Vendor', CertificationVendor);
        Certification.Get('RSFiscalName', CertificationApp);
        Certification.Get('RSFiscalIBNo', CertificationIBNo);
        Certification.Get('RSFiscalVersion', CertificationVersion);
        Certification.Get('CertificationDate', CertificationDate);
    end;

    trigger OnClosePage()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if EnabledValueChanged then
            ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany(); // refresh of experience tier has to be done in order to trigger OnGetEssentialExperienceAppAreas publisher
    end;

    var
        EnabledValueChanged: Boolean;
        Certification: Dictionary of [Text, Text];
        CertificationApp: Text;
        CertificationDate: Text;
        CertificationIBNo: Text;
        CertificationVendor: Text;
        CertificationVersion: Text;
}