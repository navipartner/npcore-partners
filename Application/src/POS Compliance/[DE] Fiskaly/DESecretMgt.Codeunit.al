codeunit 6059850 "NPR DE Secret Mgt."
{
    Access = Internal;

    [NonDebuggable]
    procedure SetSecretKey(KeyName: Text; KeyValue: Text)
    begin
        if not EncryptionEnabled() then
            IsolatedStorage.Set(KeyName, KeyValue, DataScope::Company)
        else
            IsolatedStorage.SetEncrypted(KeyName, KeyValue, DataScope::Company);
    end;

    [NonDebuggable]
    procedure GetSecretKey(KeyName: Text) KeyValue: Text
    begin
        if not IsolatedStorage.Get(KeyName, DataScope::Company, KeyValue) then
            KeyValue := '';
    end;

    [NonDebuggable]
    procedure HasSecretKey(KeyName: Text): Boolean
    begin
        if KeyName = '' then
            exit(false);
        exit(GetSecretKey(KeyName) <> '');
    end;

    procedure RemoveSecretKey(KeyName: Text)
    begin
        IsolatedStorage.Delete(KeyName, DataScope::Company);
    end;
}