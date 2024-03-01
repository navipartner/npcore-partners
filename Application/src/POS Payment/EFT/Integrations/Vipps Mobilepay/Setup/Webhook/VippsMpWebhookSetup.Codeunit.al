codeunit 6184758 "NPR Vipps Mp Webhook Setup"
{
    Access = Internal;

    internal procedure CreateWebhook(VippsMpStore: Record "NPR Vipps Mp Store"; var VippsMpWebhook: Record "NPR Vipps Mp Webhook")
    var
        VippsMpWebhookEvents: Enum "NPR Vipps Mp WebhookEvents";
        VippsMpWebhookAPI: Codeunit "NPR Vipps Mp Webhook API";
        EventList: List of [Enum "NPR Vipps Mp WebhookEvents"];
        Resp: JsonObject;
        Token: JsonToken;
        I: Integer;
    begin
#pragma warning disable AA0139
        VippsMpWebhook."Webhook Url" := AzureWebhookUrl(VippsMpWebhook);
#pragma warning restore AA0139
        VippsMpWebhook.Modify();
        foreach I in VippsMpWebhookEvents.Ordinals() do begin
            EventList.Add(Enum::"NPR Vipps Mp WebhookEvents".FromInteger(I));
        end;
        if (not VippsMpWebhookAPI.RegisterWebhook(VippsMpWebhook."Webhook Url", EventList, VippsMpStore, Resp)) then begin
            VippsMpWebhook.Delete();
            Message('Could not create webhook: ' + GetLastErrorText());
            exit;
        end;
        Resp.Get('id', Token);
#pragma warning disable AA0139
        VippsMpWebhook."Webhook Id" := Token.AsValue().AsText();
        Resp.Get('secret', Token);
        VippsMpWebhook."Webhook Secret" := Token.AsValue().AsText();
#pragma warning restore AA0139
        VippsMpWebhook.Modify();
    end;

    internal procedure DeleteWebhook(VippsMpStore: Record "NPR Vipps Mp Store"; WhRec: Record "NPR Vipps Mp Webhook")
    var
        VippsMpWebhookAPI: Codeunit "NPR Vipps Mp Webhook API";
    begin
        if (not VippsMpWebhookAPI.DeleteWebhook(WhRec."Webhook Id", VippsMpStore)) then
            Message('Could not delete Webhook: %1', GetLastErrorText());
        WhRec.Delete();
    end;

    internal procedure ListAllWebhooks(VippsMpStore: Record "NPR Vipps Mp Store")
    var
        VippsMpWebhookAPI: Codeunit "NPR Vipps Mp Webhook API";
        Resp: JsonObject;
        Token: JsonToken;
        Token2: JsonToken;
        Webhook: JsonToken;
        WebhookList: Text;
    begin
        if (not VippsMpWebhookAPI.GetAllRegisteredWebhooks(VippsMpStore, Resp)) then
            Error('Could not fetch Webhooks: %1', GetLastErrorText());
        Resp.Get('webhooks', Token);
        WebhookList := '[ ';
        foreach Webhook in Token.AsArray() do begin
            Webhook.AsObject().Get('id', Token2);
            WebhookList += Token2.AsValue().AsText() + ' => ';
            Webhook.AsObject().Get('url', Token2);
            WebhookList += Token2.AsValue().AsText() + ', ';
        end;
        WebhookList += ' ]';
        Message(WebhookList);

    end;

    internal procedure SynchronizeWebhooks(VippsMpStore: Record "NPR Vipps Mp Store"; var Deleted: Integer)
    var
        VippsMpWebhookAPI: Codeunit "NPR Vipps Mp Webhook API";
        VippsMpWebhook: Record "NPR Vipps Mp Webhook";
        Resp: JsonObject;
        Token: JsonToken;
        Token2: JsonToken;
        Webhook: JsonToken;
    begin
        if (not VippsMpWebhookAPI.GetAllRegisteredWebhooks(VippsMpStore, Resp)) then
            Error('Could not fetch Webhooks: %1', GetLastErrorText());
        Resp.Get('webhooks', Token);
        Deleted := 0;
        foreach Webhook in Token.AsArray() do begin
            Webhook.AsObject().Get('id', Token2);
            VippsMpWebhook.Reset();
            VippsMpWebhook.SetRange("Webhook Id", Token2.AsValue().AsText());
            if (not VippsMpWebhook.FindFirst()) then begin
                Deleted += 1;
                VippsMpWebhookAPI.DeleteWebhook(Token2.AsValue().AsText(), VippsMpStore);
            end;
        end;
    end;

    [NonDebuggable]
    local procedure AzureWebhookUrl(WhRec: Record "NPR Vipps Mp Webhook"): Text
    var
        EnvironmentInformation: Codeunit "Environment Information";
        AzureADTenant: Codeunit "Azure AD Tenant";
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        WebhookBaseurl: Label 'https://npvippsmobilepay.azurewebsites.net/api', Locked = true;
        KeyLbl: Label 'NPVippsMobilepayAFCode', Locked = True;
    begin
        if (not EnvironmentInformation.IsOnPrem()) then
            exit(StrSubstNo('%1/MpVippsCloud/%2/%3/%4/%5?code=%6',
            WebhookBaseurl,
            AzureADTenant.GetAadTenantId(),
            EnvironmentInformation.GetEnvironmentName(),
            CompanyName(),
            WhRec."Webhook Reference",
            AzureKeyVaultMgt.GetAzureKeyVaultSecret(KeyLbl)))
        else
            exit(StrSubstNo('%1/MpVippsOnPrem/%2/%3/%4?code=%5',
            WebhookBaseurl,
            WhRec."OnPrem AF Credential Id",
            WhRec."OnPrem AF Credential Key",
            WhRec."Webhook Reference",
            AzureKeyVaultMgt.GetAzureKeyVaultSecret(KeyLbl)));
    end;
}