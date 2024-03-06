codeunit 6184710 "NPR Vipps Mp Util"
{
    Access = Internal;

    [TryFunction]
    internal procedure InitHttpClient(var http: HttpClient; VippsMpStore: Record "NPR Vipps Mp Store"; WithAccessToken: Boolean; IdempotencyKey: Text[50])
    begin
        InitHttpClient(http, VippsMpStore, WithAccessToken);
        http.DefaultRequestHeaders().Add('Idempotency-Key', IdempotencyKey);
    end;

    [TryFunction]
    [NonDebuggable]
    internal procedure InitHttpClient(var http: HttpClient; VippsMpStore: Record "NPR Vipps Mp Store"; WithAccessToken: Boolean)
    var
        accessTokenApi: Codeunit "NPR Vipps Mp AccessToken API";
        accessToken: Text;
        azureVault: Codeunit "NPR Azure Key Vault Mgt.";
        partner_client_sub: Text;
    begin
        InitHttpClient(http, VippsMpStore.Sandbox);
        if (WithAccessToken) then begin
            accessTokenApi.GetAccessToken(VippsMpStore, accessToken);
            http.DefaultRequestHeaders().Add('Authorization', 'Bearer ' + accessToken);
        end;
        if (VippsMpStore."Partner API Enabled") then begin
            partner_client_sub := azureVault.GetAzureKeyVaultSecret('VippsMpPartnerClientSubscribtionKey');
            http.DefaultRequestHeaders().Add('Ocp-Apim-Subscription-Key', partner_client_sub);
        end else begin
            http.DefaultRequestHeaders().Add('Ocp-Apim-Subscription-Key', VippsMpStore."Client Sub. Key");
        end;
        http.DefaultRequestHeaders().Add('Merchant-Serial-Number', VippsMpStore."Merchant Serial Number");
    end;

    [TryFunction]
    [NonDebuggable]
    internal procedure InitPartnerHttpClient(var http: HttpClient; Msn: Text)
    var
        accessTokenApi: Codeunit "NPR Vipps Mp AccessToken API";
        accessToken: Text;
        azureVault: Codeunit "NPR Azure Key Vault Mgt.";
        partner_client_id: Text;
        partner_client_secret: Text;
        partner_client_sub: Text;
    begin
        InitHttpClient(http, False);
        partner_client_id := azureVault.GetAzureKeyVaultSecret('VippsMpPartnerClientId');
        partner_client_secret := azureVault.GetAzureKeyVaultSecret('VippsMpPartnerClientSecret');
        partner_client_sub := azureVault.GetAzureKeyVaultSecret('VippsMpPartnerClientSubscribtionKey');
        accessTokenApi.GetAccessToken(Msn, partner_client_id, partner_client_secret, partner_client_sub, False, accessToken);
        http.DefaultRequestHeaders().Add('Authorization', 'Bearer ' + accessToken);
        http.DefaultRequestHeaders().Add('Ocp-Apim-Subscription-Key', partner_client_sub);
        http.DefaultRequestHeaders().Add('Merchant-Serial-Number', Msn);
    end;

    [TryFunction]
    internal procedure InitHttpClient(var http: HttpClient; IsSandbox: Boolean)
    var
        SystemAppVersionCheck: Codeunit "NPR System App. Version Check";
    begin
        if (IsSandbox) then
            http.SetBaseAddress('https://apitest.vipps.no')
        else
            http.SetBaseAddress('https://api.vipps.no');
        http.DefaultRequestHeaders().Add('Vipps-System-Name', 'NP Retail');
        http.DefaultRequestHeaders().Add('Vipps-System-Version', Format(SystemAppVersionCheck.GetSystemAppVersion()));
        http.DefaultRequestHeaders().Add('Vipps-System-Plugin-Name', 'NP Retail');
        http.DefaultRequestHeaders().Add('Vipps-System-Plugin-Version', Format(SystemAppVersionCheck.GetSystemAppVersion()));
    end;

    internal procedure RemoveCurlyBraces(Guid: Guid): Text
    begin
        exit(Format(Guid).Replace('{', '').Replace('}', ''));
    end;

    internal procedure IntegerAmountToDecimal(IntAmount: Integer): Decimal
    var
        Dec: Decimal;
    begin
        Dec := IntAmount / 100;
        Exit(Dec);
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
