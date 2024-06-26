page 6184680 "NPR AT Organizations Step"
{
    Caption = 'AT Organizations';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR AT Organization";
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
                    ToolTip = 'Specifies the code to identify this AT Fiskaly organization.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the text that describes this AT Fiskaly organization.';
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
                field("FON Authentication Status"; Rec."FON Authentication Status")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the status of FinanzOnline authentication. Must be authenticated with FinanzOnline before transitioning Signature Creation Units and Cash Registers to INITIALIZED.';
                }
                field("FON Authenticated At"; Rec."FON Authenticated At")
                {
                    ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;
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