page 6014421 "NPR DE Audit Setup"
{
    Caption = 'DE Connection Parameter Set';
    ContextSensitiveHelpPage = 'docs/fiscalization/germany/how-to/setup/';
    Extensible = False;
    PageType = Card;
    SourceTable = "NPR DE Audit Setup";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Primary Key"; Rec."Primary Key")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies a code to identify this set of DE Fiskaly connection parameters.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies a text that describes the set of DE Fiskaly connection parameters.';
                }
            }
            group(Connection)
            {
                Caption = 'Connection Parameters';
                group(URLs)
                {
                    ShowCaption = false;
                    field("Api URL"; Rec."Api URL")
                    {
                        ApplicationArea = NPRDEFiscal;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the URL for the Fiskaly API';
                    }
                    field("Submission Api URL"; Rec."Submission Api URL")
                    {
                        ApplicationArea = NPRDEFiscal;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the URL for the Fiskaly submission API.';
                    }
                    field("DSFINVK Api URL"; Rec."DSFINVK Api URL")
                    {
                        ApplicationArea = NPRDEFiscal;
                        Importance = Additional;
                        ToolTip = 'Specifies URL of the DSFINVK API';
                        Visible = false;
                    }
                }
                group(Keys)
                {
                    ShowCaption = false;
                    field(ApiKeyField; ApiKeyField)
                    {
                        ApplicationArea = NPRDEFiscal;
                        Caption = 'Api Key';
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Api Key field';

                        trigger OnValidate()
                        begin
                            if ApiKeyField = '' then
                                DESecretMgt.RemoveSecretKey(Rec.ApiKeyLbl())
                            else
                                DESecretMgt.SetSecretKey(Rec.ApiKeyLbl(), ApiKeyField);
                        end;
                    }
                    field(ApiSecretField; ApiSecretField)
                    {
                        ApplicationArea = NPRDEFiscal;
                        Caption = 'Api Secret';
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Api Secret field';

                        trigger OnValidate()
                        begin
                            if ApiSecretField = '' then
                                DESecretMgt.RemoveSecretKey(Rec.ApiSecretLbl())
                            else
                                DESecretMgt.SetSecretKey(Rec.ApiSecretLbl(), ApiSecretField);
                        end;
                    }
                }
            }
            group(Taxpayer)
            {
                Caption = 'Taxpayer';
                field("Taxpayer Created"; Rec."Taxpayer Created")
                {
                    ApplicationArea = NPRDEFiscal;
                    Caption = 'Created';
                    ToolTip = 'Specifies whether the taxpayer is created at Fiskaly.';
                }
                field("Taxpayer Person Type"; Rec."Taxpayer Person Type")
                {
                    ApplicationArea = NPRDEFiscal;
                    Caption = 'Person Type';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the person type of the taxpayer.';
                }
                field("Taxpayer Registration No."; Rec."Taxpayer Registration No.")
                {
                    ApplicationArea = NPRDEFiscal;
                    Caption = 'Registration No.';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the registration number of the taxpayer.';
                }
                field("Taxpayer Tax Office Number"; Rec."Taxpayer Tax Office Number")
                {
                    ApplicationArea = NPRDEFiscal;
                    Caption = 'Tax Office Number';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the tax office number of the taxpayer.';
                }
                field("Taxpayer VAT Registration No."; Rec."Taxpayer VAT Registration No.")
                {
                    ApplicationArea = NPRDEFiscal;
                    Caption = 'VAT Registration No.';
                    ToolTip = 'Specifies the VAT registration number of the taxpayer.';
                }
                group(TaxpayerInformation)
                {
                    Caption = 'Information';

                    group(LegalTaxpayerInformation)
                    {
                        ShowCaption = false;
                        Visible = Rec."Taxpayer Person Type" = Rec."Taxpayer Person Type"::legal;
                        field("Taxpayer Company Name"; Rec."Taxpayer Company Name")
                        {
                            ApplicationArea = NPRDEFiscal;
                            Caption = 'Company Name';
                            ShowMandatory = true;
                            ToolTip = 'Specifies the company name of the taxpayer.';
                        }
                        field("Taxpayer Legal Form"; Rec."Taxpayer Legal Form")
                        {
                            ApplicationArea = NPRDEFiscal;
                            Caption = 'Legal Form';
                            ShowMandatory = true;
                            ToolTip = 'Specifies the legal form of the taxpayer.';
                        }
                    }
                    group(NaturalTaxpayerInformation)
                    {
                        ShowCaption = false;
                        Visible = Rec."Taxpayer Person Type" = Rec."Taxpayer Person Type"::natural;
                        field("Taxpayer Birthdate"; Rec."Taxpayer Birthdate")
                        {
                            ApplicationArea = NPRDEFiscal;
                            Caption = 'Birthdate';
                            ShowMandatory = true;
                            ToolTip = 'Specifies the birthdate of the taxpayer.';
                        }
                        field("Taxpayer First Name"; Rec."Taxpayer First Name")
                        {
                            ApplicationArea = NPRDEFiscal;
                            Caption = 'First Name';
                            ShowMandatory = true;
                            ToolTip = 'Specifies the first name of the taxpayer.';
                        }
                        field("Taxpayer Last Name"; Rec."Taxpayer Last Name")
                        {
                            ApplicationArea = NPRDEFiscal;
                            Caption = 'Last Name';
                            ShowMandatory = true;
                            ToolTip = 'Specifies the last name of the taxpayer.';
                        }
                        field("Taxpayer Identification No."; Rec."Taxpayer Identification No.")
                        {
                            ApplicationArea = NPRDEFiscal;
                            Caption = 'Identification No.';
                            ShowMandatory = true;
                            ToolTip = 'Specifies the identiciation number of the taxpayer.';
                        }
                        field("Taxpayer Name Prefix"; Rec."Taxpayer Name Prefix")
                        {
                            ApplicationArea = NPRDEFiscal;
                            Caption = 'Name Prefix';
                            ToolTip = 'Specifies the name prefix of the taxpayer.';
                        }
                        field("Taxpayer Salutation"; Rec."Taxpayer Salutation")
                        {
                            ApplicationArea = NPRDEFiscal;
                            Caption = 'Salutation';
                            ShowMandatory = true;
                            ToolTip = 'Specifies the salutation of the taxpayer.';
                        }
                        field("Taxpayer Name Suffix"; Rec."Taxpayer Name Suffix")
                        {
                            ApplicationArea = NPRDEFiscal;
                            Caption = 'Name Suffix';
                            ToolTip = 'Specifies the name suffix of the taxpayer.';
                        }
                        field("Taxpayer Title"; Rec."Taxpayer Title")
                        {
                            ApplicationArea = NPRDEFiscal;
                            Caption = 'Title';
                            ToolTip = 'Specifies the title of the taxpayer.';
                        }
                    }
                    field("Taxpayer Web Address"; Rec."Taxpayer Web Address")
                    {
                        ApplicationArea = NPRDEFiscal;
                        Caption = 'Web Address';
                        ToolTip = 'Specifies the web address of the taxpayer.';
                    }
                }
                group(TaxpayerAddress)
                {
                    Caption = 'Address';
                    field("Taxpayer Street"; Rec."Taxpayer Street")
                    {
                        ApplicationArea = NPRDEFiscal;
                        Caption = 'Street';
                        ShowMandatory = true;
                        ToolTip = 'Specifies the street of the taxpayer.';
                    }
                    field("Taxpayer House Number"; Rec."Taxpayer House Number")
                    {
                        ApplicationArea = NPRDEFiscal;
                        Caption = 'House Number';
                        ShowMandatory = true;
                        ToolTip = 'Specifies the house number of the taxpayer.';
                    }
                    field("Taxpayer House Number Suffix"; Rec."Taxpayer House Number Suffix")
                    {
                        ApplicationArea = NPRDEFiscal;
                        Caption = 'House Number Suffix';
                        ToolTip = 'Specifies the house number suffix of the taxpayer.';
                    }
                    field("Taxpayer Town"; Rec."Taxpayer Town")
                    {
                        ApplicationArea = NPRDEFiscal;
                        Caption = 'Town';
                        ShowMandatory = true;
                        ToolTip = 'Specifies the town of the taxpayer.';
                    }
                    field("Taxpayer ZIP Code"; Rec."Taxpayer ZIP Code")
                    {
                        ApplicationArea = NPRDEFiscal;
                        Caption = 'ZIP Code';
                        ShowMandatory = true;
                        ToolTip = 'Specifies the ZIP code of the taxpayer.';
                    }
                    field("Taxpayer Additional Address"; Rec."Taxpayer Additional Address")
                    {
                        ApplicationArea = NPRDEFiscal;
                        Caption = 'Additional Address';
                        ToolTip = 'Specifies the additional address information of the taxpayer.';
                    }
                    field("Taxpayer International Address"; Rec."Taxpayer International Address")
                    {
                        ApplicationArea = NPRDEFiscal;
                        Caption = 'International Address';
                        ToolTip = 'Specifies whether the taxpayer has international address.';
                    }
                    group(InternationalTaxpayerAddress)
                    {
                        ShowCaption = false;
                        Visible = Rec."Taxpayer International Address";
                        field("Taxpayer Country/Region Code"; Rec."Taxpayer Country/Region Code")
                        {
                            ApplicationArea = NPRDEFiscal;
                            Caption = 'Country/Region Code';
                            ShowMandatory = true;
                            ToolTip = 'Specifies the country/region of the international taxpayer.';
                        }
                    }
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(DEEstablishments)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'DE Establishments';
                Image = Home;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = page "NPR DE Establishments";
                ToolTip = 'Opens DE Establishments page.';
            }
        }
        area(Processing)
        {
            action(CreateUpdateTaxpayer)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Create / Update Taxpayer';
                Image = LinkWeb;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Creates the taxpayer at Fiskaly or updates the existing one.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    DEFiskalyCommunication.UpsertTaxpayer(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(RetrieveTaxpayer)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Retrieve Taxpayer';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Retrieves the latest information about the taxpayer from Fiskaly.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    DEFiskalyCommunication.RetrieveTaxpayer(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.SetDefaultValuesForNewRecord();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        ApiKeyField := '';
        ApiSecretField := '';

        if DESecretMgt.HasSecretKey(Rec.ApiKeyLbl()) then
            ApiKeyField := '***';
        if DESecretMgt.HasSecretKey(Rec.ApiSecretLbl()) then
            ApiSecretField := '***';
    end;

    var
        DESecretMgt: Codeunit "NPR DE Secret Mgt.";
        ApiKeyField: Text[200];
        ApiSecretField: Text[200];
}