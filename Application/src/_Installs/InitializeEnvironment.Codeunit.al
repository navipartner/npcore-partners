codeunit 6014694 "NPR Initialize Environment"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerDatabase()
    begin
        AllowHttpRequestForSandboxEnvironment();
        EnableNPRRetailInApplicationAreaSetup();
    end;

    local procedure AllowHttpRequestForSandboxEnvironment()
    var
        EnvironmentHandler: Codeunit "NPR Environment Handler";
    begin
        EnvironmentHandler.EnableAllowHttpInSandbox();
    end;

    local procedure EnableNPRRetailInApplicationAreaSetup()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        ApplicationAreaSetup.ModifyAll("NPR Retail", true);
    end;
}
