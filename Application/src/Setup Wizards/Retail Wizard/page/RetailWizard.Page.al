page 6014651 "NPR Retail Wizard"
{
    Extensible = False;
    Caption = 'Retail Wizard';
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
                    Caption = 'Welcome to Retail Setup';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'Use this wizard to configure NP Retail.';
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

            // Company Info Step
            group(CompanyInfoStep)
            {
                Visible = CompanyInfoStepVisible;
                group(Empty)
                {
                    Caption = 'Create Company';
                    field(EmptyVar; EmptyVar)
                    {

                        Caption = ' ';
                        ToolTip = 'Specifies the value of the EmptyVar field';
                        Visible = false;
                        ApplicationArea = NPRRetail;
                    }
                }
                group(CompanyInfo)
                {
                    Caption = 'Company Info';
                    part(CompanyInformationPG; "NPR Comp. Inf. Step")
                    {

                        UpdatePropagation = Both;
                        ApplicationArea = NPRRetail;
                    }
                }
            }

            // POS Store Step
            group(POSStoreStep)
            {
                Visible = POSStoreStepVisible;
                group(POSStores)
                {
                    Caption = 'Create POS Stores';
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
                    part(POSStoreListPG; "NPR POS Store List Step")
                    {
                        ApplicationArea = NPRRetail;

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
                    Caption = 'Create POS Profiles';
                    group(AuditProfile)
                    {
                        Caption = '';
                        part(POSAuditProfiles; "NPR POS Audit Profiles Step")
                        {
                            ApplicationArea = NPRRetail;

                        }
                    }
                    group(ViewProfile)
                    {
                        Caption = '';
                        part(POSViewProfiles; "NPR POS View Profiles Step")
                        {
                            ApplicationArea = NPRRetail;

                        }
                    }
                    group(EODProfile)
                    {
                        Caption = '';
                        part(POSEndOfDayProfiles; "NPR POS EOD Profiles Step")
                        {
                            ApplicationArea = NPRRetail;

                        }
                    }
                    group(PostingProfile)
                    {
                        Caption = '';
                        part(POSPostingProfiles; "NPR POS Posting Profiles Step")
                        {
                            ApplicationArea = NPRRetail;

                        }
                    }
                    group(EANBoxProfile)
                    {
                        Caption = '';
                        part(EANBoxSetups; "NPR Ean Box Setup Step")
                        {
                            ApplicationArea = NPRRetail;

                        }
                    }
                    group(SalWorkflowSetProfile)
                    {
                        Caption = '';
                        part(POSSalesWorkflowSets; "NPR POS Sales Wfl. Sets Step")
                        {
                            ApplicationArea = NPRRetail;

                        }
                    }
                    group(GlobalPOSSalesProfile)
                    {
                        Caption = '';
                        part(GlobalPOSSalesSetups; "NPR Glob. POS Sal. Setup Step")
                        {
                            ApplicationArea = NPRRetail;

                        }
                    }
                }
            }

            // POS Unit Step
            group(POSUnitStep)
            {
                Visible = POSUnitStepVisible;
                Caption = '';
                group(POSUnits)
                {
                    Caption = 'Create POS Units';
                    part(POSUnitListPG; "NPR POS Unit List Step")
                    {
                        ApplicationArea = NPRRetail;

                    }
                }
            }

            // POS Payment Bins Step
            group(POSPaymentBinsStep)
            {
                Visible = POSPaymentBinStepVisible;
                group(PaymentBins)
                {
                    Caption = 'Create POS Payment Bins';
                    part(POSPaymentBinListPG; "NPR POS Payment Bins Step")
                    {
                        ApplicationArea = NPRRetail;

                    }
                }
            }

            // POS Payment Method Step
            group(POSPaymentMethodStep)
            {
                Visible = POSPaymentMethodStepVisible;
                group(POSPaymentMethod)
                {
                    Caption = 'Create Payment Methods';

                    part(POSPaymentMethodsPG; "NPR POS Pmt. Method List Step")
                    {
                        ApplicationArea = NPRRetail;

                    }
                }
            }

            // POS Posting Setup Step
            group(POSPostingSetupStep)
            {
                Visible = POSPostingSetupStepVisible;
                group(POSPostingSetup)
                {
                    Caption = 'Set Posting Setup';

                    part(POSPostingSetupPG; "NPR POS Posting Setup Step")
                    {
                        ApplicationArea = NPRRetail;

                    }
                }
            }

            // Salesperson
            group(SalespersonStep)
            {
                Visible = SalespersonStepVisible;
                group(Salespersons)
                {
                    Caption = 'Create Salespeople';
                    part(SalespersonListPG; "NPR Salesperson/Purchaser Step")
                    {
                        ApplicationArea = NPRRetail;

                    }
                }
            }

            // User Setup Step
            group(UserSetupStep)
            {
                Visible = UserSetupStepVisible;
                group(UserSetup)
                {
                    Caption = 'User setup';
                    part(UserSetupPG; "NPR User Setup Step")
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
                        group(CompanyInfoDataMissing)
                        {
                            Caption = '';
                            Visible = not CompanyInfoDataToCreate;
                            label(CompanyInfoLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Company Information';
                                ToolTip = 'Specifies the value of the CompanyInfoLabel field';

                            }
                        }
                        group(POSStoreDataMissing)
                        {
                            Caption = '';
                            Visible = not POSStoreDataToCreate;

                            label(POSStoreLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- POS Store';
                                ToolTip = 'Specifies the value of the POSStoreLabel field';

                            }
                        }
                        group(Profiles)
                        {
                            Caption = '';
                            Visible = POSProfileDataMissing;
                            label(ProfilesLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Profiles: ';
                                ToolTip = 'Specifies the value of the ProfilesLabel field';

                            }
                            group(POSAuditProfileDataMissing)
                            {
                                Caption = '';
                                Visible = not POSAuditProfileDataToCreate;
                                label(POSAuditProfileLabel)
                                {
                                    ApplicationArea = NPRRetail;
                                    Caption = '---- POS Audit Profile';
                                    ToolTip = 'Specifies the value of the POSAuditProfileLabel field';

                                }
                            }
                            group(POSViewProfileDataMissing)
                            {
                                Caption = '';
                                Visible = not POSViewProfileDataToCreate;
                                label(POSViewProfileLabel)
                                {
                                    ApplicationArea = NPRRetail;
                                    Caption = '---- POS View Profile';
                                    ToolTip = 'Specifies the value of the POSViewProfileLabel field';

                                }
                            }
                            group(POSEndOfDayProfileDataMissing)
                            {
                                Caption = '';
                                Visible = not POSEndOfDayProfileDataToCreate;
                                label(POSEndOfDayProfileLabel)
                                {
                                    ApplicationArea = NPRRetail;
                                    Caption = '---- POS End of Day Profile';
                                    ToolTip = 'Specifies the value of the POSEndOfDayProfileLabel field';

                                }
                            }
                            group(POSPostingProfileDataMissing)
                            {
                                Caption = '';
                                Visible = not POSPostingProfileDataToCreate;
                                label(POSPostingProfileLabel)
                                {
                                    ApplicationArea = NPRRetail;
                                    Caption = '---- POS Posting Profile';
                                    ToolTip = 'Specifies the value of the POSPostingProfileLabel field';

                                }
                            }
                            group(EanBoxSetupDataMissing)
                            {
                                Caption = '';
                                Visible = not EanBoxSetupDataToCreate;
                                label(EanBoxSalesSetupLabel)
                                {
                                    ApplicationArea = NPRRetail;
                                    Caption = '---- Ean Box Setup';
                                    ToolTip = 'Specifies the value of the EanBoxSetupLabel field';

                                }
                            }
                            group(POSSalesWorkflowSetDataMissing)
                            {
                                Caption = '';
                                Visible = not POSSalesWorkflowSetDataToCreate;
                                label(POSSalesWorkflowLabel)
                                {
                                    ApplicationArea = NPRRetail;
                                    Caption = '---- POS Sales Workflow Set';
                                    ToolTip = 'Specifies the value of the POSSalesWorkflowLabel field';

                                }
                            }
                            group(GlobalPOSSalesSetupDataMissing)
                            {
                                Caption = '';
                                Visible = not GlobalPOSSalesSetupDataToCreate;
                                label(GlobalPOSSalesSetupLabel)
                                {
                                    ApplicationArea = NPRRetail;
                                    Caption = '---- Global POS Sales Setup';
                                    ToolTip = 'Specifies the value of the GlobalPOSSalesSetupLabel field';

                                }
                            }
                        }
                        group(POSUnitDataMissing)
                        {
                            Caption = '';
                            Visible = not POSUnitDataToCreate;
                            label(POSUnitLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- POS Unit';
                                ToolTip = 'Specifies the value of the POSUnitLabel field';

                            }
                        }
                        group(POSPaymentBinDataMissing)
                        {
                            Caption = '';
                            Visible = not POSPaymentBinDataToCreate;
                            label(POSPaymentBinLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- POS Payment Bin';
                                ToolTip = 'Specifies the value of the POSPaymentBinLabel field';

                            }
                        }
                        group(POSPaymentMethodDataMissing)
                        {
                            Caption = '';
                            Visible = not POSPaymentMethodDataToCreate;
                            label(POSPaymentMethodLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- POS Payment Method';
                                ToolTip = 'Specifies the value of the POSPaymentMethodLabel field';

                            }
                        }
                        group(POSPostingSetupDataMissing)
                        {
                            Caption = '';
                            Visible = not POSPostingSetupDataToCreate;
                            label(POSPostingSetupLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- POS Posting Setup';
                                ToolTip = 'Specifies the value of the POSPostingSetupLabel field';

                            }
                        }
                        group(SalespersonDataMissing)
                        {
                            Caption = '';
                            Visible = not SalespersonDataToCreate;
                            label(SalespersonLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Salespeople';
                                ToolTip = 'Specifies the value of the SalespersonLabel field';

                            }
                        }
                        group(UserSetupDataMissing)
                        {
                            Caption = '';
                            Visible = not UserSetupDataToCreate;
                            label(UserSetupLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- User Setup';
                                ToolTip = 'Specifies the value of the UserSetupLabel field';

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
                        group(CompanyInfoDataExists)
                        {
                            Caption = '';
                            Visible = CompanyInfoDataToCreate;
                            label(CompanyInfoLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Company Information';
                                ToolTip = 'Specifies the value of the CompanyInfoLabel field';

                            }
                        }
                        group(POSStoreDataExists)
                        {
                            Caption = '';
                            Visible = POSStoreDataToCreate;
                            label(POSStoreLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- POS Store';
                                ToolTip = 'Specifies the value of the POSStoreLabel field';
                            }
                        }
                        group(Profiles1)
                        {
                            Caption = '';
                            Visible = POSProfileDataToCreate;
                            label(ProfilesLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Profiles: ';
                                ToolTip = 'Specifies the value of the ProfilesLabel field';
                            }
                            group(POSAuditProfileDataExists)
                            {
                                Caption = '';
                                Visible = POSAuditProfileDataToCreate;
                                label(POSAuditProfileLabel1)
                                {
                                    ApplicationArea = NPRRetail;
                                    Caption = '---- POS Audit Profile';
                                    ToolTip = 'Specifies the value of the POSAuditProfileLabel field';
                                }
                            }
                            group(POSViewProfileDataExists)
                            {
                                Caption = '';
                                Visible = POSViewProfileDataToCreate;
                                label(POSViewProfileLabel1)
                                {
                                    ApplicationArea = NPRRetail;
                                    Caption = '---- POS View Profile';
                                    ToolTip = 'Specifies the value of the POSViewProfileLabel field';
                                }
                            }
                            group(POSEndOfDayProfileExists)
                            {
                                Caption = '';
                                Visible = POSEndOfDayProfileDataToCreate;
                                label(POSEndOfDayProfileLabel1)
                                {
                                    ApplicationArea = NPRRetail;
                                    Caption = '---- POS End of Day Profile';
                                    ToolTip = 'Specifies the value of the POSEndOfDayProfileLabel field';
                                }
                            }
                            group(POSPostingProfileDataExists)
                            {
                                Caption = '';
                                Visible = POSPostingProfileDataToCreate;
                                label(POSPostingProfileLabel1)
                                {
                                    ApplicationArea = NPRRetail;
                                    Caption = '---- POS Posting Profile';
                                    ToolTip = 'Specifies the value of the POSPostingProfileLabel field';
                                }
                            }
                            group(EanBoxSetupDataExists)
                            {
                                Caption = '';
                                Visible = EanBoxSetupDataToCreate;
                                label(EanBoxSalesSetupLabel1)
                                {
                                    ApplicationArea = NPRRetail;
                                    Caption = '---- Ean Box Setup';
                                    ToolTip = 'Specifies the value of the EanBoxSetupLabel field';
                                }
                            }
                            group(POSSalesWorkflowSetDataExisting)
                            {
                                Caption = '';
                                Visible = POSSalesWorkflowSetDataToCreate;
                                label(POSSalesWorkflowLabel1)
                                {
                                    ApplicationArea = NPRRetail;
                                    Caption = '---- POS Sales Workflow Set';
                                    ToolTip = 'Specifies the value of the POSSalesWorkflowLabel field';
                                }
                            }
                            group(GlobalPOSSalesSetupDataExists)
                            {
                                Caption = '';
                                Visible = GlobalPOSSalesSetupDataToCreate;
                                label(GlobalPOSSalesSetupLabel1)
                                {
                                    ApplicationArea = NPRRetail;
                                    Caption = '---- Global POS Sales Setup';
                                    ToolTip = 'Specifies the value of the GlobalPOSSalesSetupLabel field';
                                }
                            }
                        }
                        group(POSUnitDataExists)
                        {
                            Caption = '';
                            Visible = POSUnitDataToCreate;
                            label(POSUnitLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- POS Unit';
                                ToolTip = 'Specifies the value of the POSUnitLabel field';
                            }
                        }
                        group(POSPaymentBinDataExists)
                        {
                            Caption = '';
                            Visible = POSPaymentBinDataToCreate;
                            label(POSPaymentBinLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- POS Payment Bin';
                                ToolTip = 'Specifies the value of the POSPaymentBinLabel field';
                            }
                        }
                        group(POSPaymentMethodDataExists)
                        {
                            Caption = '';
                            Visible = POSPaymentMethodDataToCreate;
                            label(POSPaymentMethodLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- POS Payment Method';
                                ToolTip = 'Specifies the value of the POSPaymentMethodLabel field';
                            }
                        }
                        group(POSPostingSetupDataExists)
                        {
                            Caption = '';
                            Visible = POSPostingSetupDataToCreate;
                            label(POSPostingSetupLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- POS Posting Setup';
                                ToolTip = 'Specifies the value of the POSPostingSetupLabel field';
                            }
                        }
                        group(SalespersonDataExists)
                        {
                            Caption = '';
                            Visible = SalespersonDataToCreate;
                            label(SalespersonLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Salespeople';
                                ToolTip = 'Specifies the value of the SalespersonLabel field';
                            }
                        }
                        group(UserSetupDataExists)
                        {
                            Caption = '';
                            Visible = UserSetupDataToCreate;
                            label(UserSetupLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- User Setup';
                                ToolTip = 'Specifies the value of the UserSetupLabel field';
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
        SalespersonBuffer.DeleteAll();
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
        SalespersonBuffer: Record "NPR Salesperson Buffer";
        TempPOSStore: Record "NPR POS Store" temporary;
        TempAllPOSStore: Record "NPR POS Store" temporary;
        TempPOSAuditProfile: Record "NPR POS Audit Profile" temporary;
        TempAllPOSAuditProfile: Record "NPR POS Audit Profile" temporary;
        TempPOSViewProfile: Record "NPR POS View Profile" temporary;
        TempAllPOSViewProfile: Record "NPR POS View Profile" temporary;
        TempPOSEndOfDayProfile: Record "NPR POS End of Day Profile" temporary;
        TempAllPOSEndOfDayProfile: Record "NPR POS End of Day Profile" temporary;
        TempPOSPostingProfile: Record "NPR POS Posting Profile" temporary;
        TempAllPOSPostingProfile: Record "NPR POS Posting Profile" temporary;
        TempEanBoxSetup: Record "NPR Ean Box Setup" temporary;
        TempAllEanBoxSetup: Record "NPR Ean Box Setup" temporary;
        TempPOSSalesWorkflowSet: Record "NPR POS Sales Workflow Set" temporary;
        TempAllPOSSalesWorkflowSet: Record "NPR POS Sales Workflow Set" temporary;
        TempGlobalPOSSalesSetup: Record "NPR NpGp POS Sales Setup" temporary;
        TempAllGlobalPOSSalesSetup: Record "NPR NpGp POS Sales Setup" temporary;
        TempPOSUnitToCreate: Record "NPR POS Unit" temporary;
        TempAllPOSUnit: Record "NPR POS Unit" temporary;
        TempPOSPaymentBinToCreate: Record "NPR POS Payment Bin" temporary;
        TempAllPOSPaymentBin: Record "NPR POS Payment Bin" temporary;
        TempAllPOSPaymentMethod: Record "NPR POS Payment Method" temporary;
        TempAllSalesperson: Record "NPR Salesperson Buffer" temporary;
        TempAllUser: Record User temporary;
        Step: Option Start,CompanyInfoStep,POSStoresStep,POSProfilesStep,POSUnitStep,POSPaymentBinStep,POSPaymentMethodStep,POSPostingSetupStep,SalespersonStep,UserSetupStep,Finish;
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        IntroStepVisible: Boolean;
        CompanyInfoStepVisible: Boolean;
        POSStoreStepVisible: Boolean;
        POSProfilesStepVisible: Boolean;
        POSUnitStepVisible: Boolean;
        POSPaymentBinStepVisible: Boolean;
        POSPaymentMethodStepVisible: Boolean;
        POSPostingSetupStepVisible: Boolean;
        SalespersonStepVisible: Boolean;
        UserSetupStepVisible: Boolean;
        FinishStepVisible: Boolean;
        TopBannerVisible: Boolean;
        EmptyVar: Integer;
        AllDataFilledIn: Boolean;
        CompanyInfoDataToCreate: Boolean;
        POSStoreDataToCreate: Boolean;
        POSProfileDataToCreate: Boolean;
        POSProfileDataMissing: Boolean;
        POSAuditProfileDataToCreate: Boolean;
        POSViewProfileDataToCreate: Boolean;
        POSEndOfDayProfileDataToCreate: Boolean;
        POSPostingProfileDataToCreate: Boolean;
        EanBoxSetupDataToCreate: Boolean;
        POSSalesWorkflowSetDataToCreate: Boolean;
        GlobalPOSSalesSetupDataToCreate: Boolean;
        POSUnitDataToCreate: Boolean;
        POSPaymentBinDataToCreate: Boolean;
        POSPaymentMethodDataToCreate: Boolean;
        POSPostingSetupDataToCreate: Boolean;
        SalespersonDataToCreate: Boolean;
        UserSetupDataToCreate: Boolean;
        AnyDataToCreate: Boolean;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowIntroStep();
            Step::CompanyInfoStep:
                ShowCompanyInfoStep();
            Step::POSStoresStep:
                ShowPOSStoreStep();
            Step::POSProfilesStep:
                ShowPOSProfilesStep();
            Step::POSUnitStep:
                ShowPOSUnitStep();
            Step::POSPaymentBinStep:
                ShowPOSPaymentBinStep();
            Step::POSPaymentMethodStep:
                ShowPOSPaymentMethodStep();
            Step::POSPostingSetupStep:
                ShowPOSPostingSetupStep();
            Step::SalespersonStep:
                ShowSalespersonStep();
            Step::UserSetupStep:
                ShowUserSetupStep();
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

    local procedure ShowCompanyInfoStep()
    begin
        CompanyInfoStepVisible := true;
    end;

    local procedure ShowPOSStoreStep()
    begin
        POSStoreStepVisible := true;
    end;

    local procedure ShowPOSProfilesStep()
    begin
        POSProfilesStepVisible := true;

        CurrPage.POSUnitListPG.Page.CopyRealAndTemp(TempAllPOSUnit);
        CurrPage.POSEndOfDayProfiles.Page.SetGlobals(TempAllPOSUnit);
    end;

    local procedure ShowPOSUnitStep()
    begin
        POSUnitStepVisible := true;

        CurrPage.POSStoreListPG.Page.GetRec(TempPOSStore);
        CurrPage.POSStoreListPG.Page.CopyRealAndTemp(TempAllPOSStore);

        CurrPage.POSAuditProfiles.Page.GetRec(TempPOSAuditProfile);
        CurrPage.POSAuditProfiles.Page.CopyRealAndTemp(TempAllPOSAuditProfile);
        CurrPage.POSViewProfiles.Page.GetRec(TempPOSViewProfile);
        CurrPage.POSViewProfiles.Page.CopyRealAndTemp(TempAllPOSViewProfile);
        CurrPage.POSEndOfDayProfiles.Page.GetRec(TempPOSEndOfDayProfile);
        CurrPage.POSEndOfDayProfiles.Page.CopyRealAndTemp(TempAllPOSEndOfDayProfile);
        CurrPage.POSPostingProfiles.Page.GetRec(TempPOSPostingProfile);
        CurrPage.POSPostingProfiles.Page.CopyRealAndTemp(TempAllPOSPostingProfile);
        CurrPage.EANBoxSetups.Page.GetRec(TempEanBoxSetup);
        CurrPage.EANBoxSetups.Page.CopyRealAndTemp(TempAllEanBoxSetup);
        CurrPage.POSSalesWorkflowSets.Page.GetRec(TempPOSSalesWorkflowSet);
        CurrPage.POSSalesWorkflowSets.Page.CopyRealAndTemp(TempAllPOSSalesWorkflowSet);
        CurrPage.GlobalPOSSalesSetups.Page.GetRec(TempGlobalPOSSalesSetup);
        CurrPage.GlobalPOSSalesSetups.Page.CopyRealAndTemp(TempAllGlobalPOSSalesSetup);

        CurrPage.POSUnitListPG.Page.SetGlobals(TempAllPOSStore,
                                               TempAllPOSAuditProfile,
                                               TempAllPOSViewProfile,
                                               TempAllPOSEndOfDayProfile,
                                               TempAllPOSPostingProfile,
                                               TempAllEanBoxSetup,
                                               TempAllPOSSalesWorkflowSet,
                                               TempAllGlobalPOSSalesSetup);
    end;

    local procedure ShowPOSPaymentBinStep()
    begin
        POSPaymentBinStepVisible := true;

        CurrPage.POSUnitListPG.Page.GetRec(TempPOSUnitToCreate);
        CurrPage.POSUnitListPG.Page.CopyRealAndTemp(TempAllPOSUnit);
        CurrPage.POSPaymentBinListPG.Page.SetGlobals(TempAllPOSUnit);
    end;

    local procedure ShowPOSPaymentMethodStep()
    begin
        POSPaymentMethodStepVisible := true;

        CurrPage.POSPaymentBinListPG.Page.GetRec(TempPOSPaymentBinToCreate);
    end;

    local procedure ShowPOSPostingSetupStep()
    begin
        POSPostingSetupStepVisible := true;

        CurrPage.POSStoreListPG.Page.CopyRealAndTemp(TempAllPOSStore);
        CurrPage.POSPaymentBinListPG.Page.CopyRealAndTemp(TempAllPOSPaymentBin);
        CurrPage.POSPaymentMethodsPG.Page.CopyRealAndTemp(TempAllPOSPaymentMethod);
        CurrPage.POSPostingSetupPG.Page.SetGlobals(TempAllPOSStore, TempAllPOSPaymentMethod, TempAllPOSPaymentBin);
    end;

    local procedure ShowSalespersonStep()
    begin
        SalespersonStepVisible := true;
    end;

    local procedure ShowUserSetupStep()
    begin
        UserSetupStepVisible := true;

        CurrPage.UserSetupPG.Page.CopyRealAndTempUsers(TempAllUser);
        CurrPage.SalespersonListPG.Page.CopyRealAndTemp(TempAllSalesperson);
        CurrPage.POSUnitListPG.Page.CopyRealAndTemp(TempAllPOSUnit);
        CurrPage.UserSetupPG.Page.SetGlobals(TempAllSalesperson, TempAllUser, TempAllPOSUnit);
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
        CompanyInfoDataToCreate := CurrPage.CompanyInformationPG.Page.MandatoryDataFilledIn();
        POSStoreDataToCreate := CurrPage.POSStoreListPG.Page.POSStoresToCreate();

        POSAuditProfileDataToCreate := CurrPage.POSAuditProfiles.Page.POSAuditProfileDataToCreate();
        POSViewProfileDataToCreate := CurrPage.POSViewProfiles.Page.POSViewProfileDataToCreate();
        POSEndOfDayProfileDataToCreate := CurrPage.POSEndOfDayProfiles.Page.POSEndOfDayProfileDataToCreate();
        POSPostingProfileDataToCreate := CurrPage.POSPostingProfiles.Page.POSPOSPostingProfileDataToCreate();
        EanBoxSetupDataToCreate := CurrPage.EANBoxSetups.Page.EanBoxSetupDataToCreate();
        POSSalesWorkflowSetDataToCreate := CurrPage.POSSalesWorkflowSets.Page.POSSalesWorkflowSetDataToCreate();
        GlobalPOSSalesSetupDataToCreate := CurrPage.GlobalPOSSalesSetups.Page.GlobalPOSSalesSetupDataToCreate();

        POSProfileDataToCreate := POSAuditProfileDataToCreate or
                                  POSViewProfileDataToCreate or
                                  POSEndOfDayProfileDataToCreate or
                                  POSPostingProfileDataToCreate or
                                  EanBoxSetupDataToCreate or
                                  POSSalesWorkflowSetDataToCreate or
                                  GlobalPOSSalesSetupDataToCreate;

        POSProfileDataMissing := not POSAuditProfileDataToCreate or
                                 not POSViewProfileDataToCreate or
                                 not POSEndOfDayProfileDataToCreate or
                                 not POSPostingProfileDataToCreate or
                                 not EanBoxSetupDataToCreate or
                                 not POSSalesWorkflowSetDataToCreate or
                                 not GlobalPOSSalesSetupDataToCreate;

        POSUnitDataToCreate := CurrPage.POSUnitListPG.Page.POSUnitsToCreate();
        POSPaymentBinDataToCreate := CurrPage.POSPaymentBinListPG.Page.POSPaymentBinsToCreate();
        POSPaymentMethodDataToCreate := CurrPage.POSPaymentMethodsPG.Page.POSPaymentMethodsToCreate();
        POSPostingSetupDataToCreate := CurrPage.POSPostingSetupPG.Page.POSPostingSetupToCreate();
        SalespersonDataToCreate := CurrPage.SalespersonListPG.Page.SalespersonsToCreate();
        UserSetupDataToCreate := CurrPage.UserSetupPG.Page.UserSetupsToCreate();

        AllDataFilledIn := CompanyInfoDataToCreate and
                           POSStoreDataToCreate and
                           POSAuditProfileDataToCreate and
                           POSViewProfileDataToCreate and
                           POSEndOfDayProfileDataToCreate and
                           POSPostingProfileDataToCreate and
                           EanBoxSetupDataToCreate and
                           POSSalesWorkflowSetDataToCreate and
                           GlobalPOSSalesSetupDataToCreate and
                           POSUnitDataToCreate and
                           POSPaymentBinDataToCreate and
                           POSPaymentMethodDataToCreate and
                           POSPostingSetupDataToCreate and
                           SalespersonDataToCreate and
                           UserSetupDataToCreate;

        AnyDataToCreate := CompanyInfoDataToCreate or
                           POSStoreDataToCreate or
                           POSAuditProfileDataToCreate or
                           POSViewProfileDataToCreate or
                           POSEndOfDayProfileDataToCreate or
                           POSPostingProfileDataToCreate or
                           EanBoxSetupDataToCreate or
                           POSSalesWorkflowSetDataToCreate or
                           GlobalPOSSalesSetupDataToCreate or
                           POSUnitDataToCreate or
                           POSPaymentBinDataToCreate or
                           POSPaymentMethodDataToCreate or
                           POSPostingSetupDataToCreate or
                           SalespersonDataToCreate or
                           UserSetupDataToCreate;
    end;

    local procedure FinishAction();
    begin
        CurrPage.CompanyInformationPG.Page.CreateCompanyInfoData();
        CurrPage.POSStoreListPG.Page.CreatePOSStoreData();

        CurrPage.POSAuditProfiles.Page.CreatePOSAuditProfileData();
        CurrPage.POSViewProfiles.Page.CreatePOSViewProfileData();
        CurrPage.POSEndOfDayProfiles.Page.CreatePOSEndOfDayProfileData();
        CurrPage.POSPostingProfiles.Page.CreatePOSPOSPostingProfileData();
        CurrPage.EANBoxSetups.Page.CreateEanBoxSetupData();
        CurrPage.POSSalesWorkflowSets.Page.CreatePOSSalesWorkflowSetData();
        CurrPage.GlobalPOSSalesSetups.Page.CreateNpGlobalPOSSalesSetupData();

        CurrPage.POSUnitListPG.Page.CreatePOSUnitData(TempPOSUnitToCreate);
        CurrPage.POSPaymentBinListPG.Page.CreatePOSPaymentBinData(TempPOSPaymentBinToCreate);
        CurrPage.POSPaymentMethodsPG.Page.CreatePOSPaymentMethodData();
        CurrPage.POSPostingSetupPG.Page.CreatePOSPostingSetupData();
        CurrPage.SalespersonListPG.Page.CreateSalespersonData();
        CurrPage.UserSetupPG.Page.CreateUserSetupData();

        SalespersonBuffer.DeleteAll();

        OnAfterFinishStep(AnyDataToCreate);

        CurrPage.Close();
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        IntroStepVisible := false;
        CompanyInfoStepVisible := false;
        POSStoreStepVisible := false;
        POSProfilesStepVisible := false;
        POSUnitStepVisible := false;
        POSPaymentBinStepVisible := false;
        POSPaymentMethodStepVisible := false;
        POSPostingSetupStepVisible := false;
        SalespersonStepVisible := false;
        UserSetupStepVisible := false;
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
