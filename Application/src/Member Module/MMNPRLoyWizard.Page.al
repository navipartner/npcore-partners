﻿page 6151164 "NPR MM NPR Loy. Wizard"
{
    Extensible = False;
    UsageCategory = None;
    Caption = 'NPR Loyalty Wizard';
    SourceTable = "Integer";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(CommunityCode; CommunityCode)
                {

                    Caption = 'Community Code';
                    Editable = IsEditable;
                    ToolTip = 'Specifies the value of the Community Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(SystemPrefix; FS_Prefix)
                {

                    Caption = 'System Prefix';
                    Editable = IsEditable;
                    ToolTip = 'Specifies the value of the System Prefix field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(PaymentMethodCode; PaymentMethodCode)
                {

                    Caption = 'Payment Method Code';
                    ToolTip = 'Specifies the value of the Payment Method Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(GLAccount; GLAccount)
                {

                    Caption = 'Payment G/L Account';
                    ToolTip = 'Specifies the value of the Payment G/L Account field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Description; Description)
                {

                    Caption = 'Description';
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group("Server Communication")
            {
                Caption = 'Server Communication';

                field(AuthType; AuthType)
                {
                    Caption = 'Authorization Type';
                    ToolTip = 'Specifies the value of the Authorization Type field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }

                group(BasicAuth)
                {
                    ShowCaption = false;
                    Visible = IsBasicAuthVisible;
                    field(ServiceUser; ServiceUser)
                    {

                        Caption = 'Username';
                        ToolTip = 'Specifies the value of the Username field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                    field(ServicePassword; ServicePassword)
                    {

                        Caption = 'Password';
                        ToolTip = 'Specifies the value of the Password field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                }

                group(OAuth2)
                {
                    ShowCaption = false;
                    Visible = IsOAuth2Visible;
                    field(OAuth2SetupCode; OAuth2SetupCode)
                    {
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                        Caption = 'OAuth2 Setup Code';
                        Editable = false;
                        ToolTip = 'Specifies the OAuth2.0 Setup Code.';
                        trigger OnAssistEdit()
                        var
                            OAuth2SetupListPage: Page "NPR OAuth Setup List";
                            OAuth2SetupRec: Record "NPR OAuth Setup";
                        begin
                            OAuth2SetupListPage.LookupMode(true);
                            if OAuth2SetupListPage.RunModal() = Action::LookupOK then begin
                                OAuth2SetupListPage.GetRecord(OAuth2SetupRec);
                                OAuth2SetupCode := OAuth2SetupRec.Code;
                            end;
                        end;
                    }
                }
                field(ServiceBaseURL; ServiceBaseURL)
                {

                    Caption = 'Base URL';
                    ToolTip = 'Specifies the value of the Base URL field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnValidate()
                    begin

                        if (StrLen(ServiceBaseURL) < StrLen('/Codeunit/')) then
                            Error('Invalid URL.');

                        if (LowerCase(CopyStr(ServiceBaseURL, 1, 4)) <> 'http') then
                            Error('Invalid URL.');

                        if (CopyStr(ServiceBaseURL, StrLen(ServiceBaseURL) - StrLen('Codeunit/')) <> '/Codeunit/') then
                            Error('Invalid URL. URL must end with "Codeunit/" (without the quotes).');

                    end;
                }
                field(TenentName; TenantName)
                {

                    Caption = 'Tenant';
                    ToolTip = 'Specifies the value of the Tenant field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(MembershipCode; MembershipCode)
                {

                    Caption = 'Membership Code';
                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group(Setup)
            {
                Caption = 'Setup';
                field(LoyaltyCmpName; LoyaltyCmpName)
                {

                    Caption = 'Server Company Name';
                    TableRelation = Company;
                    ToolTip = 'Specifies the value of the Server Company Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(LoyaltyAuth; LoyaltyAuth)
                {

                    Caption = 'Loyalty Authorization Code';
                    ToolTip = 'Specifies the value of the Loyalty Authorization Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(EarnFactor; EarnRatio)
                {

                    Caption = 'Earn Factor';
                    DecimalPlaces = 2 : 5;
                    MinValue = 0;
                    ToolTip = 'Specifies the value of the Earn Factor field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(BurnFactor; BurnRation)
                {

                    Caption = 'Burn Factor';
                    DecimalPlaces = 2 : 5;
                    MinValue = 0;
                    ToolTip = 'Specifies the value of the Burn Factor field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        InitializeDefaults();
    end;

    trigger OnOpenPage()
    begin
        WebServiceAuthHelper.SetAuthenticationFieldsVisibility(AuthType, IsBasicAuthVisible, IsOAuth2Visible);
    end;

    trigger OnAfterGetRecord()
    begin
        WebServiceAuthHelper.SetAuthenticationFieldsVisibility(AuthType, IsBasicAuthVisible, IsOAuth2Visible);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin

        if (CloseAction <> ACTION::LookupOK) then
            exit(true);

        if (MembershipCode = '') then
            Error('The server side Membership code must be specified.');

        exit(true);

    end;

    var
        PaymentMethodCode: Code[10];
        CommunityCode: Code[20];
        FS_Prefix: Code[10];
        ServiceBaseURL: Text;
        TenantName: Text;
        ServiceUser: Text[50];
        ServicePassword: Text[30];
        GLAccount: Code[20];
        Description: Text;
        LoyaltyAuth: Text[40];
        LoyaltyCmpName: Text[80];
        IsEditable: Boolean;
        MembershipCode: Code[10];
        EarnRatio: Decimal;
        BurnRation: Decimal;

        AuthType: Enum "NPR API Auth. Type";

        OAuth2SetupCode: Code[20];

        IsBasicAuthVisible, IsOAuth2Visible : Boolean;
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";

    local procedure InitializeDefaults()
    begin
        PaymentMethodCode := 'MM-LOYALTY';
        CommunityCode := 'NPR-CC';
        FS_Prefix := 'NPR';
        GLAccount := '2345';
        Description := 'Membership Loyalty Program';
        BurnRation := 0.015;
        EarnRatio := 1;
    end;

    internal procedure SetDefaults(pCommunityCode: Code[20]; pPrefix: Code[10])
    begin

        CommunityCode := pCommunityCode;
        FS_Prefix := pPrefix;
        IsEditable := false;
    end;

    internal procedure GetUserSetup(var vCommunityCode: Code[20]; var vMembershipCode: Code[20]; var vSystemPrefix: Code[10]; var vPaymentTypeCode: Code[10]; var vPaymentGLAccount: Code[20]; var vBaseUrl: Text; var vAuthType: Enum "NPR API Auth. Type"; var vUsername: Text[50]; var vPassword: Text[30]; var vOAuthSetupCode: Code[20]; var vDescription: Text; var vAuthCode: Text[40]; var vLoyaltyServerCompanyName: Text[80]; var vEarnFactor: Decimal; var vBurnFactor: Decimal; var vTenant: Text)
    begin

        vCommunityCode := CommunityCode;
        vMembershipCode := MembershipCode;
        vSystemPrefix := FS_Prefix;
        vPaymentTypeCode := PaymentMethodCode;
        vPaymentGLAccount := GLAccount;

        vBaseUrl := ServiceBaseURL;
        vTenant := TenantName;
        vAuthType := AuthType;
        vUsername := ServiceUser;
        vPassword := ServicePassword;
        vOAuthSetupCode := OAuth2SetupCode;

        vDescription := Description;

        vAuthCode := LoyaltyAuth;
        vLoyaltyServerCompanyName := LoyaltyCmpName;

        vEarnFactor := EarnRatio;
        vBurnFactor := BurnRation;
    end;
}
