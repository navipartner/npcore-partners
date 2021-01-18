page 6150709 "NPR POS Menu Deploy from Azure"
{
    PageType = NavigatePage;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'POS Menu Deploy from Azure';

    layout
    {
        area(Content)
        {
            field("POS Menu"; PosMenu)
            {
                ApplicationArea = All;
                Lookup = true;
                ToolTip = 'Specifies the value of the PosMenu field';
                trigger OnLookup(var value: Text): Boolean
                var
                    rapidstartBaseDataMgt: Codeunit "NPR RapidStart Base Data Mgt.";
                    AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
                    packageList: List of [Text];
                    tmpRetailList: Record "NPR Retail List" temporary;
                    package: Text;
                    BaseUri: Text;
                    Secret: Text;
                begin
                    BaseUri := AzureKeyVaultMgt.GetSecret('NpRetailBaseDataBaseUrl');
                    Secret := AzureKeyVaultMgt.GetSecret('NpRetailBaseDataSecret');

                    rapidstartBaseDataMgt.GetAllPackagesInBlobStorage(BaseUri + '/posmenupackage/?restype=container&comp=list'
                        + '&sv=2019-10-10&ss=b&srt=co&sp=rlx&se=2050-06-23T00:45:22Z&st=2020-06-22T16:45:22Z&spr=https&sig=' + Secret, packageList);

                    foreach package in packageList do begin
                        tmpRetailList.Number += 1;
                        tmpRetailList.Value := package;
                        tmpRetailList.Choice := package;
                        tmpRetailList.Insert();
                    end;

                    if Page.Runmodal(Page::"NPR Retail List", tmpRetailList) <> Action::LookupOK then
                        exit(false);

                    value := tmpRetailList.Value;
                    exit(true);
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
                ApplicationArea = All;
                Caption = 'Finish';
                InFooterBar = true;
                ToolTip = 'Executes the Finish action';
                Image = Action; 

                trigger OnAction()
                var
                    AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
                    ManagedPackageMgt: Codeunit "NPR Managed Package Mgt.";
                begin
                    ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR POS Menu");
                    ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR POS Menu Button");
                    ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR POS Parameter Value");
                    ManagedPackageMgt.DeployPackageFromURL(AzureKeyVaultMgt.GetSecret('NpRetailBaseDataBaseUrl') + '/posmenupackage/' + PosMenu);

                    CurrPage.Close();
                end;
            }
        }
    }

    var
        PosMenu: Text;
}