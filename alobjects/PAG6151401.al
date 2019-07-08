page 6151401 "Magento Setup"
{
    // MAG1.17/MHA /20150611  CASE 216142 Object Created - Includes magento specific fields from NaviConnect Setup
    // MAG1.17/BHR /20150615  CASE 216109 Added field 450 "Exchange Web Code"
    // MAG1.17/TR  /20150618  CASE 210183 ActionItems for previewing credit- and gift voucher added. Currency Code added.
    // MAG1.19/TR  /20150721  CASE 218821 Currency Code added to TempGiftVoucher and TempCreditVoucher.
    // MAG1.19/MHA /20150731  CASE 219367 Removed Generic Setup under General
    // MAG1.20/TR  /20150810  CASE 218819 "Gift Voucher Activation" added to gift voucher section.
    // MAG1.21/MHA /20151104  CASE 223835 Added field 35 "Variant Picture Dimension" and 37 "Picture Miniature"
    // MAG1.21/MHA /20151123  CASE 227354 Added Field 140 "Multistore Enabled"
    // MAG1.22/TS  /20150120  CASE 231762 Added field "Ticket Enabled"
    // MAG1.22/TR  /20160414  CASE 238563 Added Field 131 "Custom Options Nos."
    // MAG1.22/MHA /20160418  CASE 230240 Added field 38 "Max. Picture Size"
    // MAG1.22/MHA /20160421  CASE 236917 Added inventory group
    // MAG1.22/MHA /20160427  CASE 240212 Setup Magento Integration Action is split up into individual Actions: SetupNpXmlTemplates(), SetupVATBusinessPostingGroups(), SetupVATProductPostingGroups(), SetupMagentoCredentials(),
    //                                    SetupMagentoWebsites(), SetupMagentoTaxClasses(), SetupMagentoCustomerGroups(), SetupNaviConnectPaymentMethods() and SetupNaviConnectShipmentMethods()
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.01/TS  /20161025  CASE 254385 Added Setup Import Types
    // MAG2.02/MHA /20170221  CASE 266871 Added field 517 "Customer Config. Template Code"
    // MAG2.03/MHA /20170316  CASE 267449 Added fields for replicating Special Price to Sales Price: 600 "Replicate to Sales Prices",605 "Replicate to Sales Type",610 "Replicate to Sales Code"
    // MAG2.03/MHA /20170425  CASE 267094 Added field 615 "Auto Seo Link Disabled"
    // MAG2.05/MHA /20170714  CASE 283777 Added field 77 "Api Authorization" and Navigate Action "Event Subscriptions"
    // MAG2.06/TS  /20170529  CASE 269051 Added Enable Bundle Products
    // MAG2.07/MHA /20170830  CASE 286943 Updated Magento Setup Actions to support Setup Event Subscription
    // MAG2.08/MHA /20171016  CASE 292926 Added Removed VatBus- and VatProductPostingGroups from Publisher Setup Functions and added SetupNpXmlTemplates
    // MAG2.09/MHA /20171211  CASE 292576 Added fields 345 "Voucher Number Format" and 350 "Voucher Date Format"
    // MAG2.09/TS  /20180108  CASE 300893 Renamed Caption for Action Group
    // MAG2.19/MHA /20190306  CASE 347974 Added field 535 "Release Order on Import"
    // MAG2.20/MHA /20190426  CASE 320423 Added field 15 "Magento Version"

    Caption = 'Magento Setup';
    PromotedActionCategories = 'New,Tasks,Reports,Display';
    SourceTable = "Magento Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(Generelt)
            {
                field("Magento Enabled";"Magento Enabled")
                {
                }
                field("Magento Version";"Magento Version")
                {
                }
                field("Magento Url";"Magento Url")
                {
                }
                group("Magento Api")
                {
                    Caption = 'Magento Api';
                    Visible = "Magento Enabled";
                    field("Api Url";"Api Url")
                    {
                        Importance = Additional;
                    }
                    field("Api Username Type";"Api Username Type")
                    {
                        Importance = Additional;
                    }
                    field("Api Username";"Api Username")
                    {
                        Enabled = "Api Username Type" = "Api Username Type"::Custom;
                        Importance = Additional;
                    }
                    field("Api Password";"Api Password")
                    {
                        Importance = Additional;
                    }
                    field("Api Authorization";"Api Authorization")
                    {
                    }
                }
                field("FORMAT(""Generic Setup"".HASVALUE)";Format("Generic Setup".HasValue))
                {
                    Caption = 'NpXml Setup';
                    Importance = Additional;

                    trigger OnAssistEdit()
                    var
                        MagentoGenericSetupMgt: Codeunit "Magento Generic Setup Mgt.";
                    begin
                        //-MAG2.00
                        MagentoGenericSetupMgt.EditGenericMagentoSetup('template_setup');
                        CurrPage.Update(false);
                        //+MAG2.00
                    end;
                }
                group("Managed Nav Module")
                {
                    Caption = 'Managed Nav Module';
                    field("Managed Nav Modules Enabled";"Managed Nav Modules Enabled")
                    {
                        Importance = Additional;
                    }
                    field("Managed Nav Api Url";"Managed Nav Api Url")
                    {
                        Importance = Additional;
                    }
                    field("Managed Nav Api Username";"Managed Nav Api Username")
                    {
                        Importance = Additional;
                    }
                    field("Managed Nav Api Password";"Managed Nav Api Password")
                    {
                        Importance = Additional;
                    }
                    field("Version No.";"Version No.")
                    {
                    }
                    field("Version Coverage";"Version Coverage")
                    {

                        trigger OnDrillDown()
                        var
                            MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
                        begin
                            //-MAG2.00
                            MagentoSetupMgt.ShowMissingObjects(Rec);
                            //+MAG2.00
                        end;
                    }
                }
            }
            group(Moduler)
            {
                field("Variant System";"Variant System")
                {

                    trigger OnValidate()
                    begin
                        //-MAG1.21
                        CurrPage.Update(true);
                        //+MAG1.21
                    end;
                }
                field("Variant Picture Dimension";"Variant Picture Dimension")
                {
                    Enabled = ("Variant System" ="Variant System"::Variety);
                    ToolTip = 'This setup enables differentiation of variant pictures';
                }
                field("Miniature Picture";"Miniature Picture")
                {
                    ToolTip = 'Note that Line Picture might affect performance on the Picture List';
                }
                field("Max. Picture Size";"Max. Picture Size")
                {
                }
                field("Auto Seo Link Disabled";"Auto Seo Link Disabled")
                {
                    Importance = Additional;
                }
                group("B2C Modules")
                {
                    Caption = 'B2C Modules';
                    field("Multistore Enabled";"Multistore Enabled")
                    {
                    }
                    field("Brands Enabled";"Brands Enabled")
                    {
                    }
                    field("Attributes Enabled";"Attributes Enabled")
                    {
                    }
                    field("Product Relations Enabled";"Product Relations Enabled")
                    {
                    }
                    field("Special Prices Enabled";"Special Prices Enabled")
                    {
                    }
                    field("Tier Prices Enabled";"Tier Prices Enabled")
                    {
                    }
                    field("Customer Group Prices Enabled";"Customer Group Prices Enabled")
                    {
                    }
                    field("Gift Voucher Enabled";"Gift Voucher Enabled")
                    {
                    }
                    field("Custom Options Enabled";"Custom Options Enabled")
                    {

                        trigger OnValidate()
                        var
                            MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
                        begin
                            //-MAG1.22
                            MagentoSetupMgt.InitCustomOptionNos(Rec);
                            CurrPage.Update(true);
                            //+MAG1.22
                        end;
                    }
                    field("Bundled Products Enabled";"Bundled Products Enabled")
                    {
                    }
                    group(Control6150658)
                    {
                        Caption = '';
                        Visible = "Custom Options Enabled";
                        field("Custom Options No. Series";"Custom Options No. Series")
                        {
                        }
                    }
                    field("Tickets Enabled";"Tickets Enabled")
                    {
                    }
                }
                group("B2B Modules")
                {
                    Caption = 'B2B Modules';
                    field("Customers Enabled";"Customers Enabled")
                    {
                    }
                    field("Sales Prices Enabled";"Sales Prices Enabled")
                    {
                    }
                    field("Sales Line Discounts Enabled";"Sales Line Discounts Enabled")
                    {
                    }
                    field("Item Disc. Group Enabled";"Item Disc. Group Enabled")
                    {
                    }
                }
            }
            group(GiftVoucher)
            {
                Caption = 'Gift Voucher';
                Visible = "Gift Voucher Enabled";
                field("Gift Voucher Activation";"Gift Voucher Activation")
                {
                }
                field("Gift Voucher Item No.";"Gift Voucher Item No.")
                {
                }
                field("Gift Voucher Account No.";"Gift Voucher Account No.")
                {
                }
                field("Gift Voucher Report";"Gift Voucher Report")
                {
                }
                field("Gift Voucher Language Code";"Gift Voucher Language Code")
                {
                }
                field("Gift Voucher Valid Period";"Gift Voucher Valid Period")
                {
                }
                field("Gift Voucher Code Pattern";"Gift Voucher Code Pattern")
                {
                }
                field("Gift Voucher Generic Setup";Format("Generic Setup".HasValue))
                {
                    Caption = 'Gift Voucher Generic Setup';

                    trigger OnAssistEdit()
                    var
                        MagentoGenericSetupMgt: Codeunit "Magento Generic Setup Mgt.";
                    begin
                        MagentoGenericSetupMgt.EditGenericMagentoSetup(MagentoGenericSetupMgt."ElementName.GiftVoucherReport");
                        CurrPage.Update(false);
                    end;
                }
                field("Voucher Number Format";"Voucher Number Format")
                {
                }
                field("Voucher Date Format";"Voucher Date Format")
                {
                }
                field("Gift Voucher Bitmap";"Gift Voucher Bitmap")
                {
                    AssistEdit = false;
                }
            }
            group(CreditVoucher)
            {
                Caption = 'Credit Voucher';
                Visible = "Gift Voucher Enabled";
                field("Credit Voucher Account No.";"Credit Voucher Account No.")
                {
                }
                field("Credit Voucher Report";"Credit Voucher Report")
                {
                }
                field("Credit Voucher Language Code";"Credit Voucher Language Code")
                {
                }
                field("Credit Voucher Valid Period";"Credit Voucher Valid Period")
                {
                }
                field("Credit Voucher Code Pattern";"Credit Voucher Code Pattern")
                {
                }
                field("Credit Voucher Generic Setup";Format("Generic Setup".HasValue))
                {
                    Caption = 'Credit Voucher Generic Setup';

                    trigger OnAssistEdit()
                    var
                        MagentoGenericSetupMgt: Codeunit "Magento Generic Setup Mgt.";
                    begin
                        MagentoGenericSetupMgt.EditGenericMagentoSetup(MagentoGenericSetupMgt."ElementName.CreditVoucherReport");
                        CurrPage.Update(false);
                    end;
                }
                field("Credit Voucher Bitmap";"Credit Voucher Bitmap")
                {
                }
            }
            group("Replicate Special Price")
            {
                Caption = 'Replicate Special Price';
                Visible = "Special Prices Enabled";
                field("Replicate to Sales Prices";"Replicate to Sales Prices")
                {
                }
                group(Control6151429)
                {
                    ShowCaption = false;
                    Visible = "Replicate to Sales Prices";
                    field("Replicate to Sales Type";"Replicate to Sales Type")
                    {
                    }
                    group(Control6151427)
                    {
                        ShowCaption = false;
                        Visible = "Replicate to Sales Type" <> 2;
                        field("Replicate to Sales Code";"Replicate to Sales Code")
                        {
                            ShowMandatory = true;
                        }
                    }
                }
            }
            group(Inventory)
            {
                Caption = 'Inventory';
                group(Control6150659)
                {
                    Caption = '';
                    Visible = (NOT "Intercompany Inventory Enabled");
                    field("Inventory Location Filter";"Inventory Location Filter")
                    {
                    }
                }
                field("Intercompany Inventory Enabled";"Intercompany Inventory Enabled")
                {
                }
                part("Inventory Companies";"Magento Inventory Companies")
                {
                    Caption = 'Inventory Companies';
                    ShowFilter = false;
                    Visible = "Intercompany Inventory Enabled";
                }
            }
            group(Customer)
            {
                field("Customer Mapping";"Customer Mapping")
                {
                }
                group(Control6151428)
                {
                    ShowCaption = false;
                    Visible = ("Customer Template Code"='');
                    field("Customer Posting Group";"Customer Posting Group")
                    {
                    }
                    field("Payment Terms Code";"Payment Terms Code")
                    {
                    }
                }
                field("Customer Template Code";"Customer Template Code")
                {
                }
                field("Customer Config. Template Code";"Customer Config. Template Code")
                {
                }
            }
            group(General)
            {
                Caption = 'Order Import';
                field("Payment Fee Account No.";"Payment Fee Account No.")
                {
                }
                field("Salesperson Code";"Salesperson Code")
                {
                }
                field("Release Order on Import";"Release Order on Import")
                {
                }
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
                    action("Setup NpXml Templates")
                    {
                        Caption = 'Setup NpXml Templates';
                        Image = Setup;
                        //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                        //PromotedCategory = Process;
                        //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                        //PromotedIsBig = true;

                        trigger OnAction()
                        var
                            MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
                        begin
                            CurrPage.Update(true);
                            //-MAG2.08 [292926]
                            //MagentoSetupMgt.SetupNpXmlTemplates();
                            MagentoSetupMgt.TriggerSetupNpXmlTemplates();
                            //+MAG2.08 [292926]
                        end;
                    }
                    action("Setup Magento Credentials")
                    {
                        Caption = 'Setup Magento Api Credentials';
                        Image = Setup;
                        //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                        //PromotedCategory = Process;
                        //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                        //PromotedIsBig = true;

                        trigger OnAction()
                        var
                            MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
                        begin
                            CurrPage.Update(true);
                            //-MAG2.07 [286943]
                            //MagentoSetupMgt.SetupMagentoCredentials();
                            MagentoSetupMgt.TriggerSetupMagentoCredentials();
                            //+MAG2.07 [286943]
                        end;
                    }
                    action("Setup Magento Websites")
                    {
                        Caption = 'Setup Magento Websites';
                        Image = Setup;
                        //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                        //PromotedCategory = Process;
                        //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                        //PromotedIsBig = true;

                        trigger OnAction()
                        var
                            MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
                        begin
                            CurrPage.Update(true);
                            //-MAG2.07 [286943]
                            //MagentoSetupMgt.SetupMagentoWebsites();
                            MagentoSetupMgt.TriggerSetupMagentoWebsites();
                            //+MAG2.07 [286943]
                        end;
                    }
                    action("Setup Magento Customer Groups")
                    {
                        Caption = 'Setup Magento Customer Groups';
                        Image = Setup;
                        //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                        //PromotedCategory = Process;
                        //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                        //PromotedIsBig = true;

                        trigger OnAction()
                        var
                            MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
                        begin
                            CurrPage.Update(true);
                            //-MAG2.07 [286943]
                            //MagentoSetupMgt.SetupMagentoCustomerGroups();
                            MagentoSetupMgt.TriggerSetupMagentoCustomerGroups();
                            //+MAG2.07 [286943]
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
                        //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                        //PromotedCategory = Process;
                        //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                        //PromotedIsBig = true;

                        trigger OnAction()
                        var
                            MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
                        begin
                            CurrPage.Update(true);
                            //-MAG2.07 [286943]
                            //MagentoSetupMgt.SetupMagentoTaxClasses();
                            MagentoSetupMgt.TriggerSetupMagentoTaxClasses();
                            //+MAG2.07 [286943]
                        end;
                    }
                    action("Setup VAT Business Posting Groups")
                    {
                        Caption = 'Setup VAT Business Posting Groups';
                        Image = Setup;
                        //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                        //PromotedCategory = Process;
                        //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                        //PromotedIsBig = true;

                        trigger OnAction()
                        var
                            MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
                        begin
                            CurrPage.Update(true);
                            //-MAG2.08 [292926]
                            //MagentoSetupMgt.TriggerSetupVATBusinessPostingGroups();
                            MagentoSetupMgt.SetupVATBusinessPostingGroups();
                            //+MAG2.08 [292926]
                            MagentoSetupMgt.CheckVATBusinessPostingGroups();
                        end;
                    }
                    action("Setup VAT Product Posting Groups")
                    {
                        Caption = 'Setup VAT Product Posting Groups';
                        Image = Setup;
                        //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                        //PromotedCategory = Process;
                        //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                        //PromotedIsBig = true;

                        trigger OnAction()
                        var
                            MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
                        begin
                            CurrPage.Update(true);
                            //-MAG2.08 [292926]
                            //MagentoSetupMgt.TriggerSetupVATProductPostingGroups();
                            MagentoSetupMgt.SetupVATProductPostingGroups();
                            //+MAG2.08 [292926]
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
                        //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                        //PromotedCategory = Process;
                        //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                        //PromotedIsBig = true;

                        trigger OnAction()
                        var
                            MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
                        begin
                            CurrPage.Update(true);
                            //-MAG2.07 [286943]
                            //MagentoSetupMgt.SetupNaviConnectPaymentMethods();
                            MagentoSetupMgt.TriggerSetupPaymentMethodMapping();
                            //+MAG2.07 [286943]
                            MagentoSetupMgt.CheckNaviConnectPaymentMethods();
                        end;
                    }
                    action("Setup Shipment Method Mapping")
                    {
                        Caption = 'Setup Shipment Method Mapping';
                        Image = Setup;
                        //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                        //PromotedCategory = Process;
                        //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                        //PromotedIsBig = true;

                        trigger OnAction()
                        var
                            MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
                        begin
                            CurrPage.Update(true);
                            //-MAG2.07 [286943]
                            //MagentoSetupMgt.SetupNaviConnectShipmentMethods();
                            MagentoSetupMgt.TriggerSetupShipmentMethodMapping();
                            //+MAG2.07 [286943]

                            MagentoSetupMgt.CheckNaviConnectShipmentMethods();
                        end;
                    }
                }
            }
            group("Managed Nav Modules")
            {
                Caption = 'Managed Nav Modules';
                Enabled = "Managed Nav Modules Enabled" AND ("Managed Nav Api Url" <> '');
                action("Update Version No.")
                {
                    Caption = 'Update Version No.';
                    Image = UpdateXML;

                    trigger OnAction()
                    var
                        MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
                    begin
                        //-MAG2.00
                        MagentoSetupMgt.UpdateVersionNo(Rec);
                        //+MAG2.00
                    end;
                }
            }
            action("Setup Import Types")
            {
                Caption = 'Setup Import Types';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
                begin
                    //-MAG2.01
                    MagentoSetupMgt.SetupImportTypes();
                    //+MAG2.01
                end;
            }
            action("Setup Control Add-ins")
            {
                Caption = 'Setup Control Add-ins';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
                begin
                    //-MAG2.00
                    CurrPage.Update(true);
                    MagentoSetupMgt.SetupClientAddIns();
                    //+MAG2.00
                end;
            }
            action("Gift Voucher")
            {
                Caption = 'Gift Voucher';
                Image = Voucher;
                Visible = "Gift Voucher Enabled";

                trigger OnAction()
                begin
                    PreviewGiftVoucherBitmap();
                end;
            }
            action("Credit Voucher")
            {
                Caption = 'Credit Voucher';
                Image = PostedReceivableVoucher;
                Visible = "Gift Voucher Enabled";

                trigger OnAction()
                begin
                    PreviewCreditVoucherBitmap();
                end;
            }
            group(Resync)
            {
                Caption = 'Resync';
                action(ResyncItems)
                {
                    Caption = 'Resync Internet Items';
                    Image = AddAction;
                    Visible = "Magento Enabled";

                    trigger OnAction()
                    var
                        MagentoMgt: Codeunit "Magento Mgt.";
                    begin
                        MagentoMgt.InitItemSync();
                        Message(StrSubstNo(Text002,Text00201));
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
                    Visible = "Replicate to Sales Prices" AND (("Replicate to Sales Type" = 2) OR ("Replicate to Sales Code" <> ''));

                    trigger OnAction()
                    var
                        MagentoItemMgt: Codeunit "Magento Item Mgt.";
                    begin
                        //-MAG2.03 [267449]
                        MagentoItemMgt.InitReplicateSpecialPrice2SalesPrices();
                        //+MAG2.03 [267449]
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
                RunObject = Page "Magento Setup Event Subs.";
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Get then
          Insert;
    end;

    var
        Text000: Label 'Gift Voucher';
        Text001: Label 'Gift Voucher';
        Text002: Label 'Resync of %1 added in the Task List';
        Text00201: Label 'Items';
        Text00202: Label 'Item Groups';
        Text00203: Label 'Attributes';
        Text00204: Label 'Brands';
        Text00205: Label 'Gift Vouchers';
        Text00206: Label 'Customers';
        Text00207: Label 'Sales Prices';

    local procedure CreateEAN(NewEAN: Code[10]) EAN: Code[13]
    begin
        EAN := '29' + PadStr('',10 - StrLen(NewEAN),'0') + NewEAN;
        EAN := EAN + Format(StrCheckSum(EAN,'131313131313'));
        exit(EAN);
    end;

    procedure PreviewGiftVoucherBitmap()
    var
        TempBlob: Record TempBlob temporary;
        TempGiftVoucher: Record "Gift Voucher" temporary;
        TempMagentoPicture: Record "Magento Picture" temporary;
        GiftVoucherMgt: Codeunit "Magento Gift Voucher Mgt.";
        NaviConnectDragDropPicAddin: Page "Magento DragDropPic. Addin";
        OutStream: OutStream;
        TempNo: Code[20];
    begin
        if "Gift Voucher Bitmap".HasValue then begin
          TempNo := '1010';
          TempGiftVoucher.Init;
          TempGiftVoucher."No." := CreateEAN(TempNo);
          TempGiftVoucher.Name := 'Customer Name';
          TempGiftVoucher.Amount := 1500.95;
          TempGiftVoucher."Currency Code" := 'DKK';
          //-MAG2.00
          //TempGiftVoucher."Certificate Number" := GiftVoucherMgt.GenerateCertificateNumber("Gift Voucher Code Pattern",TempNo);
          TempGiftVoucher."External Reference No." := GiftVoucherMgt.GenerateExternalReferenceNo("Gift Voucher Code Pattern",TempNo);
          //+MAG2.00
          TempGiftVoucher."Expire Date" := CalcDate("Gift Voucher Valid Period",Today);
          TempGiftVoucher."Gift Voucher Message".CreateOutStream(OutStream);
          OutStream.WriteText('This an example of a Gift Voucher message');
          TempGiftVoucher.Insert;
          GiftVoucherMgt.GiftVoucherToTempBlob(TempGiftVoucher,TempBlob);
          TempGiftVoucher.DeleteAll;
          TempMagentoPicture.DeleteAll;
          TempMagentoPicture.Init;
          TempMagentoPicture.Name := Text000 + ' ' + TempGiftVoucher."No.";
          TempMagentoPicture.Picture := TempBlob.Blob;
          TempMagentoPicture.Insert;
          PAGE.Run(PAGE::"Magento DragDropPic. Addin",TempMagentoPicture);
        end;
    end;

    procedure PreviewCreditVoucherBitmap()
    var
        TempBlob: Record TempBlob temporary;
        TempCreditVoucher: Record "Credit Voucher" temporary;
        TempMagentoPicture: Record "Magento Picture" temporary;
        GiftVoucherMgt: Codeunit "Magento Gift Voucher Mgt.";
        NaviConnectDragDropPicAddin: Page "Magento DragDropPic. Addin";
        TempNo: Code[20];
    begin
        if "Credit Voucher Bitmap".HasValue then begin
          TempNo := '1010';
          TempCreditVoucher.Init;
          TempCreditVoucher."No." := CreateEAN(TempNo);
          TempCreditVoucher.Name := 'Customer Name';
          TempCreditVoucher.Amount := 1500.95;
          TempCreditVoucher."Currency Code" := 'DKK';
          //-MAG2.00
          //TempCreditVoucher."Certificate Number" := GiftVoucherMgt.GenerateCertificateNumber("Credit Voucher Code Pattern",TempNo);
          TempCreditVoucher."External Reference No." := GiftVoucherMgt.GenerateExternalReferenceNo("Credit Voucher Code Pattern",TempNo);
          //+MAG2.00
          TempCreditVoucher."Expire Date" := CalcDate("Credit Voucher Valid Period",Today);
          GiftVoucherMgt.CreditVoucherToTempBlob(TempCreditVoucher,TempBlob);
          TempMagentoPicture.DeleteAll;
          TempMagentoPicture.Init;
          TempMagentoPicture.Name := Text000 + ' ' + TempCreditVoucher."No.";
          TempMagentoPicture.Picture := TempBlob.Blob;
          TempMagentoPicture.Insert;
          PAGE.Run(PAGE::"Magento DragDropPic. Addin",TempMagentoPicture);
        end;
    end;
}

