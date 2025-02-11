page 6184762 "NPR ES Organizations Step"
{
    Caption = 'ES Organizations';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR ES Organization";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the code to identify this ES Fiskaly organization.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the text that describes this ES Fiskaly organization.';
                }
                field(FiskalyAPIKey; FiskalyAPIKeyValue)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Fiskaly API Key';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the API Key provided by Fiskaly.';

                    trigger OnValidate()
                    begin
                        if FiskalyAPIKeyValue = '' then
                            ATSecretMgt.RemoveSecretKey(Rec.GetAPIKeyName())
                        else
                            ATSecretMgt.SetSecretKey(Rec.GetAPIKeyName(), FiskalyAPIKeyValue);
                    end;
                }
                field(FiskalyAPISecret; FiskalyAPISecretValue)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Fiskaly API Secret';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the API Secret provided by Fiskaly.';

                    trigger OnValidate()
                    begin
                        if FiskalyAPISecretValue = '' then
                            ATSecretMgt.RemoveSecretKey(Rec.GetAPISecretName())
                        else
                            ATSecretMgt.SetSecretKey(Rec.GetAPISecretName(), FiskalyAPISecretValue);
                    end;
                }
                field("Taxpayer Territory"; Rec."Taxpayer Territory")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the taxpayer territory of this ES Fiskaly organization. This value can be changed only until other resources are created. As of that moment a new ES Fiskaly organization should be created if changing its value is required.';
                }
                field("Taxpayer Type"; Rec."Taxpayer Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the type of taxpayer.';
                }
                field("Taxpayer Created"; Rec."Taxpayer Created")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the taxpayer is created at Fiskaly for this ES Fiskaly organization.';
                }
                field("Company Legal Name"; Rec."Company Legal Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the legal name of company that registered the software.';
                }
                field("Company Tax Number"; Rec."Company Tax Number")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the tax number of company that registered the software.';
                }
                field("Software Name"; Rec."Software Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the name of software.';
                }
                field("Software License"; Rec."Software License")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the license of software.';
                }
                field("Software Version"; Rec."Software Version")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the version of software.';
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
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        ClearSecretValues();
        GetSecretValues();
    end;

    var
        ATSecretMgt: Codeunit "NPR ES Secret Mgt.";
        FiskalyAPIKeyValue: Text[250];
        FiskalyAPISecretValue: Text[250];

    local procedure ClearSecretValues()
    begin
        Clear(FiskalyAPIKeyValue);
        Clear(FiskalyAPISecretValue);
    end;

    local procedure GetSecretValues()
    begin
        FiskalyAPIKeyValue := CopyStr(ATSecretMgt.GetSecretKey(Rec.GetAPIKeyName()), 1, MaxStrLen(FiskalyAPIKeyValue));
        FiskalyAPISecretValue := CopyStr(ATSecretMgt.GetSecretKey(Rec.GetAPISecretName()), 1, MaxStrLen(FiskalyAPISecretValue));
    end;
}