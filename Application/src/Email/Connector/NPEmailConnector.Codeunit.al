#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248262 "NPR NP Email Connector" implements "Email Connector"
{
    Access = Internal;

    var
        _Feature: Codeunit "NPR NP Email Feature";
        _FeatureNotEnabledErr: Label 'The NP Email feature is not enabled';

    procedure Send(EmailMessage: Codeunit "Email Message"; AccountId: Guid)
    var
        NPEmailAccount: Record "NPR NPEmailWebSMTPEmailAccount";
        Client: Codeunit "NPR SendGrid Client";
        JToken: JsonToken;
    begin
        NPEmailAccount.SetAutoCalcFields(SenderIdentityVerified);
        NPEmailAccount.Get(AccountId);
        NPEmailAccount.TestField(SenderIdentityVerified);

        if (JToken.ReadFrom(EmailMessage.GetBody())) and (JToken.SelectToken('npemail_dynamic_template_data', JToken)) then
            Client.SendDynamicEmail(EmailMessage, NPEmailAccount)
        else
            Client.SendEmail(EmailMessage, NPEmailAccount);
    end;

    procedure GetAccounts(var Accounts: Record "Email Account")
    var
        Feature: Codeunit "NPR NP Email Feature";
        SendGridEmailAccount: Record "NPR NPEmailWebSMTPEmailAccount";
    begin
        if (not Feature.IsFeatureEnabled()) then
            exit;

        if (SendGridEmailAccount.FindSet()) then
            repeat
                Accounts.Init();
                SendGridEmailAccount.ToEmailAccount(Accounts);
                Accounts.Insert();
            until SendGridEmailAccount.Next() = 0;
    end;

    procedure ShowAccountInformation(AccountId: Guid)
    var
        SendGridEmailAccount: Record "NPR NPEmailWebSMTPEmailAccount";
        SendGridAccountCard: Page "NPR NPEmailWebSMTPEmailAccCard";
    begin
        if (not SendGridEmailAccount.Get(AccountId)) then
            exit;

        SendGridAccountCard.SetRecord(SendGridEmailAccount);
        SendGridAccountCard.RunModal();
    end;

    procedure RegisterAccount(var EmailAccount: Record "Email Account"): Boolean
    var
        TryUpdateLocalSenderIdentities: Codeunit "NPR SendGrid Try Upd SenderIds";
        SendGridEmailAccount: Record "NPR NPEmailWebSMTPEmailAccount";
        AccountWizard: Page "NPR NPEmailWebSMTPEmailAccWiz";
        NPEmailAccount: Record "NPR NP Email Account";
        Success: Boolean;
        SetupNotDoneErr: Label 'The NP Email Account setup is not completed.';
    begin
        if (not _Feature.IsFeatureEnabled()) then
            Error(_FeatureNotEnabledErr);

        if (not NPEmailAccount.FindFirst()) then
            Error(SetupNotDoneErr);

        if (not TryUpdateLocalSenderIdentities.Run()) then;

        AccountWizard.SetNPEmailAccount(NPEmailAccount);
        AccountWizard.RunModal();
        Success := AccountWizard.GetEmailAccount(SendGridEmailAccount);
        if (Success) then begin
            SendGridEmailAccount.NPEmailAccountId := NPEmailAccount.AccountId;
            SendGridEmailAccount.Insert();
            SendGridEmailAccount.ToEmailAccount(EmailAccount);
        end;
        exit(Success);
    end;

    procedure DeleteAccount(AccountId: Guid): Boolean
    var
        SendGridEmailAccount: Record "NPR NPEmailWebSMTPEmailAccount";
    begin
        SendGridEmailAccount.SetLoadFields(AccountId);
        if (SendGridEmailAccount.Get(AccountId)) then
            SendGridEmailAccount.Delete();
    end;

    procedure GetLogoAsBase64(): Text
    begin
        exit('iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAQ1JREFUeNpi+P//fwIQv/9POgDpSWAEMRgYGAQYyAMfQAb8Z6AAsMAY7778Zjhz5z2YzcHGzGCqIsDACaRh4NHzDwwrtl8AsyM8DRjkJAVQDWD494th/+VXDL/+QringYYV+6nApR+/+MDQOXc/mG1tqAA3gAmmAGSZi9p/Bpilz979YFhx5ClBLzAhcwS5UA0BuYKQIUzoAiBD3PQQkQIy5NC1t4QDERmYqggy8HDzAG1/AuZvPPWcQZb7N3EuQBgiwOBuIIbkkg+kGQACbkADQK4hKQzQQYSNNF5D4GHAxsrKICkuDmejG8LH+pdBX5wRzJeVQAQyxUkZ5IUPFOj/ADKgkExDQHoKAQIMAGZOjNtfNzSDAAAAAElFTkSuQmCC');
    end;

    procedure GetDescription(): Text[250]
    var
        EmailDescriptionLbl: Label 'NP Email sending powered by SendGrid';
    begin
        exit(EmailDescriptionLbl);
    end;
}
#endif