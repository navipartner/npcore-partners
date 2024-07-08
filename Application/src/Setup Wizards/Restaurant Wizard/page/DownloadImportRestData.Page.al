page 6150894 "NPR Download&Import Rest Data"
{
    Extensible = False;
    Caption = 'Download & Import Predefined Setups';
    PageType = NavigatePage;

    layout
    {
        area(content)
        {
            // Banners
            group(StandardBanner)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and not FinishActionEnabled;
                field(MediaResourcesStandard; MediaResourcesStandard."Media Reference")
                {

                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the MediaResourcesStandard.Media Reference field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(FinishedBanner)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and FinishActionEnabled;
                field(MediaResourcesDone; MediaResourcesDone."Media Reference")
                {

                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the MediaResourcesDone.Media Reference field';
                    ApplicationArea = NPRRetail;
                }
            }

            // Introduction Step
            group(IntroStep)
            {
                Visible = IntroStepVisible;
                group("Welcome to Retail")
                {
                    Caption = 'Welcome to Download & Import Predefined Setups';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'Use this wizard to Download & Import Predefined Setups.';
                    }
                }
                group("Let's go!")
                {
                    Caption = 'Let''s go!';
                    group(Group22)
                    {
                        Caption = '';
                        InstructionalText = 'Choose Next to start the process.';
                    }
                }
            }

            // Download Step
            group(RestDataDownloadStep)
            {
                Visible = RestDataStepVisible;
                group(RestDataDownload)
                {
                    Caption = 'Download & Import Restaurant data setup package';
                    Visible = RestDataStepVisible;
                    group(Group23)
                    {
                        Caption = '';
                        InstructionalText = '';
                    }
                }

                field("Package file"; PackageName)
                {
                    Caption = 'Package file';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Select a package file to deploy predefined restaurant setups from.';
                    Lookup = true;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LookupPackage(Text));
                    end;
                }
            }

            // Finish Step
            group(Finish)
            {
                Visible = FinishStepVisible;
                group(FinishTxt)
                {
                    Caption = 'Finish';
                    InstructionalText = 'That was the last step of this wizard.';
                }

                group(MissingData)
                {
                    Caption = 'The following data won''t be created: ';
                    Visible = not AllDataFilledIn;
                    group(MandatoryDataMissing)
                    {
                        Caption = '';
                        group(TestDataMissing)
                        {
                            Caption = '';
                            Visible = not RestDataToCreate;
                            label(TestLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Restaurant Data';
                                ToolTip = 'Specifies the value of the TestLabel field';
                            }
                        }
                    }
                }
                group(NotAllMandatoryDataFilledInMsg)
                {
                    Caption = ' ';
                    InstructionalText = 'Please go back and review.';
                    Visible = not AllDataFilledIn;
                }
                group(FilledInData)
                {
                    Caption = 'The following data will be created: ';
                    Visible = AnyDataToCreate;
                    group(MandatoryDataFilledIn)
                    {
                        Caption = '';
                        group(RestDataExist)
                        {
                            Caption = '';
                            Visible = RestDataToCreate;
                            label(TestLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Restaurant Data';
                                ToolTip = 'Specifies the value of the TestLabel1 field';
                            }
                        }
                    }
                }
                group(AnyDataFilledInMsg)
                {
                    Caption = '';
                    InstructionalText = 'To create the data, choose Finish.';
                    Visible = AnyDataToCreate;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(ActionBack)
            {

                Caption = 'Back';
                Enabled = BackActionEnabled;
                Image = PreviousRecord;
                InFooterBar = true;
                ToolTip = 'Executes the Back action';
                ApplicationArea = NPRRetail;
                trigger OnAction();
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {

                Caption = 'Next';
                Enabled = NextActionEnabled;
                Image = NextRecord;
                InFooterBar = true;
                ToolTip = 'Executes the Next action';
                ApplicationArea = NPRRetail;
                trigger OnAction();
                begin
                    NextStep(false);
                end;
            }
            action(ActionFinish)
            {

                Caption = 'Finish';
                Enabled = FinishActionEnabled;
                Image = Approve;
                InFooterBar = true;
                ToolTip = 'Executes the Finish action';
                ApplicationArea = NPRRetail;
                trigger OnAction();
                begin
                    FinishAction();
                end;
            }
        }
    }
    trigger OnInit();
    var
    begin
        LoadTopBanners();
        Commit();
        NPRestaurantPackage := '';
    end;

    trigger OnOpenPage();
    begin
        Step := Step::Start;
        EnableControls();
    end;

    var
        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStandard: Record "Media Repository";
        MediaResourcesDone: Record "Media Resources";
        MediaResourcesStandard: Record "Media Resources";
        Step: Option Start,Download,Finish;
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        IntroStepVisible: Boolean;
        RestDataStepVisible: Boolean;
        FinishStepVisible: Boolean;
        TopBannerVisible: Boolean;
        AllDataFilledIn: Boolean;
        AnyDataToCreate: Boolean;
        RestDataToCreate: Boolean;
        NPRestaurantPackage: Text;
        PackageName: Text;
        UriFilterParametersLbl: Label 'sv=2019-10-10&ss=b&srt=co&sp=rlx&se=2050-06-23T00:45:22Z&st=2020-06-22T16:45:22Z&spr=https&sig=';

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowIntroStep();
            Step::Download:
                ShowDownloadStep();
            Step::Finish:
                ShowFinishStep();
        end;
    end;

    local procedure NextStep(Backwards: Boolean)
    begin
        if Backwards then
            Step := Step - 1
        ELSE
            Step := Step + 1;

        EnableControls();
    end;

    local procedure ShowIntroStep()
    begin
        IntroStepVisible := true;
        FinishActionEnabled := false;
        BackActionEnabled := false;
    end;

    local procedure ShowDownloadStep()
    begin
        RestDataStepVisible := true;
    end;

    local procedure ShowFinishStep()
    begin
        ImportNPRestaurantData();
        CheckIfDataFilledIn();
        IntroStepVisible := false;
        FinishStepVisible := true;
        RestDataStepVisible := false;
        NextActionEnabled := false;
        FinishActionEnabled := true;
    end;

    local procedure CheckIfDataFilledIn()
    begin
        RestDataToCreate := NPRestaurantPackage <> '';

        AllDataFilledIn := RestDataToCreate;
        AnyDataToCreate := RestDataToCreate;
    end;

    local procedure FinishAction();
    begin
        OnAfterFinishStep(AnyDataToCreate);
        CurrPage.Close();
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        IntroStepVisible := false;
        FinishStepVisible := false;
    end;

    local procedure LoadTopBanners()
    begin
        if MediaRepositoryStandard.GET('AssistedSetup-NoText-400px.png', FORMAT(CurrentClientType())) AND
           MediaRepositoryDone.GET('AssistedSetupDone-NoText-400px.png', FORMAT(CurrentClientType()))
        then
            if MediaResourcesStandard.GET(MediaRepositoryStandard."Media Resources Ref") AND
               MediaResourcesDone.GET(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesDone."Media Reference".HasValue();
    end;

    [NonDebuggable]
    local procedure LookupPackage(var Text: Text): Boolean
    var
        TempRetailList: Record "NPR Retail List" temporary;
        RapidStartBaseDataMgt: Codeunit "NPR RapidStart Base Data Mgt.";
        PackageList: List of [Text];
        Package: Text;
        AzureUriLbl: Label '%1/?restype=container&comp=list&%2%3', Comment = '%1 - Base Uri, %2 - Uri extension, %3 - Secret';
    begin
        RapidstartBaseDataMgt.GetAllPackagesInBlobStorage(
            StrSubstNo(AzureUriLbl, PosLayoutsAzureDataUrl(), UriFilterParametersLbl, AzureNpRetailBaseDataSecret()), PackageList);
        foreach Package in PackageList do begin
            TempRetailList.Number += 1;
            TempRetailList.Value := CopyStr(Package, 1, MaxStrLen(TempRetailList.Value));
            TempRetailList.Choice := CopyStr(Package, 1, MaxStrLen(TempRetailList.Choice));
            TempRetailList.Insert();
        end;

        if Page.Runmodal(Page::"NPR Retail List", TempRetailList) <> Action::LookupOK then
            exit(false);
        Text := TempRetailList.Value;
        exit(true);
    end;

    [NonDebuggable]
    local procedure ImportNPRestaurantData()
    var
        ManagedPackageMgt: Codeunit "NPR Managed Package Mgt.";
        AzureUriLbl: Label '%1/%2?%3%4', Comment = '%1 - Base Uri, %2 - Package name, %3 - Uri extension, %4 - Secret';
        NothingSelectedErr: Label 'Please select a remote package file first.';
    begin
        if PackageName = '' then
            Error(NothingSelectedErr);
        ManagedPackageMgt.AddExpectedTableID(Database::"NPR NPRE Restaurant Setup");
        ManagedPackageMgt.DeployPackageFromURL(
            StrSubstNo(AzureUriLbl, PosLayoutsAzureDataUrl(), PackageName, UriFilterParametersLbl, AzureNpRetailBaseDataSecret()));
        CurrPage.Close();
    end;

    [NonDebuggable]
    local procedure PosLayoutsAzureDataUrl(): Text
    var
        BaseData: Codeunit "NPR Base Data";
        AzureUriLbl: Label '%1/restaurantsetup', Comment = '%1 - Base Uri';
    begin
        exit(StrSubstNo(AzureUriLbl, BaseData.GetBaseUrl()));
    end;

    [NonDebuggable]
    local procedure AzureNpRetailBaseDataSecret(): Text
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
    begin
        exit(AzureKeyVaultMgt.GetAzureKeyVaultSecret('NpRetailBaseDataSecret'));
    end;

    [NonDebuggable]
    [BusinessEvent(false)]
    local procedure OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
    end;
}
