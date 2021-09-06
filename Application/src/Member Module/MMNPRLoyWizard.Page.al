page 6151164 "NPR MM NPR Loy. Wizard"
{
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
                    ApplicationArea = NPRRetail;
                }
                field(SystemPrefix; FS_Prefix)
                {

                    Caption = 'System Prefix';
                    Editable = IsEditable;
                    ToolTip = 'Specifies the value of the System Prefix field';
                    ApplicationArea = NPRRetail;
                }
                field(PaymentMethodCode; PaymentMethodCode)
                {

                    Caption = 'Payment Method Code';
                    ToolTip = 'Specifies the value of the Payment Method Code field';
                    ApplicationArea = NPRRetail;
                }
                field(GLAccount; GLAccount)
                {

                    Caption = 'Payment G/L Account';
                    ToolTip = 'Specifies the value of the Payment G/L Account field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Description)
                {

                    Caption = 'Description';
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Server Communication")
            {
                Caption = 'Server Communication';
                field(ServiceUser; ServiceUser)
                {

                    Caption = 'Username';
                    ToolTip = 'Specifies the value of the Username field';
                    ApplicationArea = NPRRetail;
                }
                field(ServicePassword; ServicePassword)
                {

                    Caption = 'Password';
                    ToolTip = 'Specifies the value of the Password field';
                    ApplicationArea = NPRRetail;
                }
                field(ServiceBaseURL; ServiceBaseURL)
                {

                    Caption = 'Base URL';
                    ToolTip = 'Specifies the value of the Base URL field';
                    ApplicationArea = NPRRetail;

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
                    ApplicationArea = NPRRetail;
                }
                field(MembershipCode; MembershipCode)
                {

                    Caption = 'Membership Code';
                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = NPRRetail;
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
                    ApplicationArea = NPRRetail;
                }
                field(LoyaltyAuth; LoyaltyAuth)
                {

                    Caption = 'Loyalty Authorization Code';
                    ToolTip = 'Specifies the value of the Loyalty Authorization Code field';
                    ApplicationArea = NPRRetail;
                }
                field(EarnFactor; EarnRatio)
                {

                    Caption = 'Earn Factor';
                    DecimalPlaces = 2 : 5;
                    MinValue = 0;
                    ToolTip = 'Specifies the value of the Earn Factor field';
                    ApplicationArea = NPRRetail;
                }
                field(BurnFactor; BurnRation)
                {

                    Caption = 'Burn Factor';
                    DecimalPlaces = 2 : 5;
                    MinValue = 0;
                    ToolTip = 'Specifies the value of the Burn Factor field';
                    ApplicationArea = NPRRetail;
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

    procedure SetDefaults(pCommunityCode: Code[20]; pPrefix: Code[10])
    begin

        CommunityCode := pCommunityCode;
        FS_Prefix := pPrefix;
        IsEditable := false;
    end;

    procedure GetUserSetup(var vCommunityCode: Code[20]; var vMembershipCode: Code[20]; var vSystemPrefix: Code[10]; var vPaymentTypeCode: Code[10]; var vPaymentGLAccount: Code[20]; var vBaseUrl: Text; var vUsername: Text[50]; var vPassword: Text[30]; var vDescription: Text; var vAuthCode: Text[40]; var vLoyaltyServerCompanyName: Text[80]; var vEarnFactor: Decimal; var vBurnFactor: Decimal; var vTenant: Text)
    begin

        vCommunityCode := CommunityCode;
        vMembershipCode := MembershipCode;
        vSystemPrefix := FS_Prefix;
        vPaymentTypeCode := PaymentMethodCode;
        vPaymentGLAccount := GLAccount;

        vBaseUrl := ServiceBaseURL;
        vTenant := TenantName;
        vUsername := ServiceUser;
        vPassword := ServicePassword;

        vDescription := Description;

        vAuthCode := LoyaltyAuth;
        vLoyaltyServerCompanyName := LoyaltyCmpName;

        vEarnFactor := EarnRatio;
        vBurnFactor := BurnRation;
    end;
}
