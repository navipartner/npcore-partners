page 6014634 "NPR Retail Downl. HW Connector"
{
    PageType = NavigatePage;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Download Hardware Connector setup from Azure';

    layout
    {
        area(Content)
        {
            group(Step1)
            {
                Visible = currentStep = 0;
            }

            field("Setup File"; SetupFiles)
            {
                Caption = 'Setup File';
                ApplicationArea = All;
                Lookup = true;
                ToolTip = 'Specifies the value of the Setup file field';
                trigger OnLookup(var SelectedValues: Text): Boolean
                var
                    tmpRetailList: Record "NPR Retail List" temporary;
                    rapidstartBaseDataMgt: Codeunit "NPR RapidStart Base Data Mgt.";
                    AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
                    packageList: List of [Text];
                    RetailListPage: Page "NPR Retail List";
                    package: Text;
                    BaseUri: Text;
                    Secret: Text;
                begin
                    BaseUri := AzureKeyVaultMgt.GetSecret('NpRetailBaseDataBaseUrl');
                    Secret := AzureKeyVaultMgt.GetSecret('NpRetailBaseDataSecret');

                    rapidstartBaseDataMgt.GetAllPackagesInBlobStorage(BaseUri + '/hwconnectorsetup/?restype=container&comp=list'
                        + '&sv=2019-10-10&ss=b&srt=co&sp=rlx&se=2050-06-23T00:45:22Z&st=2020-06-22T16:45:22Z&spr=https&sig=' + Secret, packageList);
                    foreach package in packageList do begin
                        tmpRetailList.Number += 1;
                        tmpRetailList.Value := package;
                        tmpRetailList.Choice := package;
                        tmpRetailList.Insert();
                    end;

                    RetailListPage.LookupMode(true);
                    RetailListPage.SetRec(tmpRetailList);
                    if RetailListPage.RunModal() <> Action::LookupOK then
                        exit(false);

                    SelectedValues := '';
                    RetailListPage.GetSelectionFilter(tmpRetailList);
                    tmpRetailList.MarkedOnly(true);
                    if tmpRetailList.FindSet then
                        repeat
                            if StrLen(SelectedValues) > 0 then
                                SelectedValues += ',';
                            SelectedValues += tmpRetailList.Value;
                        until tmpRetailList.Next = 0;

                    CurrPage.Update(false);
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
                    rapidstartBaseDataMgt: Codeunit "NPR RapidStart Base Data Mgt.";
                    AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
                    ManagedDependencyMgt: Codeunit "NPR Managed Dependency Mgt.";
                    BaseUri: Text;
                    Secret: Text;
                    SetupFileList: List of [Text];
                    SetupFile: Text;
                    CompleteUri: Text;
                    ReasonPhrase: Text;
                begin
                    BaseUri := AzureKeyVaultMgt.GetSecret('NpRetailBaseDataBaseUrl');
                    Secret := AzureKeyVaultMgt.GetSecret('NpRetailBaseDataSecret');

                    SetupFileList := SetupFiles.Split(',');
                    foreach SetupFile in SetupFileList do begin
                        CompleteUri := BaseUri + '/hwconnectorsetup/' + SetupFile
                            + '?sv=2019-10-10&ss=b&srt=co&sp=rlx&se=2050-06-23T00:45:22Z&st=2020-06-22T16:45:22Z&spr=https&sig=' + Secret;

                        if not (ManagedDependencyMgt.DownloadFileFromAzureBlobToUserDevice(CompleteUri, 'Download HW Connector', '', 'EXE File (*.exe)|*.exe', SetupFile, ReasonPhrase)) then
                            Error(ReasonPhrase);
                    end;

                    CurrPage.Close();
                end;
            }
        }
    }

    var
        currentStep: Integer;
        SetupFiles: Text;
}