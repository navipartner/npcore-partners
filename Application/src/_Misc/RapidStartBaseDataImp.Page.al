page 6014615 "NPR RapidStart Base Data Imp."
{
    PageType = NavigatePage;
    ApplicationArea = All;
    UsageCategory = Administration;

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
                ApplicationArea = All;
                Lookup = true;
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

                    rapidstartBaseDataMgt.GetAllPackagesInBlobStorage(BaseUri + '/pos-test-data/?restype=container&comp=list'
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
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }

            action(ActionBack)
            {
                ApplicationArea = All;
                Caption = 'Back';
                InFooterBar = true;
            }

            action(ActionNext)
            {
                ApplicationArea = All;
                Caption = 'Next';
                InFooterBar = true;
            }

            action(ActionFinish)
            {
                ApplicationArea = All;
                Caption = 'Finish';
                InFooterBar = true;

                trigger OnAction()
                var
                    rapidstartBaseDataMgt: Codeunit "NPR RapidStart Base Data Mgt.";
                    AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
                    packageName: Text;
                    BaseUri: Text;
                    Secret: Text;
                begin
                    packageName := package.Replace('.rapidstart', '');
                    BaseUri := AzureKeyVaultMgt.GetSecret('NpRetailBaseDataBaseUrl');
                    Secret := AzureKeyVaultMgt.GetSecret('NpRetailBaseDataSecret');

                    rapidstartBaseDataMgt.ImportPackage(
                        BaseUri + '/pos-test-data/' + package
                        + '?sv=2019-10-10&ss=b&srt=co&sp=rlx&se=2050-06-23T00:45:22Z&st=2020-06-22T16:45:22Z&spr=https&sig=' + Secret, packageName);

                    CurrPage.Close();
                end;
            }
        }
    }

    local procedure TakeStep(Step: Integer)
    begin
        currentStep += Step;
        SetControls();
    end;

    local procedure SetControls()
    begin
        ActionBackAllowed := false;
        ActionNextAllowed := false;
        ActionFinishAllowed := package <> '';

    end;

    var
        ActionFinishAllowed: Boolean;
        ActionNextAllowed: Boolean;
        ActionBackAllowed: Boolean;
        currentStep: Integer;
        package: Text;

}