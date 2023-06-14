page 6150886 "NPR Create Kitchen Layout"
{
    Extensible = False;
    Caption = 'Setup Kitchen Layout';
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
                    Caption = 'Welcome to Kitchen Layout Setup';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'Use this wizard to Setup Restaurant Kitchen Stations and Kitchen Station Selection Setup.';
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

            // Create Kitchen Stations
            group(KitchenStationsStep)
            {
                Visible = CreateKitchenStationsStepVisible;
                group(CreateKitchenStationsStep)
                {
                    Caption = 'Setup Kitchen Stations';
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
                    part(KitchenStationsPG; "NPR Kitchen Stations Step")
                    {
                        ApplicationArea = NPRRetail;

                    }
                }
            }

            // Create Kitchen Station Selection Setup
            group(KitchenStationSelectionSetupStep)
            {
                Visible = CreateKitchenStationSelectionSetupStepVisible;
                group(CreateKitchenStationSelectionSetupStep)
                {
                    Caption = 'Setup Kitchen Station Selection Setup';
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
                    part(KitchenStationSelectionSetupPG; "NPR Kitch. Stat. Selec. Step")
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
                        group(KitchenStationsDataMissing)
                        {
                            Caption = '';
                            Visible = not KitchenStationsDataToCreate;

                            label(KitchenStationsLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Kitchen Stations';
                                ToolTip = 'Specifies the value of the KitchenStationsLabel field';

                            }
                        }
                        group(KitchenStationSelectionSetupDataMissing)
                        {
                            Caption = '';
                            Visible = not KitchenStationSelectionSetupDataToCreate;

                            label(KitchenStationSelectionSetupLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Kitchen Station Selection Setup';
                                ToolTip = 'Specifies the value of the KitchenStationSelectionSetupLabel field';

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
                        group(KitchenStationsDataExists)
                        {
                            Caption = '';
                            Visible = KitchenStationsDataToCreate;
                            label(KitchenStationsLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Kitchen Stations';
                                ToolTip = 'Specifies the value of the KitchenStationsLabel field';
                            }
                        }
                        group(KitchenStationSelectionSetupDataExists)
                        {
                            Caption = '';
                            Visible = KitchenStationSelectionSetupDataToCreate;
                            label(KitchenStationSelectionSetupLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Kitchen Station Selection Setup';
                                ToolTip = 'Specifies the value of the KitchenStationSelectionSetupLabel field';
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
        Step: Option Start,CreateKitchenStationsStep,CreateKitchenStationSelectionSetupStep,Finish;
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        IntroStepVisible: Boolean;
        CreateKitchenStationsStepVisible: Boolean;
        CreateKitchenStationSelectionSetupStepVisible: Boolean;
        FinishStepVisible: Boolean;
        TopBannerVisible: Boolean;
        EmptyVar: Integer;
        KitchenStationsDataToCreate: Boolean;
        KitchenStationSelectionSetupDataToCreate: Boolean;
        AllDataFilledIn: Boolean;
        AnyDataToCreate: Boolean;
        TempKitchenStations: Record "NPR NPRE Kitchen Station" temporary;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowIntroStep();
            Step::CreateKitchenStationsStep:
                ShowCreateKitchenStationsStep();
            Step::CreateKitchenStationSelectionSetupStep:
                ShowCreateKitchenStationSelectionSetupStep();
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

    local procedure ShowCreateKitchenStationsStep()
    begin
        CurrPage.KitchenStationsPG.Page.CopyLiveData();
        CreateKitchenStationsStepVisible := true;
        CreateKitchenStationSelectionSetupStepVisible := false;
    end;

    local procedure ShowCreateKitchenStationSelectionSetupStep()
    begin
        CurrPage.KitchenStationSelectionSetupPG.Page.CopyLiveData();
        CurrPage.KitchenStationsPG.Page.CopyTempKitchenStations(TempKitchenStations);
        CurrPage.KitchenStationSelectionSetupPG.Page.CopyTempKitchenStations(TempKitchenStations);
        CreateKitchenStationsStepVisible := false;
        CreateKitchenStationSelectionSetupStepVisible := true;
    end;

    local procedure ShowFinishStep()
    begin
        CheckIfDataFilledIn();
        FinishStepVisible := true;
        CreateKitchenStationsStepVisible := false;
        CreateKitchenStationSelectionSetupStepVisible := false;
        NextActionEnabled := false;
        FinishActionEnabled := true;
    end;

    local procedure CheckIfDataFilledIn()
    begin
        KitchenStationsDataToCreate := CurrPage.KitchenStationsPG.Page.KitchenStationsToCreate();
        KitchenStationSelectionSetupDataToCreate := CurrPage.KitchenStationSelectionSetupPG.Page.KitchenStationSelectionSetupToCreate();
        AllDataFilledIn := KitchenStationsDataToCreate and
                           KitchenStationSelectionSetupDataToCreate;
        AnyDataToCreate := KitchenStationsDataToCreate or
                           KitchenStationSelectionSetupDataToCreate;
    end;

    local procedure FinishAction();
    begin
        CurrPage.KitchenStationsPG.Page.CreateKitchenStations();
        CurrPage.KitchenStationSelectionSetupPG.Page.CreateKitchenStationSelectionSetup();
        OnAfterFinishStep(AnyDataToCreate);
        CurrPage.Close();
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        IntroStepVisible := false;
        CreateKitchenStationsStepVisible := false;
        CreateKitchenStationSelectionSetupStepVisible := false;
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

