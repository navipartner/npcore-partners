page 6150906 "NPR POS HC Endpoint Setup"
{
    Extensible = False;
    Caption = 'Endpoint Setup';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR POS HC Endpoint Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Active; Rec.Active)
                {
                    ToolTip = 'Specifies the value of the Active field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Endpoint)
            {
                field("Endpoint URI"; Rec."Endpoint URI")
                {
                    ToolTip = 'Specifies the value of the Endpoint URI field';
                    ApplicationArea = NPRRetail;
                }
                field("Connection Timeout (ms)"; Rec."Connection Timeout (ms)")
                {
                    ToolTip = 'Specifies the value of the Connection Timeout (ms) field';
                    ApplicationArea = NPRRetail;
                }
                group(Authorization)
                {
                    Caption = 'Authorization';
                    field(AuthType; Rec.AuthType)
                    {
                        ApplicationArea = NPRRetail;
                        Tooltip = 'Specifies the Authorization Type.';

                        trigger OnValidate()
                        begin
                            CurrPage.Update();
                        end;
                    }
                    group(BasicAuth)
                    {
                        ShowCaption = false;
                        Visible = IsBasicAuthVisible;
                        field("User Account"; Rec."User Account")
                        {
                            ToolTip = 'Specifies the value of the User Account field';
                            ApplicationArea = NPRRetail;
                        }
                        field("API Password"; pw)
                        {
                            ToolTip = 'Specifies the value of the User Password field';
                            ApplicationArea = NPRRetail;
                            Caption = 'API Password';
                            ExtendedDatatype = Masked;
                            trigger OnValidate()
                            begin
                                if pw <> '' then
                                    WebServiceAuthHelper.SetApiPassword(pw, Rec."API Password Key")
                                else begin
                                    if WebServiceAuthHelper.HasApiPassword(Rec."API Password Key") then
                                        WebServiceAuthHelper.RemoveApiPassword(Rec."API Password Key");
                                end;
                            end;
                        }
                    }
                    group(OAuth2)
                    {
                        ShowCaption = false;
                        Visible = IsOAuth2Visible;
                        field("OAuth2 Setup Code"; Rec."OAuth2 Setup Code")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the OAuth2.0 Setup Code.';
                        }
                    }
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        WebServiceAuthHelper.SetAuthenticationFieldsVisibility(Rec.AuthType, IsBasicAuthVisible, IsOAuth2Visible);
    end;

    trigger OnAfterGetRecord()
    begin
        pw := '';
        if WebServiceAuthHelper.HasApiPassword(Rec."API Password Key") then
            pw := '***';
        WebServiceAuthHelper.SetAuthenticationFieldsVisibility(Rec.AuthType, IsBasicAuthVisible, IsOAuth2Visible);
    end;

    var
        [InDataSet]
        pw: Text[200];

        [InDataSet]
        IsBasicAuthVisible, IsOAuth2Visible : Boolean;
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
}

