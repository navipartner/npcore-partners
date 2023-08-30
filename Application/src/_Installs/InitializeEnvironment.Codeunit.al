codeunit 6014694 "NPR Initialize Environment"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerDatabase()
    begin
        AllowHttpRequestForSandboxEnvironment();
    end;

    local procedure AllowHttpRequestForSandboxEnvironment()
    var
        EnvironmentHandler: Codeunit "NPR Environment Handler";
    begin
        EnvironmentHandler.EnableAllowHttpInSandbox();
    end;
}
