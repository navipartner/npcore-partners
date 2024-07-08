page 6150813 "NPR Create POS Stores & Units"
{
    Extensible = False;
    Caption = 'Create POS Stores & Units';
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
                    Caption = 'Welcome to POS Stores & Units Setup';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'Use this wizard to create both POS stores & POS Units. On the next page you need to define number of POS stores to create, starting number for POS stores, number of POS units to create and starting number for POS units. After creation you have a possibility to modify created data. ';
                    }
                    group(Group19)
                    {
                        Caption = '';
                        InstructionalText = 'IMPORTANT: Field POS Store on POS Units will be populated automatically, please modify values if needed.';
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

            // POS Store & Unit Create Step
            group(POSStoreUnitsCreateStep)
            {
                Visible = CreatePOSStoresUnitsStepVisible;
                group(POSStoresCreate)
                {
                    Caption = 'Create POS Stores & Units';
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
                    part(POSStoresAndUnitsPG; "NPR POS Stores & Units Step")
                    {
                        ApplicationArea = NPRRetail;
                    }
                }
            }

            // POS Stores Modify
            group(POSStoreModifyStep)
            {
                Visible = POSStoresModifyStepVisible;
                group(POSStores)
                {
                    Caption = 'Modify POS Stores';
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
                    part(POSStoresModifyPG; "NPR POS Stores Modify Step")
                    {
                        ApplicationArea = NPRRetail;
                    }
                }
            }

            // POS Units Modify
            group(POSUnitsModifyStep)
            {
                Visible = POSUnitsModifyStepVisible;
                group(POSUnits)
                {
                    Caption = 'Modify POS Units';
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
                    part(POSUnitsModifyPG; "NPR POS Units Modify Step")
                    {
                        ApplicationArea = NPRRetail;
                    }
                }
            }

            group(RetailLogoModifyStep)
            {
                Visible = RetailLogoModifyStepVisible;
                group(RetailLogoSetup)
                {
                    Caption = 'Modify Retail Logo Setup';
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
                    part(RetailLogoModifyPG; "NPR Retail Logo Modify Step")
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
                        Caption = '';
                        group(POSStoresDataMissing)
                        {
                            Caption = '';
                            Visible = not POSStoresDataToCreate;

                            label(POSStoresLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- POS Stores';
                                ToolTip = 'Specifies the value of the POSStoresLabel field';
                            }
                        }
                        group(POSStoresDimensionDataMissing)
                        {
                            Caption = '';
                            Visible = not POSStoreDimensionsToCreate;
                            label(POSStoresDimensionLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- POS Stores Dimensions';
                                ToolTip = 'Specifies the value of the POSStoresDimensionLabel field';
                            }
                        }
                        group(POSUnitsDataMissing)
                        {
                            Caption = '';
                            Visible = not POSUnitsDataToCreate;

                            label(POSUnitsLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- POS Units';
                                ToolTip = 'Specifies the value of the POSUnitsLabel field';
                            }
                        }
                        group(POSUnitsDimensionsDataMissing)
                        {
                            Caption = '';
                            Visible = not POSUnitsDimemensionsToCreate;

                            label(POSUnitsDimensionLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- POS Units Dimensions';
                                ToolTip = 'Specifies the value of the POSUnitsLabel field';
                            }
                        }
                        group(REtailLogoDataMissing)
                        {
                            Caption = '';
                            Visible = not RetailLogoDataToCreate;

                            label(RetailLogoLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Retail Logos';
                                ToolTip = 'Specifies the value of the RetailLogoLabel field';
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
                        group(POSStoresDataExists)
                        {
                            Caption = '';
                            Visible = POSStoresDataToCreate;
                            label(POSStoresLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- POS Stores';
                                ToolTip = 'Specifies the value of the POSStoresLabel field';
                            }
                        }
                        group(POSStoresDimensionDataExists)
                        {
                            Caption = '';
                            Visible = POSStoreDimensionsToCreate;
                            label(POSStoresLabel2)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- POS Stores Dimensions';
                                ToolTip = 'Specifies the value of the POSStoresDimensionLabel field';
                            }
                        }
                        group(POSUnitsDataExists)
                        {
                            Caption = '';
                            Visible = POSUnitsDataToCreate;
                            label(POSUnitsLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- POS Units';
                                ToolTip = 'Specifies the value of the POSUnitsLabel field';
                            }
                        }
                        group(POSUnitsDimensionsDataExists)
                        {
                            Caption = '';
                            Visible = POSUnitsDimemensionsToCreate;
                            label(POSUnitsLabel2)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- POS Units Dimensions';
                                ToolTip = 'Specifies the value of the POSUnitsLabel2 field';
                            }
                        }
                        group(RetailLogoDataExists)
                        {
                            Caption = '';
                            Visible = RetailLogoDataToCreate;
                            label(RetailLogoLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Retail Logos';
                                ToolTip = 'Specifies the value of the RetailLogoLabel field';
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

    trigger OnClosePage()
    begin
        if FinishActionClicked then
            exit;

        CurrPage.RetailLogoModifyPG.Page.DeleteRetailLogoData();
    end;

    var
        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStandard: Record "Media Repository";
        MediaResourcesDone: Record "Media Resources";
        MediaResourcesStandard: Record "Media Resources";
        TempPOSStore: Record "NPR POS Store" temporary;
        TempAllPOSStore: Record "NPR POS Store" temporary;
        TempPOSUnit: Record "NPR POS Unit" temporary;
        TempPOSPaymentBin: Record "NPR POS Payment Bin" temporary;
        Step: Option Start,CreatePOSStoresUnitsStep,POSStoresModifyStep,POSUnitsModifyStep,RetailLogoModifyStep,Finish;
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        IntroStepVisible: Boolean;
        CreatePOSStoresUnitsStepVisible: Boolean;
        POSStoresModifyStepVisible: Boolean;
        POSUnitsModifyStepVisible: Boolean;
        RetailLogoModifyStepVisible: Boolean;
        FinishStepVisible: Boolean;
        TopBannerVisible: Boolean;
        FinishActionClicked: Boolean;
        EmptyVar: Integer;
        AllDataFilledIn: Boolean;
        POSStoresDataToCreate: Boolean;
        POSStoreDimensionsToCreate: Boolean;
        POSUnitsDimemensionsToCreate: Boolean;
        POSUnitsDataToCreate: Boolean;
        RetailLogoDataToCreate: Boolean;
        AnyDataToCreate: Boolean;
        POSUnitDimension1Code: Code[20];
        POSUnitDimension2Code: Code[20];
        POSStoreDimension1Code: Code[20];
        POSStoreDimension2Code: Code[20];
        POSUnitsMandatoryErrorLbl: Label 'You have created POS Store(s), creation of POS Unit(s) is Mandatory!';

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowIntroStep();
            Step::CreatePOSStoresUnitsStep:
                ShowCreatePOSStoreUnitsStep();
            Step::POSStoresModifyStep:
                ShowPOSStoresModifyStep();
            Step::POSUnitsModifyStep:
                ShowPOSUnitsModifyStep();
            Step::RetailLogoModifyStep:
                ShowRetailLogoModifyStep();
            Step::Finish:
                ShowFinishStep();
        end;
    end;

    local procedure NextStep(Backwards: Boolean)
    begin
        if (Step = Step::CreatePOSStoresUnitsStep) and (not Backwards) then
            if (CurrPage.POSStoresAndUnitsPG.Page.POSStoresToCreate()) and
               (not CurrPage.POSStoresAndUnitsPG.Page.POSUnitsToCreate()) then
                Error(POSUnitsMandatoryErrorLbl);

        if (Step = Step::CreatePOSStoresUnitsStep) and (not Backwards) then begin
            CurrPage.POSStoresAndUnitsPG.Page.CreateTempPOSStores();
            CurrPage.POSStoresAndUnitsPG.Page.CreateDefaultLayout();
            CurrPage.POSStoresAndUnitsPG.Page.CreateTempPOSUnits();
        end;

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

    local procedure ShowCreatePOSStoreUnitsStep()
    begin
        CreatePOSStoresUnitsStepVisible := true;
        POSStoresModifyStepVisible := false;
        POSUnitsModifyStepVisible := false;
        RetailLogoModifyStepVisible := false;
    end;

    local procedure ShowPOSStoresModifyStep()
    begin
        CreatePOSStoresUnitsStepVisible := false;
        POSStoresModifyStepVisible := true;
        POSUnitsModifyStepVisible := false;
        RetailLogoModifyStepVisible := false;
        CurrPage.POSStoresAndUnitsPG.Page.CopyTempStores(TempPOSStore);
        CurrPage.POSStoresAndUnitsPG.Page.GetPOSStoreDimensionCodes(POSStoreDimension1Code, POSStoreDimension2Code);
        CurrPage.POSStoresModifyPG.Page.CopyTemp(TempPOSStore);
    end;

    local procedure ShowPOSUnitsModifyStep()
    begin
        CreatePOSStoresUnitsStepVisible := false;
        POSStoresModifyStepVisible := false;
        RetailLogoModifyStepVisible := false;
        POSUnitsModifyStepVisible := true;
        CurrPage.POSStoresAndUnitsPG.Page.CopyTempUnits(TempPOSUnit);
        CurrPage.POSStoresAndUnitsPG.Page.CreateTempPOSPaymentBin(TempPOSPaymentBin, TempPOSUnit);
        CurrPage.POSStoresAndUnitsPG.Page.GetPOSUnitDimensionCodes(POSUnitDimension1Code, POSUnitDimension2Code);
        CurrPage.POSUnitsModifyPG.Page.CopyTempPOSPaymentBin(TempPOSPaymentBin);
        CurrPage.POSStoresModifyPG.Page.CopyAllPOSStores(TempAllPOSStore);
        CurrPage.POSUnitsModifyPG.Page.CopyAllPOSStores(TempAllPOSStore);
        CurrPage.POSUnitsModifyPG.Page.CopyTemp(TempPOSUnit);
    end;

    local procedure ShowRetailLogoModifyStep()
    begin
        CreatePOSStoresUnitsStepVisible := false;
        POSStoresModifyStepVisible := false;
        POSUnitsModifyStepVisible := false;
        RetailLogoModifyStepVisible := true;

        CurrPage.POSStoresAndUnitsPG.Page.CopyTempUnits(TempPOSUnit);
        CurrPage.RetailLogoModifyPG.Page.CreateRetailLogoBuffer(TempPOSUnit);
    end;

    local procedure ShowFinishStep()
    begin
        CheckIfDataFilledIn();
        FinishStepVisible := true;
        CreatePOSStoresUnitsStepVisible := false;
        POSStoresModifyStepVisible := false;
        NextActionEnabled := false;
        RetailLogoModifyStepVisible := false;
        FinishActionEnabled := true;
    end;

    local procedure CheckIfDataFilledIn()
    begin
        POSStoresDataToCreate := CurrPage.POSStoresAndUnitsPG.Page.POSStoresToCreate();
        POSStoreDimensionsToCreate := CurrPage.POSStoresModifyPG.Page.DimensionsToCreate();
        POSUnitsDataToCreate := CurrPage.POSStoresAndUnitsPG.Page.POSUnitsToCreate();
        POSUnitsDimemensionsToCreate := CurrPage.POSUnitsModifyPG.Page.DimensionsToCreate();
        RetailLogoDataToCreate := CurrPage.RetailLogoModifyPG.Page.RetailLogosToCreate();

        AllDataFilledIn := POSStoresDataToCreate and
                           POSUnitsDataToCreate and
                           RetailLogoDataToCreate;

        AnyDataToCreate := POSStoresDataToCreate or
                           POSUnitsDataToCreate or
                           RetailLogoDataToCreate;
    end;

    local procedure FinishAction();
    begin
        FinishActionClicked := true;
        CurrPage.POSStoresModifyPG.Page.CreatePOSStoreData();
        CurrPage.POSUnitsModifyPG.Page.CreatePOSUnitData();
        OnAfterFinishStep(AnyDataToCreate);
        CurrPage.Close();
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        IntroStepVisible := false;
        CreatePOSStoresUnitsStepVisible := false;
        POSStoresModifyStepVisible := false;
        POSUnitsModifyStepVisible := false;
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