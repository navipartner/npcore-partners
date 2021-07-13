page 6014400 "NPR Magento Wizard"
{
    Caption = 'NP Magento Wizard';
    PageType = NavigatePage;
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
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

            group(Step1)
            {
                Visible = StartStepVisible;
                group("Welcome to Magento")
                {
                    Caption = 'Welcome to Magento Setup';
                    Visible = StartStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'Use this Wizard to configure Magento settings.';
                    }
                }
                group("Let's go!")
                {
                    Caption = 'Let''s go!';
                    group(Group22)
                    {
                        Caption = '';
                        InstructionalText = 'Click Next to start the process.';
                    }
                }
            }

            // Magento Website Step
            group(MagentoWebsiteStep)
            {
                Visible = MagentoWebsiteStepVisible;
                group(MagentoWebsite)
                {
                    Caption = 'Magento Website';
                    part(MagentoWebsites; "NPR Website List WP")
                    {
                        ApplicationArea = NPRRetail;

                    }
                }
            }

            // Magento Store Step
            group(MagentoStoreStep)
            {
                Visible = MagentoStoreStepVisible;
                group(MagentoStore)
                {
                    Caption = 'Magento Store';
                    part(MagentoStores; "NPR Stores WP")
                    {
                        ApplicationArea = NPRRetail;

                    }
                }
            }

            // Magento Customer Mapping Step
            group(MagentoCustomerMappingStep)
            {
                Visible = MagentoCustomerMappingStepVisible;
                group(MagentoCustomerMapping)
                {
                    Caption = 'Magento Customer Mapping';
                    part(MagentCustMappings; "NPR Customer Mapping WP")
                    {
                        ApplicationArea = NPRRetail;

                    }
                }
            }

            // Magento Payment Gateway Step
            group(MagentoPaymentGatewayStep)
            {
                Visible = MagentoPaymentGatewayStepVisible;
                group(MagentoPaymentGateway)
                {
                    Caption = 'Magento Payment Gateway';
                    part(MagentoPaymentGateways; "NPR Payment Gateways WP")
                    {
                        ApplicationArea = NPRRetail;

                    }
                }
            }

            // Magento Payment Mapping Step
            group(MagentoPaymentMappingStep)
            {
                Visible = MagentoPaymentMappingStepVisible;
                group(MagentoPaymentMapping)
                {
                    Caption = 'Magento Payment Mapping';
                    part(MagentoPaymentMappings; "NPR Payment Mapping WP")
                    {
                        ApplicationArea = NPRRetail;

                    }
                }
            }

            // Magento Shippment Mapping Step
            group(MagentoShippmentMappingStep)
            {
                Visible = MagentoShippmentMappingStepVisible;
                group(MagentoShippmentMapping)
                {
                    Caption = 'Magento Shippment Mapping';
                    part(MagentoShippingMappings; "NPR Shipment Mapping WP")
                    {
                        ApplicationArea = NPRRetail;

                    }
                }
            }

            // Magento Brand Step
            group(MagentoBrandStep)
            {
                Visible = MagentoBrandStepVisible;
                group(MagentoBrand)
                {
                    Caption = 'Magento Brand';
                    part(MagentoBrands; "NPR Brands WP")
                    {
                        ApplicationArea = NPRRetail;

                    }
                }
            }

            // Magento Display Group Step
            group(MagentoDisplayGroupStep)
            {
                Visible = MagentoDisplayGroupStepVisible;
                group(MagentoDisplayGroup)
                {
                    Caption = 'Magento Display Group';
                    part(MagentoDisplayGroups; "NPR Display Groups WP")
                    {
                        ApplicationArea = NPRRetail;

                    }
                }
            }

            // Magento Display Config Step
            group(MagentoDisplayConfigStep)
            {
                Visible = MagentoDisplayConfigStepVisible;
                group(MagentoDisplayConfig)
                {
                    Caption = 'Magento Display Config';
                    part(MagentoDisplayConfigs; "NPR Display Config WP")
                    {
                        ApplicationArea = NPRRetail;

                    }
                }
            }

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
                        group(MagentoStoreMissing)
                        {
                            Caption = '';
                            Visible = not MagentoStoreDataFilledIn;
                            label(MagentoStoreLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Magento Store';
                                ToolTip = 'Specifies the value of the MagentoStoreLabel field';
                            }
                        }
                        group(MagentoWebsiteMissing)
                        {
                            Caption = '';
                            Visible = not MagentoWebsiteDataFilledIn;
                            label(MagentoWebsiteLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Magento Website';
                                ToolTip = 'Specifies the value of the MagentoWebsiteLabel field';
                            }
                        }
                        group(MagentoCustomerMappingMissing)
                        {
                            Caption = '';
                            Visible = not MagentoCustomerMappingDataFilledIn;
                            label(MagentoCustomerMappingLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Magento Customer Mapping';
                                ToolTip = 'Specifies the value of the MagentoCustomerMappingLabel field';
                            }
                        }
                        group(MagentoPaymentGatewaygMissing)
                        {
                            Caption = '';
                            Visible = not MagentoPaymentGatewayDataFilledIn;
                            label(MagentoPaymentGatewayLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Magento Payment Gateway';
                                ToolTip = 'Specifies the value of the MagentoPaymentGatewayLabel field';
                            }
                        }
                        group(MagentoPaymentMappingMissing)
                        {
                            Caption = '';
                            Visible = not MagentoPaymentMappingDataFilledIn;
                            label(MagentoPaymentMappingLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Magento Payment Mapping';
                                ToolTip = 'Specifies the value of the MagentoPaymentMappingLabel field';
                            }
                        }
                        group(MagentoShippmentMappingMissing)
                        {
                            Caption = '';
                            Visible = not MagentoShippmentMappingDataFilledIn;
                            label(MagentoShippmentMappingLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Magento Shippment Mapping';
                                ToolTip = 'Specifies the value of the MagentoShippmentMappingLabel field';
                            }
                        }
                        group(MagentoBrandMissing)
                        {
                            Caption = '';
                            Visible = not MagentoBrandDataFilledIn;
                            label(MagentoBrandsLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Magento Brand';
                                ToolTip = 'Specifies the value of the MagentoBrandLabel field';
                            }
                        }
                        group(MagentoDisplayGroupMissing)
                        {
                            Caption = '';
                            Visible = not MagentoDisplayGroupDataFilledIn;
                            label(MagentoDisplayGroupLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Magento Display Group';
                                ToolTip = 'Specifies the value of the MagentoDisplayGroupLabel field';
                            }
                        }
                        group(MagentoDisplayConfigMissing)
                        {
                            Caption = '';
                            Visible = not MagentoDisplayConfigDataFilledIn;
                            label(MagentoDisplayConfigLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Magento Display Config';
                                ToolTip = 'Specifies the value of the MagentoDisplayConfigLabel field';
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
                        group(MagentoStoreExists)
                        {
                            Caption = '';
                            Visible = MagentoStoreDataFilledIn;
                            label(MagentoStoreLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Magento Store';
                                ToolTip = 'Specifies the value of the MagentoStoreLabel field';
                            }
                        }
                        group(MagentoWebsiteExists)
                        {
                            Caption = '';
                            Visible = MagentoWebsiteDataFilledIn;
                            label(MagentoWebsiteLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Magento Website';
                                ToolTip = 'Specifies the value of the MagentoWebsiteLabel field';
                            }
                        }
                        group(MagentoCustomerMappingExists)
                        {
                            Caption = '';
                            Visible = MagentoCustomerMappingDataFilledIn;
                            label(MagentoCustomerMappingLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Magento Customer Mapping';
                                ToolTip = 'Specifies the value of the MagentoCustomerMappingLabel field';
                            }
                        }
                        group(MagentoPaymentGatewaygExists)
                        {
                            Caption = '';
                            Visible = MagentoPaymentGatewayDataFilledIn;
                            label(MagentoPaymentGatewayLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Magento Payment Gateway';
                                ToolTip = 'Specifies the value of the MagentoPaymentGatewayLabel field';
                            }
                        }
                        group(MagentoPaymentMappingExists)
                        {
                            Caption = '';
                            Visible = MagentoPaymentMappingDataFilledIn;
                            label(MagentoPaymentMappingLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Magento Payment Mapping';
                                ToolTip = 'Specifies the value of the MagentoPaymentMappingLabel field';
                            }
                        }
                        group(MagentoShippmentMappingExists)
                        {
                            Caption = '';
                            Visible = MagentoShippmentMappingDataFilledIn;
                            label(MagentoShippmentMappingLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Magento Shippment Mapping';
                                ToolTip = 'Specifies the value of the MagentoShippmentMappingLabel field';
                            }
                        }
                        group(MagentoBrandsExists)
                        {
                            Caption = '';
                            Visible = MagentoBrandDataFilledIn;
                            label(MagentoBrandsLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Magento Brand';
                                ToolTip = 'Specifies the value of the MagentoBrandLabel field';
                            }
                        }
                        group(MagentoDisplayGroupExists)
                        {
                            Caption = '';
                            Visible = MagentoDisplayGroupDataFilledIn;
                            label(MagentoDisplayGroupLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Magento Display Group';
                                ToolTip = 'Specifies the value of the MagentoDisplayGroupLabel field';
                            }
                        }
                        group(MagentoDisplayConfigExists)
                        {
                            Caption = '';
                            Visible = MagentoDisplayConfigDataFilledIn;
                            label(MagentoDisplayConfigLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Magento Display Config';
                                ToolTip = 'Specifies the value of the MagentoDisplayConfigLabel field';
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
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage();
    begin
        Step := Step::StartStep;
        EnableControls();
    end;

    var
        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStandard: Record "Media Repository";
        MediaResourcesDone: Record "Media Resources";
        MediaResourcesStandard: Record "Media Resources";
        TempMagentoWebsiteGlobal: Record "NPR Magento Website" temporary;
        TempMagentPaymentGatewayGlobal: Record "NPR Magento Payment Gateway" temporary;
        TempMagentoBrand: Record "NPR Magento Brand" temporary;
        TempMagDisplayGroup: Record "NPR Magento Display Group" temporary;
        Step: Option StartStep,MagentoWebsiteStep,MagentoStoreStep,MagentoCustomerMappingStep,MagentoPaymentGatewayStep,MagentoPaymentMappingStep,MagentoShippmentMappingStep,MagentoBrandStep,MagentoDisplayGroupStep,MagentoDisplayConfigStep,FinishStep;
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        StartStepVisible: Boolean;
        FinishStepVisible: Boolean;
        TopBannerVisible: Boolean;
        MagentoStoreStepVisible: Boolean;
        MagentoWebsiteStepVisible: Boolean;
        MagentoCustomerMappingStepVisible: Boolean;
        MagentoPaymentGatewayStepVisible: Boolean;
        MagentoPaymentMappingStepVisible: Boolean;
        MagentoShippmentMappingStepVisible: Boolean;
        MagentoBrandStepVisible: Boolean;
        MagentoDisplayGroupStepVisible: Boolean;
        MagentoDisplayConfigstepVisible: Boolean;
        MagentoStoreDataFilledIn: Boolean;
        MagentoWebsiteDataFilledIn: Boolean;
        MagentoCustomerMappingDataFilledIn: Boolean;
        MagentoPaymentGatewayDataFilledIn: Boolean;
        MagentoPaymentMappingDataFilledIn: Boolean;
        MagentoShippmentMappingDataFilledIn: Boolean;
        MagentoBrandDataFilledIn: Boolean;
        MagentoDisplayGroupDataFilledIn: Boolean;
        MagentoDisplayConfigDataFilledIn: Boolean;
        AllDataFilledIn: Boolean;
        AnyDataToCreate: Boolean;

    local procedure EnableControls();
    begin
        ResetControls();

        // STEPS
        // 1. Magento Website
        // 2. Magento Store
        // 3. Magento Customer Mapping
        // 4. Magento Payment Gateway
        // 5. Magento Payment Mapping
        // 6. Magento Shippment Mapping
        // 7. Magento Brand
        // 8. Magento Display Group
        // 9. Magento Display Config

        case Step of
            Step::StartStep:
                ShowStartStep();
            Step::MagentoWebsiteStep:
                ShowMagentoWebsiteStep();
            Step::MagentoStoreStep:
                ShowMagentoStoreStep();
            Step::MagentoCustomerMappingStep:
                ShowMagentoCustomerMappingStep();
            Step::MagentoPaymentGatewayStep:
                ShowMagentoPaymentGatewayStep();
            Step::MagentoPaymentMappingStep:
                ShowMagentoPaymentMappingStep();
            Step::MagentoShippmentMappingStep:
                ShowMagentoShippmentMappingStep();
            Step::MagentoBrandStep:
                ShowMagentoBrandStep();
            Step::MagentoDisplayGroupStep:
                ShowMagentoDisplayGroupStep();
            Step::MagentoDisplayConfigStep:
                ShowMagentoDisplayConfigstep();
            Step::FinishStep:
                ShowFinishStep();
        end;
    end;

    local procedure NextStep(Backwards: Boolean);
    begin
        if Backwards then
            Step := Step - 1
        ELSE
            Step := Step + 1;

        EnableControls();
    end;

    local procedure ResetControls();
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        StartStepVisible := false;
        MagentoStoreStepVisible := false;
        MagentoWebsiteStepVisible := false;
        MagentoCustomerMappingStepVisible := false;
        MagentoPaymentGatewayStepVisible := false;
        MagentoPaymentMappingStepVisible := false;
        MagentoShippmentMappingStepVisible := false;
        MagentoBrandStepVisible := false;
        MagentoDisplayGroupStepVisible := false;
        MagentoDisplayConfigstepVisible := false;

        FinishStepVisible := false;
    end;

    procedure ShowStartStep();
    begin
        StartStepVisible := true;

        FinishActionEnabled := false;
        BackActionEnabled := false;
    end;

    procedure ShowMagentoWebsiteStep();
    begin
        MagentoWebsiteStepVisible := true;
    end;

    procedure ShowMagentoStoreStep();
    begin
        MagentoStoreStepVisible := true;

        CurrPage.MagentoWebsites.Page.CopyRealAndTemp(TempMagentoWebsiteGlobal);
        CurrPage.MagentoStores.Page.SetGlobals(TempMagentoWebsiteGlobal);
    end;

    procedure ShowMagentoCustomerMappingStep();
    begin
        MagentoCustomerMappingStepVisible := true;
    end;

    procedure ShowMagentoPaymentGatewayStep();
    begin
        MagentoPaymentGatewayStepVisible := true;
    end;

    procedure ShowMagentoPaymentMappingStep();
    begin
        MagentoPaymentMappingStepVisible := true;

        CurrPage.MagentoPaymentGateways.Page.CopyRealAndTemp(TempMagentPaymentGatewayGlobal);
        CurrPage.MagentoPaymentMappings.Page.SetGlobals(TempMagentPaymentGatewayGlobal);
    end;

    procedure ShowMagentoShippmentMappingStep();
    begin
        MagentoShippmentMappingStepVisible := true;
    end;

    procedure ShowMagentoBrandStep();
    begin
        MagentoBrandStepVisible := true;
    end;

    procedure ShowMagentoDisplayGroupStep();
    begin
        MagentoDisplayGroupStepVisible := true;

        CurrPage.MagentoBrands.Page.CopyRealAndTemp(TempMagentoBrand);
    end;

    procedure ShowMagentoDisplayConfigstep();
    begin
        MagentoDisplayConfigstepVisible := true;

        CurrPage.MagentoDisplayGroups.Page.CopyRealAndTemp(TempMagDisplayGroup);

        CurrPage.MagentoDisplayConfigs.Page.SetGlobals(TempMagentoBrand, TempMagDisplayGroup, 0);
        CurrPage.MagentoDisplayConfigs.Page.SetGlobals(TempMagentoBrand, TempMagDisplayGroup, 1);
    end;

    procedure ShowFinishStep();
    begin
        FinishStepVisible := true;

        NextActionEnabled := false;
        FinishActionEnabled := true;

        CheckIfDataFilledIn();
    end;

    local procedure FinishAction();
    begin
        StoreData();
        CurrPage.Close();
    end;

    local procedure StoreData();
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if AnyDataToCreate then
            if not MagentoSetup.Get() then
                MagentoSetup.Insert();

        CurrPage.MagentoWebsites.Page.CreateMagentoWebsiteData();
        CurrPage.MagentoStores.Page.CreateMagentoStoreData();
        CurrPage.MagentCustMappings.Page.CreateMagentoCustomerMappingData();
        CurrPage.MagentoPaymentGateways.Page.CreateMagentoPaymentGatewayData();
        CurrPage.MagentoPaymentMappings.Page.CreateMagentoPaymentMapping();
        CurrPage.MagentoShippingMappings.Page.CreateMagentoShipmentMapping();
        CurrPage.MagentoBrands.Page.CreateMagentoBrand();
        CurrPage.MagentoDisplayGroups.Page.CreateMagentoDisplayGroup();
        CurrPage.MagentoDisplayConfigs.Page.CreateMagentoDisplayConfig();
    end;

    local procedure CheckIfDataFilledIn()
    begin
        MagentoWebsiteDataFilledIn := CurrPage.MagentoWebsites.Page.MagentoWebsiteDataToCreate();
        MagentoStoreDataFilledIn := CurrPage.MagentoStores.Page.MagentoStoreDataToCreate();
        MagentoCustomerMappingDataFilledIn := CurrPage.MagentCustMappings.Page.MagentoCustomerMappingDataToCreate();
        MagentoPaymentGatewayDataFilledIn := CurrPage.MagentoPaymentGateways.Page.MagentoPaymentGatewayDataToCreate();
        MagentoPaymentMappingDataFilledIn := CurrPage.MagentoPaymentMappings.Page.MagentoPaymentMappingToCreate();
        MagentoShippmentMappingDataFilledIn := CurrPage.MagentoShippingMappings.Page.MagentoShipmentMappingToCreate();
        MagentoBrandDataFilledIn := CurrPage.MagentoBrands.Page.MagentoBrandToCreate();
        MagentoDisplayGroupDataFilledIn := CurrPage.MagentoDisplayGroups.Page.MagentoDisplayGroupToCreate();
        MagentoDisplayConfigDataFilledIn := CurrPage.MagentoDisplayConfigs.Page.MagentoDisplayConfigToCreate();

        AllDataFilledIn := MagentoWebsiteDataFilledIn and
                           MagentoStoreDataFilledIn and
                           MagentoCustomerMappingDataFilledIn and
                           MagentoPaymentGatewayDataFilledIn and
                           MagentoPaymentMappingDataFilledIn and
                           MagentoShippmentMappingDataFilledIn and
                           MagentoBrandDataFilledIn and
                           MagentoDisplayGroupDataFilledIn and
                           MagentoDisplayConfigDataFilledIn;

        AnyDataToCreate := MagentoWebsiteDataFilledIn or
                           MagentoStoreDataFilledIn or
                           MagentoCustomerMappingDataFilledIn or
                           MagentoPaymentGatewayDataFilledIn or
                           MagentoPaymentMappingDataFilledIn or
                           MagentoShippmentMappingDataFilledIn or
                           MagentoBrandDataFilledIn or
                           MagentoDisplayGroupDataFilledIn or
                           MagentoDisplayConfigDataFilledIn;
    end;

    local procedure LoadTopBanners();
    begin
        if MediaRepositoryStandard.GET('AssistedSetup-NoText-400px.png', FORMAT(CurrentClientType())) AND
           MediaRepositoryDone.GET('AssistedSetupDone-NoText-400px.png', FORMAT(CurrentClientType()))
        then
            if MediaResourcesStandard.GET(MediaRepositoryStandard."Media Resources Ref") AND
               MediaResourcesDone.GET(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesDone."Media Reference".HasValue();
    end;
}
