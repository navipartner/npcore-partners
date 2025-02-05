page 6184778 "NPR Setup DE Connect Par. Set"
{
    Caption = 'DE Connection Parameter Set';
    Extensible = false;
    ObsoleteReason = 'Introduced page NPR Setup DE Fiskaly instead.';
    ObsoleteState = Pending;
    ObsoleteTag = '2025-02-09';
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
                group("Welcome to Retail")
                {
                    Caption = 'Welcome to Setup DE Connect Parameter Set';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'Utilize this wizard to modify Setup DE Connect Parameter Set, streamlining the process of defining and managing critical parameters. Upon completion, you retain the flexibility to review and modify the data, ensuring a seamless and tailored setup for your Setup DE Connect Parameter Set.';
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

            group(RetailVoucherTypesModifyStep)
            {
                Visible = SetDEConnectParameterStepVisible;
                group(SetupDEConnectParametersSet)
                {
                    Caption = 'Setup DE Connect Parameter Set';
                    group(Empty3)
                    {
                        Caption = '';
                        field(EmptyVar3; EmptyVar)
                        {

                            ApplicationArea = NPRRetail;
                            Caption = ' ';
                            ToolTip = 'Specifies the value of the EmptyVar field';
                            Visible = false;
                        }
                    }
                    part(SetupDEConnectParameterSet; "NPR DE Connect. Parameter Set")
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
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ActionBack)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Back';
                Enabled = BackActionEnabled;
                Image = PreviousRecord;
                InFooterBar = true;
                ToolTip = 'Executes the Back action';
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
                ToolTip = 'Executes the Next action';
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
                ToolTip = 'Executes the Finish action';
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
        AnyDataToCreate: Boolean;
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        FinishStepVisible: Boolean;
        IntroStepVisible: Boolean;
        SetDEConnectParameterStepVisible: Boolean;
        NextActionEnabled: Boolean;
        TopBannerVisible: Boolean;
        EmptyVar: Integer;
        Step: Option Start,SetupDEConnectParameterSet,Finish;

    #region HANDLE STEPS FUNCTIONS

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowIntroStep();
            Step::SetupDEConnectParameterSet:
                ShowSetupDEConnectParameterSetStep();
            Step::Finish:
                ShowFinishStep();
        end;
    end;

    local procedure ShowIntroStep()
    begin
        IntroStepVisible := true;
        BackActionEnabled := false;
        FinishActionEnabled := false;
    end;

    local procedure ShowFinishStep()
    begin
        FinishStepVisible := true;
        FinishActionEnabled := true;
        NextActionEnabled := false;
        SetDEConnectParameterStepVisible := false;
    end;

    local procedure ShowSetupDEConnectParameterSetStep()
    begin
        SetDEConnectParameterStepVisible := true;
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        IntroStepVisible := false;
        FinishStepVisible := false;
        SetDEConnectParameterStepVisible := false;
    end;

    local procedure NextStep(Backwards: Boolean)
    begin
        if Backwards then
            Step := Step - 1
        else
            Step := Step + 1;

        EnableControls();
    end;

    local procedure FinishAction();
    begin
        AnyDataToCreate := true;
        OnAfterFinishStep(AnyDataToCreate);
        CurrPage.Close();
    end;

    local procedure LoadTopBanners()
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', (CurrentClientType())) and
           MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', (CurrentClientType()))
        then
            if MediaResourcesStandard.Get(MediaRepositoryStandard."Media Resources Ref") and
               MediaResourcesDone.Get(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesDone."Media Reference".HasValue();
    end;

    #endregion HELPER FUNCTIONS

    [BusinessEvent(false)]
    local procedure OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
    end;
}