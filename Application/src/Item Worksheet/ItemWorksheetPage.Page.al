page 6060042 "NPR Item Worksheet Page"
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'Item Worksheet Page';
    DelayedInsert = false;
    PageType = Worksheet;
    PopulateAllFields = true;
    RefreshOnActivate = true;
    SaveValues = true;
    SourceTable = "NPR Item Worksheet Line";
    UsageCategory = Documents;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(CurrentWorksheetName; CurrentWorksheetName)
                {

                    Caption = 'Batch Name';
                    ToolTip = 'Specifies the value of the Batch Name field.';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        CurrPage.SaveRecord();
                        ItemWorksheetMgt.LookupName(CurrentWorksheetName, Rec);
                        CurrPage.Update(false);
                    end;

                    trigger OnValidate()
                    begin
                        ItemWorksheetMgt.CheckName(CurrentWorksheetName, Rec);
                        CurrentJnlBatchNameOnAfterVali();
                    end;
                }
                field("Show Variety Level"; ShowExpanded)
                {

                    OptionCaption = 'Variety 1,Variety 1+2,Variety 1+2+3,Variety 1+2+3+4';
                    ToolTip = 'Specifies the value of the ShowExpanded field.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if ItemWorksheet.Get(Rec."Worksheet Template Name", CurrentWorksheetName) then begin
                            ItemWorksheet."Show Variety Level" := ShowExpanded;
                            ItemWorksheet.Modify();
                            ItemWorksheet.Validate("Show Variety Level");
                            CurrPage.ItemWorksheetVarSubpage.PAGE.UpdateSubPage();
                            CurrPage.Update();
                        end;
                    end;
                }
            }
            repeater(Control1)
            {
                ShowCaption = false;
                field("Worksheet Template Name"; Rec."Worksheet Template Name")
                {

                    ToolTip = 'Specifies the value of the Worksheet Template Name field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Worksheet Name"; Rec."Worksheet Name")
                {

                    ToolTip = 'Specifies the value of the Worksheet Name field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Line No."; Rec."Line No.")
                {

                    ToolTip = 'Specifies the value of the Line No. field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Action"; Rec.Action)
                {

                    ToolTip = 'Specifies the value of the Action field.';
                    ApplicationArea = NPRRetail;
                }
                field("Vendor No."; Rec."Vendor No.")
                {

                    ToolTip = 'Specifies the value of the Vendor No. field.';
                    ApplicationArea = NPRRetail;
                }
                field("Vendor Item No."; Rec."Vendor Item No.")
                {

                    ToolTip = 'Specifies the value of the Vendor Item No. field.';
                    ApplicationArea = NPRRetail;
                }
                field("Internal Bar Code"; Rec."Internal Bar Code")
                {

                    ToolTip = 'Specifies the value of the Internal Bar Code field.';
                    ApplicationArea = NPRRetail;
                }
                field("Vendors Bar Code"; Rec."Vendors Bar Code")
                {

                    ToolTip = 'Specifies the value of the Vendors Bar Code field.';
                    ApplicationArea = NPRRetail;
                }
                field("Item No."; Rec."Item No.")
                {

                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Item No. field.';
                    ApplicationArea = NPRRetail;
                }
                field("Existing Item No."; Rec."Existing Item No.")
                {

                    ToolTip = 'Specifies the value of the Existing Item No. field.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field.';
                    ApplicationArea = NPRRetail;
                }
                field("Description 2"; Rec."Description 2")
                {

                    ToolTip = 'Specifies the value of the Description 2 field.';
                    ApplicationArea = NPRRetail;
                }
                field("Profit %"; Rec."Profit %")
                {

                    ToolTip = 'Specifies the value of the Percent of Profit field.';
                    ApplicationArea = NPRRetail;
                }
                field("Magento Item"; Rec."Magento Item")
                {

                    ToolTip = 'Specifies the value of the Magento Item field.';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    ToolTip = 'Specifies the value of the Status field.';
                    ApplicationArea = NPRRetail;
                }
                field("Status Comment"; Rec."Status Comment")
                {

                    ToolTip = 'Specifies the value of the Status Comment field.';
                    ApplicationArea = NPRRetail;
                }
                field("No. of Changes"; Rec."No. of Changes")
                {

                    ToolTip = 'Specifies the value of the No. of Changes field.';
                    ApplicationArea = NPRRetail;
                }
                field("No. of Warnings"; Rec."No. of Warnings")
                {

                    ToolTip = 'Specifies the value of the No. of Warnings field.';
                    ApplicationArea = NPRRetail;
                }
                field("Recommended Retail Price"; Rec."Recommended Retail Price")
                {

                    Style = Attention;
                    StyleExpr = RRPDiff;
                    ToolTip = 'Specifies the value of the Recommended Retail Price field.';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Price"; Rec."Sales Price")
                {

                    ToolTip = 'Specifies the value of the Unit Price field.';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Price Currency Code"; Rec."Sales Price Currency Code")
                {

                    ToolTip = 'Specifies the value of the Sales Price Currency Code field.';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Price Start Date"; Rec."Sales Price Start Date")
                {

                    ToolTip = 'Specifies the value of the Sales Price Start Date field.';
                    ApplicationArea = NPRRetail;
                }
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {

                    ToolTip = 'Specifies the value of the Direct Unit Cost field.';
                    ApplicationArea = NPRRetail;
                }
                field("Purchase Price Currency Code"; Rec."Purchase Price Currency Code")
                {

                    ToolTip = 'Specifies the value of the Purchase Price Currency Code field.';
                    ApplicationArea = NPRRetail;
                }
                field("Purchase Price Start Date"; Rec."Purchase Price Start Date")
                {

                    ToolTip = 'Specifies the value of the Purchase Price Start Date field.';
                    ApplicationArea = NPRRetail;
                }
                field("Use Variant"; Rec."Use Variant")
                {

                    ToolTip = 'Specifies the value of the Use Variant field.';
                    ApplicationArea = NPRRetail;
                }
                field("Tariff No."; Rec."Tariff No.")
                {

                    ToolTip = 'Specifies the value of the Tariff No. field.';
                    ApplicationArea = NPRRetail;
                }
                field("Base Unit of Measure"; Rec."Base Unit of Measure")
                {

                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Base Unit of Measure field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Inventory Posting Group"; Rec."Inventory Posting Group")
                {

                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Inventory Posting Group field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Costing Method"; Rec."Costing Method")
                {

                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Costing Method field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {

                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Group field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("VAT Bus. Posting Gr. (Price)"; Rec."VAT Bus. Posting Gr. (Price)")
                {

                    ToolTip = 'Specifies the value of the VAT Bus. Posting Gr. (Price) field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {

                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Gen. Prod. Posting Group field.';
                    ApplicationArea = NPRRetail;
                }
                field("No. Series"; Rec."No. Series")
                {

                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the No. Series field.';
                    ApplicationArea = NPRRetail;
                }
                field("Tax Group Code"; Rec."Tax Group Code")
                {

                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Tax Group Code field.';
                    ApplicationArea = NPRRetail;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {

                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the VAT Prod. Posting Group field.';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {

                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("<Global Dimension 2 Code>s"; Rec."Global Dimension 2 Code")
                {

                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Sales Unit of Measure"; Rec."Sales Unit of Measure")
                {

                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Sales Unit of Measure field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Purch. Unit of Measure"; Rec."Purch. Unit of Measure")
                {

                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Purch. Unit of Measure field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Manufacturer Code"; Rec."Manufacturer Code")
                {

                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Manufacturer Code field.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Item Category Code"; Rec."Item Category Code")
                {

                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Item Category Code field.';
                    ApplicationArea = NPRRetail;
                }
                field("Product Group Code"; Rec."Product Group Code")
                {

                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Product Group Code field.';
                    ApplicationArea = NPRRetail;
                }
                field("Gross Weight"; Rec."Gross Weight")
                {

                    ToolTip = 'Specifies the value of the Gross Weight field.';
                    ApplicationArea = NPRRetail;
                }
                field("Net Weight"; Rec."Net Weight")
                {

                    ToolTip = 'Specifies the value of the Net Weight field.';
                    ApplicationArea = NPRRetail;
                }
                field("Units per Parcel"; Rec."Units per Parcel")
                {

                    ToolTip = 'Specifies the value of the Units per Parcel field.';
                    ApplicationArea = NPRRetail;
                }
                field("Variety Group"; Rec."Variety Group")
                {

                    ToolTip = 'Specifies the value of the Variety Group field.';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 1"; Rec."Variety 1")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 1 field.';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 1 Table (Base)"; Rec."Variety 1 Table (Base)")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 1 Table field.';
                    ApplicationArea = NPRRetail;
                }
                field("Create Copy of Variety 1 Table"; Rec."Create Copy of Variety 1 Table")
                {

                    ToolTip = 'Specifies the value of the Create Copy of Variety 1 Table field.';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 2"; Rec."Variety 2")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 2 field.';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 2 Table (Base)"; Rec."Variety 2 Table (Base)")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 2 Table field.';
                    ApplicationArea = NPRRetail;
                }
                field("Create Copy of Variety 2 Table"; Rec."Create Copy of Variety 2 Table")
                {

                    ToolTip = 'Specifies the value of the Create Copy of Variety 2 Table field.';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 3"; Rec."Variety 3")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 3 field.';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 3 Table (Base)"; Rec."Variety 3 Table (Base)")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 3 Table field.';
                    ApplicationArea = NPRRetail;
                }
                field("Create Copy of Variety 3 Table"; Rec."Create Copy of Variety 3 Table")
                {

                    ToolTip = 'Specifies the value of the Create Copy of Variety 3 Table field.';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 4"; Rec."Variety 4")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 4 field.';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 4 Table (Base)"; Rec."Variety 4 Table (Base)")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 4 Table field.';
                    ApplicationArea = NPRRetail;
                }
                field("Create Copy of Variety 4 Table"; Rec."Create Copy of Variety 4 Table")
                {

                    ToolTip = 'Specifies the value of the Create Copy of Variety 4 Table field.';
                    ApplicationArea = NPRRetail;
                }
                field("Variety Lines to Skip"; Rec."Variety Lines to Skip")
                {

                    ToolTip = 'Specifies the value of the Variety Lines to Skip field.';
                    ApplicationArea = NPRRetail;
                }
                field("Variety Lines to Update"; Rec."Variety Lines to Update")
                {

                    ToolTip = 'Specifies the value of the Variety Lines to Update field.';
                    ApplicationArea = NPRRetail;
                }
                field("Variety Lines to Create"; Rec."Variety Lines to Create")
                {

                    ToolTip = 'Specifies the value of the Variety Lines to Create field.';
                    ApplicationArea = NPRRetail;
                }
                field(NPRAttrTextArray_01; NPRAttrTextArray[1])
                {

                    CaptionClass = '6014555,27,1,2';
                    Editable = NPRAttrEditable;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[1] field.';
                    Visible = NPRAttrVisible01;
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetWorksheetLineAttributeValue(
                            DATABASE::"NPR Item Worksheet Line", 1, Rec."Worksheet Template Name",
                            Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[1]);
                    end;
                }
                field(NPRAttrTextArray_02; NPRAttrTextArray[2])
                {

                    CaptionClass = '6014555,27,2,2';
                    Editable = NPRAttrEditable;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[2] field.';
                    Visible = NPRAttrVisible02;
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetWorksheetLineAttributeValue(
                            DATABASE::"NPR Item Worksheet Line", 2, Rec."Worksheet Template Name",
                            Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[2]);
                    end;
                }
                field(NPRAttrTextArray_03; NPRAttrTextArray[3])
                {

                    CaptionClass = '6014555,27,3,2';
                    Editable = NPRAttrEditable;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[3] field.';
                    Visible = NPRAttrVisible03;
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetWorksheetLineAttributeValue(
                            DATABASE::"NPR Item Worksheet Line", 3, Rec."Worksheet Template Name",
                            Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[3]);
                    end;
                }
                field(NPRAttrTextArray_04; NPRAttrTextArray[4])
                {

                    CaptionClass = '6014555,27,4,2';
                    Editable = NPRAttrEditable;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[4] field.';
                    Visible = NPRAttrVisible04;
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetWorksheetLineAttributeValue(
                            DATABASE::"NPR Item Worksheet Line", 4, Rec."Worksheet Template Name",
                            Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[4]);
                    end;
                }
                field(NPRAttrTextArray_05; NPRAttrTextArray[5])
                {

                    CaptionClass = '6014555,27,5,2';
                    Editable = NPRAttrEditable;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[5] field.';
                    Visible = NPRAttrVisible05;
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetWorksheetLineAttributeValue(
                            DATABASE::"NPR Item Worksheet Line", 5, Rec."Worksheet Template Name",
                            Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[5]);
                    end;
                }
                field(NPRAttrTextArray_06; NPRAttrTextArray[6])
                {

                    CaptionClass = '6014555,27,6,2';
                    Editable = NPRAttrEditable;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[6] field.';
                    Visible = NPRAttrVisible06;
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetWorksheetLineAttributeValue(
                            DATABASE::"NPR Item Worksheet Line", 6, Rec."Worksheet Template Name",
                            Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[6]);
                    end;
                }
                field(NPRAttrTextArray_07; NPRAttrTextArray[7])
                {

                    CaptionClass = '6014555,27,7,2';
                    Editable = NPRAttrEditable;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[7] field.';
                    Visible = NPRAttrVisible07;
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetWorksheetLineAttributeValue(
                            DATABASE::"NPR Item Worksheet Line", 7, Rec."Worksheet Template Name",
                            Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[7]);
                    end;
                }
                field(NPRAttrTextArray_08; NPRAttrTextArray[8])
                {

                    CaptionClass = '6014555,27,8,2';
                    Editable = NPRAttrEditable;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[8] field.';
                    Visible = NPRAttrVisible08;
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetWorksheetLineAttributeValue(
                            DATABASE::"NPR Item Worksheet Line", 8, Rec."Worksheet Template Name",
                            Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[8]);
                    end;
                }
                field(NPRAttrTextArray_09; NPRAttrTextArray[9])
                {

                    CaptionClass = '6014555,27,9,2';
                    Editable = NPRAttrEditable;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[9] field.';
                    Visible = NPRAttrVisible09;
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetWorksheetLineAttributeValue(
                            DATABASE::"NPR Item Worksheet Line", 9, Rec."Worksheet Template Name",
                            Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[9]);
                    end;
                }
                field(NPRAttrTextArray_10; NPRAttrTextArray[10])
                {

                    CaptionClass = '6014555,27,10,2';
                    Editable = NPRAttrEditable;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[10] field.';
                    Visible = NPRAttrVisible10;
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetWorksheetLineAttributeValue(
                            DATABASE::"NPR Item Worksheet Line", 10, Rec."Worksheet Template Name",
                            Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[10]);
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
                ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;
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
                ToolTip = 'Executes the Existing Item action.';
                ApplicationArea = NPRRetail;
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
                    ToolTip = 'Executes the Create action.';
                    ApplicationArea = NPRRetail;
                }
                action("Variant Code")
                {

                    Caption = 'Variant code';
                    Image = ItemVariant;
                    ToolTip = 'Executes the Variant code action.';
                    ApplicationArea = NPRRetail;
                }
                action(Barcodes)
                {

                    Caption = 'Barcode';
                    Image = BarCode;
                    ToolTip = 'Executes the Barcode action.';
                    ApplicationArea = NPRRetail;
                }
                action(SalesPrice)
                {

                    Caption = 'Sales Prices';
                    Image = SalesPrices;
                    ToolTip = 'Executes the Sales Prices action.';
                    ApplicationArea = NPRRetail;
                }
                action("Purchase Price")
                {

                    Caption = 'Purchase Price';
                    Image = Price;
                    ToolTip = 'Executes the Purchase Price action.';
                    ApplicationArea = NPRRetail;
                }
                action("Supplier barcode")
                {

                    Caption = 'Supplier Barcode';
                    Image = "Action";
                    ToolTip = 'Executes the Supplier Barcode action.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Functions)
            {
                Caption = 'Functions';
                action("Suggest Worksheet Lines")
                {

                    Caption = 'Suggest Worksheet Lines';
                    Image = ItemWorksheet;
                    ToolTip = 'Executes the Suggest Worksheet Lines action.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Clear(SuggestItemWorksheetLines);
                        ItemWorksheet.Reset();
                        ItemWorksheet.SetRange("Item Template Name", Rec."Worksheet Template Name");
                        ItemWorksheet.SetRange(Name, Rec."Worksheet Name");
                        SuggestItemWorksheetLines.SetTableView(ItemWorksheet);
                        SuggestItemWorksheetLines.RunModal();
                        CurrPage.Update();
                    end;
                }
                action(CreateItems)
                {

                    Caption = 'Create Items';
                    Image = Create;
                    ToolTip = 'Executes the Create Items action.';
                    ApplicationArea = NPRRetail;
                }
                action(Controller)
                {

                    Caption = 'Controller';
                    Image = "Action";
                    ToolTip = 'Executes the Controller action.';
                    ApplicationArea = NPRRetail;
                }
                action("Import from Buffer")
                {

                    Caption = 'Import from Buffer';
                    Image = Import;
                    ToolTip = 'Executes the Import from Buffer action.';
                    ApplicationArea = NPRRetail;
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
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Executes the Request Extra Item Info action.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.CreateQueryItemInformation(false);
                    end;
                }
                action("Combine Varieties")
                {

                    Caption = 'Combine Varieties';
                    Image = BankAccountRec;
                    ToolTip = 'Executes the Combine Varieties action.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ItemWorksheetMgt.CombineLine(Rec, 0);
                        Commit();
                        Rec.RefreshVariants(0, true);
                        CurrPage.Update();
                    end;
                }
                action("Refresh Headers")
                {

                    Caption = 'Refresh Headers';
                    Image = UpdateDescription;
                    ToolTip = 'Executes the Refresh Headers action.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.RefreshVariants(0, true);
                        CurrPage.Update();
                    end;
                }
                action("Vendor Variety Value Mapping")
                {

                    Caption = 'Vendor Variety Value Mapping';
                    Image = MapAccounts;
                    RunObject = Page "NPR Item Worksh. Vrty. Mapping";
                    RunPageLink = "Vendor No." = FIELD("Vendor No.");
                    ToolTip = 'Executes the Vendor Variety Value Mapping action.';
                    ApplicationArea = NPRRetail;
                }
                action("Suggest Existing Variants")
                {

                    Caption = 'Suggest Existing Variants';
                    Image = SKU;
                    ToolTip = 'Executes the Suggest Existing Variants action.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.RefreshVariants(1, true);
                        CurrPage.Update();
                    end;
                }
                action("Suggest Varieties Without Variants")
                {

                    Caption = 'Suggest Varieties Without Variants';
                    Image = CreateSKU;
                    ToolTip = 'Executes the Suggest Varieties Without Variants action.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.RefreshVariants(2, true);
                        CurrPage.Update();
                    end;
                }
                action("Suggest all Varieties")
                {

                    Caption = 'Suggest all Varieties';
                    Image = ItemVariant;
                    ToolTip = 'Executes the Suggest all Varieties action.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.RefreshVariants(3, true);
                        CurrPage.Update();
                    end;
                }
                action(SetRRP)
                {

                    Caption = 'Set Sales Price to RRP';
                    Image = TransferFunds;
                    ToolTip = 'Executes the Set Sales Price to RRP action.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.UpdateSalesPriceWithRRP();
                    end;
                }
                action("Shelf Label")
                {

                    Caption = 'Shelf Label';
                    Image = BinContent;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = "Report";
                    ToolTip = 'Executes the Shelf Label action.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        ReportSelectionRetail: Record "NPR Report Selection Retail";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        LabelLibrary.ToggleLine(RecRef);
                        LabelLibrary.PrintSelection(ReportSelectionRetail."Report Type"::"Shelf Label");
                    end;
                }
                action("Price Label")
                {

                    Caption = 'Price Label';
                    Image = BinLedger;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = "Report";
                    ShortCutKey = 'Ctrl+Alt+L';
                    ToolTip = 'Executes the Price Label action.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        ReportSelectionRetail: Record "NPR Report Selection Retail";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        LabelLibrary.ToggleLine(RecRef);
                        LabelLibrary.PrintSelection(ReportSelectionRetail."Report Type"::"Price Label");
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
                    ToolTip = 'Executes the Combine All Varieties action.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        GetCurrentWorksheet();
                        ItemWorksheetMgt.CombineLines(ItemWorksheet);
                        Commit();
                        ItemWorksheetLine.Reset();
                        ItemWorksheetLine.SetRange("Worksheet Template Name", Rec."Worksheet Template Name");
                        ItemWorksheetLine.SetRange("Worksheet Name", Rec."Worksheet Name");
                        if ItemWorksheetLine.FindSet() then
                            repeat
                                ItemWorksheetLine.RefreshVariants(0, true);
                            until ItemWorksheetLine.Next() = 0;
                        CurrPage.Update();
                    end;
                }
                action("Refresh All Headers")
                {

                    Caption = 'Refresh All Headers';
                    Image = UpdateDescription;
                    ToolTip = 'Executes the Refresh All Headers action.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ItemWorksheetLine.Reset();
                        ItemWorksheetLine.SetRange("Worksheet Template Name", Rec."Worksheet Template Name");
                        ItemWorksheetLine.SetRange("Worksheet Name", Rec."Worksheet Name");
                        if ItemWorksheetLine.FindSet() then
                            repeat
                                ItemWorksheetLine.RefreshVariants(0, true);
                            until ItemWorksheetLine.Next() = 0;
                        CurrPage.Update();
                    end;
                }
                action("Suggest All Existing Variants")
                {

                    Caption = 'Suggest All Existing Variants';
                    Image = SKU;
                    ToolTip = 'Executes the Suggest All Existing Variants action.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ItemWorksheetLine.Reset();
                        ItemWorksheetLine.SetRange("Worksheet Template Name", Rec."Worksheet Template Name");
                        ItemWorksheetLine.SetRange("Worksheet Name", Rec."Worksheet Name");
                        if ItemWorksheetLine.FindSet() then
                            repeat
                                ItemWorksheetLine.RefreshVariants(1, true);
                            until ItemWorksheetLine.Next() = 0;
                        CurrPage.Update();
                    end;
                }
                action("Suggest All Varieties Without Variants")
                {

                    Caption = 'Suggest All Varieties Without Variants';
                    Image = CreateSKU;
                    ToolTip = 'Executes the Suggest All Varieties Without Variants action.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ItemWorksheetLine.Reset();
                        ItemWorksheetLine.SetRange("Worksheet Template Name", Rec."Worksheet Template Name");
                        ItemWorksheetLine.SetRange("Worksheet Name", Rec."Worksheet Name");
                        if ItemWorksheetLine.FindSet() then
                            repeat
                                ItemWorksheetLine.RefreshVariants(2, true);
                            until ItemWorksheetLine.Next() = 0;
                        CurrPage.Update();
                    end;
                }
                action("Suggest All Varieties in Worksheet")
                {

                    Caption = 'Suggest All Varieties in Worksheet';
                    Image = ItemVariant;
                    ToolTip = 'Executes the Suggest All Varieties in Worksheet action.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ItemWorksheetLine.Reset();
                        ItemWorksheetLine.SetRange("Worksheet Template Name", Rec."Worksheet Template Name");
                        ItemWorksheetLine.SetRange("Worksheet Name", Rec."Worksheet Name");
                        if ItemWorksheetLine.FindSet() then
                            repeat
                                ItemWorksheetLine.RefreshVariants(3, true);
                            until ItemWorksheetLine.Next() = 0;
                        CurrPage.Update();
                    end;
                }
                action(SetRRPAll)
                {

                    Caption = 'Set All Sales Prices to RRP';
                    Image = TransferFunds;
                    ToolTip = 'Executes the Set All Sales Prices to RRP action.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        GetCurrentWorksheet();
                        ItemWorksheet.UpdateSalesPriceAllLinesWithRRP();
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
                    ToolTip = 'Executes the Field Setup action.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        ItemWorksheetFieldSetup: Record "NPR Item Worksh. Field Setup";
                        ItemWorksheetFieldSetupPage: Page "NPR Item Worksh. Field Setup";
                    begin
                        GetCurrentWorksheet();
                        ItemWorksheet.InsertDefaultFieldSetup();
                        ItemWorksheetFieldSetup.SetFilter(ItemWorksheetFieldSetup."Worksheet Template Name", ItemWorksheet."Item Template Name");
                        ItemWorksheetFieldSetup.SetFilter("Worksheet Name", ItemWorksheet.Name);
                        ItemWorksheetFieldSetupPage.SetTableView(ItemWorksheetFieldSetup);
                        ItemWorksheetFieldSetupPage.Run();
                    end;
                }
                action("Check Lines")
                {

                    Caption = 'Check Lines';
                    Image = CheckList;
                    ToolTip = 'Executes the Check Lines action.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        GetCurrentWorksheet();
                        ItemWorksheet.CheckLines(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(Register)
                {

                    Caption = 'Register';
                    Image = Approve;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';
                    ToolTip = 'Executes the Register action.';
                    ApplicationArea = NPRRetail;

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
                    ToolTip = 'Executes the Map Excelsheet action.';
                    ApplicationArea = NPRRetail;
                }
                action("Export Excel")
                {

                    Caption = 'Export Excel';
                    Image = ExportToExcel;
                    ToolTip = 'Executes the Export Excel action.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        REPORT.Run(REPORT::"NPR Export Excel Item Worksh.", false, true, Rec);
                    end;
                }
                action("Import Excel")
                {

                    Caption = 'Import Excel';
                    Image = ImportExcel;
                    ToolTip = 'Executes the Import Excel action.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        GetCurrentWorksheet();
                        ItemWshtImpExpMgt.ImportFromExcel(ItemWorksheet);
                    end;
                }
                action("Import XML")
                {

                    Caption = 'Import XML';
                    Image = Import;
                    ToolTip = 'Executes the Import XML action.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ItemWshtImpExpMgt.Import();
                    end;
                }
                action("Export XML")
                {

                    Caption = 'Export XML';
                    Image = Export;
                    ToolTip = 'Executes the Export XML action.';
                    ApplicationArea = NPRRetail;

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
        SetFieldEditable();
        SetVisibleFields();
    end;

    trigger OnAfterGetRecord()
    begin
        NPRAttrManagement.GetWorksheetLineAttributeValue(NPRAttrTextArray, DATABASE::"NPR Item Worksheet Line", Rec."Worksheet Template Name", Rec."Worksheet Name", Rec."Line No.");
        NPRAttrEditable := CurrPage.Editable();
    end;

    trigger OnClosePage()
    begin
        ItemWorksheetMgt.OnCloseForm(Rec);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        Rec.CheckManualValidation();
        SetVisibleFields();
        exit(true);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.SetUpNewLine(xRec);
        SetFieldEditable();
    end;

    trigger OnOpenPage()
    begin
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
        if OpenedFromFilteredView then begin
            Rec.CopyFilters(ItemWorksheetLine);
            exit;
        end;

        OpenedFromWorksheet := (Rec."Worksheet Name" <> '') and (Rec."Worksheet Template Name" = '');
        if OpenedFromWorksheet then begin
            CurrentWorksheetName := Rec."Worksheet Name";
            ItemWorksheetMgt.OpenJnl(CurrentWorksheetName, Rec);
            exit;
        end;
        ItemWorksheetMgt.TemplateSelection(PAGE::"NPR Item Worksheet Page", Rec, WorksheetSelected);
        if not WorksheetSelected then
            Error('');
        ItemWorksheetMgt.OpenJnl(CurrentWorksheetName, Rec);
    end;

    var
        ItemWorksheet: Record "NPR Item Worksheet";
        ItemWorksheetLine: Record "NPR Item Worksheet Line";
        NPRAttrManagement: Codeunit "NPR Attribute Management";
        ItemWorksheetMgt: Codeunit "NPR Item Worksheet Mgt.";
        ItemWshtImpExpMgt: Codeunit "NPR Item Wsht. Imp. Exp.";
        LabelLibrary: Codeunit "NPR Label Library";
        SuggestItemWorksheetLines: Report "NPR Suggest Item Worksh. Lines";
        [InDataSet]
        FieldsEditable: Boolean;
        [InDataSet]
        NPRAttrEditable: Boolean;
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
        NPRAttrVisibleArray: array[40] of Boolean;
        OpenedFromFilteredView: Boolean;
        OpenedFromWorksheet: Boolean;
        RRPDiff: Boolean;
        WorksheetSelected: Boolean;
        CurrentWorksheetName: Code[10];
        ShowExpanded: Option "Variety 1","Variety 1+2","Variety 1+2+3","Variety 1+2+3+4";
        NPRAttrTextArray: array[40] of Text;

    procedure SetFieldEditable()
    begin
        FieldsEditable := (Rec."Existing Item No." = '');
    end;

    procedure GetCurrentWorksheet()
    begin
        ItemWorksheet.Get(Rec.GetRangeMax("Worksheet Template Name"), CurrentWorksheetName);
        ShowExpanded := ItemWorksheet."Show Variety Level";
    end;

    procedure SetVisibleFields()
    begin
        CurrPage.ItemWorksheetVarSubpage.PAGE.SetRecFromIW(Rec);
        CurrPage.ItemWorksheetVarSubpage.PAGE.UpdateSubPage();
        UpdateFactBoxes();
        RRPDiff := (Rec."Recommended Retail Price" <> 0) and (Rec."Sales Price" <> 0) and (Rec."Recommended Retail Price" <> Rec."Sales Price");
    end;

    local procedure CurrentJnlBatchNameOnAfterVali()
    begin
        CurrPage.SaveRecord();
        ItemWorksheetMgt.SetName(CurrentWorksheetName, Rec);
        CurrPage.Update(false);
    end;

    local procedure UpdateFactBoxes()
    begin
        CurrPage.ItemWorksheetFactBox.PAGE.Update();
        CurrPage.NPAttribFactBox.PAGE.Update();
    end;

    procedure OpenFilteredView(var VarItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
        ItemWorksheetLine.CopyFilters(VarItemWorksheetLine);
        ItemWorksheetLine.FindFirst();
        CurrentWorksheetName := VarItemWorksheetLine."Worksheet Name";
        OpenedFromFilteredView := true;
    end;
}

