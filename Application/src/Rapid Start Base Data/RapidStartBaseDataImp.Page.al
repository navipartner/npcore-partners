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
                var
                    TempRetailList: Record "NPR Retail List" temporary;
                    AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
                    rapidstartBaseDataMgt: Codeunit "NPR RapidStart Base Data Mgt.";
                    packageList: List of [Text];
                    BaseUri: Text;
                    package: Text;
                    Secret: Text;
                begin
                    BaseUri := AzureKeyVaultMgt.GetSecret('NpRetailBaseDataBaseUrl');
                    Secret := AzureKeyVaultMgt.GetSecret('NpRetailBaseDataSecret');

                    rapidstartBaseDataMgt.GetAllPackagesInBlobStorage(BaseUri + '/pos-test-data/?restype=container&comp=list'
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
                var
                    AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
                    rapidstartBaseDataMgt: Codeunit "NPR RapidStart Base Data Mgt.";
                    BaseUri: Text;
                    packageName: Text;
                    Secret: Text;
                begin
                    packageName := package.Replace('.rapidstart', '');
                    BaseUri := AzureKeyVaultMgt.GetSecret('NpRetailBaseDataBaseUrl');
                    Secret := AzureKeyVaultMgt.GetSecret('NpRetailBaseDataSecret');

                    BindSubscription(rapidStartBaseDataMgt);
                    rapidstartBaseDataMgt.ImportPackage(
                        BaseUri + '/pos-test-data/' + package
                        + '?sv=2019-10-10&ss=b&srt=co&sp=rlx&se=2050-06-23T00:45:22Z&st=2020-06-22T16:45:22Z&spr=https&sig=' + Secret, packageName, AdjustTableNames);

                    CurrPage.Close();
                end;
            }
        }
    }

    var
        AdjustTableNames: Boolean;
        currentStep: Integer;
        package: Text;
}
