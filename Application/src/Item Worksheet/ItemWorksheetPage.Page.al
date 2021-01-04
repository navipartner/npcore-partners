page 6060042 "NPR Item Worksheet Page"
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
    //PageType = Worksheet;
    PageType = Document;
    PopulateAllFields = true;
    RefreshOnActivate = true;
    SaveValues = true;
    SourceTable = "NPR Item Worksheet Line";
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
                    ToolTip = 'Specifies the value of the Batch Name field';

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
                    ToolTip = 'Specifies the value of the ShowExpanded field';

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
                    ToolTip = 'Specifies the value of the Worksheet Template Name field';
                }
                field("Worksheet Name"; "Worksheet Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Worksheet Name field';
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field("Action"; Action)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Action field';
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor No. field';
                }
                field("Vendor Item No."; "Vendor Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor Item No. field';
                }
                field("Internal Bar Code"; "Internal Bar Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Internal Bar Code field';
                }
                field("Vendors Bar Code"; "Vendors Bar Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendors Bar Code field';
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Existing Item No."; "Existing Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Existing Item No. field';
                }
                field("Item Group"; "Item Group")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Item Group field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description 2 field';
                }
                field("Profit %"; "Profit %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Profit % field';
                }
                field("Magento Item"; "Magento Item")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Magento Item field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Status Comment"; "Status Comment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status Comment field';
                }
                field("No. of Changes"; "No. of Changes")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. of Changes field';
                }
                field("No. of Warnings"; "No. of Warnings")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. of Warnings field';
                }
                field("Recommended Retail Price"; "Recommended Retail Price")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = RRPDiff;
                    ToolTip = 'Specifies the value of the Recommended Retail Price field';
                }
                field("Sales Price"; "Sales Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
                field("Sales Price Currency Code"; "Sales Price Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Price Currency Code field';
                }
                field("Sales Price Start Date"; "Sales Price Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Price Start Date field';
                }
                field("Direct Unit Cost"; "Direct Unit Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Direct Unit Cost field';
                }
                field("Purchase Price Currency Code"; "Purchase Price Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchase Price Currency Code field';
                }
                field("Purchase Price Start Date"; "Purchase Price Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchase Price Start Date field';
                }
                field("Use Variant"; "Use Variant")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Use Variant field';
                }
                field("Tariff No."; "Tariff No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tariff No. field';
                }
                field("Base Unit of Measure"; "Base Unit of Measure")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Base Unit of Measure field';
                }
                field("Inventory Posting Group"; "Inventory Posting Group")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Inventory Posting Group field';
                }
                field("Costing Method"; "Costing Method")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Costing Method field';
                }
                field("VAT Bus. Posting Group"; "VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    Visible = false;
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Group field';
                }
                field("VAT Bus. Posting Gr. (Price)"; "VAT Bus. Posting Gr. (Price)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Gr. (Price) field';
                }
                field("Gen. Prod. Posting Group"; "Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Gen. Prod. Posting Group field';
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the No. Series field';
                }
                field("Tax Group Code"; "Tax Group Code")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Tax Group Code field';
                }
                field("VAT Prod. Posting Group"; "VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the VAT Prod. Posting Group field';
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                }
                field("<Global Dimension 2 Code>s"; "Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                }
                field("Sales Unit of Measure"; "Sales Unit of Measure")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sales Unit of Measure field';
                }
                field("Purch. Unit of Measure"; "Purch. Unit of Measure")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Purch. Unit of Measure field';
                }
                field("Manufacturer Code"; "Manufacturer Code")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Manufacturer Code field';
                }
                field("Item Category Code"; "Item Category Code")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Item Category Code field';
                }
                field("Product Group Code"; "Product Group Code")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Product Group Code field';
                }
                field("Gross Weight"; "Gross Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gross Weight field';
                }
                field("Net Weight"; "Net Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Net Weight field';
                }
                field("Units per Parcel"; "Units per Parcel")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Units per Parcel field';
                }
                field("Variety Group"; "Variety Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety Group field';
                }
                field("Variety 1"; "Variety 1")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 1 field';
                }
                field("Variety 1 Table (Base)"; "Variety 1 Table (Base)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 1 Table field';
                }
                field("Create Copy of Variety 1 Table"; "Create Copy of Variety 1 Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Copy of Variety 1 Table field';
                }
                field("Variety 2"; "Variety 2")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 2 field';
                }
                field("Variety 2 Table (Base)"; "Variety 2 Table (Base)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 2 Table field';
                }
                field("Create Copy of Variety 2 Table"; "Create Copy of Variety 2 Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Copy of Variety 2 Table field';
                }
                field("Variety 3"; "Variety 3")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 3 field';
                }
                field("Variety 3 Table (Base)"; "Variety 3 Table (Base)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 3 Table field';
                }
                field("Create Copy of Variety 3 Table"; "Create Copy of Variety 3 Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Copy of Variety 3 Table field';
                }
                field("Variety 4"; "Variety 4")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 4 field';
                }
                field("Variety 4 Table (Base)"; "Variety 4 Table (Base)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 4 Table field';
                }
                field("Create Copy of Variety 4 Table"; "Create Copy of Variety 4 Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Copy of Variety 4 Table field';
                }
                field("Variety Lines to Skip"; "Variety Lines to Skip")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety Lines to Skip field';
                }
                field("Variety Lines to Update"; "Variety Lines to Update")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety Lines to Update field';
                }
                field("Variety Lines to Create"; "Variety Lines to Create")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety Lines to Create field';
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
                        //-NPR4.19
                        NPRAttrManagement.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", 1, "Worksheet Template Name", "Worksheet Name", "Line No.", NPRAttrTextArray[1]);
                        //+NPR4.19
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
                        //-NPR4.19
                        NPRAttrManagement.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", 2, "Worksheet Template Name", "Worksheet Name", "Line No.", NPRAttrTextArray[2]);
                        //+NPR4.19
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
                        //-NPR4.19
                        NPRAttrManagement.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", 3, "Worksheet Template Name", "Worksheet Name", "Line No.", NPRAttrTextArray[3]);
                        //+NPR4.19
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
                        //-NPR4.19
                        NPRAttrManagement.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", 4, "Worksheet Template Name", "Worksheet Name", "Line No.", NPRAttrTextArray[4]);
                        //+NPR4.19
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
                        //-NPR4.19
                        NPRAttrManagement.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", 5, "Worksheet Template Name", "Worksheet Name", "Line No.", NPRAttrTextArray[5]);
                        //+NPR4.19
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
                        //-NPR4.19
                        NPRAttrManagement.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", 6, "Worksheet Template Name", "Worksheet Name", "Line No.", NPRAttrTextArray[6]);
                        //+NPR4.19
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
                        //-NPR4.19
                        NPRAttrManagement.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", 7, "Worksheet Template Name", "Worksheet Name", "Line No.", NPRAttrTextArray[7]);
                        //+NPR4.19
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
                        //-NPR4.19
                        NPRAttrManagement.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", 8, "Worksheet Template Name", "Worksheet Name", "Line No.", NPRAttrTextArray[8]);
                        //+NPR4.19
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
                        //-NPR4.19
                        NPRAttrManagement.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", 9, "Worksheet Template Name", "Worksheet Name", "Line No.", NPRAttrTextArray[9]);
                        //+NPR4.19
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
                        //-NPR4.19
                        NPRAttrManagement.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", 10, "Worksheet Template Name", "Worksheet Name", "Line No.", NPRAttrTextArray[10]);
                        //+NPR4.19
                    end;
                }
            }
            part(ItemWorksheetVarSubpage; "NPR Item Worksh. Vrty. Subpage")
            {
                ShowFilter = false;
                SubPageLink = "Worksheet Template Name" = FIELD("Worksheet Template Name"),
                              "Worksheet Name" = FIELD("Worksheet Name"),
                              "Worksheet Line No." = FIELD("Line No.");
                SubPageView = SORTING("Worksheet Template Name", "Worksheet Name", "Worksheet Line No.", "Variety 1 Value", "Variety 2 Value", "Variety 3 Value", "Variety 4 Value")
                              ORDER(Ascending);
                UpdatePropagation = SubPart;
                ApplicationArea = All;
            }
        }
        area(factboxes)
        {
            part(ItemWorksheetFactBox; "NPR Item Worksheet FactBox")
            {
                SubPageLink = "Worksheet Template Name" = FIELD("Worksheet Template Name"),
                              "Worksheet Name" = FIELD("Worksheet Name"),
                              "Line No." = FIELD("Line No.");
                Visible = true;
                ApplicationArea = All;
            }
            part(NPAttribFactBox; "NPR Item Worksh. Attr. FactBox")
            {
                Caption = 'Attributes';
                SubPageLink = "Worksheet Template Name" = FIELD("Worksheet Template Name"),
                              "Worksheet Name" = FIELD("Worksheet Name"),
                              "Line No." = FIELD("Line No.");
                SubPageView = SORTING("No. Series")
                              ORDER(Ascending);
                Visible = true;
                ApplicationArea = All;
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
                RunObject = Page "Item Card";
                RunPageLink = "No." = FIELD("Existing Item No.");
                RunPageView = SORTING("No.")
                              ORDER(Ascending);
                ApplicationArea = All;
                ToolTip = 'Executes the Existing Item action';
            }
        }
        area(processing)
        {
            group("Variant")
            {
                Caption = 'Variant';
                action(Create)
                {
                    Caption = 'Create';
                    Image = CreateForm;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Create action';
                }
                action("Variant Code")
                {
                    Caption = 'Variant code';
                    Image = ItemVariant;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Variant code action';
                }
                action(Barcodes)
                {
                    Caption = 'Barcode';
                    Image = BarCode;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Barcode action';
                }
                action(SalesPrice)
                {
                    Caption = 'Sales Prices';
                    Image = SalesPrices;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Sales Prices action';
                }
                action("Purchase Price")
                {
                    Caption = 'Purchase Price';
                    Image = Price;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Purchase Price action';
                }
                action("Supplier barcode")
                {
                    Caption = 'Supplier Barcode';
                    Image = "Action";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Supplier Barcode action';
                }
            }
            group(Functions)
            {
                Caption = 'Functions';
                action("Suggest Worksheet Lines")
                {
                    Caption = 'Suggest Worksheet Lines';
                    Image = ItemWorksheet;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Suggest Worksheet Lines action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Create Items action';
                }
                action(Controller)
                {
                    Caption = 'Controller';
                    Image = "Action";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Controller action';
                }
                action("Import from Buffer")
                {
                    Caption = 'Import from Buffer';
                    Image = Import;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Import from Buffer action';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Request Extra Item Info action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Combine Varieties action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Refresh Headers action';

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
                    RunObject = Page "NPR Item Worksh. Vrty. Mapping";
                    RunPageLink = "Vendor No." = FIELD("Vendor No.");
                    ApplicationArea = All;
                    ToolTip = 'Executes the Vendor Variety Value Mapping action';
                }
                action("Suggest Existing Variants")
                {
                    Caption = 'Suggest Existing Variants';
                    Image = SKU;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Suggest Existing Variants action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Suggest Varieties Without Variants action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Suggest all Varieties action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Set Sales Price to RRP action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Shelf Label action';

                    trigger OnAction()
                    var
                        ReportSelectionRetail: Record "NPR Report Selection Retail";
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Price Label action';

                    trigger OnAction()
                    var
                        ReportSelectionRetail: Record "NPR Report Selection Retail";
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Combine All Varieties action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Refresh All Headers action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Suggest All Existing Variants action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Suggest All Varieties Without Variants action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Suggest All Varieties in Worksheet action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Set All Sales Prices to RRP action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Field Setup action';

                    trigger OnAction()
                    var
                        ItemWorksheetFieldSetup: Record "NPR Item Worksh. Field Setup";
                        ItemWorksheetFieldSetupPage: Page "NPR Item Worksh. Field Setup";
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Check Lines action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Register action';

                    trigger OnAction()
                    begin
                        CODEUNIT.Run(CODEUNIT::"NPR Item Wsht.-Regist.(Yes/No)", Rec);
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
                    RunObject = Page "NPR Item Works. Excel Column";
                    RunPageLink = "Worksheet Template Name" = FIELD("Worksheet Template Name"),
                                  "Worksheet Name" = FIELD("Worksheet Name");
                    ApplicationArea = All;
                    ToolTip = 'Executes the Map Excelsheet action';
                }
                action("Export Excel")
                {
                    Caption = 'Export Excel';
                    Image = ExportToExcel;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Export Excel action';

                    trigger OnAction()
                    var
                        ItemWorksheetLine: Record "NPR Item Worksheet Line";
                    begin
                        //-NPR4.19
                        REPORT.Run(REPORT::"NPR Export Excel Item Worksh.", false, true, Rec);
                        //+NPR4.19
                    end;
                }
                action("Import Excel")
                {
                    Caption = 'Import Excel';
                    Image = ImportExcel;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Import Excel action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Import XML action';

                    trigger OnAction()
                    begin
                        ItemWshtImpExpMgt.Import;
                    end;
                }
                action("Export XML")
                {
                    Caption = 'Export XML';
                    Image = Export;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Export XML action';

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
        NPRAttrManagement.GetWorksheetLineAttributeValue(NPRAttrTextArray, DATABASE::"NPR Item Worksheet Line", "Worksheet Template Name", "Worksheet Name", "Line No.");
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
        NPRAttrManagement.GetAttributeVisibility(DATABASE::"NPR Item Worksheet Line", NPRAttrVisibleArray);
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
        ItemWorksheetMgt.TemplateSelection(PAGE::"NPR Item Worksheet Page", Rec, WorksheetSelected);
        if not WorksheetSelected then
            Error('');
        ItemWorksheetMgt.OpenJnl(CurrentWorksheetName, Rec);
        //GetCurrentWorksheet;
        //SetVisibleFields;
    end;

    var
        ItemWorksheetTemplate: Record "NPR Item Worksh. Template";
        ItemWorksheetMgt: Codeunit "NPR Item Worksheet Mgt.";
        LabelLibrary: Codeunit "NPR Label Library";
        OpenedFromWorksheet: Boolean;
        CurrentWorksheetName: Code[10];
        WorksheetSelected: Boolean;
        ItemWorksheet: Record "NPR Item Worksheet";
        ItemWorksheetLine: Record "NPR Item Worksheet Line";
        InvoiceNo: Code[20];
        InvoiceDate: Date;
        Freight: Decimal;
        [InDataSet]
        VendorItemNoEditable: Boolean;
        [InDataSet]
        FieldsEditable: Boolean;
        ShowExpanded: Option "Variety 1","Variety 1+2","Variety 1+2+3","Variety 1+2+3+4";
        SuggestItemWorksheetLines: Report "NPR Suggest Item Worksh. Lines";
        ItemWshtImpExpMgt: Codeunit "NPR Item Wsht. Imp. Exp.";
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

    procedure OpenFilteredView(var VarItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
        //-NPR5.32 [274473]
        ItemWorksheetLine.CopyFilters(VarItemWorksheetLine);
        ItemWorksheetLine.FindFirst;
        CurrentWorksheetName := VarItemWorksheetLine."Worksheet Name";
        OpenedFromFilteredView := true;
        //+NPR5.32 [274473]
    end;
}

