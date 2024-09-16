pageextension 6014433 "NPR Item List" extends "Item List"
{
    Editable = true;
    layout
    {
        addfirst(content)
        {
            //Smart search is removed but this field cannot be deleted because of the AppSource validation rules.
            field("NPR Search"; Rec."No.")
            {
                Visible = false;
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the item''s No.';
            }
        }

        modify(Control1)
        {
            Editable = false;
        }

        addafter(Control1901314507)
        {
            part("NPR Discount FactBox"; "NPR Discount FactBox")
            {
                Caption = 'Discounts';
                SubPageLink = "No." = FIELD("No.");
                ApplicationArea = NPRRetail;

            }
        }

        modify("Item Category Code")
        {
            Visible = false;
        }

        addafter(Description)
        {
            field("NPR Description 2"; Rec."Description 2")
            {

                ToolTip = 'Specifies the description extension should more information be required for the item.';
                ApplicationArea = NPRRetail;
            }
        }

        addafter("Price/Profit Calculation")
        {
            field("NPR Ticket Type"; Rec."NPR Ticket Type")
            {

                ToolTip = 'Specifies the ticket type.';
                ApplicationArea = NPRRetail;
            }
        }

        addafter("Profit %")
        {
            field("NPR Magento Item"; Rec."NPR Magento Item")
            {

                ToolTip = 'Specifies if the item will also be used as a Magento Item.';
                ApplicationArea = NPRRetail;
            }

            field("NPR Item Status"; Rec."NPR Item Status")
            {

                ToolTip = 'Specifies if the item is active or not as a Magento Item.';
                ApplicationArea = NPRRetail;
            }
        }

        addafter("Unit Price")
        {
            field("NPR Unit List Price"; Rec."Unit List Price")
            {

                ToolTip = 'View different prices for the item.';
                ApplicationArea = NPRRetail;
            }
        }

        addafter("Inventory Posting Group")
        {
            field("NPR ItemAvlByLocation"; Rec.Inventory)
            {
                Caption = 'Inv availability by location';

                DecimalPlaces = 2 : 2;
                ToolTip = 'View item availability by location.';
                ApplicationArea = NPRRetail;

                trigger OnDrillDown()
                begin
                    ItemFilter.Reset();
                    ItemFilter.SETRANGE("No.", Rec."No.");

                    IF Rec."Global Dimension 1 Filter" <> '' THEN
                        ItemFilter.SETRANGE("Global Dimension 1 Filter", Rec."Global Dimension 1 Filter");
                    IF Rec."Global Dimension 2 Filter" <> '' THEN
                        ItemFilter.SETRANGE("Global Dimension 2 Filter", Rec."Global Dimension 2 Filter");
                    IF Rec."Location Filter" <> '' THEN
                        ItemFilter.SETRANGE("Location Filter", Rec."Location Filter");
                    IF Rec."Drop Shipment Filter" THEN
                        ItemFilter.SETRANGE("Drop Shipment Filter", Rec."Drop Shipment Filter");
                    IF Rec."Variant Filter" <> '' THEN
                        ItemFilter.SETRANGE("Variant Filter", Rec."Variant Filter");

                    PAGE.RUN(PAGE::"Item Availability by Location", ItemFilter);
                end;

            }
        }

        addafter("Vendor Item No.")
        {
            field("NPR Item Brand"; Rec."NPR Item Brand")
            {

                Visible = false;
                ToolTip = 'Specifies the item Brand.';
                ApplicationArea = NPRRetail;
            }

        }

        addafter("Item Tracking Code")
        {
            field("NPR Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
            {

                Visible = false;
                ToolTip = 'Specifies the default Global Dimension 1 Code for the item.';
                ApplicationArea = NPRRetail;
            }
            field("NPR Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
            {

                Visible = false;
                ToolTip = 'Specifies the default Global Dimension 2 Code for the item.';
                ApplicationArea = NPRRetail;
            }

            field("NPR Units per Parcel"; Rec."Units per Parcel")
            {

                Visible = false;
                ToolTip = 'Specifies how many units are packed in one parcel.';
                ApplicationArea = NPRRetail;
            }
        }
        addbefore("Base Unit of Measure")
        {
            field("NPR Main Item/Variation"; Rec."NPR Main Item/Variation")
            {
                ToolTip = 'Specifies if the item is a main item or a variation of another item.';
                ApplicationArea = NPRRetail;
            }
            field("NPR Main Item No."; Rec."NPR Main Item No.")
            {
                ToolTip = 'Specifies the number of the main item, if this item is a variation of another item.';
                ApplicationArea = NPRRetail;
            }
        }

#if not BC17
        addafter("Assembly BOM")
        {
            field("NPR Spfy Synced Item"; Rec."NPR Spfy Synced Item")
            {
                ApplicationArea = NPRShopify;
                Visible = ShopifyIntegrationIsEnabled;
                ToolTip = 'Specifies whether the item is integrated with Shopify.';
            }
        }
#endif
    }

    actions
    {
#if BC17 or BC18
#pragma warning disable AL0432
        modify("Cross Re&ferences")
        {
            Visible = false; //we force item reference everywhere now.
        }
#pragma warning restore
#endif
        addafter("&Warehouse Entries")
        {
            action("NPR Update Description")
            {
                Caption = 'Update Magento Description';
                Promoted = true;
                PromotedCategory = Process;
                Image = Import;
                ApplicationArea = NPRRetail;
                ToolTip = 'Executes the Update Magento Description action.';
                ObsoleteState = Pending;
                ObsoleteTag = '2023-06-28';
                ObsoleteReason = 'Action moved to page Magento Setup';
                Visible = false;
            }
            action("NPR POS Sales Entries")
            {
                Caption = 'POS Sales Entries';
                Image = Entries;

                ToolTip = 'View a list of all the POS sales entries for this item.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSEntryNavigation: Codeunit "NPR POS Entry Navigation";
                begin
                    POSEntryNavigation.OpenPOSSalesLineListFromItem(Rec);
                end;
            }

            action("NPR Retail Price Log Entries")
            {
                Caption = 'Retail Price Log Entries';
                Image = Log;
                RunObject = Page "NPR Retail Price Log Entries";
                RunPageLink = "Item No." = FIELD("No.");

                ToolTip = 'View a log of all Retail Prices for this item.';
                ApplicationArea = NPRRetail;
            }
        }

        addafter(Resources)
        {
            group("NPR Magento")
            {
                Caption = 'Magento';
                action("NPR Pictures")
                {
                    Caption = 'Pictures';
                    Image = Picture;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category6;
                    Visible = MagentoEnabled;

                    ToolTip = 'Assign a picture to the item. You can either take a picture or import it.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        MagentoVariantPictureList: Page "NPR Magento Item Pict. List";
                    begin
                        Rec.TestField("No.");
                        Rec.FilterGroup(2);
                        MagentoVariantPictureList.SetItemNo(Rec."No.");
                        Rec.FilterGroup(0);

                        MagentoVariantPictureList.Run();
                    end;
                }
                action("NPR Webshops")
                {
                    Caption = 'Webshops';
                    Image = Web;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category6;
                    Visible = MagentoEnabled AND MagentoEnabledMultistore;

                    ToolTip = 'Executes the Webshops action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        MagentoStoreItem: Record "NPR Magento Store Item";
                        MagentoItemMgt: Codeunit "NPR Magento Item Mgt.";
                    begin
                        MagentoItemMgt.SetupMultiStoreData(Rec);
                        MagentoStoreItem.FilterGroup(0);
                        MagentoStoreItem.SetRange("Item No.", Rec."No.");
                        MagentoStoreItem.FilterGroup(2);
                        PAGE.Run(PAGE::"NPR Magento Store Items", MagentoStoreItem);
                    end;
                }
                action("NPR DisplayConfig")
                {
                    Caption = 'Display Config';
                    Image = ViewPage;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category6;
                    Visible = MagentoEnabled AND MagentoEnabledDisplayConfig;

                    ToolTip = 'Executes the Display Config action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        MagentoDisplayConfig: Record "NPR Magento Display Config";
                        MagentoDisplayConfigPage: Page "NPR Magento Display Config";
                    begin
                        MagentoDisplayConfig.SetRange(MagentoDisplayConfig."No.", Rec."No.");
                        MagentoDisplayConfig.SetRange(Type, MagentoDisplayConfig.Type::Item);
                        MagentoDisplayConfigPage.SetTableView(MagentoDisplayConfig);
                        MagentoDisplayConfigPage.Run();
                    end;
                }
            }

        }

        addafter(Functions)
        {
            group("NPR Print")
            {
                Caption = 'Print';
                action("NPR Price Label")
                {
                    Caption = 'Price Label';
                    Image = BinLedger;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Report;
                    ShortCutKey = 'Ctrl+Alt+L';

                    ToolTip = 'Enable printing the Price Label for the item.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        Item: Record Item;
                        LabelManagement: Codeunit "NPR Label Management";
                    begin
                        Item := Rec;
                        Item.SetRecFilter();
                        LabelManagement.ResolveVariantAndPrintItem(Item, "NPR Report Selection Type"::"Price Label".AsInteger());
                    end;
                }
                action("NPR Shelf Label")
                {
                    Caption = 'Shelf Label';
                    Image = BinLedger;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Report;
                    ShortCutKey = 'Ctrl+Alt+L';

                    ToolTip = 'Enable printing the Shelf Label for the item.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        Item: Record Item;
                        LabelManagement: Codeunit "NPR Label Management";
                    begin
                        Item := Rec;
                        Item.SetRecFilter();
                        LabelManagement.ResolveVariantAndPrintItem(Item, "NPR Report Selection Type"::"Shelf Label".AsInteger());
                    end;
                }
            }
        }

        addafter("BOM Level")
        {
            action("NPR Timeline")
            {
                Caption = 'Timeline';
                Image = Timeline;
#if BC17 or BC18 or BC19 or BC20
                ToolTip = 'Specifies the timeline from the item.';
#else
                ToolTip = 'Specifies the timeline from the item. This action is removed from version BC21 onwards.';
                Visible = false;
#endif
                ApplicationArea = NPRRetail;
                trigger OnAction()
                begin
#if BC17 or BC18 or BC19 or BC20
                    Rec.ShowTimelineFromItem(Rec);
#endif
                end;
            }
            action("NPR Retail Inventory Set")
            {
                Caption = 'Retail Inventory Set';
                Image = Intercompany;
                Visible = RetailInventoryEnabled;

                ToolTip = 'Executes the Retail Inventory Set action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    RetailInventorySetMgt: Codeunit "NPR RIS Retail Inv. Set Mgt.";
                begin
                    RetailInventorySetMgt.RunProcessInventorySet(Rec);
                end;
            }
        }

        addafter("Adjust Cost - Item Entries")
        {
            action("NPR SearchItem")
            {
                Caption = 'Search Item';
                Image = Find;
                ShortCutKey = 'Shift+Ctrl+S';

                ToolTip = 'Enable searching for items using specific criteria, such as code and description.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    BarcodeLibrary: Codeunit "NPR Barcode Lookup Mgt.";
                    InputDialog: Page "NPR Input Dialog";
                    Validering: Text[50];
                    ItemNo: Code[20];
                    VariantCode: Code[10];
                    ResolvingTable: Integer;
                begin
                    Clear(InputDialog);
                    InputDialog.SetInput(1, Validering, Text001);
                    InputDialog.LookupMode(true);
                    if InputDialog.RunModal() <> ACTION::LookupOK then
                        exit;
# pragma warning disable AA0139
                    InputDialog.InputText(1, Validering);
# pragma warning restore
                    if BarcodeLibrary.TranslateBarcodeToItemVariant(Validering, ItemNo, VariantCode, ResolvingTable, true) then begin
                        Rec.Get(ItemNo);
                        exit;
                    end;

                    Error(Error_NoBarcodeMatch, Validering);
                end;
            }
            action("NPR FilterSearchItem")
            {
                Caption = 'Filter Search Items';
                Image = "Filter";

                ToolTip = 'Enable filtering search results using attribute code or text.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    NPRAttItemSearch: Codeunit "NPR Att. Item Search";
                    InputDialog: Page "NPR Input Dialog";
                    Validering: Text;
                begin
                    Clear(InputDialog);
                    InputDialog.SetInput(1, Validering, Text001);
                    InputDialog.LookupMode(true);
                    if InputDialog.RunModal() <> ACTION::LookupOK then
                        exit;
                    InputDialog.InputText(1, Validering);

                    if not NPRAttItemSearch.SearchTextAttribute(Validering, '', Rec) then begin
                        Rec.MarkedOnly(false);
                        Error(Error_NoBarcodeMatch, Validering);
                    end else begin
                        Rec.MarkedOnly(true);
                    end;
                end;
            }
        }

        addafter(Identifiers)
        {
            action("NPR ShowMainItemVariations")
            {
                Caption = 'Main Item Variations';
                ToolTip = 'View or edit main item variations related to currently selected item.';
                ApplicationArea = NPRRetail;
                Image = CoupledItem;

                trigger OnAction()
                var
                    MainItemVariationMgt: Codeunit "NPR Main Item Variation Mgt.";
                begin
                    MainItemVariationMgt.OpenMainItemVariationList(Rec);
                end;
            }
        }
        addlast(Functions)
        {
            action("NPR SetAsMainItemVariation")
            {
                Caption = 'Set as Variation';
                ToolTip = 'Sets current item as a variation of another main item.';
                ApplicationArea = NPRRetail;
                Image = CoupledItem;

                trigger OnAction()
                var
                    MainItemVariationMgt: Codeunit "NPR Main Item Variation Mgt.";
                begin
                    MainItemVariationMgt.AddAsVariation(Rec);
                end;
            }
        }
        addafter(PricesandDiscounts)
        {
            action("NPR MultipleUnitPrices")
            {
                Caption = 'Multiple Unit Prices';
                Image = Price;
                Promoted = true;
                PromotedCategory = Category6;
                RunObject = page "NPR Quantity Discount Card";
                RunPageLink = "Item No." = field("No.");
                RunPageMode = Edit;
                ToolTip = 'Setup different unit prices for the item. An item price is automatically granted on the invoice line when the specified criteria are such as quantity are met.';
                ApplicationArea = NPRRetail;
            }
            action("NPR PeriodDiscount")
            {
                Caption = 'Period Discount';
                Image = Period;
                Promoted = true;
                PromotedCategory = Category6;
                ShortcutKey = 'Ctrl+P';
                ToolTip = 'View all period discount specified for this item.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    PeriodDiscountLine: Record "NPR Period Discount Line";
                    CampaignDiscLineList: Page "NPR Campaign Disc. Line List";
                begin
                    PeriodDiscountLine.SetRange(Status, PeriodDiscountLine.Status::Active);
                    PeriodDiscountLine.SetRange("Item No.", Rec."No.");
                    CampaignDiscLineList.SetTableView(PeriodDiscountLine);
                    CampaignDiscLineList.RunModal();
                end;
            }
            action("NPR MixDiscount")
            {
                Caption = 'Mix Discount';
                Image = Discount;
                Promoted = true;
                PromotedCategory = Category6;
                ShortcutKey = 'Ctrl+F';
                ToolTip = 'View all mix discount specified for this item.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    MixedDiscountLine: Record "NPR Mixed Discount Line";
                    MixedDiscountLines: Page "NPR Mixed Discount Lines";
                begin
                    Clear(MixedDiscountLines);
                    MixedDiscountLines.Editable(false);
                    MixedDiscountLine.Reset();
                    MixedDiscountLine.SetRange("No.", Rec."No.");
                    MixedDiscountLines.SetTableView(MixedDiscountLine);
                    MixedDiscountLines.RunModal();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        NPRRetailInventorySetMgt: Codeunit "NPR RIS Retail Inv. Set Mgt.";
#if not BC17
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
#endif
    begin
        RetailInventoryEnabled := NPRRetailInventorySetMgt.IsRetailInventoryEnabled();
        NPR_SetMagentoEnabled();
#if not BC17
        ShopifyIntegrationIsEnabled := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::" ");
#endif
    end;

    internal procedure NPR_SetMagentoEnabled()
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if not (MagentoSetup.Get() and MagentoSetup."Magento Enabled") then
            exit;
        MagentoEnabled := true;
        MagentoEnabledMultistore := MagentoSetup."Multistore Enabled";
        MagentoEnabledDisplayConfig := MagentoSetup."Customers Enabled";
    end;

    internal procedure NPR_SetVendorNo(VendorNo: Code[20])
    begin
        Rec.SetFilter("Vendor No.", VendorNo);
    end;

    internal procedure NPR_SetLocationCode(LocationCode: Code[20])
    begin
        Rec.SetFilter("Location Filter", LocationCode);
    end;

    internal procedure NPR_SetBlocked(OptBlocked: Option All,OnlyBlocked,OnlyUnblocked)
    begin
        case OptBlocked of
            OptBlocked::All:
                Rec.SetRange(Blocked);
            OptBlocked::OnlyBlocked:
                Rec.SetRange(Blocked, true);
            OptBlocked::OnlyUnblocked:
                Rec.SetRange(Blocked, false);
        end;
    end;

    internal procedure NPR_GetViewText(): Text
    begin
        exit(Rec.GetView(false));
    end;

    var
        ItemFilter: Record Item;
        MagentoEnabled: Boolean;
        MagentoEnabledDisplayConfig: Boolean;
        MagentoEnabledMultistore: boolean;
        Error_NoBarcodeMatch: Label 'No item found for value %1';
        Text001: Label 'Item No.';
        RetailInventoryEnabled: Boolean;
#if not BC17
        ShopifyIntegrationIsEnabled: Boolean;
#endif
}
