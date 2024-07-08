page 6150815 "NPR Modify POS Posting Profile"
{
    Extensible = False;
    Caption = 'Modify POS Posting Profile';
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
                    Caption = 'Welcome to POS Posting Profile Setup';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'Use this wizard to modify POS posting profile. Please give special attention to check the fields that defines rounding precision in the POS transactions. You can specify which type of rounding will be used (Nearest, Up or Down), decimal value of rounding precision (default value is 0.5) and POS Sales Rounding G/L account.';
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

            // POS Profiles Step
            group(POSProfileStep)
            {
                Visible = POSProfilesStepVisible;
                Caption = 'If code already exists, it will be incremented to the first available code.';
                group(POSProfiles)
                {
                    Caption = 'Modify POS Posting Profiles';
                    group(PostingProfile)
                    {
                        Caption = '';
                        part(POSPostingProfiles; "NPR POS Posting Profiles Step")
                        {
                            ApplicationArea = NPRRetail;

                        }
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
                        group(Profiles)
                        {
                            Caption = '';
                            Visible = POSProfileDataMissing;
                            group(POSPostingProfileDataMissing)
                            {
                                Caption = '';
                                Visible = not POSPostingProfileDataToCreate;
                                label(POSPostingProfileLabel)
                                {
                                    ApplicationArea = NPRRetail;
                                    Caption = '- POS Posting Profiles';
                                    ToolTip = 'Specifies the value of the POSPostingProfileLabel field';

                                }
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
                        group(Profiles1)
                        {
                            Caption = '';
                            Visible = POSProfileDataToCreate;

                            group(POSPostingProfileDataExists)
                            {
                                Caption = '';
                                Visible = POSPostingProfileDataToCreate;
                                label(POSPostingProfileLabel1)
                                {
                                    ApplicationArea = NPRRetail;
                                    Caption = '- POS Posting Profiles';
                                    ToolTip = 'Specifies the value of the POSPostingProfileLabel field';
                                }
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
        Step: Option Start,POSProfilesStep,Finish;
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        IntroStepVisible: Boolean;
        POSProfilesStepVisible: Boolean;
        FinishStepVisible: Boolean;
        TopBannerVisible: Boolean;
        AllDataFilledIn: Boolean;
        POSProfileDataToCreate: Boolean;
        POSProfileDataMissing: Boolean;
        POSPostingProfileDataToCreate: Boolean;
        AnyDataToCreate: Boolean;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowIntroStep();
            Step::POSProfilesStep:
                ShowPOSProfilesStep();
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

    local procedure ShowPOSProfilesStep()
    begin
        POSProfilesStepVisible := true;
    end;

    local procedure ShowFinishStep()
    begin
        CheckIfDataFilledIn();
        FinishStepVisible := true;
        NextActionEnabled := false;
        FinishActionEnabled := true;
    end;

    local procedure CheckIfDataFilledIn()
    begin
        POSPostingProfileDataToCreate := CurrPage.POSPostingProfiles.Page.POSPOSPostingProfileDataToCreate();
        POSProfileDataToCreate := POSPostingProfileDataToCreate;
        POSProfileDataMissing := not POSPostingProfileDataToCreate;
        AllDataFilledIn := POSPostingProfileDataToCreate;
        AnyDataToCreate := POSPostingProfileDataToCreate;
    end;

    local procedure FinishAction();
    begin
        CurrPage.POSPostingProfiles.Page.CreatePOSPOSPostingProfileData();
        OnAfterFinishStep(AnyDataToCreate);
        CurrPage.Close();
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        IntroStepVisible := false;
        POSProfilesStepVisible := false;
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
