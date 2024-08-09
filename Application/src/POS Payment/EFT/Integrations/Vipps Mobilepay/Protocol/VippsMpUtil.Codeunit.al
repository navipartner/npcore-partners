codeunit 6184710 "NPR Vipps Mp Util"
{
    Access = Internal;

    internal procedure HeaderNameClientId(): Text
    begin
        exit('client_id');
    end;

    internal procedure HeaderNameClientSecret(): Text
    begin
        exit('client_secret');
    end;

    internal procedure HeaderNameClientSubKey(): Text
    begin
        exit('Ocp-Apim-Subscription-Key');
    end;

    internal procedure HeaderNameMerchantSerialNo(): Text
    begin
        exit('Merchant-Serial-Number');
    end;

    internal procedure HeaderNameIdempotencyKey(): Text
    begin
        exit('Idempotency-Key');
    end;

    [NonDebuggable]
    internal procedure VippsPartnerClientId(): Text
    var
        azureVault: Codeunit "NPR Azure Key Vault Mgt.";
        clientId: Text;
    begin
#if VIPPS_MGT_MOCK
        clientId := 'np-debug-partner-clientid';
#else
        azureVault.TryGetAzureKeyVaultSecret('VippsMpPartnerClientId', clientId);
#endif
        exit(clientId);
    end;

    [NonDebuggable]
    internal procedure VippsPartnerClientSecret(): Text
    var
        azureVault: Codeunit "NPR Azure Key Vault Mgt.";
        clientSecret: Text;
    begin
#if VIPPS_MGT_MOCK
        clientSecret := 'np-debug-partner-clientsecret';
#else
        azureVault.TryGetAzureKeyVaultSecret('VippsMpPartnerClientSecret', clientSecret);
#endif
        exit(clientSecret);
    end;

    [NonDebuggable]
    internal procedure VippsPartnerSubkey(): Text
    var
        azureVault: Codeunit "NPR Azure Key Vault Mgt.";
        subKey: Text;
    begin
#if VIPPS_MGT_MOCK
        subKey := 'np-debug-partner-subkey1';
#else
        azureVault.TryGetAzureKeyVaultSecret('VippsMpPartnerClientSubscribtionKey', subKey);
#endif
        exit(subKey);
    end;

    [TryFunction]
    internal procedure InitHttpClient(var http: HttpClient; VippsMpStore: Record "NPR Vipps Mp Store"; WithAccessToken: Boolean; IdempotencyKey: Text[50])
    begin
        InitHttpClient(http, VippsMpStore, WithAccessToken);
        http.DefaultRequestHeaders().Add(HeaderNameIdempotencyKey(), IdempotencyKey);
    end;

    [TryFunction]
    [NonDebuggable]
    internal procedure InitHttpClient(var http: HttpClient; VippsMpStore: Record "NPR Vipps Mp Store"; WithAccessToken: Boolean)
    var
        accessTokenApi: Codeunit "NPR Vipps Mp AccessToken API";
        accessToken: Text;
        partner_client_sub: Text;
    begin
        InitHttpClient(http, VippsMpStore.Sandbox);
        if (WithAccessToken) then begin
            accessTokenApi.GetAccessToken(VippsMpStore, accessToken);
            http.DefaultRequestHeaders().Add('Authorization', 'Bearer ' + accessToken);
        end;
        if (VippsMpStore."Partner API Enabled") then begin
            partner_client_sub := VippsPartnerSubkey();
            http.DefaultRequestHeaders().Add(HeaderNameClientSubKey(), partner_client_sub);
        end else begin
            http.DefaultRequestHeaders().Add(HeaderNameClientSubKey(), VippsMpStore."Client Sub. Key");
        end;
        http.DefaultRequestHeaders().Add(HeaderNameMerchantSerialNo(), VippsMpStore."Merchant Serial Number");
    end;

    [TryFunction]
    internal procedure InitPartnerHttpClient(var http: HttpClient; Msn: Text)
    var
        accessTokenApi: Codeunit "NPR Vipps Mp AccessToken API";
        accessToken: Text;
        partner_client_id: Text;
        partner_client_secret: Text;
        partner_client_sub: Text;
    begin
        InitHttpClient(http, False);
        partner_client_id := VippsPartnerClientId();
        partner_client_secret := VippsPartnerClientSecret();
        partner_client_sub := VippsPartnerSubkey();
        accessTokenApi.GetAccessToken(Msn, partner_client_id, partner_client_secret, partner_client_sub, False, accessToken);
        http.DefaultRequestHeaders().Add('Authorization', 'Bearer ' + accessToken);
        http.DefaultRequestHeaders().Add(HeaderNameClientSubKey(), partner_client_sub);
        http.DefaultRequestHeaders().Add(HeaderNameMerchantSerialNo(), Msn);
    end;

    [TryFunction]
    internal procedure InitHttpClient(var http: HttpClient; IsSandbox: Boolean)
    var
        SystemAppVersionCheck: Codeunit "NPR System App. Version Check";
    begin
        //Vipps Testing API data is somewhat limited, also their entire PartnerAPI and ManagementAPI cant be used in test. So have "Mock Function" for this.
#if VIPPS_MGT_MOCK
            http.SetBaseAddress('https://mpvippswebhook.azurewebsites.net/api/');
            http.DefaultRequestHeaders().Add('x-functions-key', 'zOy3at7dAKkqLaC_TSBTkikb-fpUwrOiN9_CytjPtUXWAzFuNzOlRA==');
#else
        if (IsSandbox) then
            http.SetBaseAddress('https://apitest.vipps.no/')
        else
            http.SetBaseAddress('https://api.vipps.no/');
#endif
        http.DefaultRequestHeaders().Add('Vipps-System-Name', 'NP Retail');
        http.DefaultRequestHeaders().Add('Vipps-System-Version', Format(SystemAppVersionCheck.GetSystemAppVersion()));
        http.DefaultRequestHeaders().Add('Vipps-System-Plugin-Name', 'NP Retail');
        http.DefaultRequestHeaders().Add('Vipps-System-Plugin-Version', Format(SystemAppVersionCheck.GetSystemAppVersion()));
    end;

    internal procedure RemoveCurlyBraces(Guid: Guid): Text
    begin
        exit(Format(Guid).Replace('{', '').Replace('}', ''));
    end;

    internal procedure IntegerAmountToDecimalAmount(IntAmount: Integer): Decimal
    var
        Dec: Decimal;
    begin
        Dec := IntAmount / 100;
        Exit(Dec);
    end;

    internal procedure DecimalAmountToIntegerAmount(OrgAmount: Decimal) Int: Integer
    begin
        Evaluate(Int, Format(OrgAmount, 0, '<Precision,2:3><Sign><Integer><Decimals><Comma,.>').Replace('.', ''));
    end;

    internal procedure EventNameValue(WebhookEvent: Enum "NPR Vipps Mp WebhookEvents"): Text
    var
        lblError: Label 'Webhook event not handled. This is a programming error, please contact your vendor!';
    begin
        case WebhookEvent of
            WebhookEvent::EPAYMENT_CREATED:
                exit('epayments.payment.created.v1');
            WebhookEvent::EPAYMENT_ABORTED:
                exit('epayments.payment.aborted.v1');
            WebhookEvent::EPAYMENT_EXPIRED:
                exit('epayments.payment.expired.v1');
            WebhookEvent::EPAYMENT_CANCELLED:
                exit('epayments.payment.cancelled.v1');
            WebhookEvent::EPAYMENT_CAPTURED:
                exit('epayments.payment.captured.v1');
            WebhookEvent::EPAYMENT_REFUNDED:
                exit('epayments.payment.refunded.v1');
            WebhookEvent::EPAYMENT_AUTHORIZED:
                exit('epayments.payment.authorized.v1');
            WebhookEvent::EPAYMENT_TERMINATED:
                exit('epayments.payment.terminated.v1');
            WebhookEvent::QR_CHECKED_IN:
                exit('user.checked-in.v1');
        end;
        Error(lblError);
    end;

    internal procedure PaymentWebhookEventNameToEnum(Name: Text; var WhEvent: Enum "NPR Vipps Mp WebhookEvents")
    var
        lblError: Label 'Webhook event not handled. This is a programming error, please contact your vendor!';
    begin
        case Name of
            'CREATED':
                WhEvent := WhEvent::EPAYMENT_CREATED;
            'ABORTED':
                WhEvent := WhEvent::EPAYMENT_ABORTED;
            'EXPIRED':
                WhEvent := WhEvent::EPAYMENT_EXPIRED;
            'CANCELLED':
                WhEvent := WhEvent::EPAYMENT_CANCELLED;
            'CAPTURED':
                WhEvent := WhEvent::EPAYMENT_CAPTURED;
            'REFUNDED':
                WhEvent := WhEvent::EPAYMENT_REFUNDED;
            'AUTHORIZED':
                WhEvent := WhEvent::EPAYMENT_AUTHORIZED;
            'TERMINATED':
                WhEvent := WhEvent::EPAYMENT_TERMINATED;
            else begin
                Error(lblError);
            end;
        end;
    end;
}
