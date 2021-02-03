pageextension 6014433 "NPR Item List" extends "Item List"
{
    layout
    {
        addafter(Control1901314507)
        {
            part("NPR Item Availability FactBox"; "NPR Item Availability FactBox")
            {
                ApplicationArea = All;
            }
            part("NPR NP Attributes FactBox"; "NPR NP Attributes FactBox")
            {
                SubPageLink = "No." = FIELD("No.");
                ApplicationArea = All;
            }

            part("NPR Discount FactBox"; "NPR Discount FactBox")
            {
                Caption = 'Discounts';
                SubPageLink = "No." = FIELD("No.");
                ApplicationArea = All;
            }
            part("NPR Magento Item Pict. Factbox"; "NPR Magento Item Pict. Factbox")
            {
                Caption = 'Picture';
                ShowFilter = false;
                SubPageLink = "No." = FIELD("No.");
                Visible = MagentoEnabled;
                ApplicationArea = All;
            }
        }

        modify("Item Category Code")
        {
            Visible = false;
        }

        addafter(Description)
        {
            field("NPR Description 2"; "Description 2")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Description 2 field';
            }
        }

        addafter("Price/Profit Calculation")
        {
            field("NPR Item Group"; "NPR Item Group")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Item Group field';
            }

            field(NPR_ItemGroupDesc; ItemGroupDesc)
            {
                Caption = 'Item Group Description';
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Item Group Description field';
            }

            field("NPR Ticket Type"; "NPR Ticket Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Ticket Type field';
            }
        }

        addafter("Profit %")
        {
            field("NPR Magento Item"; "NPR Magento Item")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Magento Item field';
            }

            field("NPR Item Status"; "NPR Item Status")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Item Status field';
            }
        }

        addafter("Unit Price")
        {
            field("NPR Unit List Price"; "Unit List Price")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Unit List Price field';
            }
        }

        addafter("Inventory Posting Group")
        {
            field(NPR_Inventory; Inventory)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Inventory field';
            }

            field(NPR_ItemAvlByLocation; ItemAvlByLocation)
            {
                Caption = 'Inv availability by location';
                ApplicationArea = All;
                DecimalPlaces = 2 : 2;
                ToolTip = 'Specifies the value of the Inv availability by location field';

                trigger OnDrillDown()
                begin
                    ItemFilter.RESET;
                    ItemFilter.SETRANGE("No.", "No.");

                    IF "Global Dimension 1 Filter" <> '' THEN
                        ItemFilter.SETRANGE("Global Dimension 1 Filter", "Global Dimension 1 Filter");
                    IF "Global Dimension 2 Filter" <> '' THEN
                        ItemFilter.SETRANGE("Global Dimension 2 Filter", "Global Dimension 2 Filter");
                    IF "Location Filter" <> '' THEN
                        ItemFilter.SETRANGE("Location Filter", "Location Filter");
                    IF "Drop Shipment Filter" THEN
                        ItemFilter.SETRANGE("Drop Shipment Filter", "Drop Shipment Filter");
                    IF "Variant Filter" <> '' THEN
                        ItemFilter.SETRANGE("Variant Filter", "Variant Filter");

                    PAGE.RUN(PAGE::"Item Availability by Location", ItemFilter);
                end;

            }
        }

        addafter("Vendor Item No.")
        {
            field("NPR Label Barcode"; "NPR Label Barcode")
            {
                ApplicationArea = All;
                Visible = false;
                ToolTip = 'Specifies the value of the NPR Label Barcode field';
            }

            field("NPR Item Brand"; "NPR Item Brand")
            {
                ApplicationArea = All;
                Visible = false;
                ToolTip = 'Specifies the value of the NPR Item Brand field';
            }

        }

        addafter("Item Tracking Code")
        {
            field("NPR Global Dimension 1 Code"; "Global Dimension 1 Code")
            {
                ApplicationArea = All;
                Visible = false;
                ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
            }
            field("NPR Global Dimension 2 Code"; "Global Dimension 2 Code")
            {
                ApplicationArea = all;
                Visible = false;
                ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
            }

            field("NPR Units per Parcel"; "Units per Parcel")
            {
                ApplicationArea = all;
                Visible = false;
                ToolTip = 'Specifies the value of the Units per Parcel field';
            }

            field(NPRAttrTextArray_01; NPRAttrTextArray[1])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,1,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible01;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[1] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 1, "No.", NPRAttrTextArray[1]);
                end;
            }
            field(NPRAttrTextArray_02; NPRAttrTextArray[2])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,2,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible02;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[2] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 2, "No.", NPRAttrTextArray[2]);
                end;
            }

            field(NPRAttrTextArray_03; NPRAttrTextArray[3])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,3,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible03;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[3] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 3, "No.", NPRAttrTextArray[3]);
                end;
            }

            field(NPRAttrTextArray_04; NPRAttrTextArray[4])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,4,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible04;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[4] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 4, "No.", NPRAttrTextArray[4]);
                end;
            }

            field(NPRAttrTextArray_05; NPRAttrTextArray[5])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,5,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible05;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[5] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 5, "No.", NPRAttrTextArray[5]);
                end;
            }

            field(NPRAttrTextArray_06; NPRAttrTextArray[6])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,6,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible06;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[6] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 6, "No.", NPRAttrTextArray[6]);
                end;
            }

            field(NPRAttrTextArray_07; NPRAttrTextArray[7])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,7,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible07;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[7] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 7, "No.", NPRAttrTextArray[7]);
                end;
            }

            field(NPRAttrTextArray_08; NPRAttrTextArray[8])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,8,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible08;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[8] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 8, "No.", NPRAttrTextArray[8]);
                end;
            }

            field(NPRAttrTextArray_09; NPRAttrTextArray[9])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,9,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible09;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[9] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 9, "No.", NPRAttrTextArray[9]);
                end;
            }

            field(NPRAttrTextArray_10; NPRAttrTextArray[10])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,10,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible10;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[10] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 10, "No.", NPRAttrTextArray[10]);
                end;
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
                ApplicationArea = All;
                ToolTip = 'Executes the POS Sales Entries action';
            }
            action("NPR Retail Price Log Entries")
            {
                Caption = 'Retail Price Log Entries';
                Image = Log;
                RunObject = Page "NPR Retail Price Log Entries";
                RunPageLink = "Item No." = FIELD("No.");
                ApplicationArea = All;
                ToolTip = 'Executes the Retail Price Log Entries action';
            }
        }

        addafter(Resources)
        {
            group(NPR_Magento)
            {
                Caption = 'Magento';
                action(NPR_Pictures)
                {
                    Caption = 'Pictures';
                    Image = Picture;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Category6;
                    Visible = MagentoEnabled;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Pictures action';

                    trigger OnAction()
                    var
                        MagentoVariantPictureList: Page "NPR Magento Item Pict. List";
                    begin
                        TestField("No.");
                        FilterGroup(2);
                        MagentoVariantPictureList.SetItemNo("No.");
                        FilterGroup(0);

                        MagentoVariantPictureList.Run();
                    end;
                }
                action(NPR_Webshops)
                {
                    Caption = 'Webshops';
                    Image = Web;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Category6;
                    Visible = MagentoEnabled AND MagentoEnabledMultistore;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Webshops action';

                    trigger OnAction()
                    var
                        MagentoStoreItem: Record "NPR Magento Store Item";
                        MagentoItemMgt: Codeunit "NPR Magento Item Mgt.";
                    begin
                        MagentoItemMgt.SetupMultiStoreData(Rec);
                        MagentoStoreItem.FilterGroup(0);
                        MagentoStoreItem.SetRange("Item No.", "No.");
                        MagentoStoreItem.FilterGroup(2);
                        PAGE.Run(PAGE::"NPR Magento Store Items", MagentoStoreItem);
                    end;
                }
                action(NPR_DisplayConfig)
                {
                    Caption = 'Display Config';
                    Image = ViewPage;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Category6;
                    Visible = MagentoEnabled AND MagentoEnabledDisplayConfig;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Display Config action';

                    trigger OnAction()
                    var
                        MagentoDisplayConfigPage: Page "NPR Magento Display Config";
                        MagentoDisplayConfig: Record "NPR Magento Display Config";
                    begin
                        MagentoDisplayConfig.SetRange(MagentoDisplayConfig."No.", "No.");
                        MagentoDisplayConfig.SetRange(Type, MagentoDisplayConfig.Type::Item);
                        MagentoDisplayConfigPage.SetTableView(MagentoDisplayConfig);
                        MagentoDisplayConfigPage.Run;
                    end;
                }
            }

        }

        addafter(Functions)
        {
            group(NPR_Print)
            {
                Caption = 'Print';
                action("NPR Price Label")
                {
                    Caption = 'Price Label';
                    Image = BinLedger;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Category5;
                    ShortCutKey = 'Ctrl+Alt+L';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Price Label action';

                    trigger OnAction()
                    var
                        ItemRec: Record Item;
                        LabelLibrary: Codeunit "NPR Label Library";
                        ReportSelectionRetail: Record "NPR Report Selection Retail";
                    begin
                        ItemRec := Rec;
                        ItemRec.SetRecFilter;
                        LabelLibrary.ResolveVariantAndPrintItem(ItemRec, ReportSelectionRetail."Report Type"::"Price Label");
                    end;
                }
                action("NPR Shelf Label")
                {
                    Caption = 'Shelf Label';
                    Image = BinLedger;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Category5;
                    ShortCutKey = 'Ctrl+Alt+L';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Shelf Label action';

                    trigger OnAction()
                    var
                        ItemRec: Record Item;
                        LabelLibrary: Codeunit "NPR Label Library";
                        ReportSelectionRetail: Record "NPR Report Selection Retail";
                    begin
                        ItemRec := Rec;
                        ItemRec.SetRecFilter;
                        LabelLibrary.ResolveVariantAndPrintItem(ItemRec, ReportSelectionRetail."Report Type"::"Shelf Label");
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
                ApplicationArea = All;
                ToolTip = 'Executes the Timeline action';

                trigger OnAction()
                begin
                    ShowTimelineFromItem(Rec);
                end;
            }
            action("NPR Retail Inventory Set")
            {
                Caption = 'Retail Inventory Set';
                Image = Intercompany;
                Visible = RetailInventoryEnabled;
                ApplicationArea = All;
                ToolTip = 'Executes the Retail Inventory Set action';

                trigger OnAction()
                var
                    RetailInventorySetMgt: Codeunit "NPR RIS Retail Inv. Set Mgt.";
                begin
                    RetailInventorySetMgt.RunProcessInventorySet(Rec);
                end;
            }
        }

        addafter("Returns Orders")
        {
            action("NPR Recommended Items")
            {
                Caption = 'Recommended Items';
                Image = SuggestLines;
                RunObject = Page "NPR MCS Recomm. Lines";
                RunPageLink = "Seed Item No." = FIELD("No."),
                                  "Table No." = CONST(27);
                ApplicationArea = All;
                ToolTip = 'Executes the Recommended Items action';
            }
        }

        addafter("Adjust Cost - Item Entries")
        {
            action(NPR_SearchItem)
            {
                Caption = 'Search Item';
                Image = Find;
                ShortCutKey = 'Shift+Ctrl+S';
                ApplicationArea = All;
                ToolTip = 'Executes the Search Item action';

                trigger OnAction()
                var
                    InputDialog: Page "NPR Input Dialog";
                    Validering: Text;
                    BarcodeLibrary: Codeunit "NPR Barcode Library";
                    ItemNo: Code[20];
                    VariantCode: Code[10];
                    ResolvingTable: Integer;
                begin
                    Clear(InputDialog);
                    InputDialog.SetInput(1, Validering, Text001);
                    InputDialog.LookupMode(true);
                    if InputDialog.RunModal <> ACTION::LookupOK then
                        exit;
                    InputDialog.InputText(1, Validering);

                    if BarcodeLibrary.TranslateBarcodeToItemVariant(Validering, ItemNo, VariantCode, ResolvingTable, true) then begin
                        Get(ItemNo);
                        exit;
                    end;

                    Error(Error_NoBarcodeMatch, Validering);
                end;
            }
            action(NPR_FilterSearchItem)
            {
                Caption = 'Filter Search Items';
                Image = "Filter";
                ApplicationArea = All;
                ToolTip = 'Executes the Filter Search Items action';

                trigger OnAction()
                var
                    InputDialog: Page "NPR Input Dialog";
                    Validering: Text;
                    NPRAttItemSearch: Codeunit "NPR Att. Item Search";
                begin
                    Clear(InputDialog);
                    InputDialog.SetInput(1, Validering, Text001);
                    InputDialog.LookupMode(true);
                    if InputDialog.RunModal <> ACTION::LookupOK then
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
            action(NPR_SetNPRAttributeFilter)
            {
                Caption = 'Set Client Attribute Filter';
                Image = "Filter";
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                Visible = NPRAttrVisible01 OR NPRAttrVisible02 OR NPRAttrVisible03 OR NPRAttrVisible04 OR NPRAttrVisible05 OR NPRAttrVisible06 OR NPRAttrVisible07 OR NPRAttrVisible08 OR NPRAttrVisible09 OR NPRAttrVisible10;
                ApplicationArea = All;
                ToolTip = 'Executes the Set Client Attribute Filter action';

                trigger OnAction()
                var
                    NPRAttributeValueSet: Record "NPR Attribute Value Set";
                    NPRAttributeMgt: Codeunit "NPR Attribute Management";
                begin
                    if not NPRAttributeMgt.SetAttributeFilter(NPRAttributeValueSet) then
                        exit;

                    SetView(NPRAttributeMgt.GetAttributeFilterView(NPRAttributeValueSet, Rec));
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        NPRAttrManagement.GetMasterDataAttributeValue(NPRAttrTextArray, DATABASE::Item, "No.");
        NPRAttrEditable := CurrPage.Editable();

        GetVendorName;
    end;


    trigger OnOpenPage()
    var
        RetailInventorySetMgt: Codeunit "NPR RIS Retail Inv. Set Mgt.";
    begin
        NPRAttrManagement.GetAttributeVisibility(DATABASE::Item, NPRAttrVisibleArray);
        NPRAttrVisible01 := NPRAttrVisibleArray[1];
        NPRAttrVisible02 := NPRAttrVisibleArray[2];
        NPRAttrVisible03 := NPRAttrVisibleArray[3];
        NPRAttrVisible04 := NPRAttrVisibleArray[4];
        NPRAttrVisible05 := NPRAttrVisibleArray[5];
        NPRAttrVisible06 := NPRAttrVisibleArray[6];
        NPRAttrVisible07 := NPRAttrVisibleArray[7];
        NPRAttrVisible08 := NPRAttrVisibleArray[8];
        NPRAttrVisible09 := NPRAttrVisibleArray[9];
        NPRAttrVisible10 := NPRAttrVisibleArray[10];

        RetailInventoryEnabled := RetailInventorySetMgt.GetRetailInventoryEnabled();

        NPR_SetMagentoEnabled();
    end;

    local procedure GetVendorName()
    begin
        if TblItem.Get(Rec."No.") then begin
            Clear(VendorItemNo);
            VendorItemNo := TblItem."Vendor Item No.";
        end;
    end;

    procedure NPR_SetMagentoEnabled()
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if not (MagentoSetup.Get and MagentoSetup."Magento Enabled") then
            exit;
        MagentoEnabled := true;
        MagentoEnabledMultistore := MagentoSetup."Multistore Enabled";
        MagentoEnabledDisplayConfig := MagentoSetup."Customers Enabled";
    end;

    procedure NPR_SetVendorNo(VendorNo: Code[20])
    begin
        SetFilter("Vendor No.", VendorNo);
    end;

    procedure NPR_SetVariantCode(VariantCode: Code[20])
    begin
        SetFilter("Variant Filter", "Variant Filter");
    end;

    procedure NPR_SetLocationCode(LocationCode: Code[20])
    begin
        SetFilter("Location Filter", LocationCode);
    end;

    procedure NPR_SetBlocked(OptBlocked: Option All,OnlyBlocked,OnlyUnblocked)
    begin
        case OptBlocked of
            OptBlocked::All:
                SetRange(Blocked);
            OptBlocked::OnlyBlocked:
                SetRange(Blocked, true);
            OptBlocked::OnlyUnblocked:
                SetRange(Blocked, false);
        end;
    end;

    procedure NPR_GetViewText(): Text
    begin
        exit(Rec.GetView(false));
    end;

    var
        NPRAttrTextArray: array[40] of Text[250];
        NPRAttrManagement: Codeunit "NPR Attribute Management";
        NPRAttrEditable: Boolean;
        NPRAttrVisibleArray: array[40] of Boolean;
        NPRAttrVisible01: Boolean;
        NPRAttrVisible02: Boolean;
        NPRAttrVisible03: Boolean;
        NPRAttrVisible04: Boolean;
        NPRAttrVisible05: Boolean;
        NPRAttrVisible06: Boolean;
        NPRAttrVisible07: Boolean;
        NPRAttrVisible08: Boolean;
        NPRAttrVisible09: Boolean;
        NPRAttrVisible10: Boolean;
        VendorItemNo: Text[100];
        TblItem: Record Item;
        TblVendor: Record Vendor;
        ItemGroupDesc: Text[50];
        ItemAvlByLocation: Decimal;
        ItemFilter: Record Item;
        MagentoEnabled: Boolean;

        MagentoEnabledDisplayConfig: Boolean;
        MagentoEnabledMultistore: boolean;
        Error_NoBarcodeMatch: Label 'No item found for value %1';
        Text001: Label 'Item No.';
        RetailInventoryEnabled: Boolean;
}
