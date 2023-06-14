page 6150880 "NPR Create Rest. Serv. Flow"
{
    Extensible = False;
    Caption = 'Setup Restaurant Service Flow Profiles';
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
                group("Welcome to Restaurant")
                {
                    Caption = 'Welcome to Restaurant Service Flow Profiles Setup';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'Use this wizard to Setup Restaurant Service Flow Profiles.';
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

            // Create Restaurant Service Flow Profiles
            group(RestServFlowProfilesStep)
            {
                Visible = CreateRestServFlowProfilesStepVisible;
                group(CreateRestServFlowProfilesStep)
                {
                    Caption = 'Setup Restaurant Service Flow Profiles';
                    group(Empty1)
                    {
                        Caption = '';
                        field(EmptyVar1; EmptyVar)
                        {

                            Caption = ' ';
                            ToolTip = 'Specifies the value of the EmptyVar field';
                            Visible = false;
                            ApplicationArea = NPRRetail;
                        }
                    }
                    part(RestServFlowProfilesPG; "NPR Rest.Serv.Flow.Prof. Step")
                    {
                        ApplicationArea = NPRRetail;

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
                        group(RestServFlowProfilesDataMissing)
                        {
                            Caption = '';
                            Visible = not RestServFlowProfilesDataToCreate;

                            label(RestServFlowProfilesLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Restaurant Service Flow Profiles';
                                ToolTip = 'Specifies the value of the RestServFlowProfilesLabel field';

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
                        group(RestServFlowProfilesDataExists)
                        {
                            Caption = '';
                            Visible = RestServFlowProfilesDataToCreate;
                            label(RestServFlowProfilesLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Restaurant Service Flow Profiles';
                                ToolTip = 'Specifies the value of the RestServFlowProfilesLabel field';
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
        Step: Option Start,CreateRestServFlowProfilesStep,Finish;
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        IntroStepVisible: Boolean;
        CreateRestServFlowProfilesStepVisible: Boolean;
        FinishStepVisible: Boolean;
        TopBannerVisible: Boolean;
        EmptyVar: Integer;
        RestServFlowProfilesDataToCreate: Boolean;
        AllDataFilledIn: Boolean;
        AnyDataToCreate: Boolean;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowIntroStep();
            Step::CreateRestServFlowProfilesStep:
                ShowCreateRestServFlowProfilesStep();
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

    local procedure ShowCreateRestServFlowProfilesStep()
    begin
        CurrPage.RestServFlowProfilesPG.Page.CopyLiveData();
        CreateRestServFlowProfilesStepVisible := true;
    end;

    local procedure ShowFinishStep()
    begin
        CheckIfDataFilledIn();
        FinishStepVisible := true;
        CreateRestServFlowProfilesStepVisible := false;
        NextActionEnabled := false;
        FinishActionEnabled := true;
    end;

    local procedure CheckIfDataFilledIn()
    begin
        RestServFlowProfilesDataToCreate := CurrPage.RestServFlowProfilesPG.Page.RestServFlowProfilesToCreate();
        AllDataFilledIn := RestServFlowProfilesDataToCreate;
        AnyDataToCreate := RestServFlowProfilesDataToCreate;
    end;

    local procedure FinishAction();
    begin
        CurrPage.RestServFlowProfilesPG.Page.CreateRestServFlowProfiles();
        OnAfterFinishStep(AnyDataToCreate);
        CurrPage.Close();
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        IntroStepVisible := false;
        CreateRestServFlowProfilesStepVisible := false;
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

    [BusinessEvent(false)]
    local procedure OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
    end;
}

