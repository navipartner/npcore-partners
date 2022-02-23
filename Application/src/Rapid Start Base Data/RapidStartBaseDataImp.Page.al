page 6014615 "NPR RapidStart Base Data Imp."
{
    Extensible = False;
    PageType = NavigatePage;

    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    Caption = 'RapidStart Base Data Imp.';

    layout
    {
        area(Content)
        {
            group(Step1)
            {
                Visible = currentStep = 0;
            }

            field("Package Name"; package)
            {

                Caption = 'Package Name';
                Lookup = true;
                ToolTip = 'Specifies the value of the package field';
                ApplicationArea = NPRRetail;
                trigger OnLookup(var value: Text): Boolean
                begin
                    exit(OnLookupPackage(value));
                end;
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
            action(ActionName)
            {

                ToolTip = 'Executes the ActionName action';
                Image = Action;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin

                end;
            }

            action(ActionBack)
            {

                Caption = 'Back';
                InFooterBar = true;
                ToolTip = 'Executes the Back action';
                Image = PreviousRecord;
                ApplicationArea = NPRRetail;
            }

            action(ActionNext)
            {

                Caption = 'Next';
                InFooterBar = true;
                ToolTip = 'Executes the Next action';
                Image = NextRecord;
                ApplicationArea = NPRRetail;
            }

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
    local procedure GetAzureKeyVaultSecret(Name: Text) KeyValue: Text
    var
        AppKeyVaultSecretProvider: Codeunit "App Key Vault Secret Provider";
        InMemorySecretProvider: Codeunit "In Memory Secret Provider";
        TextMgt: Codeunit "NPR Text Mgt.";
        AppKeyVaultSecretProviderInitialised: Boolean;
    begin
        if not InMemorySecretProvider.GetSecret(Name, KeyValue) then begin
            if not AppKeyVaultSecretProviderInitialised then
                AppKeyVaultSecretProviderInitialised := AppKeyVaultSecretProvider.TryInitializeFromCurrentApp();

            if not AppKeyVaultSecretProviderInitialised then
                Error(GetLastErrorText());

            if AppKeyVaultSecretProvider.GetSecret(Name, KeyValue) then
                InMemorySecretProvider.AddSecret(Name, KeyValue)
            else
                Error(TextMgt.GetSecretFailedErr(), Name);
        end;
    end;

    [NonDebuggable]
    local procedure OnFinishAction()
    var
        rapidstartBaseDataMgt: Codeunit "NPR RapidStart Base Data Mgt.";
        BaseUri: Text;
        packageName: Text;
        Secret: Text;
    begin
        packageName := package.Replace('.rapidstart', '');
        BaseUri := GetAzureKeyVaultSecret('NpRetailBaseDataBaseUrl');
        Secret := GetAzureKeyVaultSecret('NpRetailBaseDataSecret');

        BindSubscription(rapidStartBaseDataMgt);
        rapidstartBaseDataMgt.ImportPackage(
            BaseUri + '/pos-test-data/' + package
            + '?sv=2019-10-10&ss=b&srt=co&sp=rlx&se=2050-06-23T00:45:22Z&st=2020-06-22T16:45:22Z&spr=https&sig=' + Secret, packageName, AdjustTableNames);

        CurrPage.Close();
    end;

    [NonDebuggable]
    local procedure OnLookupPackage(var value: Text): Boolean
    var
        TempRetailList: Record "NPR Retail List" temporary;
        rapidstartBaseDataMgt: Codeunit "NPR RapidStart Base Data Mgt.";
        packageList: List of [Text];
        BaseUri: Text;
        locPackage: Text;
        Secret: Text;
    begin
        BaseUri := GetAzureKeyVaultSecret('NpRetailBaseDataBaseUrl');
        Secret := GetAzureKeyVaultSecret('NpRetailBaseDataSecret');

        rapidstartBaseDataMgt.GetAllPackagesInBlobStorage(BaseUri + '/pos-test-data/?restype=container&comp=list'
            + '&sv=2019-10-10&ss=b&srt=co&sp=rlx&se=2050-06-23T00:45:22Z&st=2020-06-22T16:45:22Z&spr=https&sig=' + Secret, packageList);
        foreach locPackage in packageList do begin
            TempRetailList.Number += 1;
            TempRetailList.Value := CopyStr(locPackage, 1, MaxStrLen(TempRetailList.Value));
            TempRetailList.Choice := CopyStr(locPackage, 1, MaxStrLen(TempRetailList.Choice));
            TempRetailList.Insert();
        end;

        if Page.Runmodal(Page::"NPR Retail List", TempRetailList) <> Action::LookupOK then
            exit(false);

        value := TempRetailList.Value;
        exit(true);
    end;

    var
        AdjustTableNames: Boolean;
        currentStep: Integer;
        package: Text;
}
