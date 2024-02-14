page 6151395 "NPR RS Configuration Step"
{
    Caption = 'RS Fiscal Configuration Step';
    Extensible = false;
    PageType = CardPart;
    SourceTable = "NPR RS Fiscalisation Setup";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(LPFRAccess)
            {
                Caption = 'L-PFR Access Parameters';
                field("Sandbox URL"; Rec."Sandbox URL")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Sandbox URL field.';
                    trigger OnValidate()
                    begin
                        if not RSFiscalizationSetup.Get() then
                            RSFiscalizationSetup.Init();
                        RSFiscalizationSetup."Sandbox URL" := Rec."Sandbox URL";
                        if not RSFiscalizationSetup.Insert() then
                            RSFiscalizationSetup.Modify();
                    end;

                }
            }
            group(SUFConfiguration)
            {
                Caption = 'API Sandbox Configuration';

                field("Configuration URL"; Rec."Configuration URL")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Configuration URL field.';
                    trigger OnValidate()
                    begin
                        if not RSFiscalizationSetup.Get() then
                            RSFiscalizationSetup.Init();
                        RSFiscalizationSetup."Configuration URL" := Rec."Configuration URL";
                        if not RSFiscalizationSetup.Insert() then
                            RSFiscalizationSetup.Modify();
                    end;
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
                ToolTip = 'Executing this action, a SUF configuration is pulled from Tax Authority.';
                trigger OnAction()
                var
                    RSTaxCommunicationMgt: Codeunit "NPR RS Tax Communication Mgt.";
                begin
                    RSTaxCommunicationMgt.PullAndFillSUFConfiguration();
                    CopyRealToTemp();
                end;
            }
        }
    }

    procedure CopyRealToTemp()
    begin
        if not RSFiscalizationSetup.FindFirst() then
            exit;
        Rec.TransferFields(RSFiscalizationSetup);
        if not Rec.Insert() then
            Rec.Modify();
    end;

    internal procedure RSConfigurationToModify(): Boolean
    begin
        exit(Rec."Environment Name" <> '');
    end;

    internal procedure CreateRSConfigurationData()
    begin
        if not Rec.FindFirst() then
            exit;
        if not RSFiscalizationSetup.Get() then
            RSFiscalizationSetup.Init();
        if Rec."Sandbox URL" <> xRec."Sandbox URL" then
            RSFiscalizationSetup."Sandbox URL" := Rec."Sandbox URL";
        if Rec."Configuration URL" <> xRec."Configuration URL" then
            RSFiscalizationSetup."Configuration URL" := Rec."Configuration URL";
        if not RSFiscalizationSetup.Insert() then
            RSFiscalizationSetup.Modify();
    end;

    var
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
}