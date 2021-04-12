codeunit 6151159 "NPR MM NRP Loyalty Wizard"
{

    trigger OnRun()
    begin

        RunClientWizard();
    end;

    var
        gCommunityCode: Code[20];
        gPrefix: Code[10];

    local procedure RunClientWizard()
    var
        NPRLoyaltyWizard: Page "NPR MM NPR Loy. Wizard";
        PageAction: Action;
        CommunityCode: Code[20];
        MembershipCode: Code[20];
        BaseUrl: Text;
        TenantName: Text;
        UserName: Text;
        Password: Text;
        Prefix: Code[10];
        PaymentTypeCode: Code[10];
        GL_Account: Code[20];
        Description: Text;
        AuthCode: Text;
        LoyaltyCompanyName: Text;
        LoyaltyCode: Code[20];
        BurnFactor: Decimal;
        EarnFactor: Decimal;
    begin

        NPRLoyaltyWizard.LookupMode(true);
        if (gCommunityCode <> '') then
            NPRLoyaltyWizard.SetDefaults(gCommunityCode, gPrefix);

        PageAction := NPRLoyaltyWizard.RunModal();
        if (PageAction <> ACTION::LookupOK) then
            Error('');

        NPRLoyaltyWizard.GetUserSetup(CommunityCode, MembershipCode, Prefix, PaymentTypeCode, GL_Account, BaseUrl, UserName, Password, Description, AuthCode, LoyaltyCompanyName, EarnFactor, BurnFactor, TenantName);

        CreateCommunity(CommunityCode, Prefix, CopyStr(Description, 1, 50));
        LoyaltyCode := CreateLoyalty(StrSubstNo('%1-LOYALTY', CommunityCode), CopyStr(Description, 1, 50), EarnFactor, BurnFactor);
        CreateMembership(CommunityCode, StrSubstNo('%1%2', Prefix, MembershipCode), LoyaltyCode, CopyStr(Description, 1, 50));

        CreateEndpoints(CommunityCode, StrSubstNo('%1-M', CommunityCode), BaseUrl, 0, UserName, Password, TenantName);
        CreateEndpoints(CommunityCode, StrSubstNo('%1-L', CommunityCode), BaseUrl, 1, UserName, Password, TenantName);

        CreatePOSPaymentMethod(PaymentTypeCode, GL_Account, BurnFactor);
        CreateEFTSetup(PaymentTypeCode);

        CreateStoreSetup(CommunityCode, AuthCode, LoyaltyCompanyName, LoyaltyCode, PaymentTypeCode);
        CreatePostingSetup(PaymentTypeCode, GL_Account);

        Message('Setup done. Proceed with POS setup.');
    end;

    procedure SetCommunityCode(pCommunityCode: Code[20]; pPrefix: Code[10])
    begin

        gCommunityCode := pCommunityCode;
        gPrefix := pPrefix;
    end;

    local procedure "--"()
    begin
    end;

    local procedure CreateCommunity(CommunityCode: Code[20]; Prefix: Code[10]; Description: Text[50]): Code[20]
    var
        MemberCommunity: Record "NPR MM Member Community";
    begin

        if (not MemberCommunity.Get(CommunityCode)) then begin
            MemberCommunity.Code := CommunityCode;
            MemberCommunity.Insert();
        end;

        MemberCommunity.Init();
        MemberCommunity.Description := Description;
        MemberCommunity."Member Unique Identity" := MemberCommunity."Member Unique Identity"::NONE;
        MemberCommunity."External Membership No. Series" := CreateNoSerie(StrSubstNo('%1-MS', Prefix), 'NPR-MS0000000001');
        MemberCommunity."External Member No. Series" := CreateNoSerie(StrSubstNo('%1-ME', Prefix), 'NPR-ME0000000001');
        MemberCommunity."Member Logon Credentials" := MemberCommunity."Member Logon Credentials"::NA;
        MemberCommunity."Membership to Cust. Rel." := false;

        //MemberCommunity."Activate Loyalty Program" := FALSE;
        MemberCommunity."Activate Loyalty Program" := true;

        MemberCommunity."Create Renewal Notifications" := false;

        MemberCommunity.Modify();

        exit(MemberCommunity.Code);
    end;

    local procedure CreateMembership(CommunityCode: Code[20]; MembershipCode: Code[20]; LoyaltyCode: Code[20]; Description: Text[50]): Code[20]
    var
        MembershipSetup: Record "NPR MM Membership Setup";
    begin

        if (not MembershipSetup.Get(MembershipCode)) then begin
            MembershipSetup.Code := MembershipCode;
            MembershipSetup.Insert();
        end;

        MembershipSetup.Description := Description;
        MembershipSetup."Membership Type" := MembershipSetup."Membership Type"::INDIVIDUAL;
        MembershipSetup."Loyalty Card" := MembershipSetup."Loyalty Card"::YES;
        MembershipSetup."Customer Config. Template Code" := '';
        MembershipSetup."Member Information" := MembershipSetup."Member Information"::ANONYMOUS;
        MembershipSetup."Member Role Assignment" := MembershipSetup."Member Role Assignment"::FIRST_IS_ADMIN;
        MembershipSetup."Membership Member Cardinality" := 1;
        MembershipSetup."Community Code" := CommunityCode;
        MembershipSetup."Create Welcome Notification" := false;
        MembershipSetup."Create Renewal Notifications" := false;
        MembershipSetup."Allow Membership Delete" := true;
        MembershipSetup."Confirm Member On Card Scan" := false;
        MembershipSetup."Loyalty Code" := LoyaltyCode;
        MembershipSetup."Card Number Scheme" := MembershipSetup."Card Number Scheme"::EXTERNAL;

        MembershipSetup.Modify();

        exit(MembershipCode);
    end;

    local procedure CreateLoyalty(LoyaltyCode: Code[20]; Description: Text[50]; AmountFactor: Decimal; PointRate: Decimal): Code[20]
    var
        LoyaltySetup: Record "NPR MM Loyalty Setup";
    begin

        if (not LoyaltySetup.Get(LoyaltyCode)) then begin
            LoyaltySetup.Code := LoyaltyCode;
            LoyaltySetup.Insert();
        end;

        LoyaltySetup.Init();
        LoyaltySetup.Description := Description;
        LoyaltySetup."Collection Period" := LoyaltySetup."Collection Period"::AS_YOU_GO;
        LoyaltySetup."Expire Uncollected Points" := false;
        LoyaltySetup."Voucher Point Source" := LoyaltySetup."Voucher Point Source"::UNCOLLECTED;
        LoyaltySetup."Voucher Point Threshold" := 1;
        LoyaltySetup."Point Base" := LoyaltySetup."Point Base"::AMOUNT;
        LoyaltySetup."Amount Base" := LoyaltySetup."Amount Base"::INCL_VAT;
        LoyaltySetup."Amount Factor" := AmountFactor;
        LoyaltySetup."Point Rate" := PointRate;

        LoyaltySetup.Modify();

        exit(LoyaltyCode);
    end;

    local procedure CreatePOSPaymentMethod(PaymentTypeCode: Code[10]; GLAccountNo: Code[20]; FixedRate: Decimal): Code[10]
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin

        GeneralLedgerSetup.Get();

        if (not POSPaymentMethod.Get(PaymentTypeCode)) then begin
            POSPaymentMethod.Code := PaymentTypeCode;
            POSPaymentMethod.Insert();
        end;

        POSPaymentMethod.Init();
        POSPaymentMethod.Description := 'NPR Loyalty Points';
        POSPaymentMethod."Block POS Payment" := false;
        POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::EFT;
        POSPaymentMethod."Fixed Rate" := FixedRate * 100;
        POSPaymentMethod."Rounding Precision" := 1.0;
        POSPaymentMethod."Account No." := GLAccountNo;
        POSPaymentMethod."Currency Code" := CreateCurrencyCode('NPLP', FixedRate);
        POSPaymentMethod.Modify(true);
        exit(PaymentTypeCode);
    end;

    local procedure CreateEndpoints(CommunityCode: Code[20]; EndpointCode: Code[10]; BaseUrl: Text; ServiceType: Integer; Username: Text[50]; Password: Text[50]; TenantName: Text)
    var
        NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup";
    begin

        NPRRemoteEndpointSetup.SetFilter(Code, '=%1', EndpointCode);
        NPRRemoteEndpointSetup.DeleteAll();

        NPRRemoteEndpointSetup.Code := EndpointCode;
        NPRRemoteEndpointSetup.Type := ServiceType;
        NPRRemoteEndpointSetup.Description := StrSubstNo('NPR %1', NPRRemoteEndpointSetup.Type);
        NPRRemoteEndpointSetup."Credentials Type" := NPRRemoteEndpointSetup."Credentials Type"::NAMED;
        NPRRemoteEndpointSetup."User Account" := Username;
        NPRRemoteEndpointSetup."User Password" := Password;
        NPRRemoteEndpointSetup."Community Code" := CommunityCode;

        // CASE Type OF
        //   Type::LoyaltyServices: "Endpoint URI" := BaseUrl+'loyalty_services';
        //   Type::MemberServices : "Endpoint URI" := BaseUrl+'member_services';
        // END;
        if (TenantName = '') then begin
            case NPRRemoteEndpointSetup.Type of
                NPRRemoteEndpointSetup.Type::LoyaltyServices:
                    NPRRemoteEndpointSetup."Endpoint URI" := StrSubstNo('%1%2', BaseUrl, 'loyalty_services');
                NPRRemoteEndpointSetup.Type::MemberServices:
                    NPRRemoteEndpointSetup."Endpoint URI" := StrSubstNo('%1%2', BaseUrl, 'member_services');
            end;
        end else begin
            case NPRRemoteEndpointSetup.Type of
                NPRRemoteEndpointSetup.Type::LoyaltyServices:
                    NPRRemoteEndpointSetup."Endpoint URI" := StrSubstNo('%1%2?tenant=%3', BaseUrl, 'loyalty_services', TenantName);
                NPRRemoteEndpointSetup.Type::MemberServices:
                    NPRRemoteEndpointSetup."Endpoint URI" := StrSubstNo('%1%2?tenant=%3', BaseUrl, 'member_services', TenantName)
            end;
        end;

        NPRRemoteEndpointSetup."Connection Timeout (ms)" := 8000;
        NPRRemoteEndpointSetup.Insert();
    end;

    local procedure CreateEFTSetup(pPaymentTypeCode: Code[10])
    var
        EFTSetup: Record "NPR EFT Setup";
        LoyaltyPointsPSPClient: Codeunit "NPR MM Loy. Point PSP (Client)";
    begin

        EFTSetup.SetFilter("Payment Type POS", '=%1', pPaymentTypeCode);
        EFTSetup.DeleteAll();

        EFTSetup."Payment Type POS" := pPaymentTypeCode;
        EFTSetup."EFT Integration Type" := LoyaltyPointsPSPClient.IntegrationName();
        EFTSetup.Insert();
    end;

    local procedure CreateStoreSetup(CommunityCode: Code[20]; AuthorizationCode: Text; CompanyName: Text; LoyaltyCode: Code[20]; PaymentTypeCode: Code[10])
    var
        LoyaltyStoreSetup: Record "NPR MM Loyalty Store Setup";
        POSStore: Record "NPR POS Store";
        FromCompany: Text;
    begin

        FromCompany := DATABASE.CompanyName;

        if (POSStore.FindSet()) then begin
            repeat
                Clear(LoyaltyStoreSetup);

                LoyaltyStoreSetup.ChangeCompany();
                if LoyaltyStoreSetup.Get('', POSStore.Code, '') then
                    LoyaltyStoreSetup.Delete();

                LoyaltyStoreSetup.Init();
                LoyaltyStoreSetup."Store Code" := POSStore.Code;
                LoyaltyStoreSetup.Description := CopyStr(POSStore.Name, 1, MaxStrLen(LoyaltyStoreSetup.Description));
                LoyaltyStoreSetup."Store Endpoint Code" := StrSubstNo('%1-L', CommunityCode);
                LoyaltyStoreSetup."Accept Client Transactions" := true;
                LoyaltyStoreSetup."Authorization Code" := AuthorizationCode;
                LoyaltyStoreSetup.Setup := LoyaltyStoreSetup.Setup::CLIENT;
                LoyaltyStoreSetup."POS Payment Method Code" := PaymentTypeCode;
                LoyaltyStoreSetup."Loyalty Setup Code" := LoyaltyCode;
                LoyaltyStoreSetup.Insert();

                if (CompanyName <> '') then begin
                    LoyaltyStoreSetup.ChangeCompany(CompanyName);
                    if (not LoyaltyStoreSetup.Get(FromCompany, POSStore.Code, '')) then begin
                        LoyaltyStoreSetup.Init();
                        LoyaltyStoreSetup.Setup := LoyaltyStoreSetup.Setup::SERVER;
                        LoyaltyStoreSetup."Store Code" := POSStore.Code;
                        LoyaltyStoreSetup."Client Company Name" := FromCompany;
                        LoyaltyStoreSetup.Insert();
                    end;

                    LoyaltyStoreSetup.Description := POSStore.Name;
                    LoyaltyStoreSetup."Authorization Code" := AuthorizationCode;
                    LoyaltyStoreSetup.Modify();
                end;

            until (POSStore.Next() = 0);
        end;
    end;

    local procedure CreatePostingSetup(POSMethodCode: Code[10]; GLAccount: Code[20])
    var
        POSStore: Record "NPR POS Store";
        POSPostingSetup: Record "NPR POS Posting Setup";
    begin

        if (POSStore.FindSet()) then begin
            repeat
                POSPostingSetup.Init();
                if (not POSPostingSetup.Get(POSStore.Code, POSMethodCode, '')) then begin
                    POSPostingSetup."POS Store Code" := POSStore.Code;
                    POSPostingSetup."POS Payment Method Code" := POSMethodCode;
                    POSPostingSetup.Insert();
                end;

                POSPostingSetup."Account Type" := POSPostingSetup."Account Type"::"G/L Account";
                POSPostingSetup."Account No." := GLAccount;
                POSPostingSetup.Modify();

            until (POSStore.Next() = 0);
        end;
    end;

    local procedure CreateCurrencyCode(CurrencyCode: Code[10]; Rate: Decimal): Code[10]
    var
        Currency: Record Currency;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin

        if (not Currency.Get(CurrencyCode)) then begin
            Currency.Init();
            Currency.Code := CurrencyCode;
            Currency.Insert(true);
        end;

        Currency.Description := 'NPR Loyalty Currency';
        Currency.Modify(true);

        if (not CurrencyExchangeRate.Get(CurrencyCode, CalcDate('<-CM>', Today))) then begin
            CurrencyExchangeRate."Currency Code" := CurrencyCode;
            CurrencyExchangeRate."Starting Date" := CalcDate('<-CM>', Today);
            CurrencyExchangeRate.Insert(true);
        end;

        CurrencyExchangeRate."Exchange Rate Amount" := 1000;
        CurrencyExchangeRate."Adjustment Exch. Rate Amount" := Rate * 1000;
        CurrencyExchangeRate."Relational Exch. Rate Amount" := Rate * 1000;
        CurrencyExchangeRate."Relational Adjmt Exch Rate Amt" := Rate * 1000;
        CurrencyExchangeRate."Fix Exchange Rate Amount" := CurrencyExchangeRate."Fix Exchange Rate Amount"::Currency;
        CurrencyExchangeRate.Modify();

        exit(CurrencyCode);
    end;

    local procedure "---"()
    begin
    end;

    local procedure CreateNoSerie(NoSerieCode: Code[20]; StartNumber: Code[20]): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin

        if (not NoSeries.Get(NoSerieCode)) then begin
            NoSeries.Code := NoSerieCode;
            NoSeries.Insert();
        end;

        NoSeries.Description := 'NPR CrossCompany Loyalty';
        NoSeries."Default Nos." := true;
        NoSeries.Modify();

        if (not NoSeriesLine.Get(NoSerieCode, 10000)) then begin
            NoSeriesLine."Series Code" := NoSerieCode;
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting Date" := 20160101D;
            NoSeriesLine."Starting No." := StartNumber;
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert();
        end;

        exit(NoSerieCode);
    end;
}

