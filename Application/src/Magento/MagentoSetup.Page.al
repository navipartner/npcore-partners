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

                    ToolTip = 'Specifies the value of the Magento Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Magento Version"; Rec."Magento Version")
                {

                    ToolTip = 'Specifies the value of the Magento Version field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Magento Url"; Rec."Magento Url")
                {

                    ToolTip = 'Specifies the value of the Magento Url field';
                    ApplicationArea = NPRRetail;
                }
                group("Magento Api")
                {
                    Caption = 'Magento Api';
                    Visible = Rec."Magento Enabled";
                    field("Api Url"; Rec."Api Url")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Api Url field';
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
                        field("Api Username"; Rec."Api Username")
                        {
                            Enabled = false;
                            Importance = Additional;
                            ToolTip = 'Specifies the value of the Api Username field';
                            ApplicationArea = NPRRetail;
                        }
                        field(Password; Password)
                        {
                            Caption = 'Api Password';
                            Importance = Additional;
                            ExtendedDatatype = Masked;
                            ToolTip = 'Specifies the value of the Api Password field';
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
                            ToolTip = 'Specifies the value of the Api Authorization field';
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
                    ToolTip = 'Downloads XML Templates for products from Azure Blob Storage';
                }
                field("Stock Updat. XmlTempl. Enabled"; Rec."Stock Updat. XmlTempl. Enabled")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Downloads XML Templates for Stock updates from Azure Blob Storage';
                }
                field("Product Att. XmlTempl. Enabled"; Rec."Product Att. XmlTempl. Enabled")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Downloads XML Templates for Product Attributes from Azure Blob Storage';
                }
                field("Prod. Attr. Sets XmlTem. Enab."; Rec."Prod. Attr. Sets XmlTem. Enab.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Downloads XML Templates for Product Attribute Sets from Azure Blob Storage';
                }
                field("Order Updat. XmlTempl. Enabled"; Rec."Order Updat. XmlTempl. Enabled")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Downloads XML Templates for Order Updates from Azure Blob Storage';
                }
                field("Multi Store XmlTempl. Enabled"; Rec."Multi Store XmlTempl. Enabled")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Downloads XML Templates for Multi Stores from Azure Blob Storage';
                }
                field("Ticket Adm. XmlTempl. Enabled"; Rec."Ticket Adm. XmlTempl. Enabled")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Downloads XML Templates for Ticket Admission from Azure Blob Storage';
                }
                field("Coll. Stores XmlTempl. Enabled"; Rec."Coll. Stores XmlTempl. Enabled")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Downloads XML Templates for Collect Stores from Azure Blob Storage';
                }
                field("Delete Cust. XmlTempl. Enabled"; Rec."Delete Cust. XmlTempl. Enabled")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Downloads XML Templates for Delete Customer from Azure Blob Storage';
                }
            }
            group(Moduler)
            {
                field("Variant System"; Rec."Variant System")
                {

                    ToolTip = 'Specifies the value of the Variant System field';
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

                        ToolTip = 'This setup enables differentiation of variant pictures';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6151446)
                {
                    ShowCaption = false;
                    Visible = (VariantSystem) AND (PictureVarietyType);
                    field("Variant Picture Dimension"; Rec."Variant Picture Dimension")
                    {

                        ToolTip = 'This setup enables differentiation of variant pictures';
                        ApplicationArea = NPRRetail;
                    }
                }
                field("Miniature Picture"; Rec."Miniature Picture")
                {

                    ToolTip = 'Note that Line Picture might affect performance on the Picture List';
                    ApplicationArea = NPRRetail;
                }
                field("Max. Picture Size"; Rec."Max. Picture Size")
                {

                    ToolTip = 'Specifies the value of the Max. Picture Size (kb) field';
                    ApplicationArea = NPRRetail;
                }
                field("Auto Seo Link Disabled"; Rec."Auto Seo Link Disabled")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Auto Seo Link Disabled field';
                    ApplicationArea = NPRRetail;
                }
                group("B2C Modules")
                {
                    Caption = 'B2C Modules';
                    field("Multistore Enabled"; Rec."Multistore Enabled")
                    {

                        ToolTip = 'Specifies the value of the Multistore Enabled field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Brands Enabled"; Rec."Brands Enabled")
                    {

                        ToolTip = 'Specifies the value of the Brands Enabled field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Attributes Enabled"; Rec."Attributes Enabled")
                    {

                        ToolTip = 'Specifies the value of the Attributes Enabled field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Product Relations Enabled"; Rec."Product Relations Enabled")
                    {

                        ToolTip = 'Specifies the value of the Product Relations Enabled field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Special Prices Enabled"; Rec."Special Prices Enabled")
                    {

                        ToolTip = 'Specifies the value of the Special Prices Enabled field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Tier Prices Enabled"; Rec."Tier Prices Enabled")
                    {

                        ToolTip = 'Specifies the value of the Tier Prices Enabled field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Customer Group Prices Enabled"; Rec."Customer Group Prices Enabled")
                    {

                        ToolTip = 'Specifies the value of the Customer Group Prices Enabled field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Gift Voucher Enabled"; Rec."Gift Voucher Enabled")
                    {

                        ToolTip = 'Specifies the value of the Gift Voucher Enabled field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Custom Options Enabled"; Rec."Custom Options Enabled")
                    {

                        ToolTip = 'Specifies the value of the Custom Options Enabled field';
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

                        ToolTip = 'Specifies the value of the Bundled Products Enabled field';
                        ApplicationArea = NPRRetail;
                    }
                    group(Control6150658)
                    {
                        Caption = '';
                        Visible = Rec."Custom Options Enabled";
                        field("Custom Options No. Series"; Rec."Custom Options No. Series")
                        {

                            ToolTip = 'Specifies the value of the Custom Options Nos. field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    field("Tickets Enabled"; Rec."Tickets Enabled")
                    {

                        ToolTip = 'Specifies the value of the Tickets Enabled field';
                        ApplicationArea = NPRRetail;
                    }
                    group(Control6151449)
                    {
                        ShowCaption = false;
                        Visible = (Rec."Magento Version" = Rec."Magento Version"::"2");
                        field("Collect in Store Enabled"; Rec."Collect in Store Enabled")
                        {

                            ToolTip = 'Specifies the value of the Collect in Store Enabled field';
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

                        ToolTip = 'Specifies the value of the Customers Enabled field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sales Prices Enabled"; Rec."Sales Prices Enabled")
                    {

                        ToolTip = 'Specifies the value of the Sales Prices Enabled field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sales Line Discounts Enabled"; Rec."Sales Line Discounts Enabled")
                    {

                        ToolTip = 'Specifies the value of the Sales Line Discounts Enabled field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Item Disc. Group Enabled"; Rec."Item Disc. Group Enabled")
                    {

                        ToolTip = 'Specifies the value of the Item Disc. Group Enabled field';
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
                    ToolTip = 'Specifies the value of the From Collect Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field("NpCs Workflow Code"; Rec."NpCs Workflow Code")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Collect in Store Workflow Code field';
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

                    ToolTip = 'Specifies the value of the Activate Gift Voucher field';
                    ApplicationArea = NPRRetail;
                }
                field("Gift Voucher Item No."; Rec."Gift Voucher Item No.")
                {

                    ToolTip = 'Specifies the value of the Gift Voucher Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Gift Voucher Account No."; Rec."Gift Voucher Account No.")
                {

                    ToolTip = 'Specifies the value of the Gift Voucher Account No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Gift Voucher Report"; Rec."Gift Voucher Report")
                {

                    ToolTip = 'Specifies the value of the Gift Voucher Report field';
                    ApplicationArea = NPRRetail;
                }
                field("Gift Voucher Language Code"; Rec."Gift Voucher Language Code")
                {

                    ToolTip = 'Specifies the value of the Gift Voucher Language Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Gift Voucher Valid Period"; Rec."Gift Voucher Valid Period")
                {

                    ToolTip = 'Specifies the value of the Gift Voucher Validity field';
                    ApplicationArea = NPRRetail;
                }
                field("Gift Voucher Code Pattern"; Rec."Gift Voucher Code Pattern")
                {

                    ToolTip = 'Specifies the value of the Gift Voucher Code Pattern field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(CreditVoucher)
            {
                Caption = 'Credit Voucher';
                Visible = Rec."Gift Voucher Enabled";
                field("Credit Voucher Account No."; Rec."Credit Voucher Account No.")
                {

                    ToolTip = 'Specifies the value of the Credit Voucher Account No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Credit Voucher Report"; Rec."Credit Voucher Report")
                {

                    ToolTip = 'Specifies the value of the Credit Voucher Report field';
                    ApplicationArea = NPRRetail;
                }
                field("Credit Voucher Language Code"; Rec."Credit Voucher Language Code")
                {

                    ToolTip = 'Specifies the value of the Credit Voucher Language Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Credit Voucher Valid Period"; Rec."Credit Voucher Valid Period")
                {

                    ToolTip = 'Specifies the value of the Credit Voucher Valid Period field';
                    ApplicationArea = NPRRetail;
                }
                field("Credit Voucher Code Pattern"; Rec."Credit Voucher Code Pattern")
                {

                    ToolTip = 'Specifies the value of the Credit Voucher Code Pattern field';
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

                        ToolTip = 'Specifies the value of the Replicate to Sales Type field';
                        ApplicationArea = NPRRetail;
                    }
                    group(Control6151427)
                    {
                        ShowCaption = false;
                        Visible = Rec."Replicate to Price Source Type" <> Rec."Replicate to Price Source Type"::"All Customers";
                        field("Replicate to Sales Code"; Rec."Replicate to Sales Code")
                        {

                            ShowMandatory = true;
                            ToolTip = 'Specifies the value of the Replicate to Sales Code field';
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

                    ToolTip = 'Specifies the value of the Stock Calculation Method field';
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
                        ToolTip = 'Specifies the value of the Stock Function Name field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                    field("Stock Codeunit Id"; Rec."Stock Codeunit Id")
                    {

                        Editable = false;
                        ToolTip = 'Specifies the value of the Stock Codeunit Id field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Stock Codeunit Name"; Rec."Stock Codeunit Name")
                    {

                        ToolTip = 'Specifies the value of the Stock Codeunit Name field';
                        ApplicationArea = NPRRetail;
                    }
                }
                field("Stock NpXml Template"; Rec."Stock NpXml Template")
                {

                    ToolTip = 'Specifies the value of the Stock NpXml Template field';
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

                        ToolTip = 'Specifies the value of the Inventory Location Filter field';
                        ApplicationArea = NPRRetail;
                    }
                }
                field("Intercompany Inventory Enabled"; Rec."Intercompany Inventory Enabled")
                {

                    ToolTip = 'Specifies the value of the Intercompany Inventory Enabled field';
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
                    ApplicationArea = All;
                }
                group(AutoTransfer)
                {
                    ShowCaption = false;
                    Visible = Rec."Auto Transfer Order Enabled";
                    field("Auto Create Req. Lines"; Rec."Auto Create Req. Lines")
                    {
                        ToolTip = 'Specifies if Requisiton lines will be automatically created when needed quantity of Item is was not found in Locations from "Replenishment Transfer Mapping". If you enable this, you should go configure "Req. Worsheet Template Code".';
                        ApplicationArea = All;
                    }
                }
                group(RequisitionLines)
                {
                    ShowCaption = false;
                    Visible = Rec."Auto Create Req. Lines";
                    field("Req. Worsheet Template Code"; Rec."Req. Worsheet Template Code")
                    {
                        ToolTip = 'Specifies Req. Worsheet Template Code in which requisition lines will be created, for Items and Quantities which were not found in Locations from "Replenishment Transfer Mapping".';
                        ApplicationArea = All;
                    }
                    field("Req. Worsheet Jnl. Batch Name"; Rec."Req. Worsheet Jnl. Batch Name")
                    {
                        ToolTip = 'Specifies Req. Worsheet Template Code in which requisition lines will be created, for Items and Quantities which were not found in Locations from "Replenishment Transfer Mapping".';
                        ApplicationArea = All;
                    }
                }
                group(IncomingQuantites)
                {
                    ShowCaption = false;
                    Visible = Rec."Auto Transfer Order Enabled";
                    field("Include Projected quantities"; Rec."Include Projected Quantities")
                    {
                        ToolTip = 'Specifies if "Incoming" quantities (from Purchase Orders, Transfer Orders, Requision Lines...) will be included in the availability calculation. If this field is disabled it will consider actual stocks only.';
                        ApplicationArea = All;
                    }
                }
                group(IncomingQuantitiesPeriod)
                {
                    ShowCaption = false;
                    Visible = Rec."Include Projected Quantities";
                    field("Projected. Qty. within period"; Rec."Projected. Qty. Within Period")
                    {
                        ToolTip = 'Specifies the incoming period (DateTime formula) used for culation of available quantity in the future (from Purchase Orders, Transfer Orders, Requision Lines...).';
                        ApplicationArea = All;
                    }
                }
            }
            group(Customer)
            {
                field("Customer Update Mode"; Rec."Customer Update Mode")
                {

                    ToolTip = 'Specifies the value of the Customer Update Mode field';
                    ApplicationArea = NPRRetail;
                }
                group(Control6151460)
                {
                    ShowCaption = false;
                    Visible = (Rec."Customer Update Mode" = Rec."Customer Update Mode"::Fixed);
                    field("Fixed Customer No."; Rec."Fixed Customer No.")
                    {

                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Fixed Customer No. field';
                        ApplicationArea = NPRRetail;
                    }
                }
                field("Customer Mapping"; Rec."Customer Mapping")
                {

                    ToolTip = 'Specifies the value of the Customer Mapping field';
                    ApplicationArea = NPRRetail;
                }
                group(Control6151428)
                {
                    ShowCaption = false;
                    Visible = (Rec."Customer Template Code" = '');
                    field("Customer Posting Group"; Rec."Customer Posting Group")
                    {

                        ToolTip = 'Specifies the value of the Customer Posting Group field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Payment Terms Code"; Rec."Payment Terms Code")
                    {

                        ToolTip = 'Specifies the value of the Payment Terms Code field';
                        ApplicationArea = NPRRetail;
                    }
                }
                field("Customer Template Code"; Rec."Customer Template Code")
                {

                    ToolTip = 'Specifies the value of the Customer Template Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Config. Template Code"; Rec."Customer Config. Template Code")
                {

                    ToolTip = 'Specifies the value of the Customer Config. Template Code field';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Order Import")
            {
                Caption = 'Order Import';
                field("Payment Fee Account No."; Rec."Payment Fee Account No.")
                {

                    ToolTip = 'Specifies the value of the Payment Fee Account No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {

                    ToolTip = 'Specifies the value of the Salesperson Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Release Order on Import"; Rec."Release Order on Import")
                {

                    ToolTip = 'Specifies the value of the Release Order on Import field';
                    ApplicationArea = NPRRetail;
                }
                field("Send Order Confirmation"; Rec."Send Order Confirmation")
                {

                    ToolTip = 'Specifies the value of the Send Order Confirmation field';
                    ApplicationArea = NPRRetail;
                }
                field("E-mail Template (Order Conf.)"; Rec."E-mail Template (Order Conf.)")
                {

                    ToolTip = 'Specifies the value of the E-mail Template (Order Confirmation) field';
                    ApplicationArea = NPRRetail;
                }
                field("Use Blank Code for LCY"; Rec."Use Blank Code for LCY")
                {

                    ToolTip = 'Specifies the value of the Use Blank Code for LCY field';
                    ApplicationArea = NPRRetail;
                }
                field("E-mail Retail Vouchers to"; Rec."E-mail Retail Vouchers to")
                {

                    ToolTip = 'Specifies the value of the E-mail Retail Vouchers to field';
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

                        ToolTip = 'Specifies the value of the Post Tickets on Import field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Post Memberships on Import"; Rec."Post Memberships on Import")
                    {

                        ToolTip = 'Specifies the value of the Post Memberships on Import field';
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
                    Caption = 'Api Integration';
                    Image = SwitchCompanies;

                    action("Setup Magento Credentials")
                    {
                        Caption = 'Setup Magento Api Credentials';
                        Image = Setup;

                        ToolTip = 'Executes the Setup Magento Api Credentials action';
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

                        ToolTip = 'Executes the Setup Magento Websites action';
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

                        ToolTip = 'Executes the Setup Magento Customer Groups action';
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

                        ToolTip = 'Executes the Setup Categories action';
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

                        ToolTip = 'Executes the Setup Brands action';
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

                        ToolTip = 'Executes the Setup Magento Tax Classes action';
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

                        ToolTip = 'Executes the Setup VAT Business Posting Groups action';
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

                        ToolTip = 'Executes the Setup VAT Product Posting Groups action';
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

                        ToolTip = 'Executes the Setup Payment Method Mapping action';
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

                        ToolTip = 'Executes the Setup Shipment Method Mapping action';
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
            }
            action("Setup Import Types")
            {
                Caption = 'Setup Import Types';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Setup Import Types action';
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

                    ToolTip = 'Executes the Resync Internet Items action';
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
                    ToolTip = 'Executes the Replicate Special Prices to Sales Prices action';
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

                ToolTip = 'Executes the Event Subscriptions action';
                ApplicationArea = NPRRetail;
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
    begin
        if not Rec.Get() then
            Rec.Insert();

        CurrPage.NpCsStoreCardWorkflows.PAGE.SetStoreCodeVisible(true);

        Rec.UpdateXmlEnabledFields();

        WebServiceAuthHelper.SetAuthenticationFieldsVisibility(Rec.AuthType, IsBasicAuthVisible, IsOAuth2Visible, IsCustomAuthVisible);
    end;

    var

        [InDataSet]
        IsBasicAuthVisible, IsOAuth2Visible, IsCustomAuthVisible : Boolean;

        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
        Text002: Label 'Resync of %1 added in the Task List';
        Text00201: Label 'Items';
        HasSetupCategories: Boolean;
        HasSetupBrands: Boolean;
        VariantSystem: Boolean;
        PictureVarietyType: Boolean;
        Text003: Label 'Category update initiated';
        Text004: Label 'Brand update initiated';
        Password: Text[200];
}