page 6151024 "NPR NpRv Global Voucher Setup"
{
    Extensible = False;
    UsageCategory = None;
    Caption = 'Global Voucher Setup';
    InsertAllowed = false;
    SourceTable = "NPR NpRv Global Vouch. Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014407)
                {
                    ShowCaption = false;
                    field("Service Company Name"; Rec."Service Company Name")
                    {

                        ToolTip = 'Specifies the value of the Service Company Name field';
                        ApplicationArea = NPRRetail;
                    }
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
    }

    actions
    {
        area(processing)
        {
            action("Validate Global Voucher Setup")
            {
                Caption = 'Validate Global Voucher Setup';
                Image = Approve;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Validate Global Voucher Setup action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    NpRvModuleValidateGlobal: Codeunit "NPR NpRv Module Valid.: Global";
                begin
                    if NpRvModuleValidateGlobal.TryValidateGlobalVoucherSetup(Rec) then
                        Message(Text001)
                    else
                        Error(GetLastErrorText);
                end;
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        NpRvModuleValidateGlobal: Codeunit "NPR NpRv Module Valid.: Global";
    begin
        if not NpRvModuleValidateGlobal.TryValidateGlobalVoucherSetup(Rec) then
            exit(Confirm(Text000, false));
    end;

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
        pw: Text[200];

        [InDataSet]
        IsBasicAuthVisible, IsOAuth2Visible : Boolean;
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
        Text000: Label 'Error in Global Voucher Setup\\Close anway?';
        Text001: Label 'Global Voucher Setup validated successfully';
}

