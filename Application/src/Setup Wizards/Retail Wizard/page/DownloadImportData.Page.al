page 6150812 "NPR Download&Import Data"
{
    Extensible = False;
    Caption = 'Download & Import Print Templates and NP Retail Basic Setup';
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
                    Caption = 'Welcome to Print Templates and NP Retail Basic Setup';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'Use this wizard to Download & Import Print Templates and NP Retail Basic Setup.';
                    }
                    group(Group19)
                    {
                        Caption = '';
                        InstructionalText = 'IMPORTANT: Data will be imported in background.';
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
            group(TemplatesDownloadStep)
            {
                Visible = DownloadStepVisible;
                group(TemplatesDownload)
                {
                    Caption = 'Download & Import Print Templates and NP Retail basic setup package';
                    Visible = DownloadStepVisible;
                    group(Group23)
                    {
                        Caption = '';
                        InstructionalText = 'Selected records on Import worksheet will be inserted or modified.';
                    }
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
                            Visible = not TestDataToCreate;
                            label(TestLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Print Templates Data';
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
                        group(PrintTemplateExist)
                        {
                            Caption = '';
                            Visible = TestDataToCreate;
                            label(TestLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Print Templates Data';
                                ToolTip = 'Specifies the value of the TestLabel1 field';
                            }
                        }
                        group(NPRetailDataExist)
                        {
                            Caption = '';
                            Visible = TestDataToCreate;
                            label(TestLabel2)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- NP Retail Basic Setup Data';
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
        PrintTemplatepackage := '/retailprinttemplates/templates.json';
        NPretailpackage := 'NPRETAILWIZARDDATA.rapidstart';
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
        DownloadStepVisible: Boolean;
        FinishStepVisible: Boolean;
        TopBannerVisible: Boolean;
        AllDataFilledIn: Boolean;
        AnyDataToCreate: Boolean;
        TestDataToCreate: Boolean;
        AdjustTableNames: Boolean;
        PrintTemplatepackage: Text;
        NPretailpackage: Text;

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
        DownloadStepVisible := true;
        ImportPrintTemplateData();
    end;

    local procedure ShowFinishStep()
    begin
        ImportNPRetailBasicData();
        CheckIfDataFilledIn();
        IntroStepVisible := false;
        FinishStepVisible := true;
        DownloadStepVisible := false;
        NextActionEnabled := false;
        FinishActionEnabled := true;
    end;

    local procedure CheckIfDataFilledIn()
    begin
        TestDataToCreate := NPretailpackage <> '';

        AllDataFilledIn := TestDataToCreate;
        AnyDataToCreate := TestDataToCreate;
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

    local procedure ImportPrintTemplateData()
    var
        ManagedPackageMgt: Codeunit "NPR Managed Package Mgt.";
        BaseData: Codeunit "NPR Base Data";
    begin
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Template Header");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Template Line");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Data Items");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Data Item Links");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Data Item Constr.");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Data Item Constr. Links");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Device Settings");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Template Media Info");
        ManagedPackageMgt.DeployPrintTemplatePackage(BaseData.GetBaseUrl() + PrintTemplatepackage);
    end;

    local procedure ImportNPRetailBasicData()
    var
        BackgroundPackageImport: Record "NPR Background Package Import";
        SessionId: Integer;
    begin
        if NPretailpackage = '' then
            exit;
        BackgroundPackageImport."Package Name" := CopyStr(NPretailpackage, 1, MaxStrLen(BackgroundPackageImport."Package Name"));
        BackgroundPackageImport."Adjust Table Names" := AdjustTableNames;
        BackgroundPackageImport.Insert();
        Session.StartSession(SessionId, Codeunit::"NPR Background Package Imp.", CompanyName, BackgroundPackageImport);
    end;

    [NonDebuggable]
    [BusinessEvent(false)]
    local procedure OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
    end;
}
