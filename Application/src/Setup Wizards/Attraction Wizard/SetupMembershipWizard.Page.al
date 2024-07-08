page 6151388 "NPR Setup Membership Wizard"
{
    Extensible = False;
    Caption = 'Setup Membership Wizard';
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
                group("Welcome to Membership Wizard")
                {
                    Caption = 'Welcome to Membership Wizard';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'Use this wizard to configure Member Communities, create membership setup, modify Items that are used for membership module. Create and Modify Membership Sales Setup and decide how membership can be altered by defining Membership Sales Setup.';
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

            // Create Member Community
            group(MemberCommunityStep)
            {
                Visible = CreateMemberCommunityStepVisible;
                group(CreateMemberCommunityStep)
                {
                    Caption = 'Create Member Community';
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
                    part(MemberCommunityPG; "NPR Member Community Step")
                    {
                        ApplicationArea = NPRRetail;
                    }
                }
            }

            // Create Membership Setup
            group(MembershipSetupStep)
            {
                Visible = CreateMembershipSetupStepVisible;
                group(CreateMembershipSetupStep)
                {
                    Caption = 'Create Membership Setup';
                    group(Empty2)
                    {
                        Caption = '';
                        field(EmptyVar2; EmptyVar)
                        {
                            Caption = ' ';
                            ToolTip = 'Specifies the value of the EmptyVar field';
                            Visible = false;
                            ApplicationArea = NPRRetail;
                        }
                    }
                    part(MembershipSetupPG; "NPR Membership Setup Step")
                    {
                        ApplicationArea = NPRRetail;
                    }
                }
            }

            // Create Membership Setup Items
            group(MembershipSetupItems)
            {
                Visible = CreateMembershipSetupItemsVisible;
                group(CreateMembershipSetupItemsSetp)
                {
                    Caption = 'Modify Membership Items';
                    group(Empty3)
                    {
                        Caption = '';
                        field(EmptyVar3; EmptyVar)
                        {
                            Caption = ' ';
                            ToolTip = 'Specifies the value of the EmptyVar field';
                            Visible = false;
                            ApplicationArea = NPRRetail;
                        }
                    }
                    part(MembershipSetupItemsPG; "NPR Membership Items Step")
                    {
                        ApplicationArea = NPRRetail;
                    }
                }
            }

            // Create Membership Sales Setup
            group(MembershipSalesSetup)
            {
                Visible = CreateMembershipSalesSetupsVisible;
                group(CreateMembershipSalesSetup)
                {
                    Caption = 'Create and Modify Membership Sales Setup';
                    group(Empty4)
                    {
                        Caption = '';
                        field(EmptyVar4; EmptyVar)
                        {
                            Caption = ' ';
                            ToolTip = 'Specifies the value of the EmptyVar field';
                            Visible = false;
                            ApplicationArea = NPRRetail;
                        }
                    }
                    part(MembershipSalesSetupPG; "NPR Membership SalesSetup Step")
                    {
                        ApplicationArea = NPRRetail;
                    }
                }
            }

            // Create Membership Alteration Setup
            group(MembershipAlterationSetup)
            {
                Visible = CreateMembershipAlterationSetupsVisible;
                group(CreateMembershipAlterationSetup)
                {
                    Caption = 'Create and Modify Membership Alteration Setup';
                    group(Empty5)
                    {
                        Caption = '';
                        field(EmptyVar5; EmptyVar)
                        {
                            Caption = ' ';
                            ToolTip = 'Specifies the value of the EmptyVar field';
                            Visible = false;
                            ApplicationArea = NPRRetail;
                        }
                    }
                    part(MembershipAlterationSetupPG; "NPR Members. Alter. Setup Step")
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
                        group(MemberCommunityDataMissing)
                        {
                            Caption = '';
                            Visible = not MemberCommunityDataToCreate;

                            label(MemberCommunityLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Member Communities';
                                ToolTip = 'Specifies the value of the MemberCommunityLabel field';
                            }
                        }
                        group(MembershipSetupDataMissing)
                        {
                            Caption = '';
                            Visible = not MembershipSetupDataToCreate;

                            label(MembershipSetupLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Membership Setups';
                                ToolTip = 'Specifies the value of the MembershipSetupLabel field';
                            }
                        }
                        group(MembershipSetupItemDataMissing)
                        {
                            Caption = '';
                            Visible = not MembershipSetupItemsDataToCreate;

                            label(MembershipSetupItemLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Membership Setup Item';
                                ToolTip = 'Specifies the value of the MembershipSetupItemLabel field';
                            }
                        }
                        group(MembershipSalesSetupDataMissing)
                        {
                            Caption = '';
                            Visible = not MembershipSalesetupDataToCreate;

                            label(MembershipSalesSetupLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Membership Sales Setup';
                                ToolTip = 'Specifies the value of the MembershipSalesSetupLabel field';
                            }
                        }
                        group(MembershipAlterationSetupDataMissing)
                        {
                            Caption = '';
                            Visible = not MembershipAlterationSetupDataToCreate;

                            label(MembershipAlterationSetupLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Membership Alteration Setup';
                                ToolTip = 'Specifies the value of the MembershipAlterationSetupLabel field';
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
                        group(MemberCommunityDataExists)
                        {
                            Caption = '';
                            Visible = MemberCommunityDataToCreate;
                            label(MemberCommunityLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Member Communities';
                                ToolTip = 'Specifies the value of the MemberCommunityLabel field';
                            }
                        }
                        group(MembershipSetupDataExists)
                        {
                            Caption = '';
                            Visible = MembershipSetupDataToCreate;
                            label(MembershipSetupLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Membership Setups';
                                ToolTip = 'Specifies the value of the MembershipSetupLabel field';
                            }
                        }
                        group(MembershipSetupItemsDataExists)
                        {
                            Caption = '';
                            Visible = MembershipSetupItemsDataToCreate;
                            label(MembershipSetupItemsLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Membership Setup Items';
                                ToolTip = 'Specifies the value of the MembershipSetupItemLabel field';
                            }
                        }
                        group(MembershipSalesSetupsDataExists)
                        {
                            Caption = '';
                            Visible = MembershipSalesetupDataToCreate;
                            label(MembershipSalesSetupLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Membership Sales Setups';
                                ToolTip = 'Specifies the value of the MembershipSalesSetupLabel field';
                            }
                        }
                        group(MembershipAlterationSetupsDataExists)
                        {
                            Caption = '';
                            Visible = MembershipAlterationSetupDataToCreate;
                            label(MembershipAlterationSetupLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Membership Alteration Setups';
                                ToolTip = 'Specifies the value of the MembershipAlterationSetupLabel field';
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
        Step: Option Start,CreateMemberCommunityStep,CreateMembershipSetupStep,CreateMembershipSetupItemsStep,CreateMembershipSalesSetupsStep,CreateMembershipAlterationSetupsStep,Finish;
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        IntroStepVisible: Boolean;
        CreateMemberCommunityStepVisible: Boolean;
        CreateMembershipSetupStepVisible: Boolean;
        CreateMembershipSetupItemsVisible: Boolean;
        CreateMembershipSalesSetupsVisible: Boolean;
        CreateMembershipAlterationSetupsVisible: Boolean;
        FinishStepVisible: Boolean;
        TopBannerVisible: Boolean;
        EmptyVar: Integer;
        MemberCommunityDataToCreate: Boolean;
        MembershipSetupDataToCreate: Boolean;
        MembershipSetupItemsDataToCreate: Boolean;
        MembershipSalesetupDataToCreate: Boolean;
        MembershipAlterationSetupDataToCreate: Boolean;
        AllDataFilledIn: Boolean;
        AnyDataToCreate: Boolean;
        TempMemberCommunities: Record "NPR MM Member Community" temporary;
        TempMembershipSetups: Record "NPR MM Membership Setup" temporary;
        TempItems: Record Item temporary;
        TempMembershipSalesSetups: Record "NPR MM Members. Sales Setup" temporary;
        TempMembershipAlterationSetups: Record "NPR MM Members. Alter. Setup" temporary;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowIntroStep();
            Step::CreateMemberCommunityStep:
                ShowCreateMemberCommunityStep();
            Step::CreateMembershipSetupStep:
                ShowCreateMembershipSetupStep();
            Step::CreateMembershipSetupItemsStep:
                ShowCreateMembershipItemsStep();
            Step::CreateMembershipSalesSetupsStep:
                ShowCreateMembershipSalesSetupsStep();
            Step::CreateMembershipAlterationSetupsStep:
                ShowCreateMembershipAlterationSetupsStep();
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

    local procedure ShowCreateMemberCommunityStep()
    begin
        CurrPage.MemberCommunityPG.Page.CopyLiveData();
        CreateMemberCommunityStepVisible := true;
    end;

    local procedure ShowCreateMembershipSetupStep()
    begin
        CurrPage.MembershipSetupPG.Page.CopyLiveData();
        CurrPage.MemberCommunityPG.Page.CopyTempMemberCommunities(TempMemberCommunities);
        CurrPage.MembershipSetupPG.Page.CopyTempMembershipSetups(TempMembershipSetups);
        CurrPage.MembershipSetupItemsPG.Page.Close();
        CreateMemberCommunityStepVisible := false;
        CreateMembershipSetupStepVisible := true;
    end;

    local procedure ShowCreateMembershipItemsStep()
    begin
        CurrPage.MembershipSetupItemsPG.Page.CopyLiveData();
        CurrPage.MemberCommunityPG.Page.CopyTempMemberCommunities(TempMemberCommunities);
        CurrPage.MembershipSetupPG.Page.CopyTempMembershipSetups(TempMembershipSetups);
        CurrPage.MembershipSetupItemsPG.Page.CopyTempMembershipItems(TempItems);
        CreateMemberCommunityStepVisible := false;
        CreateMembershipSetupStepVisible := false;
        CreateMembershipSetupItemsVisible := true;
    end;

    local procedure ShowCreateMembershipSalesSetupsStep()
    begin
        CurrPage.MembershipSalesSetupPG.Page.CopyLiveData();
        CurrPage.MemberCommunityPG.Page.CopyTempMemberCommunities(TempMemberCommunities);
        CurrPage.MembershipSetupPG.Page.CopyTempMembershipSetups(TempMembershipSetups);
        CurrPage.MembershipSetupItemsPG.Page.CopyTempMembershipItems(TempItems);
        CurrPage.MembershipSalesSetupPG.Page.CopyTempMembershipSalesSetups(TempMembershipSalesSetups);
        CurrPage.MembershipSetupItemsPG.Page.Close();
        CreateMemberCommunityStepVisible := false;
        CreateMembershipSetupStepVisible := false;
        CreateMembershipSetupItemsVisible := false;
        CreateMembershipSalesSetupsVisible := true;
    end;

    local procedure ShowCreateMembershipAlterationSetupsStep()
    begin
        CurrPage.MembershipAlterationSetupPG.Page.CopyLiveData();
        CurrPage.MemberCommunityPG.Page.CopyTempMemberCommunities(TempMemberCommunities);
        CurrPage.MembershipSetupPG.Page.CopyTempMembershipSetups(TempMembershipSetups);
        CurrPage.MembershipSetupItemsPG.Page.CopyTempMembershipItems(TempItems);
        CurrPage.MembershipSalesSetupPG.Page.CopyTempMembershipSalesSetups(TempMembershipSalesSetups);
        CurrPage.MembershipAlterationSetupPG.Page.CopyTempMembershipAlterationSetups(TempMembershipAlterationSetups);
        CreateMemberCommunityStepVisible := false;
        CreateMembershipSetupStepVisible := false;
        CreateMembershipSetupItemsVisible := false;
        CreateMembershipSalesSetupsVisible := false;
        CreateMembershipAlterationSetupsVisible := true;
    end;

    local procedure ShowFinishStep()
    begin
        CheckIfDataFilledIn();
        FinishStepVisible := true;
        CreateMemberCommunityStepVisible := false;
        CreateMembershipSetupStepVisible := false;
        CreateMembershipSetupItemsVisible := false;
        CreateMembershipSalesSetupsVisible := false;
        CreateMembershipAlterationSetupsVisible := false;
        NextActionEnabled := false;
        FinishActionEnabled := true;
    end;

    local procedure CheckIfDataFilledIn()
    begin
        MemberCommunityDataToCreate := CurrPage.MemberCommunityPG.Page.MemberCommunitiesToCreate();
        MembershipSetupDataToCreate := CurrPage.MembershipSetupPG.Page.MembershipSetupsToCreate();
        MembershipSetupItemsDataToCreate := CurrPage.MembershipSetupItemsPG.Page.MembershipItemsToCreate();
        MembershipSalesetupDataToCreate := CurrPage.MembershipSalesSetupPG.Page.MembershipSalesSetupsToCreate();
        MembershipAlterationSetupDataToCreate := CurrPage.MembershipAlterationSetupPG.Page.MembershipAlterationSetupsToCreate();
        AllDataFilledIn := MemberCommunityDataToCreate and
                           MembershipSetupDataToCreate and
                           MembershipSetupItemsDataToCreate and
                           MembershipSalesetupDataToCreate and
                           MembershipAlterationSetupDataToCreate;
        AnyDataToCreate := MemberCommunityDataToCreate or
                           MembershipSetupDataToCreate or
                           MembershipSetupItemsDataToCreate or
                           MembershipSalesetupDataToCreate or
                           MembershipAlterationSetupDataToCreate;
    end;

    local procedure FinishAction();
    begin
        CurrPage.MemberCommunityPG.Page.CreateMemberCommunities();
        CurrPage.MembershipSetupPG.Page.CreateMembershipSetups();
        CurrPage.MembershipSetupItemsPG.Page.CreateMembershipItems();
        CurrPage.MembershipSalesSetupPG.Page.CreateMembershipSalesSetups();
        CurrPage.MembershipAlterationSetupPG.Page.CreateMembershipAlterationSetups();
        OnAfterFinishStep(AnyDataToCreate);
        CurrPage.Close();
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        IntroStepVisible := false;
        CreateMemberCommunityStepVisible := false;
        CreateMembershipSetupStepVisible := false;
        CreateMembershipSetupItemsVisible := false;
        CreateMembershipSalesSetupsVisible := false;
        CreateMembershipAlterationSetupsVisible := false;
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

