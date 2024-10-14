page 6184823 "NPR Setup FR EoD Profile"
{
    Caption = 'FR POS End of Day Profile Setup';
    Extensible = false;
    PageType = NavigatePage;

    layout
    {
        area(Content)
        {
            // Banners
            group(StandardBanner)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and not FinishActionEnabled;
                field(MediaResourcesStandard; MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the MediaResourcesStandard.Media Reference field';
                }
            }
            group(FinishedBanner)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and FinishActionEnabled;
                field(MediaResourcesDone; MediaResourcesDone."Media Reference")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the MediaResourcesDone.Media Reference field';
                }
            }

            // Introduction Step
            group(IntroStep)
            {
                Visible = IntroStepVisible;
                group(Welcome)
                {
                    Caption = 'Welcome to End of Day Profile Setup';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'Use this wizard to configure the End of Day profile settings for regulatory compliance.';
                    }
                }
                group("Let's go!")
                {
                    Caption = 'Let''s go!';
                    group(Group22)
                    {
                        Caption = '';
                        InstructionalText = 'Choose Next to begin setting up the End of Day profile.';
                    }
                }
            }

            // Profile Setup Step
            group(ProfileSetupStep)
            {
                Visible = ProfileSetupStepVisible;
                group(ProfileSetupInstructions)
                {
                    Caption = '';
                    InstructionalText = 'Enter the required profile settings, such as code, description, and frequency.';
                }
                group(ProfileInformation)
                {
                    Caption = 'Enter Profile Information';
                    ShowCaption = false;
                    part(ProfileInfoPage; "NPR FR POS EOD Profile Step")
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
                    InstructionalText = 'You have completed the End of Day Profile setup.';
                }
                group(NotAllMandatoryDataPopulatedMsg)
                {
                    Caption = ' ';
                    InstructionalText = 'Setup failed. Please ensure all required profile information is entered.';
                    Visible = not DataPopulated;
                }
                group(AllMandatoryDataPopulatedMsg)
                {
                    Caption = '';
                    InstructionalText = 'To finish, choose Finish.';
                    Visible = DataPopulated;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionBack)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Back';
                Enabled = BackActionEnabled;
                Image = PreviousRecord;
                InFooterBar = true;
                ToolTip = 'Go back to the previous step';
                trigger OnAction();
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Next';
                Enabled = NextActionEnabled;
                Image = NextRecord;
                InFooterBar = true;
                ToolTip = 'Move to the next step';
                trigger OnAction();
                begin
                    NextStep(false);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Finish';
                Enabled = FinishActionEnabled;
                Image = Approve;
                InFooterBar = true;
                ToolTip = 'Finish the setup';
                trigger OnAction();
                begin
                    FinishAction();
                end;
            }
        }
    }

    trigger OnInit();
    begin
        LoadTopBanners();
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
        BackActionEnabled: Boolean;
        DataPopulated: Boolean;
        FinishActionEnabled: Boolean;
        FinishStepVisible: Boolean;
        IntroStepVisible: Boolean;
        NextActionEnabled: Boolean;
        ProfileSetupStepVisible: Boolean;
        TopBannerVisible: Boolean;
        Step: Option Start,ProfileSetupStep,Finish;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowIntroStep();
            Step::ProfileSetupStep:
                ShowProfileSetupStep();
            Step::Finish:
                ShowFinishStep();
        end;
    end;

    local procedure NextStep(Backwards: Boolean)
    begin
        if Backwards then
            Step := Step - 1
        else
            Step := Step + 1;

        EnableControls();
    end;

    local procedure ShowIntroStep()
    begin
        IntroStepVisible := true;
        BackActionEnabled := false;
        FinishActionEnabled := false;
    end;

    local procedure ShowProfileSetupStep()
    begin
        CurrPage.ProfileInfoPage.Page.CopyRealToTemp();
        ProfileSetupStepVisible := true;
    end;

    local procedure ShowFinishStep()
    begin
        CheckIfDataPopulated();
        FinishStepVisible := true;
        NextActionEnabled := false;
        FinishActionEnabled := DataPopulated;
    end;

    local procedure CheckIfDataPopulated()
    begin
        DataPopulated := CurrPage.ProfileInfoPage.Page.IsDataPopulated();
    end;

    local procedure FinishAction();
    begin
        CurrPage.ProfileInfoPage.Page.CreatePOSEODProfieData();
        OnAfterFinishStep(DataPopulated);
        CurrPage.Close();
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        IntroStepVisible := false;
        ProfileSetupStepVisible := false;
        FinishStepVisible := false;
    end;

    local procedure LoadTopBanners();
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', Format(CurrentClientType())) and
           MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', Format(CurrentClientType()))
        then
            if MediaResourcesStandard.Get(MediaRepositoryStandard."Media Resources Ref") and
               MediaResourcesDone.Get(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesDone."Media Reference".HasValue();
    end;

    [BusinessEvent(false)]
    local procedure OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
    end;
}
