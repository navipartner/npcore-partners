page 6184944 "NPR DE Conn. Param. Sets Step"
{
    Caption = 'DE Connection Parameter Sets';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR DE Audit Setup";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Repeater)
            {
                field("Primary Key"; Rec."Primary Key")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies a code to identify this set of DE Fiskaly connection parameters.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies a text that describes the set of DE Fiskaly connection parameters.';
                }
                field("Api URL"; Rec."Api URL")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the URL for the Fiskaly API';
                }
                field("Submission Api URL"; Rec."Submission Api URL")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the URL for the Fiskaly submission API.';
                }
                field(ApiKeyField; ApiKeyField)
                {
                    Caption = 'Api Key';
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Api Key field';
                    ApplicationArea = NPRRetail;

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
                    Caption = 'Api Secret';
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Api Secret field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if ApiSecretField = '' then
                            DESecretMgt.RemoveSecretKey(Rec.ApiSecretLbl())
                        else
                            DESecretMgt.SetSecretKey(Rec.ApiSecretLbl(), ApiSecretField);
                    end;
                }
                field("Taxpayer Created"; Rec."Taxpayer Created")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the taxpayer is created at Fiskaly.';
                }
                field("Taxpayer Person Type"; Rec."Taxpayer Person Type")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the person type of the taxpayer.';
                }
                field("Taxpayer Registration No."; Rec."Taxpayer Registration No.")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the registration number of the taxpayer.';
                }
                field("Taxpayer Tax Office Number"; Rec."Taxpayer Tax Office Number")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the tax office number of the taxpayer.';
                }
                field("Taxpayer VAT Registration No."; Rec."Taxpayer VAT Registration No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the VAT registration number of the taxpayer.';
                }
                field("Taxpayer Company Name"; Rec."Taxpayer Company Name")
                {
                    ApplicationArea = NPRRetail;
                    Enabled = Rec."Taxpayer Person Type" = Rec."Taxpayer Person Type"::legal;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the company name of the taxpayer.';
                }
                field("Taxpayer Legal Form"; Rec."Taxpayer Legal Form")
                {
                    ApplicationArea = NPRRetail;
                    Enabled = Rec."Taxpayer Person Type" = Rec."Taxpayer Person Type"::legal;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the legal form of the taxpayer.';
                }
                field("Taxpayer Birthdate"; Rec."Taxpayer Birthdate")
                {
                    ApplicationArea = NPRRetail;
                    Enabled = Rec."Taxpayer Person Type" = Rec."Taxpayer Person Type"::natural;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the birthdate of the taxpayer.';
                }
                field("Taxpayer First Name"; Rec."Taxpayer First Name")
                {
                    ApplicationArea = NPRRetail;
                    Enabled = Rec."Taxpayer Person Type" = Rec."Taxpayer Person Type"::natural;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the first name of the taxpayer.';
                }
                field("Taxpayer Last Name"; Rec."Taxpayer Last Name")
                {
                    ApplicationArea = NPRRetail;
                    Enabled = Rec."Taxpayer Person Type" = Rec."Taxpayer Person Type"::natural;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the last name of the taxpayer.';
                }
                field("Taxpayer Identification No."; Rec."Taxpayer Identification No.")
                {
                    ApplicationArea = NPRRetail;
                    Enabled = Rec."Taxpayer Person Type" = Rec."Taxpayer Person Type"::natural;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the identiciation number of the taxpayer.';
                }
                field("Taxpayer Name Prefix"; Rec."Taxpayer Name Prefix")
                {
                    ApplicationArea = NPRRetail;
                    Enabled = Rec."Taxpayer Person Type" = Rec."Taxpayer Person Type"::natural;
                    ToolTip = 'Specifies the name prefix of the taxpayer.';
                }
                field("Taxpayer Salutation"; Rec."Taxpayer Salutation")
                {
                    ApplicationArea = NPRRetail;
                    Enabled = Rec."Taxpayer Person Type" = Rec."Taxpayer Person Type"::natural;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the salutation of the taxpayer.';
                }
                field("Taxpayer Name Suffix"; Rec."Taxpayer Name Suffix")
                {
                    ApplicationArea = NPRRetail;
                    Enabled = Rec."Taxpayer Person Type" = Rec."Taxpayer Person Type"::natural;
                    ToolTip = 'Specifies the name suffix of the taxpayer.';
                }
                field("Taxpayer Title"; Rec."Taxpayer Title")
                {
                    ApplicationArea = NPRRetail;
                    Enabled = Rec."Taxpayer Person Type" = Rec."Taxpayer Person Type"::natural;
                    ToolTip = 'Specifies the title of the taxpayer.';
                }
                field("Taxpayer Web Address"; Rec."Taxpayer Web Address")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the web address of the taxpayer.';
                }
                field("Taxpayer Street"; Rec."Taxpayer Street")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the street of the taxpayer.';
                }
                field("Taxpayer House Number"; Rec."Taxpayer House Number")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the house number of the taxpayer.';
                }
                field("Taxpayer House Number Suffix"; Rec."Taxpayer House Number Suffix")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the house number suffix of the taxpayer.';
                }
                field("Taxpayer Town"; Rec."Taxpayer Town")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the town of the taxpayer.';
                }
                field("Taxpayer ZIP Code"; Rec."Taxpayer ZIP Code")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the ZIP code of the taxpayer.';
                }
                field("Taxpayer Additional Address"; Rec."Taxpayer Additional Address")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the additional address information of the taxpayer.';
                }
                field("Taxpayer International Address"; Rec."Taxpayer International Address")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the taxpayer has international address.';
                }
                field("Taxpayer Country/Region Code"; Rec."Taxpayer Country/Region Code")
                {
                    ApplicationArea = NPRRetail;
                    Enabled = Rec."Taxpayer International Address";
                    ShowMandatory = true;
                    ToolTip = 'Specifies the country/region of the international taxpayer.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateUpdateTaxpayer)
            {
                ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;
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