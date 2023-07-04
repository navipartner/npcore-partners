codeunit 6150930 "NPR Sandbox Secret Injection"
{
    //Open page 6150806 "NPR Sandbox Secret Injection" and inject values you need to develop/debug/test in a MS sandbox

    Access = Internal;

    var
        _SecretPrefix: Label 'SANDBOX_SECRET_INJECTION', Locked = true; //To avoid name clashes with other isolated storage values

    [NonDebuggable]
    procedure AddSecret(SecretName: Text; SecretValue: Text)
    begin
        IsolatedStorage.Set(_SecretPrefix + SecretName, SecretValue, DataScope::Module);
    end;

    [NonDebuggable]
    procedure TryGetSecret(SecretName: Text; var OutSecretValue: Text): Boolean
    begin
        if not IsolatedStorage.Contains(_SecretPrefix + SecretName) then
            exit(false);

        exit(IsolatedStorage.Get(_SecretPrefix + SecretName, OutSecretValue));
    end;

}