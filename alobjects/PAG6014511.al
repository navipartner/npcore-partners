page 6014511 "Retail Item List"
{
    // NPR4.11/TSA /20150422 CASE 209946 - Entity and Shortcut Attributes
    // NPR4.15/TS  /20151013 CASE 224751 Added NpAttribute Factbox
    // NPR4.15/TS  /20151014 CASE 224015 Added Action SearchItem
    // NPR4.17/LS  /20151022 CASE 225607  Action6500 commented.
    // MAG1.21/TR  /20151028 CASE 225601 Action Group Magento added. Access to Display Config added.
    // MAG1.21/MHA /20151118 CASE 227354 Added PromotedActionCategoriesML (5 = Retail,6 = Magento)
    // MAG1.21/MHA /20151118 CASE 223835 Action Magento Pictures and Webshops Action
    // NPR4.18/TS  /20151130 CASE 227725 Added Option to Filter by Vendor Item No.
    // NPR4.18/MMV /20151230 CASE 229221 Added Label action
    // NPR5.22/MMV /20160420 CASE 237743 Readded label action?? This time with an updated reference
    // MAG2.00/MHA /20160525 CASE 242557 Magento Integration
    // MAG2.01/TR  /20160811 CASE 246629 Added Magento Item Picture Factbox
    // NPR5.29/LS  /20161108 CASE 257874 Changed length from 100 to 250 for Global Var "NPRAttrTextArray"
    // NPR5.29/TS  /20161125  CASE 257206 Added field Inventory
    // NPR5.29/MMV /20161201 CASE 259398 Removed search field since it was unusable.
    //                                   Updated action SearchItem.
    // NPR5.29/TS  /20170103 CASE 262001 Added Fields TicketType and Item Group
    // NPR5.30/MMV /20170221 CASE 266517 Renamed label action caption.
    // NPR5.30/TJ  /20170221 CASE 266258 Changed RunObject property on actions Item Journal and Item Reclassification Journal to use new pages Retail Item Journal and Retail Item Reclass. Journal
    // NPR5.30/BR  /20170213 CASE 252646 Added function GetViewText
    // NPR5.30/BR  /20170228 CASE 252646 Added RelatedInformation to MCS Recommendations Lines page
    // NPR5.31/BR  /20170424 CASE 272843 Added global functions SetVendorNo, SetVariantCode and SetLocation Code for lookup from Purchase Order Page
    // NPR5.31/BR  /20170426 CASE 272849 added NPR Item Availability Factbox
    // NPR5.33/ANEN/20170427 CASE 273989 Extending to 40 attributes
    // NPR5.34/ANEN/20170608 CASE 279662 Add action FilterSearchItems for search in attributes
    // NPR5.33/JLK /20170613 CASE 277219 Added field "Global Dimension 1 Code" and "Global Dimension 2 Code"
    // NPR5.34/JLK /20170630 CASE 279958 Added field Description 2
    // NPR5.36/JLK /20170925 CASE 291332 Added field Unit per parcel
    // NPR5.37/MHA /20171026 CASE 293180 Added Action: SetNPRAttributeFilter
    // NPR5.38/BHR /20170911 CASE 294359 display Description of ItemGroup
    // NPR5.38/BR  /20171116 CASE 295255 Added Action POS Sales Entries, renamed controls to PageSalesPrices2 and PageSalesLineDiscounts2 because of duplicate name
    // NPR5.38/BR  /20171201 CASE 298368 Added function SetBlocked
    // NPR5.38/TS  /20171205 CASE 298562 Added Qty. on Sales Order ( Additional )
    // NPR5.40/MHA /20180316 CASE 304031 Added History Entry Action: "PriceLog"
    // NPR5.40/MHA /20180320 CASE 307025 Added Item Availability by Action "RetailInventorySet"
    // NPR5.41/TS  /20180330 CASE 308196 Added Discount
    // NPR5.42/TS  /20180305 CASE 313406 Added field Magento Itema and Qty on Purch Order
    // NPR5.42/TS  /20180510 CASE 314710 Added Sales (Qty.)
    // NPR5.42/BHR /20180514 CASE 315055 Promoted Item Availability By location
    // NPR5.42/TS  /20180515 CASE 313386 Added Field Unit List Price
    // NPR5.43/TS  /20180606 CASE 314710 Removed Sales (Qty)(318569)
    // NPR5.43/BHR /20180622 CASE 319926 Removed "Substitutes Exist", "Stockkeeping Unit Exists","Assembly BOM","Qty. on Purch. Order","Qty. on Sales Order","Cost is Adjusted","Production BOM No.","Routing No."
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action
    // NPR5.48/TJ  /20190102 CASE 340615 Removed field "Product Group Code"
    // NPR5.48/TS  /20180104 CASE 338609 Added Shortcut Ctrl+Alt+L to Price Label
    // NPR5.50/JAVA/20190429 CASE 353381 BC14: Implement changes done in page 542 (use generic SetMultiRecord() function instead of specific functions).
    // NPR5.51/THRO/20190717 CASE 361514 Action POS Sales Entries named POSSalesEntries (for AL Conversion)
    // NPR5.51/ZESO/20190814 CASE 363460 Added Item Status
    // NPR5.51/ZESO/20190708 CASE 361229 Added Page Action Attributes and Factbox Item Attributes
    // NPR5.51/SARA/20190904 CASE 366962 Added Page Action 'Shelf Labels'
    // NPR5.53/MHA /20191113  CASE 374721 Updated Page Caption
    // NPR5.55/YAHA/20200303 CASE 393483 Added ondrilldown functionality to ItemAvlByLocation(New field)
    // NPR5.55/YAHA/20200818 CASE 418943 Added filters for the drill down options

    Caption = 'Retail Item List';
    CardPageID = "Retail Item Card";
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Reports,Manage,Retail,Magento';
    SourceTable = Item;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                Editable = false;
                ShowCaption = false;
                field("No.";"No.")
                {
                }
                field(Description;Description)
                {
                }
                field("Description 2";"Description 2")
                {
                }
                field("Created From Nonstock Item";"Created From Nonstock Item")
                {
                    Visible = false;
                }
                field("Base Unit of Measure";"Base Unit of Measure")
                {
                }
                field("Shelf No.";"Shelf No.")
                {
                    Visible = false;
                }
                field("Costing Method";"Costing Method")
                {
                    Visible = false;
                }
                field("Standard Cost";"Standard Cost")
                {
                    Visible = false;
                }
                field("Unit Cost";"Unit Cost")
                {
                }
                field("Last Direct Cost";"Last Direct Cost")
                {
                    Visible = false;
                }
                field("Price/Profit Calculation";"Price/Profit Calculation")
                {
                    Visible = false;
                }
                field("Item Group";"Item Group")
                {
                }
                field(ItemGroupDesc;ItemGroupDesc)
                {
                    Caption = 'Item Group Description';
                }
                field("Ticket Type";"Ticket Type")
                {
                }
                field("Profit %";"Profit %")
                {
                    Visible = false;
                }
                field("Magento Item";"Magento Item")
                {
                }
                field("Item Status";"Item Status")
                {
                }
                field("Unit Price";"Unit Price")
                {
                }
                field("Unit List Price";"Unit List Price")
                {
                }
                field("Inventory Posting Group";"Inventory Posting Group")
                {
                    Visible = false;
                }
                field(Inventory;Inventory)
                {
                }
                field(ItemAvlByLocation;ItemAvlByLocation)
                {
                    Caption = 'Inv availability by location';
                    DecimalPlaces = 2:2;

                    trigger OnDrillDown()
                    begin
                        //-NPR5.55 [393483]
                        ItemFilter.Reset;
                        ItemFilter.SetRange("No.","No.");
                        //-NPR5.55 [418943]
                        if "Global Dimension 1 Filter" <> '' then
                          ItemFilter.SetRange("Global Dimension 1 Filter","Global Dimension 1 Filter");
                        if "Global Dimension 2 Filter" <> '' then
                          ItemFilter.SetRange("Global Dimension 2 Filter","Global Dimension 2 Filter");
                        if "Location Filter" <>  '' then
                          ItemFilter.SetRange("Location Filter","Location Filter");
                        if "Drop Shipment Filter"  then
                          ItemFilter.SetRange("Drop Shipment Filter","Drop Shipment Filter");
                        if "Variant Filter" <>  '' then
                          ItemFilter.SetRange("Variant Filter","Variant Filter");
                        //+NPR5.55 [418943]
                        PAGE.Run(PAGE::"Item Availability by Location",ItemFilter);
                        //+NPR5.55 [393483]
                    end;
                }
                field("Gen. Prod. Posting Group";"Gen. Prod. Posting Group")
                {
                    Visible = false;
                }
                field("VAT Prod. Posting Group";"VAT Prod. Posting Group")
                {
                    Visible = false;
                }
                field("Item Disc. Group";"Item Disc. Group")
                {
                    Visible = false;
                }
                field("Vendor No.";"Vendor No.")
                {
                }
                field("Vendor Item No.";"Vendor Item No.")
                {
                    Visible = false;
                }
                field("Label Barcode";"Label Barcode")
                {
                    Visible = false;
                }
                field(Season;Season)
                {
                    Visible = false;
                }
                field("Item Brand";"Item Brand")
                {
                    Visible = false;
                }
                field("Tariff No.";"Tariff No.")
                {
                    Visible = false;
                }
                field("Search Description";"Search Description")
                {
                }
                field("Overhead Rate";"Overhead Rate")
                {
                    Visible = false;
                }
                field("Indirect Cost %";"Indirect Cost %")
                {
                    Visible = false;
                }
                field("Item Category Code";"Item Category Code")
                {
                    Visible = false;
                }
                field(Blocked;Blocked)
                {
                    Visible = false;
                }
                field("Last Date Modified";"Last Date Modified")
                {
                    Visible = false;
                }
                field("Sales Unit of Measure";"Sales Unit of Measure")
                {
                    Visible = false;
                }
                field("Replenishment System";"Replenishment System")
                {
                    Visible = false;
                }
                field("Purch. Unit of Measure";"Purch. Unit of Measure")
                {
                    Visible = false;
                }
                field("Lead Time Calculation";"Lead Time Calculation")
                {
                    Visible = false;
                }
                field("Manufacturing Policy";"Manufacturing Policy")
                {
                    Visible = false;
                }
                field("Flushing Method";"Flushing Method")
                {
                    Visible = false;
                }
                field("Assembly Policy";"Assembly Policy")
                {
                    Visible = false;
                }
                field("Item Tracking Code";"Item Tracking Code")
                {
                    Visible = false;
                }
                field("Global Dimension 1 Code";"Global Dimension 1 Code")
                {
                    Visible = false;
                }
                field("Global Dimension 2 Code";"Global Dimension 2 Code")
                {
                    Visible = false;
                }
                field("Units per Parcel";"Units per Parcel")
                {
                    Visible = false;
                }
                field(NPRAttrTextArray_01;NPRAttrTextArray[1])
                {
                    CaptionClass = '6014555,27,1,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible01;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Item, 1, "No.", NPRAttrTextArray[1]);
                    end;
                }
                field(NPRAttrTextArray_02;NPRAttrTextArray[2])
                {
                    CaptionClass = '6014555,27,2,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible02;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Item, 2, "No.", NPRAttrTextArray[2]);
                    end;
                }
                field(NPRAttrTextArray_03;NPRAttrTextArray[3])
                {
                    CaptionClass = '6014555,27,3,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible03;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Item, 3, "No.", NPRAttrTextArray[3]);
                    end;
                }
                field(NPRAttrTextArray_04;NPRAttrTextArray[4])
                {
                    CaptionClass = '6014555,27,4,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible04;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Item, 4, "No.", NPRAttrTextArray[4]);
                    end;
                }
                field(NPRAttrTextArray_05;NPRAttrTextArray[5])
                {
                    CaptionClass = '6014555,27,5,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible05;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Item, 5, "No.", NPRAttrTextArray[5]);
                    end;
                }
                field(NPRAttrTextArray_06;NPRAttrTextArray[6])
                {
                    CaptionClass = '6014555,27,6,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible06;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Item, 6, "No.", NPRAttrTextArray[6]);
                    end;
                }
                field(NPRAttrTextArray_07;NPRAttrTextArray[7])
                {
                    CaptionClass = '6014555,27,7,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible07;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Item, 7, "No.", NPRAttrTextArray[7]);
                    end;
                }
                field(NPRAttrTextArray_08;NPRAttrTextArray[8])
                {
                    CaptionClass = '6014555,27,8,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible08;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Item, 8, "No.", NPRAttrTextArray[8]);
                    end;
                }
                field(NPRAttrTextArray_09;NPRAttrTextArray[9])
                {
                    CaptionClass = '6014555,27,9,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible09;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Item, 9, "No.", NPRAttrTextArray[9]);
                    end;
                }
                field(NPRAttrTextArray_10;NPRAttrTextArray[10])
                {
                    CaptionClass = '6014555,27,10,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible10;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue (DATABASE::Item, 10, "No.", NPRAttrTextArray[10]);
                    end;
                }
            }
        }
        area(factboxes)
        {
            part(Control6150628;"NP Attributes FactBox")
            {
                SubPageLink = "No."=FIELD("No.");
            }
            part("Item Availability FactBox";"NPR Item Availability FactBox")
            {
                Caption = 'Item Availability FactBox';
                SubPageLink = "No."=FIELD("No."),
                              "Date Filter"=FIELD("Date Filter"),
                              "Global Dimension 1 Filter"=FIELD("Global Dimension 1 Filter"),
                              "Global Dimension 2 Filter"=FIELD("Global Dimension 1 Filter"),
                              "Location Filter"=FIELD("Location Filter"),
                              "Drop Shipment Filter"=FIELD("Drop Shipment Filter"),
                              "Bin Filter"=FIELD("Bin Filter"),
                              "Variant Filter"=FIELD("Variant Filter"),
                              "Lot No. Filter"=FIELD("Lot No. Filter"),
                              "Serial No. Filter"=FIELD("Serial No. Filter");
            }
            part(Control1901314507;"Item Invoicing FactBox")
            {
                SubPageLink = "No."=FIELD("No."),
                              "Date Filter"=FIELD("Date Filter"),
                              "Global Dimension 1 Filter"=FIELD("Global Dimension 1 Filter"),
                              "Global Dimension 2 Filter"=FIELD("Global Dimension 1 Filter"),
                              "Location Filter"=FIELD("Location Filter"),
                              "Drop Shipment Filter"=FIELD("Drop Shipment Filter"),
                              "Bin Filter"=FIELD("Bin Filter"),
                              "Variant Filter"=FIELD("Variant Filter"),
                              "Lot No. Filter"=FIELD("Lot No. Filter"),
                              "Serial No. Filter"=FIELD("Serial No. Filter");
                Visible = true;
            }
            part(Control1903326807;"Item Replenishment FactBox")
            {
                SubPageLink = "No."=FIELD("No."),
                              "Date Filter"=FIELD("Date Filter"),
                              "Global Dimension 1 Filter"=FIELD("Global Dimension 1 Filter"),
                              "Global Dimension 2 Filter"=FIELD("Global Dimension 1 Filter"),
                              "Location Filter"=FIELD("Location Filter"),
                              "Drop Shipment Filter"=FIELD("Drop Shipment Filter"),
                              "Bin Filter"=FIELD("Bin Filter"),
                              "Variant Filter"=FIELD("Variant Filter"),
                              "Lot No. Filter"=FIELD("Lot No. Filter"),
                              "Serial No. Filter"=FIELD("Serial No. Filter");
                Visible = false;
            }
            part(Control1906840407;"Item Planning FactBox")
            {
                SubPageLink = "No."=FIELD("No."),
                              "Date Filter"=FIELD("Date Filter"),
                              "Global Dimension 1 Filter"=FIELD("Global Dimension 1 Filter"),
                              "Global Dimension 2 Filter"=FIELD("Global Dimension 1 Filter"),
                              "Location Filter"=FIELD("Location Filter"),
                              "Drop Shipment Filter"=FIELD("Drop Shipment Filter"),
                              "Bin Filter"=FIELD("Bin Filter"),
                              "Variant Filter"=FIELD("Variant Filter"),
                              "Lot No. Filter"=FIELD("Lot No. Filter"),
                              "Serial No. Filter"=FIELD("Serial No. Filter");
                Visible = true;
            }
            part(Control1901796907;"Item Warehouse FactBox")
            {
                SubPageLink = "No."=FIELD("No."),
                              "Date Filter"=FIELD("Date Filter"),
                              "Global Dimension 1 Filter"=FIELD("Global Dimension 1 Filter"),
                              "Global Dimension 2 Filter"=FIELD("Global Dimension 1 Filter"),
                              "Location Filter"=FIELD("Location Filter"),
                              "Drop Shipment Filter"=FIELD("Drop Shipment Filter"),
                              "Bin Filter"=FIELD("Bin Filter"),
                              "Variant Filter"=FIELD("Variant Filter"),
                              "Lot No. Filter"=FIELD("Lot No. Filter"),
                              "Serial No. Filter"=FIELD("Serial No. Filter");
                Visible = false;
            }
            part("Discount FactBox";"Discount FactBox")
            {
                Caption = 'Discounts';
                SubPageLink = "No."=FIELD("No.");
            }
            part(ItemAttributesFactBox;"Item Attributes Factbox")
            {
                ApplicationArea = Basic,Suite;
            }
            systempart(Control1900383207;Links)
            {
                Visible = true;
            }
            systempart(Control1905767507;Notes)
            {
                Visible = true;
            }
            part(Picture;"Magento Item Picture Factbox")
            {
                Caption = 'Picture';
                ShowFilter = false;
                SubPageLink = "No."=FIELD("No.");
                Visible = MagentoEnabled;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Availability)
            {
                Caption = 'Availability';
                Image = Item;
                action("Items b&y Location")
                {
                    Caption = 'Items b&y Location';
                    Image = ItemAvailbyLoc;

                    trigger OnAction()
                    var
                        ItemsByLocation: Page "Items by Location";
                    begin
                        ItemsByLocation.SetRecord(Rec);
                        ItemsByLocation.Run;
                    end;
                }
                group("&Item Availability by")
                {
                    Caption = '&Item Availability by';
                    Image = ItemAvailability;
                    action("<Action5>")
                    {
                        Caption = 'Event';
                        Image = "Event";

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItem(Rec,ItemAvailFormsMgt.ByEvent);
                        end;
                    }
                    action(Period)
                    {
                        Caption = 'Period';
                        Image = Period;
                        RunObject = Page "Item Availability by Periods";
                        RunPageLink = "No."=FIELD("No."),
                                      "Global Dimension 1 Filter"=FIELD("Global Dimension 1 Filter"),
                                      "Global Dimension 2 Filter"=FIELD("Global Dimension 2 Filter"),
                                      "Location Filter"=FIELD("Location Filter"),
                                      "Drop Shipment Filter"=FIELD("Drop Shipment Filter"),
                                      "Variant Filter"=FIELD("Variant Filter");
                    }
                    action(Variant)
                    {
                        Caption = 'Variant';
                        Image = ItemVariant;
                        RunObject = Page "Item Availability by Variant";
                        RunPageLink = "No."=FIELD("No."),
                                      "Global Dimension 1 Filter"=FIELD("Global Dimension 1 Filter"),
                                      "Global Dimension 2 Filter"=FIELD("Global Dimension 2 Filter"),
                                      "Location Filter"=FIELD("Location Filter"),
                                      "Drop Shipment Filter"=FIELD("Drop Shipment Filter"),
                                      "Variant Filter"=FIELD("Variant Filter");
                    }
                    action(Location)
                    {
                        Caption = 'Location';
                        Image = Warehouse;
                        Promoted = true;
                        PromotedCategory = Process;
                        PromotedIsBig = true;
                        RunObject = Page "Item Availability by Location";
                        RunPageLink = "No."=FIELD("No."),
                                      "Global Dimension 1 Filter"=FIELD("Global Dimension 1 Filter"),
                                      "Global Dimension 2 Filter"=FIELD("Global Dimension 2 Filter"),
                                      "Location Filter"=FIELD("Location Filter"),
                                      "Drop Shipment Filter"=FIELD("Drop Shipment Filter"),
                                      "Variant Filter"=FIELD("Variant Filter");
                    }
                    action("BOM Level")
                    {
                        Caption = 'BOM Level';
                        Image = BOMLevel;

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItem(Rec,ItemAvailFormsMgt.ByBOM);
                        end;
                    }
                    action(Timeline)
                    {
                        Caption = 'Timeline';
                        Image = Timeline;

                        trigger OnAction()
                        begin
                            ShowTimelineFromItem(Rec);
                        end;
                    }
                    action(RetailInventorySet)
                    {
                        Caption = 'Retail Inventory Set';
                        Image = Intercompany;
                        Visible = RetailInventoryEnabled;

                        trigger OnAction()
                        var
                            RetailInventorySetMgt: Codeunit "RIS Retail Inventory Set Mgt.";
                        begin
                            //-NPR5.40 [307025]
                            RetailInventorySetMgt.RunProcessInventorySet(Rec);
                            //+NPR5.40 [307025]
                        end;
                    }
                }
            }
            group("Master Data")
            {
                Caption = 'Master Data';
                Image = DataEntry;
                action("&Units of Measure")
                {
                    Caption = '&Units of Measure';
                    Image = UnitOfMeasure;
                    RunObject = Page "Item Units of Measure";
                    RunPageLink = "Item No."=FIELD("No.");
                }
                action(Attributes)
                {
                    AccessByPermission = TableData "Item Attribute"=R;
                    ApplicationArea = Advanced;
                    Caption = 'Attributes';
                    Image = Category;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Category4;
                    Scope = Repeater;
                    ToolTip = 'View or edit the item''s attributes, such as color, size, or other characteristics that help to describe the item.';

                    trigger OnAction()
                    begin
                        //-#361229 [361229]
                        PAGE.RunModal(PAGE::"Item Attribute Value Editor",Rec);
                        CurrPage.SaveRecord;
                        CurrPage.ItemAttributesFactBox.PAGE.LoadItemAttributesData("No.");
                        //+#361229 [361229]
                    end;
                }
                action("Va&riants")
                {
                    Caption = 'Va&riants';
                    Image = ItemVariant;
                    RunObject = Page "Item Variants";
                    RunPageLink = "Item No."=FIELD("No.");
                }
                group(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    action("Dimensions-Single")
                    {
                        Caption = 'Dimensions-Single';
                        Image = Dimensions;
                        RunObject = Page "Default Dimensions";
                        RunPageLink = "Table ID"=CONST(27),
                                      "No."=FIELD("No.");
                        ShortCutKey = 'Shift+Ctrl+D';
                    }
                    action("Dimensions-&Multiple")
                    {
                        Caption = 'Dimensions-&Multiple';
                        Image = DimensionSets;

                        trigger OnAction()
                        var
                            Item: Record Item;
                            DefaultDimMultiple: Page "Default Dimensions-Multiple";
                        begin
                            CurrPage.SetSelectionFilter(Item);
                            //-NPR5.50 [353381]
                            //DefaultDimMultiple.SetMultiItem(Item);
                            DefaultDimMultiple.SetMultiRecord(Item,Item.FieldNo("No. 2"));
                            //+NPR5.50 [353381]
                            DefaultDimMultiple.RunModal;
                        end;
                    }
                }
                action("Substituti&ons")
                {
                    Caption = 'Substituti&ons';
                    Image = ItemSubstitution;
                    RunObject = Page "Item Substitution Entry";
                    RunPageLink = Type=CONST(Item),
                                  "No."=FIELD("No.");
                }
                action("Cross Re&ferences")
                {
                    Caption = 'Cross Re&ferences';
                    Image = Change;
                    RunObject = Page "Item Cross Reference Entries";
                    RunPageLink = "Item No."=FIELD("No.");
                }
                action("E&xtended Texts")
                {
                    Caption = 'E&xtended Texts';
                    Image = Text;
                    RunObject = Page "Extended Text List";
                    RunPageLink = "Table Name"=CONST(Item),
                                  "No."=FIELD("No.");
                    RunPageView = SORTING("Table Name","No.","Language Code","All Language Codes","Starting Date","Ending Date");
                }
                action(Translations)
                {
                    Caption = 'Translations';
                    Image = Translations;
                    RunObject = Page "Item Translations";
                    RunPageLink = "Item No."=FIELD("No."),
                                  "Variant Code"=CONST('');
                }
                action("&Picture")
                {
                    Caption = '&Picture';
                    Image = Picture;
                    RunObject = Page "Item Picture";
                    RunPageLink = "No."=FIELD("No."),
                                  "Date Filter"=FIELD("Date Filter"),
                                  "Global Dimension 1 Filter"=FIELD("Global Dimension 1 Filter"),
                                  "Global Dimension 2 Filter"=FIELD("Global Dimension 2 Filter"),
                                  "Location Filter"=FIELD("Location Filter"),
                                  "Drop Shipment Filter"=FIELD("Drop Shipment Filter"),
                                  "Variant Filter"=FIELD("Variant Filter");
                }
                action(Identifiers)
                {
                    Caption = 'Identifiers';
                    Image = BarCode;
                    RunObject = Page "Item Identifiers";
                    RunPageLink = "Item No."=FIELD("No.");
                    RunPageView = SORTING("Item No.","Variant Code","Unit of Measure Code");
                }
            }
            group("Assembly/Production")
            {
                Caption = 'Assembly/Production';
                Image = Production;
                action(Structure)
                {
                    Caption = 'Structure';
                    Image = Hierarchy;

                    trigger OnAction()
                    var
                        BOMStructure: Page "BOM Structure";
                    begin
                        BOMStructure.InitItem(Rec);
                        BOMStructure.Run;
                    end;
                }
                action("Cost Shares")
                {
                    Caption = 'Cost Shares';
                    Image = CostBudget;

                    trigger OnAction()
                    var
                        BOMCostShares: Page "BOM Cost Shares";
                    begin
                        BOMCostShares.InitItem(Rec);
                        BOMCostShares.Run;
                    end;
                }
                group("Assemb&ly")
                {
                    Caption = 'Assemb&ly';
                    Image = AssemblyBOM;
                    action("<Action32>")
                    {
                        Caption = 'Assembly BOM';
                        Image = BOM;
                        RunObject = Page "Assembly BOM";
                        RunPageLink = "Parent Item No."=FIELD("No.");
                    }
                    action("Where-Used")
                    {
                        Caption = 'Where-Used';
                        Image = Track;
                        RunObject = Page "Where-Used List";
                        RunPageLink = Type=CONST(Item),
                                      "No."=FIELD("No.");
                        RunPageView = SORTING(Type,"No.");
                    }
                    action("Calc. Stan&dard Cost")
                    {
                        Caption = 'Calc. Stan&dard Cost';
                        Image = CalculateCost;

                        trigger OnAction()
                        begin
                            CalculateStdCost.CalcItem("No.",true);
                        end;
                    }
                    action("Calc. Unit Price")
                    {
                        Caption = 'Calc. Unit Price';
                        Image = SuggestItemPrice;

                        trigger OnAction()
                        begin
                            CalculateStdCost.CalcAssemblyItemPrice("No.");
                        end;
                    }
                }
                group(Production)
                {
                    Caption = 'Production';
                    Image = Production;
                    action("Production BOM")
                    {
                        Caption = 'Production BOM';
                        Image = BOM;
                        RunObject = Page "Production BOM";
                        RunPageLink = "No."=FIELD("No.");
                    }
                    action(Action29)
                    {
                        Caption = 'Where-Used';
                        Image = "Where-Used";

                        trigger OnAction()
                        var
                            ProdBOMWhereUsed: Page "Prod. BOM Where-Used";
                        begin
                            ProdBOMWhereUsed.SetItem(Rec,WorkDate);
                            ProdBOMWhereUsed.RunModal;
                        end;
                    }
                    action(Action24)
                    {
                        Caption = 'Calc. Stan&dard Cost';
                        Image = CalculateCost;

                        trigger OnAction()
                        begin
                            CalculateStdCost.CalcItem("No.",false);
                        end;
                    }
                }
            }
            group(History)
            {
                Caption = 'History';
                Image = History;
                group("E&ntries")
                {
                    Caption = 'E&ntries';
                    Image = Entries;
                    action("Ledger E&ntries")
                    {
                        Caption = 'Ledger E&ntries';
                        Image = ItemLedger;
                        Promoted = false;
                        //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                        //PromotedCategory = Process;
                        RunObject = Page "Item Ledger Entries";
                        RunPageLink = "Item No."=FIELD("No.");
                        RunPageView = SORTING("Item No.");
                        ShortCutKey = 'Ctrl+F7';
                    }
                    action("&Reservation Entries")
                    {
                        Caption = '&Reservation Entries';
                        Image = ReservationLedger;
                        RunObject = Page "Reservation Entries";
                        RunPageLink = "Reservation Status"=CONST(Reservation),
                                      "Item No."=FIELD("No.");
                        RunPageView = SORTING("Item No.","Variant Code","Location Code","Reservation Status");
                    }
                    action("&Phys. Inventory Ledger Entries")
                    {
                        Caption = '&Phys. Inventory Ledger Entries';
                        Image = PhysicalInventoryLedger;
                        RunObject = Page "Phys. Inventory Ledger Entries";
                        RunPageLink = "Item No."=FIELD("No.");
                        RunPageView = SORTING("Item No.");
                    }
                    action("&Value Entries")
                    {
                        Caption = '&Value Entries';
                        Image = ValueLedger;
                        RunObject = Page "Value Entries";
                        RunPageLink = "Item No."=FIELD("No.");
                        RunPageView = SORTING("Item No.");
                    }
                    action("Item &Tracking Entries")
                    {
                        Caption = 'Item &Tracking Entries';
                        Image = ItemTrackingLedger;

                        trigger OnAction()
                        var
                            ItemTrackingMgt: Codeunit "Item Tracking Management";
                        begin
                            //-NPR4.17
                            //ItemTrackingMgt.CallItemTrackingEntryForm(3,'',"No.",'','','','');
                            //+NPR4.17
                        end;
                    }
                    action("&Warehouse Entries")
                    {
                        Caption = '&Warehouse Entries';
                        Image = BinLedger;
                        RunObject = Page "Warehouse Entries";
                        RunPageLink = "Item No."=FIELD("No.");
                        RunPageView = SORTING("Item No.","Bin Code","Location Code","Variant Code","Unit of Measure Code","Lot No.","Serial No.","Entry Type",Dedicated);
                    }
                    action(POSSalesEntries)
                    {
                        Caption = 'POS Sales Entries';
                        Image = Entries;
                    }
                    action(PriceLog)
                    {
                        Caption = 'Retail Price Log Entries';
                        Image = Log;
                        RunObject = Page "Retail Price Log Entries";
                        RunPageLink = "Item No."=FIELD("No.");
                    }
                }
                group(Statistics)
                {
                    Caption = 'Statistics';
                    Image = Statistics;
                    action(Action16)
                    {
                        Caption = 'Statistics';
                        Image = Statistics;
                        Promoted = true;
                        PromotedCategory = Process;
                        ShortCutKey = 'F7';

                        trigger OnAction()
                        var
                            ItemStatistics: Page "Item Statistics";
                        begin
                            ItemStatistics.SetItem(Rec);
                            ItemStatistics.RunModal;
                        end;
                    }
                    action("Entry Statistics")
                    {
                        Caption = 'Entry Statistics';
                        Image = EntryStatistics;
                        RunObject = Page "Item Entry Statistics";
                        RunPageLink = "No."=FIELD("No."),
                                      "Date Filter"=FIELD("Date Filter"),
                                      "Global Dimension 1 Filter"=FIELD("Global Dimension 1 Filter"),
                                      "Global Dimension 2 Filter"=FIELD("Global Dimension 2 Filter"),
                                      "Location Filter"=FIELD("Location Filter"),
                                      "Drop Shipment Filter"=FIELD("Drop Shipment Filter"),
                                      "Variant Filter"=FIELD("Variant Filter");
                    }
                    action("T&urnover")
                    {
                        Caption = 'T&urnover';
                        Image = Turnover;
                        RunObject = Page "Item Turnover";
                        RunPageLink = "No."=FIELD("No."),
                                      "Global Dimension 1 Filter"=FIELD("Global Dimension 1 Filter"),
                                      "Global Dimension 2 Filter"=FIELD("Global Dimension 2 Filter"),
                                      "Location Filter"=FIELD("Location Filter"),
                                      "Drop Shipment Filter"=FIELD("Drop Shipment Filter"),
                                      "Variant Filter"=FIELD("Variant Filter");
                    }
                }
                action("Co&mments")
                {
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name"=CONST(Item),
                                  "No."=FIELD("No.");
                }
            }
            group("S&ales")
            {
                Caption = 'S&ales';
                Image = Sales;
                action(Prices)
                {
                    Caption = 'Prices';
                    Image = Price;
                    RunObject = Page "Sales Prices";
                    RunPageLink = "Item No."=FIELD("No.");
                    RunPageView = SORTING("Item No.");
                }
                action("Line Discounts")
                {
                    Caption = 'Line Discounts';
                    Image = LineDiscount;
                    RunObject = Page "Sales Line Discounts";
                    RunPageLink = Type=CONST(Item),
                                  Code=FIELD("No.");
                    RunPageView = SORTING(Type,Code);
                }
                action("Prepa&yment Percentages")
                {
                    Caption = 'Prepa&yment Percentages';
                    Image = PrepaymentPercentages;
                    RunObject = Page "Sales Prepayment Percentages";
                    RunPageLink = "Item No."=FIELD("No.");
                }
                action(Orders)
                {
                    Caption = 'Orders';
                    Image = Document;
                    RunObject = Page "Sales Orders";
                    RunPageLink = Type=CONST(Item),
                                  "No."=FIELD("No.");
                    RunPageView = SORTING("Document Type",Type,"No.");
                }
                action("Returns Orders")
                {
                    Caption = 'Returns Orders';
                    Image = ReturnOrder;
                    RunObject = Page "Sales Return Orders";
                    RunPageLink = Type=CONST(Item),
                                  "No."=FIELD("No.");
                    RunPageView = SORTING("Document Type",Type,"No.");
                }
                action("Recommended Items")
                {
                    Caption = 'Recommended Items';
                    Image = SuggestLines;
                    RunObject = Page "MCS Recommendations Lines";
                    RunPageLink = "Seed Item No."=FIELD("No."),
                                  "Table No."=CONST(27);
                }
            }
            group("&Purchases")
            {
                Caption = '&Purchases';
                Image = Purchasing;
                action("Ven&dors")
                {
                    Caption = 'Ven&dors';
                    Image = Vendor;
                    RunObject = Page "Item Vendor Catalog";
                    RunPageLink = "Item No."=FIELD("No.");
                    RunPageView = SORTING("Item No.");
                }
                action(Action39)
                {
                    Caption = 'Prices';
                    Image = Price;
                    RunObject = Page "Purchase Prices";
                    RunPageLink = "Item No."=FIELD("No.");
                    RunPageView = SORTING("Item No.");
                }
                action(Action42)
                {
                    Caption = 'Line Discounts';
                    Image = LineDiscount;
                    RunObject = Page "Purchase Line Discounts";
                    RunPageLink = "Item No."=FIELD("No.");
                    RunPageView = SORTING("Item No.");
                }
                action(Action125)
                {
                    Caption = 'Prepa&yment Percentages';
                    Image = PrepaymentPercentages;
                    RunObject = Page "Purchase Prepmt. Percentages";
                    RunPageLink = "Item No."=FIELD("No.");
                }
                action(Action40)
                {
                    Caption = 'Orders';
                    Image = Document;
                    RunObject = Page "Purchase Orders";
                    RunPageLink = Type=CONST(Item),
                                  "No."=FIELD("No.");
                    RunPageView = SORTING("Document Type",Type,"No.");
                }
                action("Return Orders")
                {
                    Caption = 'Return Orders';
                    Image = ReturnOrder;
                    RunObject = Page "Purchase Return Orders";
                    RunPageLink = Type=CONST(Item),
                                  "No."=FIELD("No.");
                    RunPageView = SORTING("Document Type",Type,"No.");
                }
                action("Nonstoc&k Items")
                {
                    Caption = 'Nonstoc&k Items';
                    Image = NonStockItem;
                    RunObject = Page "Catalog Item List";
                }
            }
            group(Warehouse)
            {
                Caption = 'Warehouse';
                Image = Warehouse;
                action("&Bin Contents")
                {
                    Caption = '&Bin Contents';
                    Image = BinContent;
                    RunObject = Page "Item Bin Contents";
                    RunPageLink = "Item No."=FIELD("No.");
                    RunPageView = SORTING("Item No.");
                }
                action("Stockkeepin&g Units")
                {
                    Caption = 'Stockkeepin&g Units';
                    Image = SKU;
                    RunObject = Page "Stockkeeping Unit List";
                    RunPageLink = "Item No."=FIELD("No.");
                    RunPageView = SORTING("Item No.");
                }
            }
            group(Service)
            {
                Caption = 'Service';
                Image = ServiceItem;
                action("Ser&vice Items")
                {
                    Caption = 'Ser&vice Items';
                    Image = ServiceItem;
                    RunObject = Page "Service Items";
                    RunPageLink = "Item No."=FIELD("No.");
                    RunPageView = SORTING("Item No.");
                }
                action(Troubleshooting)
                {
                    Caption = 'Troubleshooting';
                    Image = Troubleshoot;

                    trigger OnAction()
                    var
                        TroubleshootingHeader: Record "Troubleshooting Header";
                    begin
                        TroubleshootingHeader.ShowForItem(Rec);
                    end;
                }
                action("Troubleshooting Setup")
                {
                    Caption = 'Troubleshooting Setup';
                    Image = Troubleshoot;
                    RunObject = Page "Troubleshooting Setup";
                    RunPageLink = Type=CONST(Item),
                                  "No."=FIELD("No.");
                }
            }
            group(Resources)
            {
                Caption = 'Resources';
                Image = Resource;
                group("R&esource")
                {
                    Caption = 'R&esource';
                    Image = Resource;
                    action("Resource &Skills")
                    {
                        Caption = 'Resource &Skills';
                        Image = ResourceSkills;
                        RunObject = Page "Resource Skills";
                        RunPageLink = Type=CONST(Item),
                                      "No."=FIELD("No.");
                    }
                    action("Skilled R&esources")
                    {
                        Caption = 'Skilled R&esources';
                        Image = ResourceSkills;

                        trigger OnAction()
                        var
                            ResourceSkill: Record "Resource Skill";
                        begin
                            Clear(SkilledResourceList);
                            SkilledResourceList.Initialize(ResourceSkill.Type::Item,"No.",Description);
                            SkilledResourceList.RunModal;
                        end;
                    }
                }
            }
            group(Magento)
            {
                Caption = 'Magento';
                action(Pictures)
                {
                    Caption = 'Pictures';
                    Image = Picture;
                    Promoted = true;
                    PromotedCategory = Category6;
                    Visible = MagentoEnabled;

                    trigger OnAction()
                    var
                        MagentoVariantPictureList: Page "Magento Item Picture List";
                    begin
                        //-MAG1.21
                        TestField("No.");
                        //CLEAR(MagentoVariantPictureList);
                        FilterGroup(2);
                        MagentoVariantPictureList.SetItemNo("No.");
                        FilterGroup(0);

                        MagentoVariantPictureList.Run();
                        //+MAG1.21
                    end;
                }
                action(Webshops)
                {
                    Caption = 'Webshops';
                    Image = Web;
                    Promoted = true;
                    PromotedCategory = Category6;
                    Visible = MagentoEnabled AND MagentoEnabledMultistore;

                    trigger OnAction()
                    var
                        MagentoStoreItem: Record "Magento Store Item";
                        MagentoItemMgt: Codeunit "Magento Item Mgt.";
                    begin
                        //-MAG1.21
                        MagentoItemMgt.SetupMultiStoreData(Rec);
                        MagentoStoreItem.FilterGroup(0);
                        MagentoStoreItem.SetRange("Item No.","No.");
                        MagentoStoreItem.FilterGroup(2);
                        PAGE.Run(PAGE::"Magento Store Items",MagentoStoreItem);
                        //+MAG1.21
                    end;
                }
                action(DisplayConfig)
                {
                    Caption = 'Display Config';
                    Image = ViewPage;
                    Promoted = true;
                    PromotedCategory = Category6;
                    Visible = MagentoEnabled AND MagentoEnabledDisplayConfig;

                    trigger OnAction()
                    var
                        MagentoDisplayConfigPage: Page "Magento Display Config";
                        MagentoDisplayConfig: Record "Magento Display Config";
                    begin
                        //-MAG1.21
                        MagentoDisplayConfig.SetRange(MagentoDisplayConfig."No.","No.");
                        MagentoDisplayConfig.SetRange(Type,MagentoDisplayConfig.Type::Item);
                        MagentoDisplayConfigPage.SetTableView(MagentoDisplayConfig);
                        MagentoDisplayConfigPage.Run;
                        //+MAG1.21
                    end;
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("&Create Stockkeeping Unit")
                {
                    Caption = '&Create Stockkeeping Unit';
                    Image = CreateSKU;

                    trigger OnAction()
                    var
                        Item: Record Item;
                    begin
                        Item.SetRange("No.","No.");
                        REPORT.RunModal(REPORT::"Create Stockkeeping Unit",true,false,Item);
                    end;
                }
                action("C&alculate Counting Period")
                {
                    Caption = 'C&alculate Counting Period';
                    Image = CalculateCalendar;

                    trigger OnAction()
                    var
                        PhysInvtCountMgt: Codeunit "Phys. Invt. Count.-Management";
                    begin
                        PhysInvtCountMgt.UpdateItemPhysInvtCount(Rec);
                    end;
                }
            }
            group(Print)
            {
                Caption = 'Print';
                action("Price Label")
                {
                    Caption = 'Price Label';
                    Image = BinLedger;
                    Promoted = true;
                    PromotedCategory = Category5;
                    ShortCutKey = 'Ctrl+Alt+L';

                    trigger OnAction()
                    var
                        ItemRec: Record Item;
                        LabelLibrary: Codeunit "Label Library";
                        ReportSelectionRetail: Record "Report Selection Retail";
                    begin
                        ItemRec := Rec;
                        ItemRec.SetRecFilter;
                        LabelLibrary.ResolveVariantAndPrintItem(ItemRec, ReportSelectionRetail."Report Type"::"Price Label");
                    end;
                }
                action("Shelf Label")
                {
                    Caption = 'Shelf Label';
                    Image = BinLedger;
                    Promoted = true;
                    PromotedCategory = Category5;
                    ShortCutKey = 'Ctrl+Alt+L';

                    trigger OnAction()
                    var
                        ItemRec: Record Item;
                        LabelLibrary: Codeunit "Label Library";
                        ReportSelectionRetail: Record "Report Selection Retail";
                    begin
                        //-NPR5.51 [366962]
                        ItemRec := Rec;
                        ItemRec.SetRecFilter;
                        LabelLibrary.ResolveVariantAndPrintItem(ItemRec, ReportSelectionRetail."Report Type"::"Shelf Label");
                        //+NPR5.51 [366962]
                    end;
                }
            }
            action(PageSalesPrices2)
            {
                Caption = 'Sales Prices';
                Image = SalesPrices;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Sales Prices";
                RunPageLink = "Item No."=FIELD("No.");
                RunPageView = SORTING("Item No.");
            }
            action(PageSalesLineDiscounts2)
            {
                Caption = 'Sales Line Discounts';
                Image = SalesLineDisc;
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                RunObject = Page "Sales Line Discounts";
                RunPageLink = Type=CONST(Item),
                              Code=FIELD("No.");
                RunPageView = SORTING(Type,Code);
            }
            action("Requisition Worksheet")
            {
                Caption = 'Requisition Worksheet';
                Image = Worksheet;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Req. Worksheet";
            }
            action("Item Journal")
            {
                Caption = 'Item Journal';
                Image = Journals;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Retail Item Journal";
            }
            action("Item Reclassification Journal")
            {
                Caption = 'Item Reclassification Journal';
                Image = Journals;
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                RunObject = Page "Retail Item Reclass. Journal";
            }
            action("Item Tracing")
            {
                Caption = 'Item Tracing';
                Image = ItemTracing;
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                RunObject = Page "Item Tracing";
            }
            action("Adjust Item Cost/Price")
            {
                Caption = 'Adjust Item Cost/Price';
                Image = AdjustItemCost;
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                RunObject = Report "Adjust Item Costs/Prices";
            }
            action("Adjust Cost - Item Entries")
            {
                Caption = 'Adjust Cost - Item Entries';
                Image = AdjustEntries;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Report "Adjust Cost - Item Entries";
            }
            action(SearchItem)
            {
                Caption = 'Search Item';
                Image = Find;
                ShortCutKey = 'Shift+Ctrl+S';

                trigger OnAction()
                var
                    InputDialog: Page "Input Dialog";
                    Validering: Text;
                    BarcodeLibrary: Codeunit "Barcode Library";
                    ItemNo: Code[20];
                    VariantCode: Code[10];
                    ResolvingTable: Integer;
                begin
                    //-NPR4.15
                    Clear(InputDialog);
                    InputDialog.SetInput(1,Validering,Text001);
                    InputDialog.LookupMode(true);
                    if InputDialog.RunModal <> ACTION::LookupOK then
                      exit;
                    InputDialog.InputText(1,Validering);

                    //-NPR5.29 [259398]
                    if BarcodeLibrary.TranslateBarcodeToItemVariant(Validering, ItemNo, VariantCode, ResolvingTable, true) then begin
                      Get(ItemNo);
                      exit;
                    end;

                    Error(Error_NoBarcodeMatch, Validering);

                    // AlternativeNo.SETRANGE(Type,AlternativeNo.Type::Item);
                    // AlternativeNo.SETRANGE("Alt. No.",Validering);
                    // //-NPR4.18
                    // //IF AlternativeNo.FINDFIRST THEN
                    // IF AlternativeNo.FINDFIRST THEN BEGIN
                    // //+NPR4.18
                    //  SETRANGE("No.",AlternativeNo.Code);
                    //  FINDFIRST;
                    //  SETRANGE("No.");
                    // //-NPR4.18
                    // END ELSE BEGIN
                    //  SETRANGE("Vendor Item No.",Validering);
                    //  FINDFIRST;
                    //  SETRANGE("Vendor Item No.");
                    // END;
                    //+NPR4.18
                    //+NPR4.15
                    //+NPR5.29 [259398]
                end;
            }
            action(FilterSearchItem)
            {
                Caption = 'Filter Search Items';
                Image = "Filter";

                trigger OnAction()
                var
                    InputDialog: Page "Input Dialog";
                    Validering: Text;
                    NPRAttItemSearch: Codeunit "NPR Att. Item Search";
                begin
                    //-NPR5.34
                    Clear(InputDialog);
                    InputDialog.SetInput(1,Validering,Text001);
                    InputDialog.LookupMode(true);
                    if InputDialog.RunModal <> ACTION::LookupOK then
                      exit;
                    InputDialog.InputText(1,Validering);

                    if not NPRAttItemSearch.SearchTextAttribute(Validering, '', Rec) then begin
                      Rec.MarkedOnly(false);
                      Error(Error_NoBarcodeMatch, Validering);
                    end else begin
                      Rec.MarkedOnly(true);
                    end;


                    //+NPR5.34
                end;
            }
            action(SetNPRAttributeFilter)
            {
                Caption = 'Set Client Attribute Filter';
                Image = "Filter";
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                Visible = NPRAttrVisible01 OR NPRAttrVisible02 OR NPRAttrVisible03 OR NPRAttrVisible04 OR NPRAttrVisible05 OR NPRAttrVisible06 OR NPRAttrVisible07 OR NPRAttrVisible08 OR NPRAttrVisible09 OR NPRAttrVisible10;

                trigger OnAction()
                var
                    NPRAttributeValueSet: Record "NPR Attribute Value Set";
                    NPRAttributeMgt: Codeunit "NPR Attribute Management";
                begin
                    //-NPR5.37 [293180]
                    if not NPRAttributeMgt.SetAttributeFilter(NPRAttributeValueSet) then
                      exit;

                    SetView(NPRAttributeMgt.GetAttributeFilterView(NPRAttributeValueSet,Rec));
                    //+NPR5.37 [293180]
                end;
            }
        }
        area(reporting)
        {
            action("Inventory - List")
            {
                Caption = 'Inventory - List';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Inventory - List";
            }
            action("Item Register - Quantity")
            {
                Caption = 'Item Register - Quantity';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Item Register - Quantity";
            }
            action("Inventory - Transaction Detail")
            {
                Caption = 'Inventory - Transaction Detail';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Inventory - Transaction Detail";
            }
            action("Inventory Availability")
            {
                Caption = 'Inventory Availability';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Inventory Availability";
            }
            action(Status)
            {
                Caption = 'Status';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report Status;
            }
            action("Inventory - Availability Plan")
            {
                Caption = 'Inventory - Availability Plan';
                Image = ItemAvailability;
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Inventory - Availability Plan";
            }
            action("Inventory Order Details")
            {
                Caption = 'Inventory Order Details';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Inventory Order Details";
            }
            action("Inventory Purchase Orders")
            {
                Caption = 'Inventory Purchase Orders';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Inventory Purchase Orders";
            }
            action("Inventory - Top 10 List")
            {
                Caption = 'Inventory - Top 10 List';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Inventory - Top 10 List";
            }
            action("Inventory - Sales Statistics")
            {
                Caption = 'Inventory - Sales Statistics';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Inventory - Sales Statistics";
            }
            action("Assemble to Order - Sales")
            {
                Caption = 'Assemble to Order - Sales';
                Image = "Report";
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Assemble to Order - Sales";
            }
            action("Inventory - Customer Sales")
            {
                Caption = 'Inventory - Customer Sales';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Inventory - Customer Sales";
            }
            action("Inventory - Vendor Purchases")
            {
                Caption = 'Inventory - Vendor Purchases';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Inventory - Vendor Purchases";
            }
            action("Price List")
            {
                Caption = 'Price List';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Price List";
            }
            action("Inventory Cost and Price List")
            {
                Caption = 'Inventory Cost and Price List';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Inventory Cost and Price List";
            }
            action("Inventory - Reorders")
            {
                Caption = 'Inventory - Reorders';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Inventory - Reorders";
            }
            action("Inventory - Sales Back Orders")
            {
                Caption = 'Inventory - Sales Back Orders';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Inventory - Sales Back Orders";
            }
            action("Item/Vendor Catalog")
            {
                Caption = 'Item/Vendor Catalog';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Item/Vendor Catalog";
            }
            action("Inventory - Cost Variance")
            {
                Caption = 'Inventory - Cost Variance';
                Image = ItemCosts;
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Inventory - Cost Variance";
            }
            action("Phys. Inventory List")
            {
                Caption = 'Phys. Inventory List';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Phys. Inventory List";
            }
            action("Inventory Valuation")
            {
                Caption = 'Inventory Valuation';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Inventory Valuation";
            }
            action("Nonstock Item Sales")
            {
                Caption = 'Nonstock Item Sales';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Catalog Item Sales";
            }
            action("Item Substitutions")
            {
                Caption = 'Item Substitutions';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Item Substitutions";
            }
            action("Invt. Valuation - Cost Spec.")
            {
                Caption = 'Invt. Valuation - Cost Spec.';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Invt. Valuation - Cost Spec.";
            }
            action("Inventory Valuation - WIP")
            {
                Caption = 'Inventory Valuation - WIP';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Inventory Valuation - WIP";
            }
            action("Item Register - Value")
            {
                Caption = 'Item Register - Value';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Item Register - Value";
            }
            action("Item Charges - Specification")
            {
                Caption = 'Item Charges - Specification';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Item Charges - Specification";
            }
            action("Item Age Composition - Qty.")
            {
                Caption = 'Item Age Composition - Qty.';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Item Age Composition - Qty.";
            }
            action("Item Age Composition - Value")
            {
                Caption = 'Item Age Composition - Value';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Item Age Composition - Value";
            }
            action("Item Expiration - Quantity")
            {
                Caption = 'Item Expiration - Quantity';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Item Expiration - Quantity";
            }
            action("Cost Shares Breakdown")
            {
                Caption = 'Cost Shares Breakdown';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Cost Shares Breakdown";
            }
            action("Detailed Calculation")
            {
                Caption = 'Detailed Calculation';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Detailed Calculation";
            }
            action("Rolled-up Cost Shares")
            {
                Caption = 'Rolled-up Cost Shares';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Rolled-up Cost Shares";
            }
            action("Single-Level Cost Shares")
            {
                Caption = 'Single-Level Cost Shares';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Single-level Cost Shares";
            }
            action("Where Used (Top Level)")
            {
                Caption = 'Where Used (Top Level)';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Where-Used (Top Level)";
            }
            action("Quantity Explosion of BOM")
            {
                Caption = 'Quantity Explosion of BOM';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Quantity Explosion of BOM";
            }
            action("Compare List")
            {
                Caption = 'Compare List';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Compare List";
            }
        }
    }

    trigger OnAfterGetRecord()
    begin

        //-NPR4.11
        NPRAttrManagement.GetMasterDataAttributeValue (NPRAttrTextArray, DATABASE::Item, "No.");
        NPRAttrEditable := CurrPage.Editable ();
        //+NPR4.11
        //-NPR5.38
        ItemGroupDesc := '';
        if ItemGroup.Get("Item Group") then
          ItemGroupDesc  := ItemGroup.Description;
        //+NPR5.38


        //-NPR5.55 [393483]
        ItemFilter.Reset;
        ItemFilter.SetRange("No.",Rec."No.");
        if ItemFilter.FindFirst then begin
          ItemFilter.CalcFields(Inventory);
          ItemAvlByLocation := ItemFilter.Inventory;
        end;
        //+NPR5.55 [393483]
    end;

    trigger OnOpenPage()
    var
        RetailInventorySetMgt: Codeunit "RIS Retail Inventory Set Mgt.";
    begin

        //-NPR4.11
        NPRAttrManagement.GetAttributeVisibility (DATABASE::Item, NPRAttrVisibleArray);
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
        //+NPR4.11

        //-MAG1.21
        SetMagentoEnabled();
        //+MAG1.21

        //-NPR5.40 [307025]
        RetailInventoryEnabled := RetailInventorySetMgt.GetRetailInventoryEnabled();
        //+NPR5.40 [307025]
    end;

    var
        SkilledResourceList: Page "Skilled Resource List";
        CalculateStdCost: Codeunit "Calculate Standard Cost";
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        SearchItem: Text;
        NPRAttrTextArray: array [40] of Text[250];
        NPRAttrManagement: Codeunit "NPR Attribute Management";
        NPRAttrEditable: Boolean;
        NPRAttrVisibleArray: array [40] of Boolean;
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
        MagentoEnabled: Boolean;
        MagentoEnabledDisplayConfig: Boolean;
        MagentoEnabledMultistore: Boolean;
        Text001: Label 'Item No.';
        Error_NoBarcodeMatch: Label 'No item found for value %1';
        ItemGroupDesc: Text[50];
        ItemGroup: Record "Item Group";
        RetailInventoryEnabled: Boolean;
        ItemFilter: Record Item;
        ItemAvlByLocation: Decimal;

    procedure GetSelectionFilter(): Text
    var
        Item: Record Item;
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
    begin
        CurrPage.SetSelectionFilter(Item);
        exit(SelectionFilterManagement.GetSelectionFilterForItem(Item));
    end;

    procedure SetSelection(var Item: Record Item)
    begin
        CurrPage.SetSelectionFilter(Item);
    end;

    procedure GetViewText(): Text
    begin
        //-NPR5.30 [252646]
        exit(Rec.GetView(false));
        //+NPR5.30 [252646]
    end;

    procedure "--- NC"()
    begin
    end;

    procedure SetMagentoEnabled()
    var
        MagentoSetup: Record "Magento Setup";
    begin
        //-MAG1.21
        if not (MagentoSetup.Get and MagentoSetup."Magento Enabled") then
          exit;
        MagentoEnabled := true;
        MagentoEnabledMultistore := MagentoSetup."Multistore Enabled";
        MagentoEnabledDisplayConfig := MagentoSetup."Customers Enabled";
        //+MAG1.21
    end;

    procedure SetVendorNo(VendorNo: Code[20])
    begin
        //-NPR5.31 [272843]
        SetFilter("Vendor No.",VendorNo);
        //+NPR5.31 [272843]
    end;

    procedure SetVariantCode(VariantCode: Code[20])
    begin
        //-NPR5.31 [272843]
        SetFilter("Variant Filter","Variant Filter");
        //+NPR5.31 [272843]
    end;

    procedure SetLocationCode(LocationCode: Code[20])
    begin
        //-NPR5.31 [272843]
        SetFilter("Location Filter",LocationCode);
        //+NPR5.31 [272843]
    end;

    procedure SetBlocked(OptBlocked: Option All,OnlyBlocked,OnlyUnblocked)
    begin
        //-NPR5.38 [298368]
        case OptBlocked of
          OptBlocked::All:
            SetRange(Blocked);
          OptBlocked::OnlyBlocked:
            SetRange(Blocked,true);
          OptBlocked::OnlyUnblocked:
            SetRange(Blocked,false);
        end;
        //+NPR5.38 [298368]
    end;
}

