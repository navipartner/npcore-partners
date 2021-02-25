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
                    ApplicationArea = All;
                    Caption = 'Community Code';
                    Editable = IsEditable;
                    ToolTip = 'Specifies the value of the Community Code field';
                }
                field("FS_Prefix"; FS_Prefix)
                {
                    ApplicationArea = All;
                    Caption = 'System Prefix';
                    Editable = IsEditable;
                    ToolTip = 'Specifies the value of the System Prefix field';
                }
                field(PaymentMethodCode; PaymentMethodCode)
                {
                    ApplicationArea = All;
                    Caption = 'Payment Method Code';
                    ToolTip = 'Specifies the value of the Payment Method Code field';
                }
                field(GLAccount; GLAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Payment G/L Account';
                    ToolTip = 'Specifies the value of the Payment G/L Account field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
            group("Server Communication")
            {
                Caption = 'Server Communication';
                field(ServiceUser; ServiceUser)
                {
                    ApplicationArea = All;
                    Caption = 'Username';
                    ToolTip = 'Specifies the value of the Username field';
                }
                field(ServicePassword; ServicePassword)
                {
                    ApplicationArea = All;
                    Caption = 'Password';
                    ToolTip = 'Specifies the value of the Password field';
                }
                field(ServiceBaseURL; ServiceBaseURL)
                {
                    ApplicationArea = All;
                    Caption = 'Base URL';
                    ToolTip = 'Specifies the value of the Base URL field';

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
                field(TenentName; TenentName)
                {
                    ApplicationArea = All;
                    Caption = 'Tenant';
                    ToolTip = 'Specifies the value of the Tenant field';
                }
                field(MembershipCode; MembershipCode)
                {
                    ApplicationArea = All;
                    Caption = 'Membership Code';
                    ToolTip = 'Specifies the value of the Membership Code field';
                }
            }
            group(Setup)
            {
                Caption = 'Setup';
                field(LoyaltyCmpName; LoyaltyCmpName)
                {
                    ApplicationArea = All;
                    Caption = 'Server Company Name';
                    TableRelation = Company;
                    ToolTip = 'Specifies the value of the Server Company Name field';
                }
                field(LoyaltyAuth; LoyaltyAuth)
                {
                    ApplicationArea = All;
                    Caption = 'Loyalty Authorization Code';
                    ToolTip = 'Specifies the value of the Loyalty Authorization Code field';
                }
                field(EarnFactor; EarnRatio)
                {
                    ApplicationArea = All;
                    Caption = 'Earn Factor';
                    DecimalPlaces = 2 : 5;
                    MinValue = 0;
                    ToolTip = 'Specifies the value of the Earn Factor field';
                }
                field(BurnFactor; BurnRation)
                {
                    ApplicationArea = All;
                    Caption = 'Burn Factor';
                    DecimalPlaces = 2 : 5;
                    MinValue = 0;
                    ToolTip = 'Specifies the value of the Burn Factor field';
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
        TenentName: Text;
        ServiceUser: Text;
        ServicePassword: Text;
        GLAccount: Code[20];
        Description: Text;
        LoyaltyAuth: Text;
        LoyaltyCmpInSameDB: Boolean;
        LoyaltyCmpName: Text;
        IsEditable: Boolean;
        MembershipCode: Code[10];
        EarnRatio: Decimal;
        BurnRation: Decimal;

    local procedure InitializeDefaults()
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
    begin
        PaymentMethodCode := 'MM-LOYALTY';
        CommunityCode := 'NPR-CC';
        FS_Prefix := 'NPR';
        GLAccount := '2345';
        Description := 'Membership Loyalty Program';
        LoyaltyCmpInSameDB := true;

        if (UserId = 'TSA') then begin
            ServiceBaseURL := AzureKeyVaultMgt.GetSecret('MMLoyaltyServiceBaseUrl');
            ServiceUser := AzureKeyVaultMgt.GetSecret('MMLoyaltyServiceUsername');
            ServicePassword := AzureKeyVaultMgt.GetSecret('MMLoyaltyServicePassword');
        end;

        BurnRation := 0.015;
        EarnRatio := 1;
    end;

    procedure SetDefaults(pCommunityCode: Code[20]; pPrefix: Code[10])
    begin

        CommunityCode := pCommunityCode;
        FS_Prefix := pPrefix;
        IsEditable := false;
    end;

    procedure GetUserSetup(var vCommunityCode: Code[20]; var vMembershipCode: Code[20]; var vSystemPrefix: Code[10]; var vPaymentTypeCode: Code[10]; var vPaymentGLAccount: Code[20]; var vBaseUrl: Text; var vUsername: Text; var vPassword: Text; var vDescription: Text; var vAuthCode: Text; var vLoyaltyServerCompanyName: Text; var vEarnFactor: Decimal; var vBurnFactor: Decimal; var vTenant: Text)
    begin

        vCommunityCode := CommunityCode;
        vMembershipCode := MembershipCode;
        vSystemPrefix := FS_Prefix;
        vPaymentTypeCode := PaymentMethodCode;
        vPaymentGLAccount := GLAccount;

        vBaseUrl := ServiceBaseURL;
        vTenant := TenentName;
        vUsername := ServiceUser;
        vPassword := ServicePassword;

        vDescription := Description;

        vAuthCode := LoyaltyAuth;
        vLoyaltyServerCompanyName := LoyaltyCmpName;

        vEarnFactor := EarnRatio;
        vBurnFactor := BurnRation;
    end;
}
