codeunit 6184859 "NPR AT Secret Mgt."
{
    Access = Internal;

    [NonDebuggable]
    internal procedure SetSecretKey(KeyName: Text; KeyValue: Text)
    begin
        if HasSecretKey(KeyName) then
            IsolatedStorage.Delete(KeyName, DataScope::Company);

        if not EncryptionEnabled() then
            IsolatedStorage.Set(KeyName, KeyValue, DataScope::Company)
        else
            IsolatedStorage.SetEncrypted(KeyName, KeyValue, DataScope::Company);
    end;

    [NonDebuggable]
    internal procedure GetSecretKey(KeyName: Text) KeyValue: Text
    begin
        if not IsolatedStorage.Get(KeyName, DataScope::Company, KeyValue) then
            KeyValue := '';
    end;

    [NonDebuggable]
    internal procedure HasSecretKey(KeyName: Text): Boolean
    begin
        if KeyName = '' then
            exit(false);

        exit(GetSecretKey(KeyName) <> '');
    end;

    internal procedure RemoveSecretKey(KeyName: Text)
    begin
        IsolatedStorage.Delete(KeyName, DataScope::Company);
    end;
}