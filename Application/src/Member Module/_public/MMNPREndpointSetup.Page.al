page 6060072 "NPR MM NPR Endpoint Setup"
{
    Caption = 'NPR Endpoint Setup';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM NPR Remote Endp. Setup";
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Community Code"; Rec."Community Code")
                {

                    ToolTip = 'Specifies the value of the Community Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(AuthType; Rec.AuthType)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Tooltip = 'Specifies the Authorization Type.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("User Account"; Rec."User Account")
                {

                    ToolTip = 'Specifies the value of the User Account field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Visible = IsBasicAuthVisible;
                }

                field("User Password"; pw)
                {

                    ToolTip = 'Specifies the value of the User Password field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
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
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the OAuth2.0 Setup Code.';
                    Visible = IsOAuth2Visible;
                }
                field("Endpoint URI"; Rec."Endpoint URI")
                {

                    ToolTip = 'Specifies the value of the Endpoint URI field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Disabled; Rec.Disabled)
                {

                    ToolTip = 'Specifies the value of the Disabled field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Connection Timeout (ms)"; Rec."Connection Timeout (ms)")
                {
                    ToolTip = 'Specifies the value of the Connection Timeout (ms) field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    actions
    {

        area(Processing)
        {
            action(TestConnection)
            {
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Caption = 'Test Connection';
                Image = TestDatabase;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Executes the Test Connection action';

                trigger OnAction()
                var
                    MMMembership: Codeunit "NPR MM NPR Membership";
                begin
                    MMMembership.TestEndpointConnection(Rec);
                end;
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
        if WebServiceAuthHelper.HasApiPassword(Rec."User Password Key") then
            pw := '***';
        WebServiceAuthHelper.SetAuthenticationFieldsVisibility(Rec.AuthType, IsBasicAuthVisible, IsOAuth2Visible);
    end;

    var
        pw: Text[200];

        IsBasicAuthVisible, IsOAuth2Visible : Boolean;
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
}

