page 6151401 "NPR Magento Setup"
{
    Caption = 'Magento Setup';
    PromotedActionCategories = 'New,Tasks,Reports,Display';
    RefreshOnActivate = true;
    SourceTable = "NPR Magento Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(Generelt)
            {
                field("Magento Enabled"; Rec."Magento Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Magento Enabled field';
                }
                field("Magento Version"; Rec."Magento Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Magento Version field';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Magento Url"; Rec."Magento Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Magento Url field';
                }
                group("Magento Api")
                {
                    Caption = 'Magento Api';
                    Visible = Rec."Magento Enabled";
                    field("Api Url"; Rec."Api Url")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Api Url field';
                    }
                    field("Api Username Type"; Rec."Api Username Type")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Api Username Type field';
                    }
                    field("Api Username"; Rec."Api Username")
                    {
                        ApplicationArea = All;
                        Enabled = Rec."Api Username Type" = Rec."Api Username Type"::Custom;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Api Username field';
                    }
                    field(Password; Password)
                    {
                        ApplicationArea = All;
                        Caption = 'Api Password';
                        Importance = Additional;
                        ExtendedDatatype = Masked;
                        ToolTip = 'Specifies the value of the Api Password field';

                        trigger OnValidate()
                        begin
                            Rec.SetApiPassword(Password);
                            Commit();
                        end;
                    }
                    field("Api Authorization"; Rec."Api Authorization")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Api Authorization field';
                    }
                }
                field("FORMAT(""Generic Setup"".HASVALUE)"; Format(Rec."Generic Setup".HasValue))
                {
                    ApplicationArea = All;
                    Caption = 'NpXml Setup';
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the NpXml Setup field';

                    trigger OnAssistEdit()
                    var
                        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
                    begin
                        MagentoGenericSetupMgt.EditGenericMagentoSetup('//template_setup');
                        CurrPage.Update(false);
                    end;
                }
                group("Managed Nav Module")
                {
                    Caption = 'Managed Nav Module';
                    field("Managed Nav Modules Enabled"; Rec."Managed Nav Modules Enabled")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Managed Nav Modules Enabled field';
                    }
                    field("Managed Nav Api Url"; Rec."Managed Nav Api Url")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Managed Nav Api Url field';
                    }
                    field("Managed Nav Api Username"; Rec."Managed Nav Api Username")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Managed Nav api brugernavn field';
                    }
                    field(NavPassword; NavPassword)
                    {
                        ApplicationArea = All;
                        Caption = 'Managed Nav Api Password';
                        ExtendedDatatype = Masked;
                        ToolTip = 'Specifies the value of the Managed Nav Api Password field';

                        trigger OnValidate()
                        begin
                            Rec.SetNavApiPassword(NavPassword);
                            Commit();
                        end;
                    }
                    field("Version No."; Rec."Version No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Version No. field';
                    }
                }
            }
            group(Moduler)
            {
                field("Variant System"; Rec."Variant System")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant System field';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                group(Control6151447)
                {
                    ShowCaption = false;
                    Visible = VariantSystem;
                    field("Picture Variety Type"; Rec."Picture Variety Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'This setup enables differentiation of variant pictures';
                    }
                }
                group(Control6151446)
                {
                    ShowCaption = false;
                    Visible = (VariantSystem) AND (PictureVarietyType);
                    field("Variant Picture Dimension"; Rec."Variant Picture Dimension")
                    {
                        ApplicationArea = All;
                        ToolTip = 'This setup enables differentiation of variant pictures';
                    }
                }
                field("Miniature Picture"; Rec."Miniature Picture")
                {
                    ApplicationArea = All;
                    ToolTip = 'Note that Line Picture might affect performance on the Picture List';
                }
                field("Max. Picture Size"; Rec."Max. Picture Size")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Max. Picture Size (kb) field';
                }
                field("Auto Seo Link Disabled"; Rec."Auto Seo Link Disabled")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Auto Seo Link Disabled field';
                }
                group("B2C Modules")
                {
                    Caption = 'B2C Modules';
                    field("Multistore Enabled"; Rec."Multistore Enabled")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Multistore Enabled field';
                    }
                    field("Brands Enabled"; Rec."Brands Enabled")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Brands Enabled field';
                    }
                    field("Attributes Enabled"; Rec."Attributes Enabled")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Attributes Enabled field';
                    }
                    field("Product Relations Enabled"; Rec."Product Relations Enabled")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Product Relations Enabled field';
                    }
                    field("Special Prices Enabled"; Rec."Special Prices Enabled")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Special Prices Enabled field';
                    }
                    field("Tier Prices Enabled"; Rec."Tier Prices Enabled")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Tier Prices Enabled field';
                    }
                    field("Customer Group Prices Enabled"; Rec."Customer Group Prices Enabled")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customer Group Prices Enabled field';
                    }
                    field("Gift Voucher Enabled"; Rec."Gift Voucher Enabled")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Gift Voucher Enabled field';
                    }
                    field("Custom Options Enabled"; Rec."Custom Options Enabled")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Custom Options Enabled field';

                        trigger OnValidate()
                        var
                            MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
                        begin
                            MagentoSetupMgt.InitCustomOptionNos(Rec);
                            CurrPage.Update(true);
                        end;
                    }
                    field("Bundled Products Enabled"; Rec."Bundled Products Enabled")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bundled Products Enabled field';
                    }
                    group(Control6150658)
                    {
                        Caption = '';
                        Visible = Rec."Custom Options Enabled";
                        field("Custom Options No. Series"; Rec."Custom Options No. Series")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Custom Options Nos. field';
                        }
                    }
                    field("Tickets Enabled"; Rec."Tickets Enabled")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Tickets Enabled field';
                    }
                    group(Control6151449)
                    {
                        ShowCaption = false;
                        Visible = (Rec."Magento Version" = Rec."Magento Version"::"2");
                        field("Collect in Store Enabled"; Rec."Collect in Store Enabled")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Collect in Store Enabled field';
                        }
                    }
                }
                group("B2B Modules")
                {
                    Caption = 'B2B Modules';
                    Visible = (Rec."Magento Version" <> Rec."Magento Version"::"2");
                    field("Customers Enabled"; Rec."Customers Enabled")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customers Enabled field';
                    }
                    field("Sales Prices Enabled"; Rec."Sales Prices Enabled")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sales Prices Enabled field';
                    }
                    field("Sales Line Discounts Enabled"; Rec."Sales Line Discounts Enabled")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sales Line Discounts Enabled field';
                    }
                    field("Item Disc. Group Enabled"; Rec."Item Disc. Group Enabled")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Item Disc. Group Enabled field';
                    }
                }
            }
            group("Collect in Store")
            {
                Caption = 'Collect in Store';
                Visible = Rec."Collect in Store Enabled";
                field("NpCs From Store Code"; Rec."NpCs From Store Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the From Collect Store Code field';
                }
                field("NpCs Workflow Code"; Rec."NpCs Workflow Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Collect in Store Workflow Code field';
                }
            }
            part(NpCsStoreCardWorkflows; "NPR NpCs Store Card Workflows")
            {
                Caption = 'Collect Stores';
                Editable = (Rec."NpCs Workflow Code" <> '');
                SubPageLink = "Workflow Code" = FIELD("NpCs Workflow Code");
                Visible = Rec."Collect in Store Enabled";
                ApplicationArea = All;
            }
            group(GiftVoucher)
            {
                Caption = 'Gift Voucher';
                Visible = Rec."Gift Voucher Enabled";
                field("Gift Voucher Activation"; Rec."Gift Voucher Activation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Activate Gift Voucher field';
                }
                field("Gift Voucher Item No."; Rec."Gift Voucher Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gift Voucher Item No. field';
                }
                field("Gift Voucher Account No."; Rec."Gift Voucher Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gift Voucher Account No. field';
                }
                field("Gift Voucher Report"; Rec."Gift Voucher Report")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gift Voucher Report field';
                }
                field("Gift Voucher Language Code"; Rec."Gift Voucher Language Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gift Voucher Language Code field';
                }
                field("Gift Voucher Valid Period"; Rec."Gift Voucher Valid Period")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gift Voucher Validity field';
                }
                field("Gift Voucher Code Pattern"; Rec."Gift Voucher Code Pattern")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gift Voucher Code Pattern field';
                }
            }
            group(CreditVoucher)
            {
                Caption = 'Credit Voucher';
                Visible = Rec."Gift Voucher Enabled";
                field("Credit Voucher Account No."; Rec."Credit Voucher Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Credit Voucher Account No. field';
                }
                field("Credit Voucher Report"; Rec."Credit Voucher Report")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Credit Voucher Report field';
                }
                field("Credit Voucher Language Code"; Rec."Credit Voucher Language Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Credit Voucher Language Code field';
                }
                field("Credit Voucher Valid Period"; Rec."Credit Voucher Valid Period")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Credit Voucher Valid Period field';
                }
                field("Credit Voucher Code Pattern"; Rec."Credit Voucher Code Pattern")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Credit Voucher Code Pattern field';
                }
            }
            group("Replicate Special Price")
            {
                Caption = 'Replicate Special Price';
                Visible = Rec."Special Prices Enabled";
                field("Replicate to Sales Prices"; Rec."Replicate to Sales Prices")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Replicate to Sales Prices field';
                }
                group(Control6151429)
                {
                    ShowCaption = false;
                    Visible = Rec."Replicate to Sales Prices";
                    field("Replicate to Sales Type"; Rec."Replicate to Sales Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Replicate to Sales Type field';
                    }
                    group(Control6151427)
                    {
                        ShowCaption = false;
                        Visible = Rec."Replicate to Sales Type" <> Rec."Replicate to Sales Type"::"All Customers";
                        field("Replicate to Sales Code"; Rec."Replicate to Sales Code")
                        {
                            ApplicationArea = All;
                            ShowMandatory = true;
                            ToolTip = 'Specifies the value of the Replicate to Sales Code field';
                        }
                    }
                }
            }
            group(Stock)
            {
                Caption = 'Stock';
                field("Stock Calculation Method"; Rec."Stock Calculation Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Stock Calculation Method field';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                group(Control6151463)
                {
                    ShowCaption = false;
                    Visible = (Rec."Stock Calculation Method" = Rec."Stock Calculation Method"::Function);
                    field("Stock Function Name"; Rec."Stock Function Name")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Stock Function Name field';

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                    field("Stock Codeunit Id"; Rec."Stock Codeunit Id")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Stock Codeunit Id field';
                    }
                    field("Stock Codeunit Name"; Rec."Stock Codeunit Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Stock Codeunit Name field';
                    }
                }
                field("Stock NpXml Template"; Rec."Stock NpXml Template")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Stock NpXml Template field';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                group(Control6150659)
                {
                    Caption = '';
                    Visible = (NOT Rec."Intercompany Inventory Enabled");
                    field("Inventory Location Filter"; Rec."Inventory Location Filter")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Inventory Location Filter field';
                    }
                }
                field("Intercompany Inventory Enabled"; Rec."Intercompany Inventory Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Intercompany Inventory Enabled field';
                }
                part("Inventory Companies"; "NPR Magento Inv. Companies")
                {
                    Caption = 'Inventory Companies';
                    ShowFilter = false;
                    Visible = Rec."Intercompany Inventory Enabled";
                    ApplicationArea = All;
                }
            }
            group(Customer)
            {
                field("Customer Update Mode"; Rec."Customer Update Mode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Update Mode field';
                }
                group(Control6151460)
                {
                    ShowCaption = false;
                    Visible = (Rec."Customer Update Mode" = Rec."Customer Update Mode"::Fixed);
                    field("Fixed Customer No."; Rec."Fixed Customer No.")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Fixed Customer No. field';
                    }
                }
                field("Customer Mapping"; Rec."Customer Mapping")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Mapping field';
                }
                group(Control6151428)
                {
                    ShowCaption = false;
                    Visible = (Rec."Customer Template Code" = '');
                    field("Customer Posting Group"; Rec."Customer Posting Group")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customer Posting Group field';
                    }
                    field("Payment Terms Code"; Rec."Payment Terms Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Payment Terms Code field';
                    }
                }
                field("Customer Template Code"; Rec."Customer Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Template Code field';
                }
                field("Customer Config. Template Code"; Rec."Customer Config. Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Config. Template Code field';
                }
            }
            group("Order Import")
            {
                Caption = 'Order Import';
                field("Payment Fee Account No."; Rec."Payment Fee Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Fee Account No. field';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("Release Order on Import"; Rec."Release Order on Import")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Release Order on Import field';
                }
                field("Send Order Confirmation"; Rec."Send Order Confirmation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send Order Confirmation field';
                }
                field("E-mail Template (Order Conf.)"; Rec."E-mail Template (Order Conf.)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-mail Template (Order Confirmation) field';
                }
                field("Use Blank Code for LCY"; Rec."Use Blank Code for LCY")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Use Blank Code for LCY field';
                }
                field("E-mail Retail Vouchers to"; Rec."E-mail Retail Vouchers to")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-mail Retail Vouchers to field';
                }
                group("Post On Import")
                {
                    Caption = 'Post On Import';
                    field("Post Retail Vouchers on Import"; Rec."Post Retail Vouchers on Import")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Immediately post Sales Order Lines for new Retail Vouchers';
                    }
                    field("Post Tickets on Import"; Rec."Post Tickets on Import")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Post Tickets on Import field';
                    }
                    field("Post Memberships on Import"; Rec."Post Memberships on Import")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Post Memberships on Import field';
                    }
                }
            }
            part(Control6151459; "NPR Magento Setup PostOnImport")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("Magento Integration")
            {
                Caption = 'Magento Integration';
                group("Api Integration")
                {
                    Caption = 'Api Integration';
                    Image = SwitchCompanies;

                    action("Setup Magento Credentials")
                    {
                        Caption = 'Setup Magento Api Credentials';
                        Image = Setup;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Setup Magento Api Credentials action';

                        trigger OnAction()
                        var
                            MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
                        begin
                            CurrPage.Update(true);
                            MagentoSetupMgt.TriggerSetupMagentoCredentials();
                        end;
                    }
                    action("Setup Magento Websites")
                    {
                        Caption = 'Setup Magento Websites';
                        Image = Setup;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Setup Magento Websites action';

                        trigger OnAction()
                        var
                            MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
                        begin
                            CurrPage.Update(true);
                            MagentoSetupMgt.TriggerSetupMagentoWebsites();
                        end;
                    }
                    action("Setup Magento Customer Groups")
                    {
                        Caption = 'Setup Magento Customer Groups';
                        Image = Setup;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Setup Magento Customer Groups action';

                        trigger OnAction()
                        var
                            MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
                        begin
                            CurrPage.Update(true);
                            MagentoSetupMgt.TriggerSetupMagentoCustomerGroups();
                        end;
                    }
                    action("Setup Categories")
                    {
                        Caption = 'Setup Categories';
                        Image = Setup;
                        Promoted = true;
                        PromotedOnly = true;
                        PromotedCategory = Process;
                        PromotedIsBig = true;
                        Visible = HasSetupCategories;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Setup Categories action';

                        trigger OnAction()
                        var
                            MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
                        begin
                            MagentoSetupMgt.TriggerSetupCategories();
                            Message(Text003);
                        end;
                    }
                    action("Setup Brands")
                    {
                        Caption = 'Setup Brands';
                        Image = Setup;
                        Promoted = true;
                        PromotedOnly = true;
                        PromotedCategory = Process;
                        PromotedIsBig = true;
                        Visible = HasSetupBrands;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Setup Brands action';

                        trigger OnAction()
                        var
                            MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
                        begin
                            MagentoSetupMgt.TriggerSetupBrands();
                            Message(Text004);
                        end;
                    }
                }
                group(VAT)
                {
                    Caption = 'VAT';
                    Image = VATPostingSetup;
                    action("Setup Magento Tax Classes")
                    {
                        Caption = 'Setup Magento Tax Classes';
                        Image = Setup;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Setup Magento Tax Classes action';

                        trigger OnAction()
                        var
                            MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
                        begin
                            CurrPage.Update(true);
                            MagentoSetupMgt.TriggerSetupMagentoTaxClasses();
                        end;
                    }
                    action("Setup VAT Business Posting Groups")
                    {
                        Caption = 'Setup VAT Business Posting Groups';
                        Image = Setup;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Setup VAT Business Posting Groups action';

                        trigger OnAction()
                        var
                            MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
                        begin
                            CurrPage.Update(true);
                            MagentoSetupMgt.SetupVATBusinessPostingGroups();
                            MagentoSetupMgt.CheckVATBusinessPostingGroups();
                        end;
                    }
                    action("Setup VAT Product Posting Groups")
                    {
                        Caption = 'Setup VAT Product Posting Groups';
                        Image = Setup;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Setup VAT Product Posting Groups action';

                        trigger OnAction()
                        var
                            MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
                        begin
                            CurrPage.Update(true);
                            MagentoSetupMgt.SetupVATProductPostingGroups();
                            MagentoSetupMgt.CheckVATProductPostingGroups();
                        end;
                    }
                }
                group(Mapping)
                {
                    Caption = 'Mapping';
                    Image = SetupList;
                    action("Setup Payment Method Mapping")
                    {
                        Caption = 'Setup Payment Method Mapping';
                        Image = Setup;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Setup Payment Method Mapping action';

                        trigger OnAction()
                        var
                            MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
                        begin
                            CurrPage.Update(true);
                            MagentoSetupMgt.TriggerSetupPaymentMethodMapping();
                            MagentoSetupMgt.CheckNaviConnectPaymentMethods();
                        end;
                    }
                    action("Setup Shipment Method Mapping")
                    {
                        Caption = 'Setup Shipment Method Mapping';
                        Image = Setup;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Setup Shipment Method Mapping action';

                        trigger OnAction()
                        var
                            MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
                        begin
                            CurrPage.Update(true);
                            MagentoSetupMgt.TriggerSetupShipmentMethodMapping();
                            MagentoSetupMgt.CheckNaviConnectShipmentMethods();
                        end;
                    }
                }
            }
            group("Managed Nav Modules")
            {
                Caption = 'Managed Nav Modules';
                Enabled = Rec."Managed Nav Modules Enabled" AND (Rec."Managed Nav Api Url" <> '');
                action("Update Version No.")
                {
                    Caption = 'Update Version No.';
                    Image = UpdateXML;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Update Version No. action';

                    trigger OnAction()
                    var
                        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
                    begin
                        MagentoSetupMgt.UpdateVersionNo(Rec);
                        CurrPage.Update(true);
                    end;
                }
            }
            action("Setup Import Types")
            {
                Caption = 'Setup Import Types';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Setup Import Types action';

                trigger OnAction()
                var
                    MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
                begin
                    MagentoSetupMgt.SetupImportTypes();
                end;
            }
            action("Setup Control Add-ins")
            {
                Caption = 'Setup Control Add-ins';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Setup Control Add-ins action';

                trigger OnAction()
                var
                    MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
                begin
                    CurrPage.Update(true);
                    MagentoSetupMgt.SetupClientAddIns();
                end;
            }
            group(Resync)
            {
                Caption = 'Resync';
                action(ResyncItems)
                {
                    Caption = 'Resync Internet Items';
                    Image = AddAction;
                    Visible = Rec."Magento Enabled";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Resync Internet Items action';

                    trigger OnAction()
                    var
                        MagentoMgt: Codeunit "NPR Magento Mgt.";
                    begin
                        MagentoMgt.InitItemSync();
                        Message(StrSubstNo(Text002, Text00201));
                    end;
                }
            }
            group(Replicate)
            {
                Caption = 'Replicate';
                action("Replicate Special Prices to Sales Prices")
                {
                    Caption = 'Replicate Special Prices to Sales Prices';
                    Image = SuggestSalesPrice;
                    Visible = Rec."Replicate to Sales Prices" AND ((Rec."Replicate to Sales Type" = Rec."Replicate to Sales Type"::"All Customers") OR (Rec."Replicate to Sales Code" <> ''));
                    ApplicationArea = All;
                    ToolTip = 'Executes the Replicate Special Prices to Sales Prices action';

                    trigger OnAction()
                    var
                        MagentoItemMgt: Codeunit "NPR Magento Item Mgt.";
                    begin
                        MagentoItemMgt.InitReplicateSpecialPrice2SalesPrices();
                    end;
                }
            }
        }
        area(navigation)
        {
            action("Event Subscriptions")
            {
                Caption = 'Event Subscriptions';
                Image = "Where-Used";
                RunObject = Page "NPR Magento Setup Event Subs.";
                ApplicationArea = All;
                ToolTip = 'Executes the Event Subscriptions action';
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        Password := '';
        NavPassword := '';
        HasSetupCategories := MagentoSetupMgt.HasSetupCategories();
        HasSetupBrands := MagentoSetupMgt.HasSetupBrands();

        if not IsNullGuid(Rec."Api Password Key") then
            Password := '***';
        if not IsNullGuid(Rec."Managed Nav Api Password Key") then
            NavPassword := '***';

        VariantSystem := Rec."Variant System".AsInteger() = 2;
        PictureVarietyType := Rec."Picture Variety Type".AsInteger() = 0;
    end;

    trigger OnOpenPage()
    begin
        if not Rec.Get() then
            Rec.Insert();

        CurrPage.NpCsStoreCardWorkflows.PAGE.SetStoreCodeVisible(true);
    end;

    var
        Text002: Label 'Resync of %1 added in the Task List';
        Text00201: Label 'Items';
        HasSetupCategories: Boolean;
        HasSetupBrands: Boolean;
        VariantSystem: Boolean;
        PictureVarietyType: Boolean;
        Text003: Label 'Category update initiated';
        Text004: Label 'Brand update initiated';
        Password: Text;
        NavPassword: Text;
}