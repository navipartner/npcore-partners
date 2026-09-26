codeunit 85470 "NPR Azure Key Vault Mgt. Tests"
{
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _WrongModuleErr: Label 'This procedure cannot be called from another application.', Locked = true;

    [Test]
    procedure DirectGetterRejectsExternalCaller()
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        ErrorText: Text;
    begin
        // The test app has internalsVisibleTo access, but is still a different module.
        ClearLastError();
        asserterror AzureKeyVaultMgt.GetAzureKeyVaultSecret('CallerValidationTest');
        ErrorText := GetLastErrorText();

        _Assert.AreEqual(_WrongModuleErr, ErrorText, 'The direct getter must reject the test app.');
    end;

    [Test]
    procedure TryGetterRejectsExternalCaller()
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        SecretValue: Text;
        ErrorText: Text;
        Success: Boolean;
    begin
        SecretValue := 'unchanged';

        ClearLastError();
        Success := AzureKeyVaultMgt.TryGetAzureKeyVaultSecret('CallerValidationTest', SecretValue);
        ErrorText := GetLastErrorText();

        _Assert.IsFalse(Success, 'The try getter must reject the test app.');
        _Assert.AreEqual(_WrongModuleErr, ErrorText, 'Both entry points must reject the caller for the same reason.');
        _Assert.AreEqual('unchanged', SecretValue, 'A rejected call must not assign the secret to the output.');
    end;

    [Test]
    procedure TryGetterWithoutReturnValueRejectsExternalCaller()
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        SecretValue: Text;
        ErrorText: Text;
    begin
        ClearLastError();
        asserterror AzureKeyVaultMgt.TryGetAzureKeyVaultSecret('CallerValidationTest', SecretValue);
        ErrorText := GetLastErrorText();

        _Assert.AreEqual(_WrongModuleErr, ErrorText, 'Ignoring the try return value must still reject the caller.');
        _Assert.AreEqual('', SecretValue, 'A rejected call must not return the secret.');
    end;
}
