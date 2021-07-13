pageextension 6014433 "NPR Item List" extends "Item List"
{
    layout
    {
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

                ToolTip = 'Specifies the value of the Description 2 field';
                ApplicationArea = NPRRetail;
            }
        }

        addafter("Price/Profit Calculation")
        {
            field("NPR Ticket Type"; Rec."NPR Ticket Type")
            {

                ToolTip = 'Specifies the value of the NPR Ticket Type field';
                ApplicationArea = NPRRetail;
            }
        }

        addafter("Profit %")
        {
            field("NPR Magento Item"; Rec."NPR Magento Item")
            {

                ToolTip = 'Specifies the value of the NPR Magento Item field';
                ApplicationArea = NPRRetail;
            }

            field("NPR Item Status"; Rec."NPR Item Status")
            {

                ToolTip = 'Specifies the value of the NPR Item Status field';
                ApplicationArea = NPRRetail;
            }
        }

        addafter("Unit Price")
        {
            field("NPR Unit List Price"; Rec."Unit List Price")
            {

                ToolTip = 'Specifies the value of the Unit List Price field';
                ApplicationArea = NPRRetail;
            }
        }

        addafter("Inventory Posting Group")
        {
            field("NPR ItemAvlByLocation"; ItemAvlByLocation)
            {
                Caption = 'Inv availability by location';

                DecimalPlaces = 2 : 2;
                ToolTip = 'Specifies the value of the Inv availability by location field';
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
                ToolTip = 'Specifies the value of the NPR Item Brand field';
                ApplicationArea = NPRRetail;
            }

        }

        addafter("Item Tracking Code")
        {
            field("NPR Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
            {

                Visible = false;
                ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                ApplicationArea = NPRRetail;
            }
            field("NPR Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
            {

                Visible = false;
                ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                ApplicationArea = NPRRetail;
            }

            field("NPR Units per Parcel"; Rec."Units per Parcel")
            {

                Visible = false;
                ToolTip = 'Specifies the value of the Units per Parcel field';
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
        addafter("&Warehouse Entries")
        {
            action("NPR POS Sales Entries")
            {
                Caption = 'POS Sales Entries';
                Image = Entries;

                ToolTip = 'Executes the POS Sales Entries action';
                ApplicationArea = NPRRetail;
            }
            action("NPR Retail Price Log Entries")
            {
                Caption = 'Retail Price Log Entries';
                Image = Log;
                RunObject = Page "NPR Retail Price Log Entries";
                RunPageLink = "Item No." = FIELD("No.");

                ToolTip = 'Executes the Retail Price Log Entries action';
                ApplicationArea = NPRRetail;
            }
        }

        addafter(Resources)
        {
            group("NPR NPR_Magento")
            {
                Caption = 'Magento';
                action("NPR NPR_Pictures")
                {
                    Caption = 'Pictures';
                    Image = Picture;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category6;
                    Visible = MagentoEnabled;

                    ToolTip = 'Executes the Pictures action';
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
                action("NPR NPR_Webshops")
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
                action("NPR NPR_DisplayConfig")
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
                        MagentoDisplayConfigPage: Page "NPR Magento Display Config";
                        MagentoDisplayConfig: Record "NPR Magento Display Config";
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
            group("NPR NPR_Print")
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

                    ToolTip = 'Executes the Price Label action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        Item: Record Item;
                        LabelLibrary: Codeunit "NPR Label Library";
                        ReportSelectionRetail: Record "NPR Report Selection Retail";
                    begin
                        Item := Rec;
                        Item.SetRecFilter();
                        LabelLibrary.ResolveVariantAndPrintItem(Item, ReportSelectionRetail."Report Type"::"Price Label");
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

                    ToolTip = 'Executes the Shelf Label action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        Item: Record Item;
                        LabelLibrary: Codeunit "NPR Label Library";
                        ReportSelectionRetail: Record "NPR Report Selection Retail";
                    begin
                        Item := Rec;
                        Item.SetRecFilter();
                        LabelLibrary.ResolveVariantAndPrintItem(Item, ReportSelectionRetail."Report Type"::"Shelf Label");
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

                ToolTip = 'Executes the Timeline action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.ShowTimelineFromItem(Rec);
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
            action("NPR NPR_SearchItem")
            {
                Caption = 'Search Item';
                Image = Find;
                ShortCutKey = 'Shift+Ctrl+S';

                ToolTip = 'Executes the Search Item action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    InputDialog: Page "NPR Input Dialog";
                    Validering: Text;
                    BarcodeLibrary: Codeunit "NPR Barcode Lookup Mgt.";
                    ItemNo: Code[20];
                    VariantCode: Code[10];
                    ResolvingTable: Integer;
                begin
                    Clear(InputDialog);
                    InputDialog.SetInput(1, Validering, Text001);
                    InputDialog.LookupMode(true);
                    if InputDialog.RunModal() <> ACTION::LookupOK then
                        exit;
                    InputDialog.InputText(1, Validering);

                    if BarcodeLibrary.TranslateBarcodeToItemVariant(Validering, ItemNo, VariantCode, ResolvingTable, true) then begin
                        Rec.Get(ItemNo);
                        exit;
                    end;

                    Error(Error_NoBarcodeMatch, Validering);
                end;
            }
            action("NPR NPR_FilterSearchItem")
            {
                Caption = 'Filter Search Items';
                Image = "Filter";

                ToolTip = 'Executes the Filter Search Items action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    InputDialog: Page "NPR Input Dialog";
                    Validering: Text;
                    NPRAttItemSearch: Codeunit "NPR Att. Item Search";
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
    }

    trigger OnOpenPage()
    var
        RetailInventorySetMgt: Codeunit "NPR RIS Retail Inv. Set Mgt.";
    begin
        RetailInventoryEnabled := RetailInventorySetMgt.GetRetailInventoryEnabled();
        NPR_SetMagentoEnabled();
    end;

    procedure NPR_SetMagentoEnabled()
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if not (MagentoSetup.Get() and MagentoSetup."Magento Enabled") then
            exit;
        MagentoEnabled := true;
        MagentoEnabledMultistore := MagentoSetup."Multistore Enabled";
        MagentoEnabledDisplayConfig := MagentoSetup."Customers Enabled";
    end;

    procedure NPR_SetVendorNo(VendorNo: Code[20])
    begin
        Rec.SetFilter("Vendor No.", VendorNo);
    end;

    procedure NPR_SetLocationCode(LocationCode: Code[20])
    begin
        Rec.SetFilter("Location Filter", LocationCode);
    end;

    procedure NPR_SetBlocked(OptBlocked: Option All,OnlyBlocked,OnlyUnblocked)
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

    procedure NPR_GetViewText(): Text
    begin
        exit(Rec.GetView(false));
    end;

    var
        ItemAvlByLocation: Decimal;
        ItemFilter: Record Item;
        MagentoEnabled: Boolean;
        MagentoEnabledDisplayConfig: Boolean;
        MagentoEnabledMultistore: boolean;
        Error_NoBarcodeMatch: Label 'No item found for value %1';
        Text001: Label 'Item No.';
        RetailInventoryEnabled: Boolean;
}