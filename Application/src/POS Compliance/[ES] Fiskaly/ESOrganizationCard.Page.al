page 6184702 "NPR ES Organization Card"
{
    Caption = 'ES Organization Card';
    Extensible = false;
    PageType = Card;
    SourceTable = "NPR ES Organization";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the code to identify this ES Fiskaly organization.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the text that describes this ES Fiskaly organization.';
                }
                field(Disabled; Rec.Disabled)
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies whether the record is disabled due to taxpayer information change.';
                }
            }
            group(FiskalyConnectionCredentials)
            {
                Caption = 'Fiskaly Connection Credentials';
                group(Keys)
                {
                    ShowCaption = false;
                    field(APIKey; APIKeyValue)
                    {
                        ApplicationArea = NPRESFiscal;
                        Caption = 'API Key';
                        ExtendedDatatype = Masked;
                        ToolTip = 'Specifies the value of the API Key provided by Fiskaly.';

                        trigger OnValidate()
                        begin
                            if APIKeyValue = '' then
                                ESSecretMgt.RemoveSecretKey(Rec.GetAPIKeyName())
                            else
                                ESSecretMgt.SetSecretKey(Rec.GetAPIKeyName(), APIKeyValue);
                        end;
                    }
                    field(APISecret; APISecretValue)
                    {
                        ApplicationArea = NPRESFiscal;
                        Caption = 'API Secret';
                        ExtendedDatatype = Masked;
                        ToolTip = 'Specifies the value of the API Secret provided by Fiskaly.';

                        trigger OnValidate()
                        begin
                            if APISecretValue = '' then
                                ESSecretMgt.RemoveSecretKey(Rec.GetAPISecretName())
                            else
                                ESSecretMgt.SetSecretKey(Rec.GetAPISecretName(), APISecretValue);
                        end;
                    }
                }
            }
            group(Taxpayer)
            {
                Caption = 'Taxpayer';

                field("Taxpayer Territory"; Rec."Taxpayer Territory")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the taxpayer territory of this ES Fiskaly organization. This value can be changed only until other resources are created. As of that moment a new ES Fiskaly organization should be created if changing its value is required.';
                }
                field("Taxpayer Type"; Rec."Taxpayer Type")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the type of taxpayer.';
                }
                field("Taxpayer Created"; Rec."Taxpayer Created")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies whether the taxpayer is created at Fiskaly for this ES Fiskaly organization.';
                }
            }
            group("Software Information")
            {
                Caption = 'Software Information';

                field("Company Legal Name"; Rec."Company Legal Name")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the legal name of company that registered the software.';
                }
                field("Company Tax Number"; Rec."Company Tax Number")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the tax number of company that registered the software.';
                }
                field("Software Name"; Rec."Software Name")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the name of software.';
                }
                field("Software License"; Rec."Software License")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the license of software.';
                }
                field("Software Version"; Rec."Software Version")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the version of software.';
                }
                field("Responsibility Declaration URL"; Rec."Responsibility Declaration URL")
                {
                    ApplicationArea = NPRESFiscal;
                    Enabled = Rec."Responsibility Declaration URL" <> '';
                    ToolTip = 'Specifies the URL where the responsibility declaration document is stored.';

                    trigger OnDrillDown()
                    begin
                        ShowResponsibilityDeclaration();
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateTaxpayer)
            {
                ApplicationArea = NPRESFiscal;
                Caption = 'Create Taxpayer';
                Enabled = not Rec.Disabled;
                Image = LinkWeb;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Creates the taxpayer at Fiskaly.';

                trigger OnAction()
                var
                    ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    ESFiskalyCommunication.CreateTaxpayer(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(RetrieveTaxpayer)
            {
                ApplicationArea = NPRESFiscal;
                Caption = 'Retrieve Taxpayer';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Retrieves the latest information about the taxpayer from Fiskaly.';

                trigger OnAction()
                var
                    ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    ESFiskalyCommunication.RetrieveTaxpayer(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(DisableOrganization)
            {
                ApplicationArea = NPRESFiscal;
                Caption = 'Disable';
                Enabled = not Rec.Disabled;
                Image = Cancel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Disables the organization in case of any amendment to the taxpayer data.';

                trigger OnAction()
                begin
                    Rec.Disable();
                end;
            }
            action(RetrieveSoftware)
            {
                ApplicationArea = NPRESFiscal;
                Caption = 'Retrieve Software';
                Image = ExportDatabase;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Retrieves the latest information about the software from Fiskaly.';

                trigger OnAction()
                var
                    ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    ESFiskalyCommunication.RetrieveSoftware(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(ViewResponsibilityDeclaration)
            {
                ApplicationArea = NPRESFiscal;
                Caption = 'View Responsibility Declaration';
                Enabled = Rec."Responsibility Declaration URL" <> '';
                Image = View;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Views responsibility declaration document stored at the URL if responsibility declaration exists for the territory.';

                trigger OnAction()
                begin
                    ShowResponsibilityDeclaration();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        ClearSecretValues();
        GetSecretValues();
    end;

    var
        ESSecretMgt: Codeunit "NPR ES Secret Mgt.";
        APIKeyValue: Text[250];
        APISecretValue: Text[250];

    local procedure ClearSecretValues()
    begin
        Clear(APIKeyValue);
        Clear(APISecretValue);
    end;

    local procedure GetSecretValues()
    begin
        APIKeyValue := CopyStr(ESSecretMgt.GetSecretKey(Rec.GetAPIKeyName()), 1, MaxStrLen(APIKeyValue));
        APISecretValue := CopyStr(ESSecretMgt.GetSecretKey(Rec.GetAPISecretName()), 1, MaxStrLen(APISecretValue));
    end;

    local procedure ShowResponsibilityDeclaration()
    begin
        Rec.TestField("Responsibility Declaration URL");
        Hyperlink(Rec."Responsibility Declaration URL");
    end;
}