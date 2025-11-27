page 6151172 "NPR NpGp POS Sales Setup Card"
{
    Extensible = False;
    UsageCategory = None;
    Caption = 'Global POS Sales Setup Card';
    ContextSensitiveHelpPage = 'docs/retail/pos_profiles/how-to/global_profile/global_profile/';
    PageType = Card;
    SourceTable = "NPR NpGp POS Sales Setup";

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
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
                    field("Use OData api"; Rec."Use api")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies if the OData api is used';
                    }
                    field("OData Base Url"; Rec."OData Base Url")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the base url for the OData api. The base url can be found by opening the page ''NaviPartner API URL'' in the company to receive the Global POS Sales transactions';
                    }
                    group(OData)
                    {
                        ShowCaption = false;
                        Visible = Rec."Use api";
                        field("Environment Type"; Rec."Environment Type")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the environment type of the endpoint';
                        }
                        field("Last exported POS Entry"; Rec."Last exported POS Entry")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the Entry No. of the last exported POS Entry. Use the assist edit action to update the value when using api is initialized.';
                            trigger OnAssistEdit()
                            var
                                NpGpExporttoAPI: Codeunit "NPR NpGp Export to API";
                            begin
                                NpGpExporttoAPI.ChangeExportControl(Rec.Code);
                            end;
                        }
                        field("Last exported"; Rec."Last exported")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the time for the lastest export.';
                        }
                    }
#endif
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
                    TryGetGlobalPOSService: Codeunit "NPR NpGp Try Get Glob Pos Serv";
                begin
                    if TryGetGlobalPOSService.Run(Rec) then
                        Message(Text001)
                    else
                        Error(GetLastErrorText());
                end;
            }
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
            action("Manual Export POS Entry")
            {
                Caption = 'Manual Export POS Entry';
                Image = ExportFile;
                ToolTip = 'Manually export a specific POS Entry that was skipped or needs to be re-exported';
                ApplicationArea = NPRRetail;
                Visible = Rec."Use api";

                trigger OnAction()
                var
                    NpGpExporttoAPI: Codeunit "NPR NpGp Export to API";
                begin
                    NpGpExporttoAPI.ManualExportPOSEntry(Rec.Code);
                end;
            }
#endif
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
        TryGetGlobalPOSService: Codeunit "NPR NpGp Try Get Glob Pos Serv";
    begin
        if not TryGetGlobalPOSService.Run(Rec) then
            exit(Confirm(StrSubstNo(Text000, GetLastErrorText()), false));
    end;

    var
        IsBasicAuthVisible, IsOAuth2Visible : Boolean;
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
        Text000: Label 'Error in Global POS Sales Setup: %1\\Close anway?';
        Text001: Label 'Global POS Sales Setup validated successfully';
        Password: Text[200];
}

