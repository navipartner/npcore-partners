page 6150882 "NPR Create Restaurant Layout"
{
    Extensible = False;
    Caption = 'Setup Restaurant Layout';
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
                    Caption = 'Welcome to Restaurant Layout Setup';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'Use this wizard to Setup Restaurants, Seating Locations and Seatings.';
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

            // Create Restaurants
            group(RestaurantsStep)
            {
                Visible = CreateRestaurantsStepVisible;
                group(CreateRestaurantsStep)
                {
                    Caption = 'Setup Restaurants';
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
                    part(RestaurantsPG; "NPR Restaurants Step")
                    {
                        ApplicationArea = NPRRetail;

                    }
                }
            }

            // Create Seating Locations
            group(SeatingLocationsStep)
            {
                Visible = CreateSeatingLocationsStepVisible;
                group(CreateSeatingLocationsStep)
                {
                    Caption = 'Setup Seating Locations';
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
                    part(SeatingLocationsPG; "NPR Seating Locations Step")
                    {
                        ApplicationArea = NPRRetail;

                    }
                }
            }

            // Create Seatings
            group(SeatingsStep)
            {
                Visible = CreateSeatingsStepVisible;
                group(CreateSeatingsStep)
                {
                    Caption = 'Setup Seatings';
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
                    part(SeatingsPG; "NPR Seatings Step")
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
                        group(RestaurantsDataMissing)
                        {
                            Caption = '';
                            Visible = not RestaurantsDataToCreate;

                            label(RestaurantsLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Restaurants';
                                ToolTip = 'Specifies the value of the RestaurantsLabel field';

                            }
                        }
                        group(SeatingLocationsDataMissing)
                        {
                            Caption = '';
                            Visible = not SeatingLocationsDataToCreate;

                            label(SeatingLocationsLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Seating Locations';
                                ToolTip = 'Specifies the value of the SeatingLocationsLabel field';

                            }
                        }
                        group(SeatingsDataMissing)
                        {
                            Caption = '';
                            Visible = not SeatingsDataToCreate;

                            label(SeatingsLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Seatings';
                                ToolTip = 'Specifies the value of the SeatingsLabel field';

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
                        group(RestaurantsDataExists)
                        {
                            Caption = '';
                            Visible = RestaurantsDataToCreate;
                            label(RestaurantsLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Restaurants';
                                ToolTip = 'Specifies the value of the RestaurantsLabel field';
                            }
                        }
                        group(SeatingLocationsDataExists)
                        {
                            Caption = '';
                            Visible = SeatingLocationsDataToCreate;
                            label(SeatingLocationsLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Seating Locations';
                                ToolTip = 'Specifies the value of the SeatingLocationsLabel field';
                            }
                        }
                        group(SeatingsDataExists)
                        {
                            Caption = '';
                            Visible = SeatingsDataToCreate;
                            label(SeatingsLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Seatings';
                                ToolTip = 'Specifies the value of the SeatingsLabel field';
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
        Step: Option Start,CreateRestaurantsStep,CreateSeatingLocationsStep,CreateSeatingsStep,Finish;
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        IntroStepVisible: Boolean;
        CreateRestaurantsStepVisible: Boolean;
        CreateSeatingLocationsStepVisible: Boolean;
        CreateSeatingsStepVisible: Boolean;
        FinishStepVisible: Boolean;
        TopBannerVisible: Boolean;
        EmptyVar: Integer;
        RestaurantsDataToCreate: Boolean;
        SeatingLocationsDataToCreate: Boolean;
        SeatingsDataToCreate: Boolean;
        AllDataFilledIn: Boolean;
        AnyDataToCreate: Boolean;
        TempRestaurant: Record "NPR NPRE Restaurant" temporary;
        TempSeatingLocations: Record "NPR NPRE Seating Location" temporary;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowIntroStep();
            Step::CreateRestaurantsStep:
                ShowCreateRestaurantsStep();
            Step::CreateSeatingLocationsStep:
                ShowCreateSeatingLocationsStep();
            Step::CreateSeatingsStep:
                ShowCreateSeatingsStep();
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

    local procedure ShowCreateRestaurantsStep()
    begin
        CurrPage.RestaurantsPG.Page.CopyLiveData();
        CreateRestaurantsStepVisible := true;
        CreateSeatingLocationsStepVisible := false;
        CreateSeatingsStepVisible := false;
    end;

    local procedure ShowCreateSeatingLocationsStep()
    begin
        CurrPage.SeatingLocationsPG.Page.CopyLiveData();
        CurrPage.RestaurantsPG.Page.CopyTempRestaurants(TempRestaurant);
        CurrPage.SeatingLocationsPG.Page.CopyTempRestaurants(TempRestaurant);
        CreateRestaurantsStepVisible := false;
        CreateSeatingLocationsStepVisible := true;
        CreateSeatingsStepVisible := false;
    end;

    local procedure ShowCreateSeatingsStep()
    begin
        CurrPage.SeatingsPG.Page.CopyLiveData();
        CurrPage.SeatingLocationsPG.Page.CopyTempSeatingLocations(TempSeatingLocations);
        CurrPage.SeatingsPG.Page.CopyTempSeatingLocations(TempSeatingLocations);
        CreateRestaurantsStepVisible := false;
        CreateSeatingLocationsStepVisible := false;
        CreateSeatingsStepVisible := true;
    end;

    local procedure ShowFinishStep()
    begin
        CheckIfDataFilledIn();
        FinishStepVisible := true;
        CreateRestaurantsStepVisible := false;
        CreateSeatingLocationsStepVisible := false;
        CreateSeatingsStepVisible := false;
        NextActionEnabled := false;
        FinishActionEnabled := true;
    end;

    local procedure CheckIfDataFilledIn()
    begin
        RestaurantsDataToCreate := CurrPage.RestaurantsPG.Page.RestaurantsToCreate();
        SeatingLocationsDataToCreate := CurrPage.SeatingLocationsPG.Page.SeatingLocationsToCreate();
        SeatingsDataToCreate := CurrPage.SeatingsPG.Page.SeatingsToCreate();
        AllDataFilledIn := RestaurantsDataToCreate and
                           SeatingLocationsDataToCreate and
                           SeatingsDataToCreate;
        AnyDataToCreate := RestaurantsDataToCreate or
                           SeatingLocationsDataToCreate or
                           SeatingsDataToCreate;
    end;

    local procedure FinishAction();
    begin
        CurrPage.RestaurantsPG.Page.CreateRestaurants();
        CurrPage.SeatingLocationsPG.Page.CreateSeatingLocations();
        CurrPage.SeatingsPG.Page.CreateSeatings();
        OnAfterFinishStep(AnyDataToCreate);
        CurrPage.Close();
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        IntroStepVisible := false;
        CreateRestaurantsStepVisible := false;
        CreateSeatingLocationsStepVisible := false;
        CreateSeatingsStepVisible := false;
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

