page 6151172 "NPR NpGp POS Sales Setup Card"
{
    Caption = 'Global POS Sales Setup Card';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR NpGp POS Sales Setup";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                group(Control6014407)
                {
                    ShowCaption = false;
                    field("Code"; Rec.Code)
                    {

                        ToolTip = 'Specifies the value of the Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Description; Rec.Description)
                    {

                        ToolTip = 'Specifies the value of the Description field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Company Name"; Rec."Company Name")
                    {

                        ToolTip = 'Specifies the value of the Company Name field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014408)
                {
                    ShowCaption = false;
                    field("Service Url"; Rec."Service Url")
                    {

                        ToolTip = 'Specifies the value of the Service Url field';
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
                            field("Service Username"; Rec."Service Username")
                            {

                                ToolTip = 'Specifies the value of the Service Username field';
                                ApplicationArea = NPRRetail;
                            }
                            field(Password; Password)
                            {

                                Caption = 'Service Password';
                                ExtendedDatatype = Masked;
                                ToolTip = 'Specifies the value of the Service Password field';
                                ApplicationArea = NPRRetail;

                                trigger OnValidate()
                                begin
                                    if Password <> '' then
                                        WebServiceAuthHelper.SetApiPassword(Password, Rec."Service Password")
                                    else begin
                                        if WebServiceAuthHelper.HasApiPassword(Rec."Service Password") then
                                            WebServiceAuthHelper.RemoveApiPassword(Rec."Service Password");
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
    }

    actions
    {
        area(processing)
        {
            action("Validate Global POS Sales Setup")
            {
                Caption = 'Validate Global POS Sales Setup';
                Image = Approve;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Validate Global POS Sales Setup action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    NpGpPOSSalesSyncMgt: Codeunit "NPR NpGp POS Sales Sync Mgt.";
                begin
                    if NpGpPOSSalesSyncMgt.TryGetGlobalPosSalesService(Rec) then
                        Message(Text001)
                    else
                        Error(GetLastErrorText);
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
        Password := '';
        if WebServiceAuthHelper.HasApiPassword(Rec."Service Password") then
            Password := '***';
        WebServiceAuthHelper.SetAuthenticationFieldsVisibility(Rec.AuthType, IsBasicAuthVisible, IsOAuth2Visible);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        NpGpPOSSalesSyncMgt: Codeunit "NPR NpGp POS Sales Sync Mgt.";
    begin
        if not NpGpPOSSalesSyncMgt.TryGetGlobalPosSalesService(Rec) then
            exit(Confirm(Text000, false));
    end;

    var

        [InDataSet]
        IsBasicAuthVisible, IsOAuth2Visible : Boolean;
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
        Text000: Label 'Error in Global POS Sales Setup\\Close anway?';
        Text001: Label 'Global POS Sales Setup validated successfully';
        Password: Text[200];
}

