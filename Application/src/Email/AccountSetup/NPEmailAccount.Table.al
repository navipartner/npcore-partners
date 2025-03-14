#if not (BC17 or BC18 or BC19 or BC20 or BC21)
table 6151033 "NPR NP Email Account"
{
    Access = Internal;
    Caption = 'NP Email Account';

    fields
    {
        field(1; AccountId; Integer)
        {
            Caption = 'Account Id';
            DataClassification = SystemMetadata;
        }
        field(2; Username; Text[50])
        {
            Caption = 'Username';
            DataClassification = CustomerContent;
        }
        field(3; APIKeyReference; Guid)
        {
            Caption = 'API Key Reference';
            DataClassification = SystemMetadata;
        }
        field(6; APIKeyCacheExpiry; DateTime)
        {
            Caption = 'API Key Cache Expiry';
            DataClassification = SystemMetadata;
        }
        field(4; BillingEmail; Text[100])
        {
            Caption = 'Billing E-mail';
            ExtendedDatatype = EMail;
            DataClassification = CustomerContent;
        }
        field(5; CompanyName; Text[100])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; AccountId)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        Domain: Record "NPR NP Email Domain";
        SenderIdentity: Record "NPR SendGrid Sender Identity";
        EmailAccount: Record "NPR NPEmailWebSMTPEmailAccount";
    begin
        Domain.SetRange(AccountId, Rec.AccountId);
        Domain.DeleteAll();

        SenderIdentity.SetRange(NPEmailAccountId, Rec.AccountId);
        SenderIdentity.DeleteAll();

        EmailAccount.SetRange(NPEmailAccountId, Rec.AccountId);
        EmailAccount.DeleteAll();
    end;

    [NonDebuggable]
    internal procedure GetApiKey() ApiKey: Text
    begin
        if (IsNullGuid(Rec.APIKeyReference)) then
            exit('');
        if (Rec.APIKeyCacheExpiry <> 0DT) and (Rec.APIKeyCacheExpiry < CurrentDateTime()) then
            RefreshApiKey();
        if (IsolatedStorage.Get(Rec.APIKeyReference, DataScope::Company, ApiKey)) then;
    end;

    [NonDebuggable]
    internal procedure SetApiKey(NewKey: Text)
    begin
        if (IsNullGuid(Rec.APIKeyReference)) then
            Rec.APIKeyReference := CreateGuid();
        if (EncryptionEnabled() and EncryptionKeyExists()) then
            IsolatedStorage.SetEncrypted(Rec.APIKeyReference, NewKey, DataScope::Company)
        else
            IsolatedStorage.Set(Rec.APIKeyReference, NewKey, DataScope::Company);

        Rec.APIKeyCacheExpiry := CurrentDateTime() + (60 * 60 * 1000); // cache for 1 hour
    end;

    local procedure RefreshApiKey()
    var
        Client: Codeunit "NPR SendGrid Client";
        [NonDebuggable]
        ApiKey: Text;
    begin
        Client.GetApiKeyFromD1Database(Client.GetEnvironmentIdentifier(), ApiKey);
        Rec.SetApiKey(ApiKey);
        Rec.Modify();
    end;
}
#endif