page 6060072 "NPR MM NPR Endpoint Setup"
{
    Extensible = False;

    Caption = 'NPR Endpoint Setup';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM NPR Remote Endp. Setup";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Community Code"; Rec."Community Code")
                {

                    ToolTip = 'Specifies the value of the Community Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(AuthType; Rec.AuthType)
                {
                    ApplicationArea = NPRRetail;
                    Tooltip = 'Specifies the Authorization Type.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("User Account"; Rec."User Account")
                {

                    ToolTip = 'Specifies the value of the User Account field';
                    ApplicationArea = NPRRetail;
                    Visible = IsBasicAuthVisible;
                }

                field("User Password"; pw)
                {

                    ToolTip = 'Specifies the value of the User Password field';
                    ApplicationArea = NPRRetail;
                    Caption = 'User Password';
                    ExtendedDatatype = Masked;
                    Visible = IsBasicAuthVisible;
                    trigger OnValidate()
                    begin
                        if pw <> '' then
                            WebServiceAuthHelper.SetApiPassword(pw, Rec."User Password Key")
                        else begin
                            if WebServiceAuthHelper.HasApiPassword(Rec."User Password Key") then
                                WebServiceAuthHelper.RemoveApiPassword(Rec."User Password Key");
                        end;
                    end;
                }
                field("OAuth2 Setup Code"; Rec."OAuth2 Setup Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the OAuth2.0 Setup Code.';
                    Visible = IsOAuth2Visible;
                }
                field("Endpoint URI"; Rec."Endpoint URI")
                {

                    ToolTip = 'Specifies the value of the Endpoint URI field';
                    ApplicationArea = NPRRetail;
                }
                field(Disabled; Rec.Disabled)
                {

                    ToolTip = 'Specifies the value of the Disabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Connection Timeout (ms)"; Rec."Connection Timeout (ms)")
                {
                    ToolTip = 'Specifies the value of the Connection Timeout (ms) field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        WebServiceAuthHelper.SetAuthenticationFieldsVisibility(Rec.AuthType, IsBasicAuthVisible, IsOAuth2Visible);
    end;

    trigger OnAfterGetRecord()
    begin
        pw := '';
        if WebServiceAuthHelper.HasApiPassword(Rec."User Password Key") then
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

