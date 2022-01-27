table 6014529 "NPR DE Audit Setup"
{
    Access = Internal;
    Caption = 'DE Audit Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(20; "Api URL"; Text[250])
        {
            Caption = 'Fiskaly API URL';
            DataClassification = CustomerContent;
        }

        field(21; "DSFINVK Api URL"; Text[250])
        {
            Caption = 'DSFINVK API URL';
            DataClassification = CustomerContent;
        }
        field(30; "Last Fiskaly Context"; Blob)
        {
            Caption = 'Last Fiskaly Context';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    [NonDebuggable]
    procedure SetApiKey(NewKey: Text)
    begin
        if not EncryptionEnabled() then
            IsolatedStorage.Set(ApiKeyLbl, NewKey, DataScope::Company)
        else
            IsolatedStorage.SetEncrypted(ApiKeyLbl, NewKey, DataScope::Company);
    end;

    [NonDebuggable]
    procedure GetApiKey() KeyValue: Text
    begin
        if IsolatedStorage.Get(ApiKeyLbl, DataScope::Company, KeyValue) then;
    end;

    [NonDebuggable]
    procedure HasApiKey(): Boolean
    begin
        exit(GetApiKey() <> '');
    end;

    procedure RemoveApiKey()
    begin
        IsolatedStorage.Delete(ApiKeyLbl, DataScope::Company);
    end;

    [NonDebuggable]
    procedure SetApiSecret(NewSecret: Text)
    begin
        if not EncryptionEnabled() then
            IsolatedStorage.Set(ApiSecretLbl, NewSecret, DataScope::Company)
        else
            IsolatedStorage.SetEncrypted(ApiSecretLbl, NewSecret, DataScope::Company);
    end;

    [NonDebuggable]
    procedure GetApiSecret() SecretValue: Text
    begin
        if IsolatedStorage.Get(ApiSecretLbl, DataScope::Company, SecretValue) then;
    end;

    [NonDebuggable]
    procedure HasApiSecret(): Boolean
    begin
        exit(GetApiSecret() <> '');
    end;

    procedure RemoveApiSecret()
    begin
        IsolatedStorage.Delete(ApiSecretLbl, DataScope::Company);
    end;

    var
        ApiKeyLbl: Label 'DEFiskalyApiKey', Locked = true;
        ApiSecretLbl: Label 'DEFiskalyApiSecret', Locked = true;
}
