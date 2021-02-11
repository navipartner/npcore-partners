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
                ToolTip = 'Specifies the value of the package field';
                trigger OnLookup(var value: Text): Boolean
                var
                    tmpRetailList: Record "NPR Retail List" temporary;
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
            field("Adjust Table Names"; AdjustTableNames)
            {
                ApplicationArea = All;
                Caption = 'Adjust Table Names';
                ToolTip = 'Specifies whether table names in the package should be adjusted. The option should be enabled if the package contains NPRetail tables, and it was created in NAV/BC version prior to BC16';
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
                ToolTip = 'Executes the ActionName action';
                Image = Action;

                trigger OnAction()
                begin

                end;
            }

            action(ActionBack)
            {
                ApplicationArea = All;
                Caption = 'Back';
                InFooterBar = true;
                ToolTip = 'Executes the Back action';
                Image = PreviousRecord;
            }

            action(ActionNext)
            {
                ApplicationArea = All;
                Caption = 'Next';
                InFooterBar = true;
                ToolTip = 'Executes the Next action';
                Image = NextRecord;
            }

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
                    rapidstartBaseDataMgt: Codeunit "NPR RapidStart Base Data Mgt.";
                    BaseUri: Text;
                    packageName: Text;
                    Secret: Text;
                begin
                    packageName := package.Replace('.rapidstart', '');
                    BaseUri := AzureKeyVaultMgt.GetSecret('NpRetailBaseDataBaseUrl');
                    Secret := AzureKeyVaultMgt.GetSecret('NpRetailBaseDataSecret');

                    rapidstartBaseDataMgt.ImportPackage(
                        BaseUri + '/pos-test-data/' + package
                        + '?sv=2019-10-10&ss=b&srt=co&sp=rlx&se=2050-06-23T00:45:22Z&st=2020-06-22T16:45:22Z&spr=https&sig=' + Secret, packageName, AdjustTableNames);

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
        ActionBackAllowed: Boolean;
        ActionFinishAllowed: Boolean;
        ActionNextAllowed: Boolean;
        AdjustTableNames: Boolean;
        currentStep: Integer;
        package: Text;
}