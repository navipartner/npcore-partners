page 6060030 "NPR PepperRapidPackage"
{
    Extensible = False;
    PageType = NavigatePage;

    UsageCategory = Administration;
    Caption = 'Pepper EFT Setup Rapid Package Deploy from Azure';
    ApplicationArea = NPRRetail;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-06-13';
    ObsoleteReason = 'No longer supported';

    layout
    {
        area(Content)
        {
            group(Step1)
            {
                Visible = currentStep = 0;
            }

            field("Package File"; packages)
            {
                Caption = 'Package File';

                Lookup = true;
                ToolTip = 'Specifies the value of the package field';
                ApplicationArea = NPRRetail;
                trigger OnLookup(var SelectedValues: Text): Boolean
                begin
                    exit(OnLookupPackage(SelectedValues));
                end;
            }
            field("Configuration Package Name"; PackageNamesFromFileNames)
            {
                Enabled = false;

                Caption = 'Configuration Package name';
                ToolTip = 'Specifies Configuration Package name(s) which will be used. It is generated from the file name(s) from Azure Blob storage. If filename containis sufix "_ver" then it will be truncated, else it will be the same as file name.';
                ApplicationArea = NPRRetail;
            }
            field("Adjust Table Names"; AdjustTableNames)
            {

                Caption = 'Adjust Table Names';
                ToolTip = 'Specifies whether table names in the package should be adjusted. The option should be enabled if the package contains NPRetail tables, and it was created in NAV/BC version prior to BC16';
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
        area(Processing)
        {


            action(ActionFinish)
            {

                Caption = 'Finish';
                InFooterBar = true;
                ToolTip = 'Executes the Finish action';
                Image = Action;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    OnFinishAction();
                end;
            }
        }
    }

    [NonDebuggable]
    local procedure OnLookupPackage(var SelectedValues: Text): Boolean
    var
        TempRetailList: Record "NPR Retail List" temporary;
        rapidstartBaseDataMgt: Codeunit "NPR RapidStart Base Data Mgt.";
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        BaseData: Codeunit "NPR Base Data";
        packageList: List of [Text];
        RetailListPage: Page "NPR Retail List";
        package: Text;
        BaseUri: Text;
        Secret: Text;
        PackageNameFromFileName: Text;
    begin
        BaseUri := BaseData.GetBaseUrl();
        Secret := AzureKeyVaultMgt.GetAzureKeyVaultSecret('NpRetailBaseDataSecret');

        rapidstartBaseDataMgt.GetAllPackagesInBlobStorage(BaseUri + '/pepperpackage/?restype=container&comp=list'
            + '&sv=2019-10-10&ss=b&srt=co&sp=rlx&se=2050-06-23T00:45:22Z&st=2020-06-22T16:45:22Z&spr=https&sig=' + Secret, packageList);
        foreach package in packageList do begin
            TempRetailList.Number += 1;
            TempRetailList.Value := CopyStr(package, 1, MaxStrLen(TempRetailList.Value));
            TempRetailList.Choice := CopyStr(package, 1, MaxStrLen(TempRetailList.Choice));
            TempRetailList.Insert();
        end;

        Commit();
        RetailListPage.LookupMode(true);
        RetailListPage.SetRec(TempRetailList);
        if RetailListPage.RunModal() <> Action::LookupOK then
            exit(false);

        SelectedValues := '';
        PackageNamesFromFileNames := '';
        RetailListPage.GetSelectionFilter(TempRetailList);
        TempRetailList.MarkedOnly(true);
        if TempRetailList.FindSet() then
            repeat
                PackageNameFromFileName := TempRetailList.Value.Replace('.rapidstart', '');
                if PackageNameFromFileName.Contains('_ver') then
                    PackageNameFromFileName := PackageNameFromFileName.Substring(1, PackageNameFromFileName.IndexOf('_ver') - 1);

                if StrLen(PackageNamesFromFileNames) > 0 then
                    PackageNamesFromFileNames += ',';
                PackageNamesFromFileNames += PackageNameFromFileName;

                if StrLen(SelectedValues) > 0 then
                    SelectedValues += ',';
                SelectedValues += TempRetailList.Value;
            until TempRetailList.Next() = 0;

        CurrPage.Update(false);
        exit(true);
    end;

    [NonDebuggable]
    local procedure OnFinishAction()
    var
        rapidstartBaseDataMgt: Codeunit "NPR RapidStart Base Data Mgt.";
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        BaseData: Codeunit "NPR Base Data";
        packageName: Text;
        BaseUri: Text;
        Secret: Text;
        RapidPackageList: List of [Text];
        RapidPackage: Text;
    begin
        BaseUri := BaseData.GetBaseUrl();
        Secret := AzureKeyVaultMgt.GetAzureKeyVaultSecret('NpRetailBaseDataSecret');

        RapidPackageList := packages.Split(',');
        foreach RapidPackage in RapidPackageList do begin
            packageName := RapidPackage.Replace('.rapidstart', '');
            if packageName.Contains('_ver') then
                packageName := packageName.Substring(1, packageName.IndexOf('_ver') - 1);

            rapidstartBaseDataMgt.ImportPackage(
                BaseUri + '/pepperpackage/' + RapidPackage
                + '?sv=2019-10-10&ss=b&srt=co&sp=rlx&se=2050-06-23T00:45:22Z&st=2020-06-22T16:45:22Z&spr=https&sig=' + Secret, packageName, AdjustTableNames);
        end;

        CurrPage.Close();
    end;

    var
        AdjustTableNames: Boolean;
        currentStep: Integer;
        packages: Text;
        PackageNamesFromFileNames: Text;
}
