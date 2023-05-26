page 6150854 "NPR RS Fiscalisation Setup"
{
    ApplicationArea = NPRRSFiscal;
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
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Enable RS Fiscalisation field.';
                    trigger OnValidate()
                    var
                        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
                    begin
                        RSAuditMgt.EnableApplicationAreaForNPRRSFiscal(Rec."Enable RS Fiscal");
                    end;
                }
                field("Allow Offline Use"; Rec."Allow Offline Use")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Allow Offline Use field.';
                }
                field(Training; Rec.Training)
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Training field.';
                }
            }
            group(FiscalBillEMailing)
            {
                Caption = 'Fiscal Bill E-Mailing';
                field("Report Mail Selection"; Rec."Report E-Mail Selection")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Report E-Mail Selection field.';
                }
                field("E-Mail Subject"; Rec."E-Mail Subject")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the E-Mail Subject field.';
                }
            }
            group(LPRFAccess)
            {
                Caption = 'L-PRF Access Parameters';
                field("Sandbox URL"; Rec."Sandbox URL")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Sandbox URL field.';
                }
            }
            group(SUFConfiguration)
            {
                Caption = 'API Sandbox Configuration';

                field("Configuration URL"; Rec."Configuration URL")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Configuration URL field.';
                }
                field("Organization Name"; Rec."Organization Name")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Organization Name field.';
                }
                field("Server Time Zone"; Rec."Server Time Zone")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Server Time Zone field.';
                }
                field(Country; Rec.Country)
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Country field.';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the City field.';
                }
                field(Street; Rec.Street)
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Street field.';
                }
                field("Environment Name"; Rec."Environment Name")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Environment Name field.';
                }
                field("NPT Server URL"; Rec."NPT Server URL")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the NPT Server URL field.';
                }
                group(Endpoints)
                {
                    Caption = 'Endpoints';
                    field("TaxPayer Admin Portal URL"; Rec."TaxPayer Admin Portal URL")
                    {
                        ApplicationArea = NPRRSFiscal;
                        ToolTip = 'Specifies the value of the TaxPayer Admin Portal URL field.';
                    }
                    field("TaxCore API URL"; Rec."TaxCore API URL")
                    {
                        ApplicationArea = NPRRSFiscal;
                        ToolTip = 'Specifies the value of the TaxCore API URL field.';
                    }
                    field("VSDC URL"; Rec."VSDC URL")
                    {
                        ApplicationArea = NPRRSFiscal;
                        ToolTip = 'Specifies the value of the VSDC URL field.';
                    }
                    field("Root URL"; Rec."Root URL")
                    {
                        ApplicationArea = NPRRSFiscal;
                        ToolTip = 'Specifies the value of the Root URL field.';
                    }
                }
            }
            group(CertificationDetails)
            {
                Caption = 'Certification Details';
                field(CertificationVendor; CertificationVendor)
                {
                    ApplicationArea = NPRRSFiscal;
                    Caption = 'Vendor Name';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Vendor Name field.';
                }
                field(CertificationApp; CertificationApp)
                {
                    ApplicationArea = NPRRSFiscal;
                    Caption = 'Certified App Name';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Certified App Name field.';
                }
                field(CertificationIBNo; CertificationIBNo)
                {
                    ApplicationArea = NPRRSFiscal;
                    Caption = 'Certified IB Number';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Certified IB Number field.';
                }
                field(CertificationVersion; CertificationVersion)
                {
                    ApplicationArea = NPRRSFiscal;
                    Caption = 'Certified Version';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Certified Version field.';
                }
                field(CertificationDate; CertificationDate)
                {
                    ApplicationArea = NPRRSFiscal;
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
                ApplicationArea = NPRRSFiscal;
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
                ApplicationArea = NPRRSFiscal;
                Caption = 'Allowed Tax Rates List';
                Image = ValidateEmailLoggingSetup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = page "NPR RS Allowed Tax Rates List";
                ToolTip = 'Opens Allowed Tax Rates List page.';
            }
            action(RSAppArea)
            {
                ApplicationArea = NPRRSFiscal;
                Caption = 'RS Application Area Setup';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = page "NPR RS Fiscal App. Area Setup";
                ToolTip = 'Open RS Application Area Setup page';
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

    var
        Certification: Dictionary of [Text, Text];
        CertificationApp: Text;
        CertificationDate: Text;
        CertificationIBNo: Text;
        CertificationVendor: Text;
        CertificationVersion: Text;
}