page 6184583 "NPR AT Organization Card"
{
    Caption = 'AT Organization Card';
    Extensible = false;
    PageType = Card;
    SourceTable = "NPR AT Organization";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the code to identify this AT Fiskaly organization.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the text that describes this AT Fiskaly organization.';
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
                        ApplicationArea = NPRATFiscal;
                        Caption = 'API Key';
                        ExtendedDatatype = Masked;
                        ToolTip = 'Specifies the value of the API Key provided by Fiskaly.';

                        trigger OnValidate()
                        begin
                            if APIKeyValue = '' then
                                ATSecretMgt.RemoveSecretKey(Rec.GetAPIKeyName())
                            else
                                ATSecretMgt.SetSecretKey(Rec.GetAPIKeyName(), APIKeyValue);
                        end;
                    }
                    field(APISecret; APISecretValue)
                    {
                        ApplicationArea = NPRATFiscal;
                        Caption = 'API Secret';
                        ExtendedDatatype = Masked;
                        ToolTip = 'Specifies the value of the API Secret provided by Fiskaly.';

                        trigger OnValidate()
                        begin
                            if APISecretValue = '' then
                                ATSecretMgt.RemoveSecretKey(Rec.GetAPISecretName())
                            else
                                ATSecretMgt.SetSecretKey(Rec.GetAPISecretName(), APISecretValue);
                        end;
                    }
                }
            }
            group(FONAuthentication)
            {
                Caption = 'FinanzOnline Authentication';

                field("FON Authentication Status"; Rec."FON Authentication Status")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the status of FinanzOnline authentication. Must be authenticated with FinanzOnline before transitioning Signature Creation Units and Cash Registers to INITIALIZED.';
                }
                field("FON Authenticated At"; Rec."FON Authenticated At")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the date and time when authentication is done at FinanzOnline.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(AuthenticateFON)
            {
                ApplicationArea = NPRATFiscal;
                Caption = 'Authenticate FON';
                Image = LinkWeb;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Authenticates the taxpayer with the FinanzOnline.';

                trigger OnAction()
                var
                    ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    ATFiskalyCommunication.AuthenticateFON(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(RetrieveFONStatus)
            {
                ApplicationArea = NPRATFiscal;
                Caption = 'Retrieve FON Status';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Checks the authentication status of the taxpayer with the FinanzOnline.';

                trigger OnAction()
                var
                    ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    ATFiskalyCommunication.RetrieveFONStatus(Rec);
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
        ATSecretMgt: Codeunit "NPR AT Secret Mgt.";
        APIKeyValue: Text[250];
        APISecretValue: Text[250];

    local procedure ClearSecretValues()
    begin
        Clear(APIKeyValue);
        Clear(APISecretValue);
    end;

    local procedure GetSecretValues()
    begin
        APIKeyValue := CopyStr(ATSecretMgt.GetSecretKey(Rec.GetAPIKeyName()), 1, MaxStrLen(APIKeyValue));
        APISecretValue := CopyStr(ATSecretMgt.GetSecretKey(Rec.GetAPISecretName()), 1, MaxStrLen(APIKeyValue));
    end;
}