page 6151387 "NPR Create Tickets&TicketItems"
{
    Extensible = False;
    Caption = 'Create Tickets & Ticket Items';
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
                group("Welcome to Ticketing Wizard")
                {
                    Caption = 'Welcome to Ticket Wizard';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'Use this wizard to create Ticket Types, run Ticket Wizard as well as modify Ticket Items that have been imported in previous step.';
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

            // Create Ticket Type
            group(TicketTypeStep)
            {
                Visible = CreateTicketTypeVisible;
                group(CreateTicketTypeStep)
                {
                    Caption = 'Create Ticket Type';
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
                    part(TicketTypePG; "NPR Create TicketType Step")
                    {
                        ApplicationArea = NPRRetail;
                    }
                }
            }

            // Modify Ticket Items
            group(TicketItems)
            {
                Visible = CreateTicketItemsVisible;
                group(CreateTicketItemsStep)
                {
                    Caption = 'Modify Ticket Items';
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
                    part(TicketItemsPG; "NPR Create TicketItems Step")
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
                        group(TicketTypeDataMissing)
                        {
                            Caption = '';
                            Visible = not TicketTypeDataToCreate;

                            label(TicketTypeLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Ticket Types';
                                ToolTip = 'Specifies the value of the TicketTypeLabel field';
                            }
                        }
                        group(TicketItemDataMissing)
                        {
                            Caption = '';
                            Visible = not TicketItemsDataToCreate;

                            label(TicketItemLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Ticket Item';
                                ToolTip = 'Specifies the value of the TicketItemLabel field';

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
                        group(TickeTypeDataExists)
                        {
                            Caption = '';
                            Visible = TicketTypeDataToCreate;
                            label(TicketTypeLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Ticket Types';
                                ToolTip = 'Specifies the value of the TicketTypeLabel field';
                            }
                        }
                        group(TicketItemsDataExists)
                        {
                            Caption = '';
                            Visible = TicketItemsDataToCreate;
                            label(TicketItemLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Ticket Items';
                                ToolTip = 'Specifies the value of the TicketItemLabel field';
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
        Step: Option Start,CreateTicketTypeStep,CreateTicketItemsStep,Finish;
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        IntroStepVisible: Boolean;
        CreateTicketTypeVisible: Boolean;
        CreateTicketItemsVisible: Boolean;
        FinishStepVisible: Boolean;
        TopBannerVisible: Boolean;
        EmptyVar: Integer;
        TicketTypeDataToCreate: Boolean;
        TicketItemsDataToCreate: Boolean;
        AllDataFilledIn: Boolean;
        AnyDataToCreate: Boolean;
        TempTicketTypes: Record "NPR TM Ticket Type" temporary;
        TempTicketItems: Record Item temporary;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowIntroStep();
            Step::CreateTicketTypeStep:
                ShowCreateTicketTypeStep();
            Step::CreateTicketItemsStep:
                ShowCreateTicketItemsStep();
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

    local procedure ShowCreateTicketTypeStep()
    begin
        CurrPage.TicketTypePG.Page.CopyLiveData();
        CreateTicketTypeVisible := true;
    end;

    local procedure ShowCreateTicketItemsStep()
    begin
        CurrPage.TicketItemsPG.Page.CopyLiveData();
        CurrPage.TicketTypePG.Page.CopyTempTicketTypes(TempTicketTypes);
        CurrPage.TicketItemsPG.Page.CopyTempTicketItems(TempTicketItems);
        CreateTicketTypeVisible := false;
        CreateTicketItemsVisible := true;
    end;

    local procedure ShowFinishStep()
    begin
        CheckIfDataFilledIn();
        FinishStepVisible := true;
        CreateTicketTypeVisible := false;
        CreateTicketItemsVisible := false;
        NextActionEnabled := false;
        FinishActionEnabled := true;
    end;

    local procedure CheckIfDataFilledIn()
    begin
        TicketTypeDataToCreate := CurrPage.TicketTypePG.Page.TicketTypesToCreate();
        TicketItemsDataToCreate := CurrPage.TicketItemsPG.Page.TicketItemsToCreate();
        AllDataFilledIn := TicketTypeDataToCreate and
                           TicketItemsDataToCreate;
        AnyDataToCreate := TicketTypeDataToCreate or
                           TicketItemsDataToCreate;
    end;

    local procedure FinishAction();
    begin
        CurrPage.TicketTypePG.Page.CreateTicketTypes();
        CurrPage.TicketItemsPG.Page.CreateTicketItems();
        OnAfterFinishStep(AnyDataToCreate);
        CurrPage.Close();
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        IntroStepVisible := false;
        CreateTicketTypeVisible := false;
        CreateTicketItemsVisible := false;
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