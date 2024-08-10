page 6150854 "NPR RS Fiscalisation Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'RS Tax Fiscalization Setup';
    ContextSensitiveHelpPage = 'docs/fiscalization/serbia/how-to/setup/';
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
                    ToolTip = 'Specifies the value of the Enable RS Fiscalization field.';

                    trigger OnValidate()
                    begin
                        if xRec."Enable RS Fiscal" <> Rec."Enable RS Fiscal" then
                            EnabledValueChanged := true;
                    end;
                }
                field("Fiscal Proforma on Sales Doc."; Rec."Fiscal Proforma on Sales Doc.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if Sales Documents will automatically be issued as Fiscal Proforma.';
                }
                field("Allow Offline Use"; Rec."Allow Offline Use")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'When this switch is on, it is possible to work when offline.';
                }
                field(Training; Rec.Training)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'When this switch is on, receipts will be issued due the training process and will have a Trainig label on them.';
                }
            }
            group(FiscalBillEMailing)
            {
                Caption = 'Fiscal Bill E-Mailing';
                field("Report Mail Selection"; Rec."Report E-Mail Selection")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the format of E-mailed Fiscal Bills.';
                }
                field("E-Mail Subject"; Rec."E-Mail Subject")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the subject of the E-Mailed Fiscal Bill.';
                }
            }
            group(LPFRAccess)
            {
                Caption = 'L-PFR Access Parameters';
                field("Sandbox URL"; Rec."Sandbox URL")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Sandbox URL.';
                }
            }
            group(SUFConfiguration)
            {
                Caption = 'API Sandbox Configuration';

                field("Configuration URL"; Rec."Configuration URL")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Configuration URL.';
                }
                field("Organization Name"; Rec."Organization Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Organization Name - name of the TAX Authority Institution.';
                }
                field("Server Time Zone"; Rec."Server Time Zone")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Server Time Zone - time zone that server is using.';
                }
                field(Country; Rec.Country)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Country of the Tax Authority.';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the City of the Tax Authority.';
                }
                field(Street; Rec.Street)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Street of the Tax Authority.';
                }
                field("Environment Name"; Rec."Environment Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Environment Name.';
                }
                field("NPT Server URL"; Rec."NPT Server URL")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the NPT Server URL.';
                }
                group(Endpoints)
                {
                    Caption = 'Endpoints';
                    field("TaxPayer Admin Portal URL"; Rec."TaxPayer Admin Portal URL")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the TaxPayer Admin Portal URL - URL of a Electronic Fiscalization Server.';
                    }
                    field("TaxCore API URL"; Rec."TaxCore API URL")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the TaxCore API URL.';
                    }
                    field("VSDC URL"; Rec."VSDC URL")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the VSDC URL.';
                    }
                    field("Root URL"; Rec."Root URL")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the Root URL.';
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
                    ToolTip = 'Specifies the Certification Vendor Name.';
                }
                field(CertificationApp; CertificationApp)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Certified App Name';
                    Editable = false;
                    ToolTip = 'Specifies the Certified App Name.';
                }
                field(CertificationIBNo; CertificationIBNo)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Certified IB Number';
                    Editable = false;
                    ToolTip = 'Specifies the Certified IB Number.';
                }
                field(CertificationVersion; CertificationVersion)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Certified Version';
                    Editable = false;
                    ToolTip = 'Specifies the Certified Version.';
                }
                field(CertificationDate; CertificationDate)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Certification Date';
                    Editable = false;
                    ToolTip = 'Specifies the Certification Date.';
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