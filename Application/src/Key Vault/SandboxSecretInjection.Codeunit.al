codeunit 6150930 "NPR Sandbox Secret Injection"
{
    //Open page 6150806 "NPR Sandbox Secret Injection" and inject values you need to develop/debug/test in a MS sandbox

    Access = Internal;

    [NonDebuggable]
    procedure AddSecret(SecretName: Text; SecretValue: Text)
    begin
        CheckInjectionAllowed();
        IsolatedStorage.Set(SecretNameWithPrefix(SecretName), SecretValue, DataScope::Module);
    end;

    [NonDebuggable]
    procedure RemoveSecret(SecretName: Text)
    var
        SecretDoesNotExitErr: Label 'The secret you want to remove does not exist in the current environment.';
    begin
        if not IsolatedStorage.Contains(SecretNameWithPrefix(SecretName)) then
            Error(SecretDoesNotExitErr);

        IsolatedStorage.Delete(SecretNameWithPrefix(SecretName), DataScope::Module);
    end;

    [NonDebuggable]
    procedure TryGetSecret(SecretName: Text; var OutSecretValue: Text): Boolean
    begin
        if not InjectionAllowed() then
            exit(false);

        if not IsolatedStorage.Contains(SecretNameWithPrefix(SecretName)) then
            exit(false);

        exit(IsolatedStorage.Get(SecretNameWithPrefix(SecretName), OutSecretValue));
    end;

    procedure CheckInjectionAllowed()
    var
        ProductionNotAllowedErr: Label 'Secret injection is not available in production environments.';
    begin
        if not InjectionAllowed() then
            Error(ProductionNotAllowedErr);
    end;

    local procedure InjectionAllowed(): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        exit(not (EnvironmentInformation.IsSaaSInfrastructure() and EnvironmentInformation.IsProduction()));
    end;

    [NonDebuggable]
    local procedure SecretNameWithPrefix(SecretName: Text): Text
    var
        SecretPrefix: Label 'SANDBOX_SECRET_INJECTION', Locked = true; //To avoid name clashes with other isolated storage values
    begin
        exit(SecretPrefix + SecretName);
    end;
}