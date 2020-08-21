page 6060042 "Item Worksheet Page"
{
    // NPR4.18/BR  /20160209  CASE 182391 Object Created
    // NPR4.19/BR  /20160216  CASE 182391 Added Export to Excel Action, added field Tariff No.,Changed Functions Caption, added NPR Attribute support
    // NPR5.22/BR  /20160316  CASE 182391 added fields 500,510,520
    // NPR5.22/BR  /20160321  CASE 182391 Added support for mapping an Excel file
    // NPR5.22/BR  /20160323  CASE 182391 Added field Recommended Retail Price, Actions Set Sales Price to RRP
    // NPR5.22/BR  /20160420  CASE 182391 Added more actions for all lines in Worksheet
    // NPR5.23/BR  /20160525  CASE 242498 Added field Net Weight and Gross Weight
    // NPR5.25/BR  /20160708  CASE 246088 Added fields No. of Changes and No. of Warnings
    // NPR5.25/BR  /20160708  CASE 246088 Added Action Field Setup
    // NPR5.25/BR  /20160803  CASE 234602 Added Action Request Extra Item Information
    // NPR5.31/JLK /20170331  CASE 268274 Changed ENU Caption
    // NPR5.32/BR  /20170504  CASE 274473 Added function OpenFilteredView
    // NPR5.33/ANEN/20170427  CASE 273989 Extending to 40 attributes
    // NPR5.37/BR  /20170910  CASE 268786 Added Action Vendor Variety Mapping
    // NPR5.38/BR  /20171124  CASE 297587 Added fields Sales Price Start Date and Purchase Price Start Date
    // NPR5.41/JKL /20180424  CASE 310223  changed visibility parameter on client attributtte 1 to NPRAttrVisible01 + added field units pr. parcel
    // NPR5.48/TS  /20181206  CASE 338656 Added Missing Picture to Action
    // NPR5.50/THRO/20190526  CASE 356260 Removed FieldsVisible and ShowAllInfo variables - Let user deside which fields to see. Field hidden by the variables set to visible=false
    // NPR5.51/MHA /20190819  CASE 365377 Removed action "GIM import document"
    // NPR5.52/SARA/20190906  CASE 366969 Added action 'Shelf Label' and 'Price Label'
    // NPR5.54/ZESO/20200225  CASE 385388 Added fields Magento Item, Profit % and Description2

    AutoSplitKey = true;
    Caption = 'Item Worksheet Page';
    DelayedInsert = false;
    PageType = Worksheet;
    PopulateAllFields = true;
    RefreshOnActivate = true;
    SaveValues = true;
    SourceTable = "Item Worksheet Line";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(CurrentWorksheetName; CurrentWorksheetName)
                {
                    ApplicationArea = All;
                    Caption = 'Batch Name';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        CurrPage.SaveRecord;
                        ItemWorksheetMgt.LookupName(CurrentWorksheetName, Rec);
                        CurrPage.Update(false);
                    end;

                    trigger OnValidate()
                    begin
                        ItemWorksheetMgt.CheckName(CurrentWorksheetName, Rec);
                        CurrentJnlBatchNameOnAfterVali;
                    end;
                }
                field("Show Variety Level"; ShowExpanded)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if ItemWorksheet.Get("Worksheet Template Name", CurrentWorksheetName) then begin
                            ItemWorksheet."Show Variety Level" := ShowExpanded;
                            ItemWorksheet.Modify;
                            ItemWorksheet.Validate("Show Variety Level");
                            CurrPage.ItemWorksheetVarSubpage.PAGE.UpdateSubPage;
                            CurrPage.Update;
                        end;
                    end;
                }
            }
            repeater(Control1)
            {
                ShowCaption = false;
                field("Worksheet Template Name"; "Worksheet Template Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Worksheet Name"; "Worksheet Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Action"; Action)
                {
                    ApplicationArea = All;
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Vendor Item No."; "Vendor Item No.")
                {
                    ApplicationArea = All;
                }
                field("Internal Bar Code"; "Internal Bar Code")
                {
                    ApplicationArea = All;
                }
                field("Vendors Bar Code"; "Vendors Bar Code")
                {
                    ApplicationArea = All;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                }
                field("Existing Item No."; "Existing Item No.")
                {
                    ApplicationArea = All;
                }
                field("Item Group"; "Item Group")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                }
                field("Profit %"; "Profit %")
                {
                    ApplicationArea = All;
                }
                field("Magento Item"; "Magento Item")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Status Comment"; "Status Comment")
                {
                    ApplicationArea = All;
                }
                field("No. of Changes"; "No. of Changes")
                {
                    ApplicationArea = All;
                }
                field("No. of Warnings"; "No. of Warnings")
                {
                    ApplicationArea = All;
                }
                field("Recommended Retail Price"; "Recommended Retail Price")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = RRPDiff;
                }
                field("Sales Price"; "Sales Price")
                {
                    ApplicationArea = All;
                }
                field("Sales Price Currency Code"; "Sales Price Currency Code")
                {
                    ApplicationArea = All;
                }
                field("Sales Price Start Date"; "Sales Price Start Date")
                {
                    ApplicationArea = All;
                }
                field("Direct Unit Cost"; "Direct Unit Cost")
                {
                    ApplicationArea = All;
                }
                field("Purchase Price Currency Code"; "Purchase Price Currency Code")
                {
                    ApplicationArea = All;
                }
                field("Purchase Price Start Date"; "Purchase Price Start Date")
                {
                    ApplicationArea = All;
                }
                field("Use Variant"; "Use Variant")
                {
                    ApplicationArea = All;
                }
                field("Tariff No."; "Tariff No.")
                {
                    ApplicationArea = All;
                }
                field("Base Unit of Measure"; "Base Unit of Measure")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    Visible = false;
                }
                field("Inventory Posting Group"; "Inventory Posting Group")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    Visible = false;
                }
                field("Costing Method"; "Costing Method")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    Visible = false;
                }
                field("VAT Bus. Posting Group"; "VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    Visible = false;
                }
                field("VAT Bus. Posting Gr. (Price)"; "VAT Bus. Posting Gr. (Price)")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Gen. Prod. Posting Group"; "Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                }
                field("Tax Group Code"; "Tax Group Code")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                }
                field("VAT Prod. Posting Group"; "VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    Visible = false;
                }
                field("<Global Dimension 2 Code>s"; "Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    Visible = false;
                }
                field("Sales Unit of Measure"; "Sales Unit of Measure")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    Visible = false;
                }
                field("Purch. Unit of Measure"; "Purch. Unit of Measure")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    Visible = false;
                }
                field("Manufacturer Code"; "Manufacturer Code")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    Visible = false;
                }
                field("Item Category Code"; "Item Category Code")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                }
                field("Product Group Code"; "Product Group Code")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                }
                field("Gross Weight"; "Gross Weight")
                {
                    ApplicationArea = All;
                }
                field("Net Weight"; "Net Weight")
                {
                    ApplicationArea = All;
                }
                field("Units per Parcel"; "Units per Parcel")
                {
                    ApplicationArea = All;
                }
                field("Variety Group"; "Variety Group")
                {
                    ApplicationArea = All;
                }
                field("Variety 1"; "Variety 1")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Variety 1 Table (Base)"; "Variety 1 Table (Base)")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Create Copy of Variety 1 Table"; "Create Copy of Variety 1 Table")
                {
                    ApplicationArea = All;
                }
                field("Variety 2"; "Variety 2")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Variety 2 Table (Base)"; "Variety 2 Table (Base)")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Create Copy of Variety 2 Table"; "Create Copy of Variety 2 Table")
                {
                    ApplicationArea = All;
                }
                field("Variety 3"; "Variety 3")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Variety 3 Table (Base)"; "Variety 3 Table (Base)")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Create Copy of Variety 3 Table"; "Create Copy of Variety 3 Table")
                {
                    ApplicationArea = All;
                }
                field("Variety 4"; "Variety 4")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Variety 4 Table (Base)"; "Variety 4 Table (Base)")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Create Copy of Variety 4 Table"; "Create Copy of Variety 4 Table")
                {
                    ApplicationArea = All;
                }
                field("Variety Lines to Skip"; "Variety Lines to Skip")
                {
                    ApplicationArea = All;
                }
                field("Variety Lines to Update"; "Variety Lines to Update")
                {
                    ApplicationArea = All;
                }
                field("Variety Lines to Create"; "Variety Lines to Create")
                {
                    ApplicationArea = All;
                }
                field(NPRAttrTextArray_01; NPRAttrTextArray[1])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,1,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible01;

                    trigger OnValidate()
                    begin
                        //-NPR4.19
                        NPRAttrManagement.SetWorksheetLineAttributeValue(DATABASE::"Item Worksheet Line", 1, "Worksheet Template Name", "Worksheet Name", "Line No.", NPRAttrTextArray[1]);
                        //+NPR4.19
                    end;
                }
                field(NPRAttrTextArray_02; NPRAttrTextArray[2])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,2,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible02;

                    trigger OnValidate()
                    begin
                        //-NPR4.19
                        NPRAttrManagement.SetWorksheetLineAttributeValue(DATABASE::"Item Worksheet Line", 2, "Worksheet Template Name", "Worksheet Name", "Line No.", NPRAttrTextArray[2]);
                        //+NPR4.19
                    end;
                }
                field(NPRAttrTextArray_03; NPRAttrTextArray[3])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,3,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible03;

                    trigger OnValidate()
                    begin
                        //-NPR4.19
                        NPRAttrManagement.SetWorksheetLineAttributeValue(DATABASE::"Item Worksheet Line", 3, "Worksheet Template Name", "Worksheet Name", "Line No.", NPRAttrTextArray[3]);
                        //+NPR4.19
                    end;
                }
                field(NPRAttrTextArray_04; NPRAttrTextArray[4])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,4,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible04;

                    trigger OnValidate()
                    begin
                        //-NPR4.19
                        NPRAttrManagement.SetWorksheetLineAttributeValue(DATABASE::"Item Worksheet Line", 4, "Worksheet Template Name", "Worksheet Name", "Line No.", NPRAttrTextArray[4]);
                        //+NPR4.19
                    end;
                }
                field(NPRAttrTextArray_05; NPRAttrTextArray[5])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,5,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible05;

                    trigger OnValidate()
                    begin
                        //-NPR4.19
                        NPRAttrManagement.SetWorksheetLineAttributeValue(DATABASE::"Item Worksheet Line", 5, "Worksheet Template Name", "Worksheet Name", "Line No.", NPRAttrTextArray[5]);
                        //+NPR4.19
                    end;
                }
                field(NPRAttrTextArray_06; NPRAttrTextArray[6])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,6,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible06;

                    trigger OnValidate()
                    begin
                        //-NPR4.19
                        NPRAttrManagement.SetWorksheetLineAttributeValue(DATABASE::"Item Worksheet Line", 6, "Worksheet Template Name", "Worksheet Name", "Line No.", NPRAttrTextArray[6]);
                        //+NPR4.19
                    end;
                }
                field(NPRAttrTextArray_07; NPRAttrTextArray[7])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,7,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible07;

                    trigger OnValidate()
                    begin
                        //-NPR4.19
                        NPRAttrManagement.SetWorksheetLineAttributeValue(DATABASE::"Item Worksheet Line", 7, "Worksheet Template Name", "Worksheet Name", "Line No.", NPRAttrTextArray[7]);
                        //+NPR4.19
                    end;
                }
                field(NPRAttrTextArray_08; NPRAttrTextArray[8])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,8,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible08;

                    trigger OnValidate()
                    begin
                        //-NPR4.19
                        NPRAttrManagement.SetWorksheetLineAttributeValue(DATABASE::"Item Worksheet Line", 8, "Worksheet Template Name", "Worksheet Name", "Line No.", NPRAttrTextArray[8]);
                        //+NPR4.19
                    end;
                }
                field(NPRAttrTextArray_09; NPRAttrTextArray[9])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,9,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible09;

                    trigger OnValidate()
                    begin
                        //-NPR4.19
                        NPRAttrManagement.SetWorksheetLineAttributeValue(DATABASE::"Item Worksheet Line", 9, "Worksheet Template Name", "Worksheet Name", "Line No.", NPRAttrTextArray[9]);
                        //+NPR4.19
                    end;
                }
                field(NPRAttrTextArray_10; NPRAttrTextArray[10])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,10,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible10;

                    trigger OnValidate()
                    begin
                        //-NPR4.19
                        NPRAttrManagement.SetWorksheetLineAttributeValue(DATABASE::"Item Worksheet Line", 10, "Worksheet Template Name", "Worksheet Name", "Line No.", NPRAttrTextArray[10]);
                        //+NPR4.19
                    end;
                }
            }
            part(ItemWorksheetVarSubpage; "Item Worksheet Variety Subpage")
            {
                ShowFilter = false;
                SubPageLink = "Worksheet Template Name" = FIELD("Worksheet Template Name"),
                              "Worksheet Name" = FIELD("Worksheet Name"),
                              "Worksheet Line No." = FIELD("Line No.");
                SubPageView = SORTING("Worksheet Template Name", "Worksheet Name", "Worksheet Line No.", "Variety 1 Value", "Variety 2 Value", "Variety 3 Value", "Variety 4 Value")
                              ORDER(Ascending);
                UpdatePropagation = SubPart;
            }
        }
        area(factboxes)
        {
            part(ItemWorksheetFactBox; "Item Worksheet FactBox")
            {
                SubPageLink = "Worksheet Template Name" = FIELD("Worksheet Template Name"),
                              "Worksheet Name" = FIELD("Worksheet Name"),
                              "Line No." = FIELD("Line No.");
                Visible = true;
            }
            part(NPAttribFactBox; "Item Worksheet Attr. FactBox")
            {
                Caption = 'Attributes';
                SubPageLink = "Worksheet Template Name" = FIELD("Worksheet Template Name"),
                              "Worksheet Name" = FIELD("Worksheet Name"),
                              "Line No." = FIELD("Line No.");
                SubPageView = SORTING("No. Series")
                              ORDER(Ascending);
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Existing Item")
            {
                Caption = 'Existing Item';
                Image = Item;
                RunObject = Page "Retail Item Card";
                RunPageLink = "No." = FIELD("Existing Item No.");
                RunPageView = SORTING("No.")
                              ORDER(Ascending);
            }
        }
        area(processing)
        {
            group(Variant)
            {
                Caption = 'Variant';
                action(Create)
                {
                    Caption = 'Create';
                    Image = CreateForm;
                }
                action("Variant Code")
                {
                    Caption = 'Variant code';
                    Image = ItemVariant;
                }
                action(Barcodes)
                {
                    Caption = 'Barcode';
                    Image = BarCode;
                }
                action(SalesPrice)
                {
                    Caption = 'Sales Prices';
                    Image = SalesPrices;
                }
                action("Purchase Price")
                {
                    Caption = 'Purchase Price';
                    Image = Price;
                }
                action("Supplier barcode")
                {
                    Caption = 'Supplier Barcode';
                    Image = "Action";
                }
            }
            group(Functions)
            {
                Caption = 'Functions';
                action("Suggest Worksheet Lines")
                {
                    Caption = 'Suggest Worksheet Lines';
                    Image = ItemWorksheet;

                    trigger OnAction()
                    begin
                        Clear(SuggestItemWorksheetLines);
                        ItemWorksheet.Reset;
                        ItemWorksheet.SetRange("Item Template Name", "Worksheet Template Name");
                        ItemWorksheet.SetRange(Name, "Worksheet Name");
                        SuggestItemWorksheetLines.SetTableView(ItemWorksheet);
                        SuggestItemWorksheetLines.RunModal;
                        CurrPage.Update;
                    end;
                }
                action(CreateItems)
                {
                    Caption = 'Create Items';
                    Image = Create;
                }
                action(Controller)
                {
                    Caption = 'Controller';
                    Image = "Action";
                }
                action("Import from Buffer")
                {
                    Caption = 'Import from Buffer';
                    Image = Import;
                }
            }
            group("Worksheet Line")
            {
                Caption = 'Worksheet Line';
                action(QueryItemInfo)
                {
                    Caption = 'Request Extra Item Info';
                    Image = CoupledItem;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        //-NPR5.25 [234602]
                        CreateQueryItemInformation(false);
                        //+NPR5.25 [234602]
                    end;
                }
                action("Combine Varieties")
                {
                    Caption = 'Combine Varieties';
                    Image = BankAccountRec;

                    trigger OnAction()
                    begin
                        ItemWorksheetMgt.CombineLine(Rec, 0);
                        //-NPR4.19
                        Commit;
                        RefreshVariants(0, true);
                        //-NPR4.19
                        CurrPage.Update;
                    end;
                }
                action("Refresh Headers")
                {
                    Caption = 'Refresh Headers';
                    Image = UpdateDescription;

                    trigger OnAction()
                    begin
                        RefreshVariants(0, true);
                        CurrPage.Update;
                    end;
                }
                action("Vendor Variety Value Mapping")
                {
                    Caption = 'Vendor Variety Value Mapping';
                    Image = MapAccounts;
                    RunObject = Page "Item Worksheet Variety Mapping";
                    RunPageLink = "Vendor No." = FIELD("Vendor No.");
                }
                action("Suggest Existing Variants")
                {
                    Caption = 'Suggest Existing Variants';
                    Image = SKU;

                    trigger OnAction()
                    begin
                        RefreshVariants(1, true);
                        CurrPage.Update;
                    end;
                }
                action("Suggest Varieties Without Variants")
                {
                    Caption = 'Suggest Varieties Without Variants';
                    Image = CreateSKU;

                    trigger OnAction()
                    begin
                        RefreshVariants(2, true);
                        CurrPage.Update;
                    end;
                }
                action("Suggest all Varieties")
                {
                    Caption = 'Suggest all Varieties';
                    Image = ItemVariant;

                    trigger OnAction()
                    begin
                        RefreshVariants(3, true);
                        CurrPage.Update;
                    end;
                }
                action(SetRRP)
                {
                    Caption = 'Set Sales Price to RRP';
                    Image = TransferFunds;

                    trigger OnAction()
                    begin
                        //-NPR5.22
                        UpdateSalesPriceWithRRP;
                        //+NPR5.22
                    end;
                }
                action("Shelf Label")
                {
                    Caption = 'Shelf Label';
                    Image = BinContent;
                    Promoted = true;
                    PromotedCategory = "Report";

                    trigger OnAction()
                    var
                        ReportSelectionRetail: Record "Report Selection Retail";
                        RecRef: RecordRef;
                    begin
                        //-NPR5.52 [366969]
                        RecRef.GetTable(Rec);
                        LabelLibrary.ToggleLine(RecRef);
                        LabelLibrary.PrintSelection(ReportSelectionRetail."Report Type"::"Shelf Label");
                        //+NPR5.52 [366969]
                    end;
                }
                action("Price Label")
                {
                    Caption = 'Price Label';
                    Image = BinLedger;
                    Promoted = true;
                    PromotedCategory = "Report";
                    ShortCutKey = 'Ctrl+Alt+L';

                    trigger OnAction()
                    var
                        ReportSelectionRetail: Record "Report Selection Retail";
                        RecRef: RecordRef;
                    begin
                        //-NPR5.52 [366969]
                        RecRef.GetTable(Rec);
                        LabelLibrary.ToggleLine(RecRef);
                        LabelLibrary.PrintSelection(ReportSelectionRetail."Report Type"::"Price Label");
                        //+NPR5.52 [366969]
                    end;
                }
            }
            group(Worksheet)
            {
                Caption = 'Worksheet';
                action("Combine All Varietes")
                {
                    Caption = 'Combine All Varieties';
                    Image = BankAccountRec;

                    trigger OnAction()
                    begin
                        GetCurrentWorksheet;
                        //-NPR5.23 [242498]
                        ItemWorksheetMgt.CombineLines(ItemWorksheet);
                        //ItemWorksheetMgt.CombineLines(ItemWorksheet,0);
                        //+NPR5.23 [242498]
                        //-NPR4.19
                        Commit;
                        ItemWorksheetLine.Reset;
                        ItemWorksheetLine.SetRange("Worksheet Template Name", "Worksheet Template Name");
                        ItemWorksheetLine.SetRange("Worksheet Name", "Worksheet Name");
                        if ItemWorksheetLine.FindSet then
                            repeat
                                ItemWorksheetLine.RefreshVariants(0, true);
                            until ItemWorksheetLine.Next = 0;
                        //-NPR4.19
                        CurrPage.Update;
                    end;
                }
                action("Refresh All Headers")
                {
                    Caption = 'Refresh All Headers';
                    Image = UpdateDescription;

                    trigger OnAction()
                    begin
                        ItemWorksheetLine.Reset;
                        ItemWorksheetLine.SetRange("Worksheet Template Name", "Worksheet Template Name");
                        ItemWorksheetLine.SetRange("Worksheet Name", "Worksheet Name");
                        if ItemWorksheetLine.FindSet then
                            repeat
                                ItemWorksheetLine.RefreshVariants(0, true);
                            until ItemWorksheetLine.Next = 0;
                        CurrPage.Update;
                    end;
                }
                action("Suggest All Existing Variants")
                {
                    Caption = 'Suggest All Existing Variants';
                    Image = SKU;

                    trigger OnAction()
                    begin
                        //-NPR5.22
                        ItemWorksheetLine.Reset;
                        ItemWorksheetLine.SetRange("Worksheet Template Name", "Worksheet Template Name");
                        ItemWorksheetLine.SetRange("Worksheet Name", "Worksheet Name");
                        if ItemWorksheetLine.FindSet then
                            repeat
                                ItemWorksheetLine.RefreshVariants(1, true);
                            until ItemWorksheetLine.Next = 0;
                        CurrPage.Update;
                        //+NPR5.22
                    end;
                }
                action("Suggest All Varieties Without Variants")
                {
                    Caption = 'Suggest All Varieties Without Variants';
                    Image = CreateSKU;

                    trigger OnAction()
                    begin
                        //-NPR5.22
                        ItemWorksheetLine.Reset;
                        ItemWorksheetLine.SetRange("Worksheet Template Name", "Worksheet Template Name");
                        ItemWorksheetLine.SetRange("Worksheet Name", "Worksheet Name");
                        if ItemWorksheetLine.FindSet then
                            repeat
                                ItemWorksheetLine.RefreshVariants(2, true);
                            until ItemWorksheetLine.Next = 0;
                        CurrPage.Update;
                        //+NPR5.22
                    end;
                }
                action("Suggest All Varieties in Worksheet")
                {
                    Caption = 'Suggest All Varieties in Worksheet';
                    Image = ItemVariant;

                    trigger OnAction()
                    begin
                        //-NPR5.22
                        ItemWorksheetLine.Reset;
                        ItemWorksheetLine.SetRange("Worksheet Template Name", "Worksheet Template Name");
                        ItemWorksheetLine.SetRange("Worksheet Name", "Worksheet Name");
                        if ItemWorksheetLine.FindSet then
                            repeat
                                ItemWorksheetLine.RefreshVariants(3, true);
                            until ItemWorksheetLine.Next = 0;
                        CurrPage.Update;
                        //+NPR5.22
                    end;
                }
                action(SetRRPAll)
                {
                    Caption = 'Set All Sales Prices to RRP';
                    Image = TransferFunds;

                    trigger OnAction()
                    begin
                        //-NPR5.22
                        GetCurrentWorksheet;
                        ItemWorksheet.UpdateSalesPriceAllLinesWithRRP;
                        //+NPR5.22
                    end;
                }
            }
            group(ActionGroup6150674)
            {
                Caption = 'Register';
                action("Field Setup")
                {
                    Caption = 'Field Setup';
                    Image = MapAccounts;

                    trigger OnAction()
                    var
                        ItemWorksheetFieldSetup: Record "Item Worksheet Field Setup";
                        ItemWorksheetFieldSetupPage: Page "Item Worksheet Field Setup";
                    begin
                        //-NPR5.25 [246088]
                        GetCurrentWorksheet;
                        ItemWorksheet.InsertDefaultFieldSetup;
                        ItemWorksheetFieldSetup.Reset;
                        ItemWorksheetFieldSetup.SetFilter(ItemWorksheetFieldSetup."Worksheet Template Name", ItemWorksheet."Item Template Name");
                        ItemWorksheetFieldSetup.SetFilter("Worksheet Name", ItemWorksheet.Name);
                        ItemWorksheetFieldSetupPage.SetTableView(ItemWorksheetFieldSetup);
                        ItemWorksheetFieldSetupPage.Run;
                        //+NPR5.25 [246088]
                    end;
                }
                action("Check Lines")
                {
                    Caption = 'Check Lines';
                    Image = CheckList;

                    trigger OnAction()
                    begin
                        //-NPR5.25 [246088]
                        GetCurrentWorksheet;
                        //+NPR5.25 [246088]
                        ItemWorksheet.CheckLines(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(Register)
                {
                    Caption = 'Register';
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    begin
                        CODEUNIT.Run(CODEUNIT::"Item Wsht.-Register (Yes/No)", Rec);
                        CurrPage.Update(false);
                    end;
                }
            }
            group("Import/Export")
            {
                Caption = 'Import/Export';
                action("Map Excelsheet")
                {
                    Caption = 'Map Excelsheet';
                    Image = MapAccounts;
                    RunObject = Page "Item Worksheet Excel Column";
                    RunPageLink = "Worksheet Template Name" = FIELD("Worksheet Template Name"),
                                  "Worksheet Name" = FIELD("Worksheet Name");
                }
                action("Export Excel")
                {
                    Caption = 'Export Excel';
                    Image = ExportToExcel;

                    trigger OnAction()
                    var
                        ItemWorksheetLine: Record "Item Worksheet Line";
                    begin
                        //-NPR4.19
                        REPORT.Run(REPORT::"Export Excel Item Worksheet", false, true, Rec);
                        //+NPR4.19
                    end;
                }
                action("Import Excel")
                {
                    Caption = 'Import Excel';
                    Image = ImportExcel;

                    trigger OnAction()
                    begin
                        GetCurrentWorksheet;
                        ItemWshtImpExpMgt.ImportFromExcel(ItemWorksheet);
                    end;
                }
                action("Import XML")
                {
                    Caption = 'Import XML';
                    Image = Import;

                    trigger OnAction()
                    begin
                        ItemWshtImpExpMgt.Import;
                    end;
                }
                action("Export XML")
                {
                    Caption = 'Export XML';
                    Image = Export;

                    trigger OnAction()
                    begin
                        ItemWshtImpExpMgt.Export(Rec);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetFieldEditable;
        SetVisibleFields;
    end;

    trigger OnAfterGetRecord()
    begin
        //-NPR4.19
        NPRAttrManagement.GetWorksheetLineAttributeValue(NPRAttrTextArray, DATABASE::"Item Worksheet Line", "Worksheet Template Name", "Worksheet Name", "Line No.");
        NPRAttrEditable := CurrPage.Editable();
        //+NPR4.19
    end;

    trigger OnClosePage()
    begin
        ItemWorksheetMgt.OnCloseForm(Rec);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        //-NPR5.25 [246088]
        CheckManualValidation;
        //+NPR5.25 [246088]
        SetVisibleFields;
        exit(true);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetUpNewLine(xRec);
        SetFieldEditable;
    end;

    trigger OnOpenPage()
    begin
        //-NPR4.19
        NPRAttrManagement.GetAttributeVisibility(DATABASE::"Item Worksheet Line", NPRAttrVisibleArray);
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

        NPRAttrEditable := CurrPage.Editable();
        //+NPR4.19

        //-NPR5.32 [274473]
        if OpenedFromFilteredView then begin
            CopyFilters(ItemWorksheetLine);
            exit;
        end;
        //+NPR5.32 [274473]

        OpenedFromWorksheet := ("Worksheet Name" <> '') and ("Worksheet Template Name" = '');
        if OpenedFromWorksheet then begin
            CurrentWorksheetName := "Worksheet Name";
            ItemWorksheetMgt.OpenJnl(CurrentWorksheetName, Rec);
            exit;
        end;
        ItemWorksheetMgt.TemplateSelection(PAGE::"Item Worksheet Page", Rec, WorksheetSelected);
        if not WorksheetSelected then
            Error('');
        ItemWorksheetMgt.OpenJnl(CurrentWorksheetName, Rec);
        //GetCurrentWorksheet;
        //SetVisibleFields;
    end;

    var
        ItemWorksheetTemplate: Record "Item Worksheet Template";
        ItemWorksheetMgt: Codeunit "Item Worksheet Management";
        LabelLibrary: Codeunit "Label Library";
        OpenedFromWorksheet: Boolean;
        CurrentWorksheetName: Code[10];
        WorksheetSelected: Boolean;
        ItemWorksheet: Record "Item Worksheet";
        ItemWorksheetLine: Record "Item Worksheet Line";
        InvoiceNo: Code[20];
        InvoiceDate: Date;
        Freight: Decimal;
        [InDataSet]
        VendorItemNoEditable: Boolean;
        [InDataSet]
        FieldsEditable: Boolean;
        ShowExpanded: Option "Variety 1","Variety 1+2","Variety 1+2+3","Variety 1+2+3+4";
        SuggestItemWorksheetLines: Report "Suggest Item Worksheet Lines";
        ItemWshtImpExpMgt: Codeunit "Item Wsht. Imp. Exp. Mgt.";
        NPRAttrTextArray: array[40] of Text;
        NPRAttrManagement: Codeunit "NPR Attribute Management";
        [InDataSet]
        NPRAttrEditable: Boolean;
        NPRAttrVisibleArray: array[40] of Boolean;
        [InDataSet]
        NPRAttrVisible01: Boolean;
        [InDataSet]
        NPRAttrVisible02: Boolean;
        [InDataSet]
        NPRAttrVisible03: Boolean;
        [InDataSet]
        NPRAttrVisible04: Boolean;
        [InDataSet]
        NPRAttrVisible05: Boolean;
        [InDataSet]
        NPRAttrVisible06: Boolean;
        [InDataSet]
        NPRAttrVisible07: Boolean;
        [InDataSet]
        NPRAttrVisible08: Boolean;
        [InDataSet]
        NPRAttrVisible09: Boolean;
        [InDataSet]
        NPRAttrVisible10: Boolean;
        RRPDiff: Boolean;
        OpenedFromFilteredView: Boolean;

    procedure SetFieldEditable()
    begin
        //IF VendorItemNoEditable = ("Existing Item No." <> '') THEN
        //  EXIT;


        FieldsEditable := ("Existing Item No." = '');
    end;

    procedure GetCurrentWorksheet()
    begin
        ItemWorksheet.Get(GetRangeMax("Worksheet Template Name"), CurrentWorksheetName);
        ShowExpanded := ItemWorksheet."Show Variety Level";
    end;

    procedure SetVisibleFields()
    begin
        //-NPR5.50 [356260]
        //FieldsVisible:=ShowAllInfo;
        //+NPR5.50 [356260]
        //CurrPage.UPDATE(FALSE);
        CurrPage.ItemWorksheetVarSubpage.PAGE.SetRecFromIW(Rec);
        CurrPage.ItemWorksheetVarSubpage.PAGE.UpdateSubPage;
        //-NPR4.19
        UpdateFactBoxes;
        //+NPR4.19
        //-NPR5.22
        RRPDiff := ("Recommended Retail Price" <> 0) and ("Sales Price" <> 0) and ("Recommended Retail Price" <> "Sales Price");
        //+NPR5.22
    end;

    local procedure CurrentJnlBatchNameOnAfterVali()
    begin
        CurrPage.SaveRecord;
        ItemWorksheetMgt.SetName(CurrentWorksheetName, Rec);
        CurrPage.Update(false);
    end;

    local procedure UpdateFactBoxes()
    begin
        CurrPage.ItemWorksheetFactBox.PAGE.Update;
        CurrPage.NPAttribFactBox.PAGE.Update;
    end;

    procedure OpenFilteredView(var VarItemWorksheetLine: Record "Item Worksheet Line")
    begin
        //-NPR5.32 [274473]
        ItemWorksheetLine.CopyFilters(VarItemWorksheetLine);
        ItemWorksheetLine.FindFirst;
        CurrentWorksheetName := VarItemWorksheetLine."Worksheet Name";
        OpenedFromFilteredView := true;
        //+NPR5.32 [274473]
    end;
}

