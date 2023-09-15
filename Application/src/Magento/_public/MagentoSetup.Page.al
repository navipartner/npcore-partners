page 6151401 "NPR Magento Setup"
{
    Caption = 'Magento Setup';
    PromotedActionCategories = 'New,Tasks,Reports,Display';
    RefreshOnActivate = true;
    SourceTable = "NPR Magento Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("Magento Enabled"; Rec."Magento Enabled")
                {

                    ToolTip = 'Specifies if Magento is enabled or not.';
                    ApplicationArea = NPRRetail;
                }
                field("Magento Version"; Rec."Magento Version")
                {

                    ToolTip = 'Specifies the Magento version.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Magento Url"; Rec."Magento Url")
                {

                    ToolTip = 'Specifies the Magento URL.';
                    ApplicationArea = NPRRetail;
                }
                group("Magento Api")
                {
                    Caption = 'Magento API';
                    Visible = Rec."Magento Enabled";
                    field("Api Url"; Rec."Api Url")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the API URL.';
                        ApplicationArea = NPRRetail;
                    }

                    field(AuthType; Rec.AuthType)
                    {
                        ApplicationArea = NPRRetail;
                        Tooltip = 'Specifies the Authorization Type.';

                        trigger OnValidate()
                        begin
                            CurrPage.Update();
                        end;
                    }

                    group(BasicAuth)
                    {
                        ShowCaption = false;
                        Visible = IsBasicAuthVisible;

                        field("Automatic Username"; Rec."Automatic Username")
                        {
                            ToolTip = 'Specifies if the Basic Username is automatically generated';
                            ApplicationArea = NPRRetail;
                        }
                        field("Api Username"; Rec."Api Username")
                        {
                            Enabled = not Rec."Automatic Username";
                            ToolTip = 'Specifies the API Username.';
                            ApplicationArea = NPRRetail;
                        }
                        field(Password; Password)
                        {
                            Caption = 'API Password';
                            ToolTip = 'Specifies the API Password.';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                if Password <> '' then
                                    WebServiceAuthHelper.SetApiPassword(Password, Rec."Api Password Key")
                                else begin
                                    if WebServiceAuthHelper.HasApiPassword(Rec."Api Password Key") then
                                        WebServiceAuthHelper.RemoveApiPassword(Rec."Api Password Key");
                                end;

                                Commit();
                            end;
                        }
                    }
                    group(OAuth2)
                    {
                        ShowCaption = false;
                        Visible = IsOAuth2Visible;
                        field("OAuth2 Setup Code"; Rec."OAuth2 Setup Code")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the OAuth2.0 Setup Code.';
                        }
                    }

                    group(Custom)
                    {
                        ShowCaption = false;
                        Visible = IsCustomAuthVisible;
                        field("Api Authorization"; Rec."Api Authorization")
                        {
                            ToolTip = 'Specifies the API Authorization.';
                            ApplicationArea = NPRRetail;
                        }
                    }
                }
            }
            group("Xml Templates")
            {
                field("Products Xml Templates Enabled"; Rec."Products XmlTemplates Enabled")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Downloads XML Templates for products from Azure Blob Storage.';
                }
                field("Stock Updat. XmlTempl. Enabled"; Rec."Stock Updat. XmlTempl. Enabled")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Downloads XML Templates for Stock updates from Azure Blob Storage.';
                }
                field("Product Att. XmlTempl. Enabled"; Rec."Product Att. XmlTempl. Enabled")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Downloads XML Templates for Product Attributes from Azure Blob Storage.';
                }
                field("Prod. Attr. Sets XmlTem. Enab."; Rec."Prod. Attr. Sets XmlTem. Enab.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Downloads XML Templates for Product Attribute Sets from Azure Blob Storage.';
                }
                field("Order Updat. XmlTempl. Enabled"; Rec."Order Updat. XmlTempl. Enabled")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Downloads XML Templates for Order Updates from Azure Blob Storage.';
                }
                field("Multi Store XmlTempl. Enabled"; Rec."Multi Store XmlTempl. Enabled")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Downloads XML Templates for Multi Stores from Azure Blob Storage.';
                }
                field("Ticket Adm. XmlTempl. Enabled"; Rec."Ticket Adm. XmlTempl. Enabled")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Downloads XML Templates for Ticket Admission from Azure Blob Storage.';
                }
                field("Coll. Stores XmlTempl. Enabled"; Rec."Coll. Stores XmlTempl. Enabled")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Downloads XML Templates for Collect Stores from Azure Blob Storage.';
                }
                field("Delete Cust. XmlTempl. Enabled"; Rec."Delete Cust. XmlTempl. Enabled")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Downloads XML Templates for Delete Customer from Azure Blob Storage.';
                }
            }
#if not (BC17 or BC18 or BC19 or BC20)
            group(IntegrationAreas)
            {
                Caption = 'Integration Areas';
                Visible = (Rec."Magento Version" <> Rec."Magento Version"::"1");

                field("MSI Integration Area Enabled"; Rec."MSI Integration Area Enabled")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the Multi Source Integration integration is enabled';

                    trigger OnValidate()
                    begin
                        if (Rec."MSI Integration Area Enabled") then
                            _IntegrationAreaMgt.EnableArea(Enum::"NPR M2 Integration Area"::"MSI Stock Data", Rec);
                    end;
                }
            }
            part(IntegrationRecords; "NPR M2 Integration Records")
            {
                Caption = 'Integration Records';
                Visible = (Rec."Magento Version" <> Rec."Magento Version"::"1");
            }
#endif
            group(Moduler)
            {
                field("Variant System"; Rec."Variant System")
                {

                    ToolTip = 'Specifies the Variant System.';
                    ApplicationArea = NPRRetail;

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

                        ToolTip = 'Specifies the picture variety.';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6151446)
                {
                    ShowCaption = false;
                    Visible = (VariantSystem) AND (PictureVarietyType);
                    field("Variant Picture Dimension"; Rec."Variant Picture Dimension")
                    {

                        ToolTip = 'This setup enables differentiation of variant pictures.';
                        ApplicationArea = NPRRetail;
                    }
                }
                field("Miniature Picture"; Rec."Miniature Picture")
                {

                    ToolTip = 'Specifies the miniature version of the picture.Note that Line Picture might affect performance on the Picture List.';
                    ApplicationArea = NPRRetail;
                }
                field("Max. Picture Size"; Rec."Max. Picture Size")
                {

                    ToolTip = 'Specifies the maximum picture size in kilobates.';
                    ApplicationArea = NPRRetail;
                }
                field("Auto Seo Link Disabled"; Rec."Auto Seo Link Disabled")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies if the Auto SEO Link is disabled or not.';
                    ApplicationArea = NPRRetail;
                }
                group("B2C Modules")
                {
                    Caption = 'B2C Modules';
                    field("Multistore Enabled"; Rec."Multistore Enabled")
                    {

                        ToolTip = 'Specifies if the multistore feature is enabled or not.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Brands Enabled"; Rec."Brands Enabled")
                    {

                        ToolTip = 'Specifies if the brands feature is enabled or not';
                        ApplicationArea = NPRRetail;
                    }
                    field("Attributes Enabled"; Rec."Attributes Enabled")
                    {

                        ToolTip = 'Specifies if the attributes feature is enabled or not.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Product Relations Enabled"; Rec."Product Relations Enabled")
                    {

                        ToolTip = 'Specifies if the product relations are enabled or not.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Special Prices Enabled"; Rec."Special Prices Enabled")
                    {

                        ToolTip = 'Specifies if the special prices feature is enabled or not.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Tier Prices Enabled"; Rec."Tier Prices Enabled")
                    {

                        ToolTip = 'Specifies if the tier prices feature is enabled or not.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Customer Group Prices Enabled"; Rec."Customer Group Prices Enabled")
                    {

                        ToolTip = 'Specifies if the customer group prices feature is enabled or not.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Gift Voucher Enabled"; Rec."Gift Voucher Enabled")
                    {

                        ToolTip = 'Specifies if gift vouchers are enabled or not.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Custom Options Enabled"; Rec."Custom Options Enabled")
                    {

                        ToolTip = 'Specifies if custom options are enabled or not.';
                        ApplicationArea = NPRRetail;

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

                        ToolTip = 'Specifies if the bundled products are enabled or not.';
                        ApplicationArea = NPRRetail;
                    }
                    group(Control6150658)
                    {
                        Caption = '';
                        Visible = Rec."Custom Options Enabled";
                        field("Custom Options No. Series"; Rec."Custom Options No. Series")
                        {

                            ToolTip = 'Specifies if custom options numbers are enabled or not.';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    field("Tickets Enabled"; Rec."Tickets Enabled")
                    {

                        ToolTip = 'Specifies if the tickets feature is enabled or not.';
                        ApplicationArea = NPRRetail;
                    }
                    group(Control6151449)
                    {
                        ShowCaption = false;
                        Visible = (Rec."Magento Version" = Rec."Magento Version"::"2");
                        field("Collect in Store Enabled"; Rec."Collect in Store Enabled")
                        {

                            ToolTip = 'Specifies if the collect in store feature is enabled or not.';
                            ApplicationArea = NPRRetail;
                        }
                    }
                }
                group("B2B Modules")
                {
                    Caption = 'B2B Modules';
                    Visible = (Rec."Magento Version" <> Rec."Magento Version"::"2");
                    field("Customers Enabled"; Rec."Customers Enabled")
                    {

                        ToolTip = 'Specifies if the customers are enabled or not.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sales Prices Enabled"; Rec."Sales Prices Enabled")
                    {

                        ToolTip = 'Specifies if the sales prices feature is enabled or not.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sales Line Discounts Enabled"; Rec."Sales Line Discounts Enabled")
                    {

                        ToolTip = 'Specifies if the sales line discounts are enabled or not.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Item Disc. Group Enabled"; Rec."Item Disc. Group Enabled")
                    {

                        ToolTip = 'Specifies if the item discount group feature is enabled or not.';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group("Collect in Store")
            {
                Caption = 'Collect in Store';
                Visible = Rec."Collect in Store Enabled";
                field("NpCs From Store Code"; Rec."NpCs From Store Code")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the from collect store code.';
                    ApplicationArea = NPRRetail;
                }
                field("NpCs Workflow Code"; Rec."NpCs Workflow Code")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the collect in store workflow code.';
                    ApplicationArea = NPRRetail;
                }
            }
            part(NpCsStoreCardWorkflows; "NPR NpCs Store Card Workflows")
            {
                Caption = 'Collect Stores';
                Editable = (Rec."NpCs Workflow Code" <> '');
                SubPageLink = "Workflow Code" = FIELD("NpCs Workflow Code");
                Visible = Rec."Collect in Store Enabled";
                ApplicationArea = NPRRetail;

            }
            group(GiftVoucher)
            {
                Caption = 'Gift Voucher';
                Visible = Rec."Gift Voucher Enabled";
                field("Gift Voucher Activation"; Rec."Gift Voucher Activation")
                {

                    ToolTip = 'Enable the gift voucher.';
                    ApplicationArea = NPRRetail;
                }
                field("Gift Voucher Item No."; Rec."Gift Voucher Item No.")
                {

                    ToolTip = 'Specifies the gift voucher item number.';
                    ApplicationArea = NPRRetail;
                }
                field("Gift Voucher Account No."; Rec."Gift Voucher Account No.")
                {

                    ToolTip = 'Specifies the gift voucher account number.';
                    ApplicationArea = NPRRetail;
                }
                field("Gift Voucher Report"; Rec."Gift Voucher Report")
                {

                    ToolTip = 'Specifies the gift voucher report.';
                    ApplicationArea = NPRRetail;
                }
                field("Gift Voucher Language Code"; Rec."Gift Voucher Language Code")
                {

                    ToolTip = 'Specifies the gift voucher language code.';
                    ApplicationArea = NPRRetail;
                }
                field("Gift Voucher Valid Period"; Rec."Gift Voucher Valid Period")
                {

                    ToolTip = 'Specifies the gift voucher validity period.';
                    ApplicationArea = NPRRetail;
                }
                field("Gift Voucher Code Pattern"; Rec."Gift Voucher Code Pattern")
                {

                    ToolTip = 'Specifies the gift voucher code pattern.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(CreditVoucher)
            {
                Caption = 'Credit Voucher';
                Visible = Rec."Gift Voucher Enabled";
                field("Credit Voucher Account No."; Rec."Credit Voucher Account No.")
                {

                    ToolTip = 'Specifies the credit voucher account number.';
                    ApplicationArea = NPRRetail;
                }
                field("Credit Voucher Report"; Rec."Credit Voucher Report")
                {

                    ToolTip = 'Specifies the credit voucher report';
                    ApplicationArea = NPRRetail;
                }
                field("Credit Voucher Language Code"; Rec."Credit Voucher Language Code")
                {

                    ToolTip = 'Specifies the credit voucher language code.';
                    ApplicationArea = NPRRetail;
                }
                field("Credit Voucher Valid Period"; Rec."Credit Voucher Valid Period")
                {

                    ToolTip = 'Specifies the credit voucher validity period.';
                    ApplicationArea = NPRRetail;
                }
                field("Credit Voucher Code Pattern"; Rec."Credit Voucher Code Pattern")
                {

                    ToolTip = 'Specifies the credit voucher code pattern.';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Replicate Special Price")
            {
                Caption = 'Replicate Special Price';
                Visible = Rec."Special Prices Enabled";
                field("Replicate to Sales Prices"; Rec."Replicate to Sales Prices")
                {

                    ToolTip = 'Specifies the value of the Replicate to Sales Prices field';
                    ApplicationArea = NPRRetail;
                }
                group(Control6151429)
                {
                    ShowCaption = false;
                    Visible = Rec."Replicate to Sales Prices";
                    field("Replicate to Price Source Type"; Rec."Replicate to Price Source Type")
                    {

                        ToolTip = 'Specifies the replication to sales prices.';
                        ApplicationArea = NPRRetail;
                    }
                    group(Control6151427)
                    {
                        ShowCaption = false;
                        Visible = Rec."Replicate to Price Source Type" <> Rec."Replicate to Price Source Type"::"All Customers";
                        field("Replicate to Sales Code"; Rec."Replicate to Sales Code")
                        {

                            ShowMandatory = true;
                            ToolTip = 'Specifies the replication to sales code.';
                            ApplicationArea = NPRRetail;
                        }
                    }
                }
            }
            group(Stock)
            {
                Caption = 'Stock';
                field("Stock Calculation Method"; Rec."Stock Calculation Method")
                {

                    ToolTip = 'Specifies the Stock calculation method.';
                    ApplicationArea = NPRRetail;

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

                        ShowMandatory = true;
                        ToolTip = 'Specifies the stock function name.';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                    field("Stock Codeunit Id"; Rec."Stock Codeunit Id")
                    {

                        Editable = false;
                        ToolTip = 'Specifies the stock codeunit ID.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Stock Codeunit Name"; Rec."Stock Codeunit Name")
                    {

                        ToolTip = 'Specifies the stock codeunit name.';
                        ApplicationArea = NPRRetail;
                    }
                }
                field("Stock NpXml Template"; Rec."Stock NpXml Template")
                {

                    ToolTip = 'Specifies the stock npXml template.';
                    ApplicationArea = NPRRetail;

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

                        ToolTip = 'Specifies the inventory location filter.';
                        ApplicationArea = NPRRetail;
                    }
                }
                field("Intercompany Inventory Enabled"; Rec."Intercompany Inventory Enabled")
                {

                    ToolTip = 'Specifies if the intercompany inventory is enabled or not.';
                    ApplicationArea = NPRRetail;
                }
                part("Inventory Companies"; "NPR Magento Inv. Companies")
                {
                    Caption = 'Inventory Companies';
                    ShowFilter = false;
                    Visible = Rec."Intercompany Inventory Enabled";
                    ApplicationArea = NPRRetail;

                }
                field("Auto Transfer Order Enabled"; Rec."Auto Transfer Order Enabled")
                {
                    ToolTip = 'Specifies if Transfer orders will be automatically created when ordered quantity of Item is greater than available quantity of that Item in Location which is configured on Magento Website. If you enable this, you should go to page "Replenishment Transfer Mapping" and configure it.';
                    ApplicationArea = NPRRetail;
                }
                group(AutoTransfer)
                {
                    ShowCaption = false;
                    Visible = Rec."Auto Transfer Order Enabled";
                    field("Auto Create Req. Lines"; Rec."Auto Create Req. Lines")
                    {
                        ToolTip = 'Specifies if Requisiton lines will be automatically created when needed quantity of Item is was not found in Locations from "Replenishment Transfer Mapping". If you enable this, you should go configure "Req. Worsheet Template Code".';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(RequisitionLines)
                {
                    ShowCaption = false;
                    Visible = Rec."Auto Create Req. Lines";
                    field("Req. Worsheet Template Code"; Rec."Req. Worsheet Template Code")
                    {
                        ToolTip = 'Specifies Req. Worsheet Template Code in which requisition lines will be created, for Items and Quantities which were not found in Locations from "Replenishment Transfer Mapping".';
                        ApplicationArea = NPRRetail;
                    }
                    field("Req. Worsheet Jnl. Batch Name"; Rec."Req. Worsheet Jnl. Batch Name")
                    {
                        ToolTip = 'Specifies Req. Worsheet Template Code in which requisition lines will be created, for Items and Quantities which were not found in Locations from "Replenishment Transfer Mapping".';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(IncomingQuantites)
                {
                    ShowCaption = false;
                    Visible = Rec."Auto Transfer Order Enabled";
                    field("Include Projected quantities"; Rec."Include Projected Quantities")
                    {
                        ToolTip = 'Specifies if "Incoming" quantities (from Purchase Orders, Transfer Orders, Requision Lines...) will be included in the availability calculation. If this field is disabled it will consider actual stocks only.';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(IncomingQuantitiesPeriod)
                {
                    ShowCaption = false;
                    Visible = Rec."Include Projected Quantities";
                    field("Projected. Qty. within period"; Rec."Projected. Qty. Within Period")
                    {
                        ToolTip = 'Specifies the incoming period (DateTime formula) used for culation of available quantity in the future (from Purchase Orders, Transfer Orders, Requision Lines...).';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group(Customer)
            {
                field("Customer Update Mode"; Rec."Customer Update Mode")
                {

                    ToolTip = 'Specifies the customer update mode.';
                    ApplicationArea = NPRRetail;
                }
                group(Control6151460)
                {
                    ShowCaption = false;
                    Visible = (Rec."Customer Update Mode" = Rec."Customer Update Mode"::Fixed);
                    field("Fixed Customer No."; Rec."Fixed Customer No.")
                    {

                        ShowMandatory = true;
                        ToolTip = 'Specifies the fixed customer number.';
                        ApplicationArea = NPRRetail;
                    }
                }
                field("Customer Mapping"; Rec."Customer Mapping")
                {

                    ToolTip = 'Specifies the customer mapping.';
                    ApplicationArea = NPRRetail;
                }
                group(Control6151428)
                {
                    ShowCaption = false;
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteTag = 'NPR23.0';
                    ObsoleteReason = 'Not in use anymore.';
                    field("Customer Posting Group"; Rec."Customer Posting Group")
                    {
                        ToolTip = 'Specifies the customer posting group.';
                        ApplicationArea = NPRRetail;
                        ObsoleteState = Pending;
                        ObsoleteTag = 'NPR23.0';
                        ObsoleteReason = 'Not in use anymore.';
                        Visible = false;
                    }
                    field("Payment Terms Code"; Rec."Payment Terms Code")
                    {
                        ToolTip = 'Specifies the payment terms code.';
                        ApplicationArea = NPRRetail;
                        ObsoleteState = Pending;
                        ObsoleteTag = 'NPR23.0';
                        ObsoleteReason = 'Not in use anymore.';
                        Visible = false;
                    }
                }

                field("Customer Template Code"; Rec."Customer Template Code")
                {

                    ToolTip = 'Specifies the customer template code.';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Config. Template Code"; Rec."Customer Config. Template Code")
                {

                    ToolTip = 'Specifies the customer configuration template.';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Order Import")
            {
                Caption = 'Order Import';
                field("Payment Fee Account No."; Rec."Payment Fee Account No.")
                {

                    ToolTip = 'Specifies the payment fee account number.';

                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {

                    ToolTip = 'Specifies the salesperson code.';
                    ApplicationArea = NPRRetail;
                }
                field("Release Order on Import"; Rec."Release Order on Import")
                {

                    ToolTip = 'Specifies if the release order on import is enabled or not.';
                    ApplicationArea = NPRRetail;
                }
                field("Send Order Confirmation"; Rec."Send Order Confirmation")
                {

                    ToolTip = 'Specifies if the send order confirmation is enabled or not.';
                    ApplicationArea = NPRRetail;
                }
                field("E-mail Template (Order Conf.)"; Rec."E-mail Template (Order Conf.)")
                {

                    ToolTip = 'Specifies the E-mail template of order confirmation.';
                    ApplicationArea = NPRRetail;
                }
                field("Use Blank Code for LCY"; Rec."Use Blank Code for LCY")
                {

                    ToolTip = 'Specifies if the use blank code for the local currency is enabled or not.';
                    ApplicationArea = NPRRetail;
                }
                field("E-mail Retail Vouchers to"; Rec."E-mail Retail Vouchers to")
                {

                    ToolTip = 'Specifies the E-mail retail vouchers.';

                    ApplicationArea = NPRRetail;
                }
                group("Post On Import")
                {
                    Caption = 'Post On Import';
                    field("Post Retail Vouchers on Import"; Rec."Post Retail Vouchers on Import")
                    {

                        ToolTip = 'Immediately post Sales Order Lines for new Retail Vouchers';
                        ApplicationArea = NPRRetail;
                    }
                    field("Post Tickets on Import"; Rec."Post Tickets on Import")
                    {

                        ToolTip = 'Specifies if the post tickets on import is enabled or not.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Post Memberships on Import"; Rec."Post Memberships on Import")
                    {

                        ToolTip = 'Specifies if the post memberships on import is enabled or not.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Prevent posting if commented"; Rec."Prevent posting if commented")
                    {
                        ToolTip = 'Specifies if automatic Post On Import will be skipped if WEB Order has comments (Record links)';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group("Post on Import Setup")
            {
                Caption = 'Post on Import Setup';

                part(Control6151459; "NPR Magento Setup PostOnImport")
                {
                    ApplicationArea = NPRRetail;
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
                    Caption = 'API Integration';
                    Image = SwitchCompanies;

                    action("Setup Magento Credentials")
                    {
                        Caption = 'Setup Magento API Credentials';
                        Image = Setup;

                        ToolTip = 'Opens the page to setup Magento API credentials.';
                        ApplicationArea = NPRRetail;

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

                        ToolTip = 'Opens the page to setup magento websites.';
                        ApplicationArea = NPRRetail;

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

                        ToolTip = 'Opens the page to setup Magento customer groups.';
                        ApplicationArea = NPRRetail;

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

                        ToolTip = 'Opens the page to setup categories.';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
                        begin
                            MagentoSetupMgt.TriggerSetupCategories(false);
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

                        ToolTip = 'Opens the page to setup brands.';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
                        begin
                            MagentoSetupMgt.TriggerSetupBrands(false);
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

                        ToolTip = 'Opens the page to setup Magento tax classes.';
                        ApplicationArea = NPRRetail;

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

                        ToolTip = 'Opens the page to setup VAT Business Posting Groups.';
                        ApplicationArea = NPRRetail;

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

                        ToolTip = 'Opens the page to setup VAT Product Posting Groups.';
                        ApplicationArea = NPRRetail;

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

                        ToolTip = 'Opens the page to setup Payment Method Mapping.';
                        ApplicationArea = NPRRetail;

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

                        ToolTip = 'Opens the page to setup Shipment Method Mapping.';
                        ApplicationArea = NPRRetail;

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
                group("Azure Active Directory OAuth")
                {
                    Caption = 'Azure Active Directory OAuth';
                    Visible = HasAzureADConnection;
                    Image = XMLSetup;

                    action("Create Azure AD App")
                    {
                        Caption = 'Create Azure AD App';
                        ToolTip = 'Running this action will create an Azure AD App and a accompaning client secret.';
                        Image = Setup;
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
                        begin
                            MagentoSetupMgt.CreateAzureADApplication();
                        end;
                    }
                    action("Create Azure AD App Secret")
                    {
                        Caption = 'Create Azure AD App Secret';
                        ToolTip = 'Running this action will create a client secret for an existing Azure AD App.';
                        Image = Setup;
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            AppInfo: ModuleInfo;
                            AADApplication: Record "AAD Application";
                            AADApplicationList: Page "AAD Application List";
                            AADApplicationMgt: Codeunit "NPR AAD Application Mgt.";
                            NoAppsToManageErr: Label 'No AAD Apps with App Name like %1 to manage';
                            SecretDisplayNameLbl: Label 'NaviPartner M2 integration - %1', Comment = '%1 = today''s date';
                        begin
                            NavApp.GetCurrentModuleInfo(AppInfo);

                            AADApplication.SetFilter("App Name", '@' + AppInfo.Name);
                            if (AADApplication.IsEmpty()) then
                                Error(NoAppsToManageErr, AppInfo.Name);

                            AADApplicationList.LookupMode(true);
                            AADApplicationList.SetTableView(AADApplication);
                            if (AADApplicationList.RunModal() <> Action::LookupOK) then
                                exit;

                            AADApplicationList.GetRecord(AADApplication);
                            AADApplicationMgt.CreateAzureADSecret(AADApplication."Client Id", StrSubstNo(SecretDisplayNameLbl, Format(Today(), 0, 9)));
                        end;
                    }
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

                ToolTip = 'Opens the page to setup Import Types.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
                begin
                    MagentoSetupMgt.SetupImportTypes();
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

                    ToolTip = 'Performs the resynchronization of internet items.';
                    ApplicationArea = NPRRetail;

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
                    Visible = Rec."Replicate to Sales Prices" AND ((Rec."Replicate to Price Source Type" = Rec."Replicate to Price Source Type"::"All Customers") OR (Rec."Replicate to Sales Code" <> ''));
                    ToolTip = 'Replicates special prices to sales prices.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        MagentoItemMgt: Codeunit "NPR Magento Item Mgt.";
                    begin
                        MagentoItemMgt.InitReplicateSpecialPrice2SalesPrices();
                    end;
                }
            }
            group("Magento Contacts")
            {
                Caption = 'Magento Contacts';
                action("Show All Magento Contacts")
                {
                    Caption = 'Show All Magento Contacts';
                    Image = ListPage;

                    ToolTip = 'Shows a list of all Magento Contacts';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        M2AccountManager: Codeunit "NPR M2 Account Manager";
                    begin
                        M2AccountManager.ShowMagentoContacts();
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

                ToolTip = 'Opens the Event Subscriptions page.';
                ApplicationArea = NPRRetail;
            }
            action("NPR Update Description")
            {
                Caption = 'Update Magento Description';
                Promoted = true;
                PromotedCategory = Process;
                Image = Import;
                ApplicationArea = NPRRetail;
                ToolTip = 'Executes the Update Magento Description action. You will be asked for .CSV file from which data will be imported. File should have 3 columns/fields sorted as: Item No, Magento Description, Magento Short Description. Field separator is pipe (|) while field Delimiter, or somewhere called qualificator is quotation marks symbol ("). For example: "1000"|"Magento Description"|"Magento Short Description". Also, if the file contians special characters and you see them like this: Æ,æ,Ø,ø,Å,å,ß you should do replace command because they should be HTML encoded (including ; at the end): Æ is &AElig;  æ is &aelig;  Ø is &Oslash;  ø is &oslash;  Å is &Aring;  å is &aring;  ß is &szlig; ';

                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::"NPR ImportMagentoDescription", false, true);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        Password := '';
        HasSetupCategories := MagentoSetupMgt.HasSetupCategories();
        HasSetupBrands := MagentoSetupMgt.HasSetupBrands();

        if not IsNullGuid(Rec."Api Password Key") then
            Password := '***';

        VariantSystem := Rec."Variant System".AsInteger() = 2;
        PictureVarietyType := Rec."Picture Variety Type".AsInteger() = 0;

        WebServiceAuthHelper.SetAuthenticationFieldsVisibility(Rec.AuthType, IsBasicAuthVisible, IsOAuth2Visible, IsCustomAuthVisible);
    end;

    trigger OnOpenPage()
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
    begin
        if not Rec.Get() then
            Rec.Insert();

        CurrPage.NpCsStoreCardWorkflows.PAGE.SetStoreCodeVisible(true);

        Rec.UpdateXmlEnabledFields();

        WebServiceAuthHelper.SetAuthenticationFieldsVisibility(Rec.AuthType, IsBasicAuthVisible, IsOAuth2Visible, IsCustomAuthVisible);

        HasAzureADConnection := (AzureADTenant.GetAadTenantId() <> '');
    end;

    var
        IsBasicAuthVisible, IsOAuth2Visible, IsCustomAuthVisible : Boolean;
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
        Text002: Label 'Resync of %1 added in the Task List';
        Text00201: Label 'Items';
        HasSetupCategories: Boolean;
        HasSetupBrands: Boolean;
        HasAzureADConnection: Boolean;
        VariantSystem: Boolean;
        PictureVarietyType: Boolean;
        Text003: Label 'Category update initiated';
        Text004: Label 'Brand update initiated';
        Password: Text[200];
#if not (BC17 or BC18 or BC19 or BC20)
        _IntegrationAreaMgt: Codeunit "NPR M2 Integration Area Mgt.";
#endif
}
