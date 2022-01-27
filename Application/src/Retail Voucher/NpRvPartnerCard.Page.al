page 6151027 "NPR NpRv Partner Card"
{
    Extensible = False;
    Caption = 'Retail Voucher Partner';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR NpRv Partner";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014407)
                {
                    ShowCaption = false;
                    field("Code"; Rec.Code)
                    {

                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Name; Rec.Name)
                    {

                        ToolTip = 'Specifies the value of the Name field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014408)
                {
                    ShowCaption = false;
                    field("Service Url"; Rec."Service Url")
                    {

                        ShowMandatory = true;
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
                            field("Service Password"; pw)
                            {
                                ToolTip = 'Specifies the value of the User Password field';
                                ApplicationArea = NPRRetail;
                                Caption = 'Service Password';
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
    }

    actions
    {
        area(processing)
        {
            action("Validate Partner Setup")
            {
                Caption = 'Validate Partner Setup';
                Image = Approve;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Validate Partner Setup action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    NpRvPartnerMgt: Codeunit "NPR NpRv Partner Mgt.";
                begin
                    if NpRvPartnerMgt.TryValidateGlobalVoucherService(Rec) then
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
        pw := '';
        if WebServiceAuthHelper.HasApiPassword(Rec."API Password Key") then
            pw := '***';
        WebServiceAuthHelper.SetAuthenticationFieldsVisibility(Rec.AuthType, IsBasicAuthVisible, IsOAuth2Visible);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        NpRvPartnerMgt: Codeunit "NPR NpRv Partner Mgt.";
    begin
        if not NpRvPartnerMgt.TryValidateGlobalVoucherService(Rec) then
            exit(Confirm(Text000, false));
    end;

    var
        pw: Text[200];

        [InDataSet]
        IsBasicAuthVisible, IsOAuth2Visible : Boolean;
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
        Text000: Label 'Error in Partner Setup\\Close anway?';
        Text001: Label 'Partner Setup validated successfully';
}

