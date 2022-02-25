page 6150709 "NPR POS Menu Deploy from Azure"
{
    Extensible = False;
    PageType = NavigatePage;

    UsageCategory = Administration;
    Caption = 'POS Menu Deploy from Azure';
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            field("POS Menu"; PosMenu)
            {

                Caption = 'POS Menu';
                Lookup = true;
                ToolTip = 'Specifies the value of the PosMenu field';
                ApplicationArea = NPRRetail;
                trigger OnLookup(var value: Text): Boolean
                begin
                    exit(OnLookupPosMenu(value));
                end;
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
    local procedure OnLookupPosMenu(var value: Text): Boolean
    var
        rapidstartBaseDataMgt: Codeunit "NPR RapidStart Base Data Mgt.";
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        packageList: List of [Text];
        TempRetailList: Record "NPR Retail List" temporary;
        package: Text;
        BaseUri: Text;
        Secret: Text;
    begin
        BaseUri := AzureKeyVaultMgt.GetAzureKeyVaultSecret('NpRetailBaseDataBaseUrl');
        Secret := AzureKeyVaultMgt.GetAzureKeyVaultSecret('NpRetailBaseDataSecret');

        rapidstartBaseDataMgt.GetAllPackagesInBlobStorage(BaseUri + '/posmenupackage/?restype=container&comp=list'
            + '&sv=2019-10-10&ss=b&srt=co&sp=rlx&se=2050-06-23T00:45:22Z&st=2020-06-22T16:45:22Z&spr=https&sig=' + Secret, packageList);

        foreach package in packageList do begin
            TempRetailList.Number += 1;
            TempRetailList.Value := CopyStr(package, 1, MaxStrLen(TempRetailList.Value));
            TempRetailList.Choice := CopyStr(package, 1, MaxStrLen(TempRetailList.Choice));
            TempRetailList.Insert();
        end;

        if Page.Runmodal(Page::"NPR Retail List", TempRetailList) <> Action::LookupOK then
            exit(false);

        value := TempRetailList.Value;
        exit(true);
    end;

    [NonDebuggable]
    local procedure OnFinishAction()
    var
        ManagedPackageMgt: Codeunit "NPR Managed Package Mgt.";
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
    begin
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR POS Menu");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR POS Menu Button");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR POS Parameter Value");
        ManagedPackageMgt.DeployPackageFromURL(AzureKeyVaultMgt.GetAzureKeyVaultSecret('NpRetailBaseDataBaseUrl') + '/posmenupackage/' + PosMenu);

        CurrPage.Close();
    end;

    var
        PosMenu: Text;
}
