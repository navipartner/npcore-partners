page 6014615 "RapidStart Base Data Import"
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
                Lookup = true;
                trigger OnLookup(var value: Text): Boolean
                var
                    rapidstartBaseDataMgt: Codeunit "RapidStart Base Data Mgt.";
                    packageList: List of [Text];
                    tmpRetailList: Record "Retail List" temporary;
                    package: Text;
                begin
                    rapidstartBaseDataMgt.GetAllPackagesInBlobStorage('https://npretailbasedata.blob.core.windows.net/pos-test-data/?restype=container&comp=list'
                        + '&sv=2019-10-10&ss=b&srt=co&sp=rlx&se=2050-06-23T00:45:22Z&st=2020-06-22T16:45:22Z&spr=https&sig=kIxoirxmw87n5k1rCHwsqjjS%2FMpOTTi5fCMCYzq2cH8%3D', packageList);
                    foreach package in packageList do begin
                        tmpRetailList.Number += 1;
                        tmpRetailList.Value := package;
                        tmpRetailList.Choice := package;
                        tmpRetailList.Insert();
                    end;

                    if Page.Runmodal(Page::"Retail List", tmpRetailList) <> Action::LookupOK then
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
                    rapidstartBaseDataMgt: Codeunit "RapidStart Base Data Mgt.";
                    packageName: Text;
                begin
                    packageName := package.Replace('.rapidstart', '');

                    rapidstartBaseDataMgt.ImportPackage(
                        'https://npretailbasedata.blob.core.windows.net/pos-test-data/' + package
                        + '?sv=2019-10-10&ss=b&srt=co&sp=rlx&se=2050-06-23T00:45:22Z&st=2020-06-22T16:45:22Z&spr=https&sig=kIxoirxmw87n5k1rCHwsqjjS%2FMpOTTi5fCMCYzq2cH8%3D', packageName);
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