codeunit 6014423 "NPR Install Mng. Dependencies"
{

    trigger OnRun()
    begin
        InsertBaseData;
        Commit;
        DownloadManagedDependecies;
    end;

    var
        Text001: Label 'This will Setup %1 to download automatically';
        Text002: Label 'Do you wish to Continue?';
        Text003: Label 'Downloading Managed Dependencies';
        Dia: Dialog;
        Text004: Label 'This can take 1-2 minutes';

    procedure InsertBaseData()
    var
        DependencyMgtSetup: Record "NPR Dependency Mgt. Setup";
    begin
        if GuiAllowed then
            if not Confirm(StrSubstNo(Text001, DependencyMgtSetup.TableCaption) + '\' + Text002) then
                exit;
        InsertSetup;
    end;

    procedure DownloadManagedDependecies()
    var
        ManagedDependencyMgt: Codeunit "NPR Managed Dependency Mgt.";
    begin
        if GuiAllowed then
            Dia.Open(Text003 + '\' + Text004);

        ManagedDependencyMgt.Run();

        if GuiAllowed then
            Dia.Close;
    end;

    procedure InsertSetup()
    var
        DependencyMgtSetup: Record "NPR Dependency Mgt. Setup";
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
    begin
        if not DependencyMgtSetup.Get then begin
            DependencyMgtSetup.Init;
            DependencyMgtSetup.Insert;
        end;

        DependencyMgtSetup."OData URL" := AzureKeyVaultMgt.GetSecret('NpDeployOdataUrl');
        DependencyMgtSetup.Username := AzureKeyVaultMgt.GetSecret('NpDeployOdataUsername');
        DependencyMgtSetup.StoreManagedDependencyPassword(AzureKeyVaultMgt.GetSecret('NpDeployOdataPassword'));
        DependencyMgtSetup."Accept Statuses" := DependencyMgtSetup."Accept Statuses"::Released;
        DependencyMgtSetup.Configured := true;
        DependencyMgtSetup.Modify;
    end;
}

