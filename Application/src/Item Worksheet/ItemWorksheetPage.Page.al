page 6060042 "NPR Item Worksheet Page"
{
    AutoSplitKey = true;
    Caption = 'Item Worksheet Page';
    DelayedInsert = false;
    PageType = Worksheet;
    PopulateAllFields = true;
    RefreshOnActivate = true;
    SaveValues = true;
    SourceTable = "NPR Item Worksheet Line";
    UsageCategory = Documents;
    ApplicationArea = All;

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
                    ToolTip = 'Specifies the value of the Batch Name field.';

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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ShowExpanded field.';

                    trigger OnValidate()
                    begin
                        if ItemWorksheet.Get(Rec."Worksheet Template Name", CurrentWorksheetName) then begin
                            ItemWorksheet."Show Variety Level" := ShowExpanded;
                            ItemWorksheet.Modify();
                            ItemWorksheet.Validate("Show Variety Level");
                            CurrPage.ItemWorksheetVarSubpage.PAGE.UpdateSubPage;
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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Worksheet Template Name field.';
                    Visible = false;
                }
                field("Worksheet Name"; Rec."Worksheet Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Worksheet Name field.';
                    Visible = false;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line No. field.';
                    Visible = false;
                }
                field("Action"; Rec.Action)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Action field.';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor No. field.';
                }
                field("Vendor Item No."; Rec."Vendor Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor Item No. field.';
                }
                field("Internal Bar Code"; Rec."Internal Bar Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Internal Bar Code field.';
                }
                field("Vendors Bar Code"; Rec."Vendors Bar Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendors Bar Code field.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Item No. field.';
                }
                field("Existing Item No."; Rec."Existing Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Existing Item No. field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description 2 field.';
                }
                field("Profit %"; Rec."Profit %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Percent of Profit field.';
                }
                field("Magento Item"; Rec."Magento Item")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Magento Item field.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field.';
                }
                field("Status Comment"; Rec."Status Comment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status Comment field.';
                }
                field("No. of Changes"; Rec."No. of Changes")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. of Changes field.';
                }
                field("No. of Warnings"; Rec."No. of Warnings")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. of Warnings field.';
                }
                field("Recommended Retail Price"; Rec."Recommended Retail Price")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = RRPDiff;
                    ToolTip = 'Specifies the value of the Recommended Retail Price field.';
                }
                field("Sales Price"; Rec."Sales Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Price field.';
                }
                field("Sales Price Currency Code"; Rec."Sales Price Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Price Currency Code field.';
                }
                field("Sales Price Start Date"; Rec."Sales Price Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Price Start Date field.';
                }
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Direct Unit Cost field.';
                }
                field("Purchase Price Currency Code"; Rec."Purchase Price Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchase Price Currency Code field.';
                }
                field("Purchase Price Start Date"; Rec."Purchase Price Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchase Price Start Date field.';
                }
                field("Use Variant"; Rec."Use Variant")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Use Variant field.';
                }
                field("Tariff No."; Rec."Tariff No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tariff No. field.';
                }
                field("Base Unit of Measure"; Rec."Base Unit of Measure")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Base Unit of Measure field.';
                    Visible = false;
                }
                field("Inventory Posting Group"; Rec."Inventory Posting Group")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Inventory Posting Group field.';
                    Visible = false;
                }
                field("Costing Method"; Rec."Costing Method")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Costing Method field.';
                    Visible = false;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Group field.';
                    Visible = false;
                }
                field("VAT Bus. Posting Gr. (Price)"; Rec."VAT Bus. Posting Gr. (Price)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Gr. (Price) field.';
                    Visible = false;
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Gen. Prod. Posting Group field.';
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the No. Series field.';
                }
                field("Tax Group Code"; Rec."Tax Group Code")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Tax Group Code field.';
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the VAT Prod. Posting Group field.';
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field.';
                    Visible = false;
                }
                field("<Global Dimension 2 Code>s"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field.';
                    Visible = false;
                }
                field("Sales Unit of Measure"; Rec."Sales Unit of Measure")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Sales Unit of Measure field.';
                    Visible = false;
                }
                field("Purch. Unit of Measure"; Rec."Purch. Unit of Measure")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Purch. Unit of Measure field.';
                    Visible = false;
                }
                field("Manufacturer Code"; Rec."Manufacturer Code")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Manufacturer Code field.';
                    Visible = false;
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Item Category Code field.';
                }
                field("Product Group Code"; Rec."Product Group Code")
                {
                    ApplicationArea = All;
                    Editable = FieldsEditable;
                    ToolTip = 'Specifies the value of the Product Group Code field.';
                }
                field("Gross Weight"; Rec."Gross Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gross Weight field.';
                }
                field("Net Weight"; Rec."Net Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Net Weight field.';
                }
                field("Units per Parcel"; Rec."Units per Parcel")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Units per Parcel field.';
                }
                field("Variety Group"; Rec."Variety Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety Group field.';
                }
                field("Variety 1"; Rec."Variety 1")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 1 field.';
                }
                field("Variety 1 Table (Base)"; Rec."Variety 1 Table (Base)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 1 Table field.';
                }
                field("Create Copy of Variety 1 Table"; Rec."Create Copy of Variety 1 Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Copy of Variety 1 Table field.';
                }
                field("Variety 2"; Rec."Variety 2")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 2 field.';
                }
                field("Variety 2 Table (Base)"; Rec."Variety 2 Table (Base)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 2 Table field.';
                }
                field("Create Copy of Variety 2 Table"; Rec."Create Copy of Variety 2 Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Copy of Variety 2 Table field.';
                }
                field("Variety 3"; Rec."Variety 3")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 3 field.';
                }
                field("Variety 3 Table (Base)"; Rec."Variety 3 Table (Base)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 3 Table field.';
                }
                field("Create Copy of Variety 3 Table"; Rec."Create Copy of Variety 3 Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Copy of Variety 3 Table field.';
                }
                field("Variety 4"; Rec."Variety 4")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 4 field.';
                }
                field("Variety 4 Table (Base)"; Rec."Variety 4 Table (Base)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 4 Table field.';
                }
                field("Create Copy of Variety 4 Table"; Rec."Create Copy of Variety 4 Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Copy of Variety 4 Table field.';
                }
                field("Variety Lines to Skip"; Rec."Variety Lines to Skip")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety Lines to Skip field.';
                }
                field("Variety Lines to Update"; Rec."Variety Lines to Update")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety Lines to Update field.';
                }
                field("Variety Lines to Create"; Rec."Variety Lines to Create")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety Lines to Create field.';
                }
                field(NPRAttrTextArray_01; NPRAttrTextArray[1])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,1,2';
                    Editable = NPRAttrEditable;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[1] field.';
                    Visible = NPRAttrVisible01;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetWorksheetLineAttributeValue(
                            DATABASE::"NPR Item Worksheet Line", 1, Rec."Worksheet Template Name",
                            Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[1]);
                    end;
                }
                field(NPRAttrTextArray_02; NPRAttrTextArray[2])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,2,2';
                    Editable = NPRAttrEditable;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[2] field.';
                    Visible = NPRAttrVisible02;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetWorksheetLineAttributeValue(
                            DATABASE::"NPR Item Worksheet Line", 2, Rec."Worksheet Template Name",
                            Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[2]);
                    end;
                }
                field(NPRAttrTextArray_03; NPRAttrTextArray[3])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,3,2';
                    Editable = NPRAttrEditable;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[3] field.';
                    Visible = NPRAttrVisible03;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetWorksheetLineAttributeValue(
                            DATABASE::"NPR Item Worksheet Line", 3, Rec."Worksheet Template Name",
                            Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[3]);
                    end;
                }
                field(NPRAttrTextArray_04; NPRAttrTextArray[4])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,4,2';
                    Editable = NPRAttrEditable;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[4] field.';
                    Visible = NPRAttrVisible04;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetWorksheetLineAttributeValue(
                            DATABASE::"NPR Item Worksheet Line", 4, Rec."Worksheet Template Name",
                            Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[4]);
                    end;
                }
                field(NPRAttrTextArray_05; NPRAttrTextArray[5])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,5,2';
                    Editable = NPRAttrEditable;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[5] field.';
                    Visible = NPRAttrVisible05;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetWorksheetLineAttributeValue(
                            DATABASE::"NPR Item Worksheet Line", 5, Rec."Worksheet Template Name",
                            Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[5]);
                    end;
                }
                field(NPRAttrTextArray_06; NPRAttrTextArray[6])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,6,2';
                    Editable = NPRAttrEditable;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[6] field.';
                    Visible = NPRAttrVisible06;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetWorksheetLineAttributeValue(
                            DATABASE::"NPR Item Worksheet Line", 6, Rec."Worksheet Template Name",
                            Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[6]);
                    end;
                }
                field(NPRAttrTextArray_07; NPRAttrTextArray[7])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,7,2';
                    Editable = NPRAttrEditable;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[7] field.';
                    Visible = NPRAttrVisible07;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetWorksheetLineAttributeValue(
                            DATABASE::"NPR Item Worksheet Line", 7, Rec."Worksheet Template Name",
                            Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[7]);
                    end;
                }
                field(NPRAttrTextArray_08; NPRAttrTextArray[8])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,8,2';
                    Editable = NPRAttrEditable;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[8] field.';
                    Visible = NPRAttrVisible08;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetWorksheetLineAttributeValue(
                            DATABASE::"NPR Item Worksheet Line", 8, Rec."Worksheet Template Name",
                            Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[8]);
                    end;
                }
                field(NPRAttrTextArray_09; NPRAttrTextArray[9])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,9,2';
                    Editable = NPRAttrEditable;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[9] field.';
                    Visible = NPRAttrVisible09;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetWorksheetLineAttributeValue(
                            DATABASE::"NPR Item Worksheet Line", 9, Rec."Worksheet Template Name",
                            Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[9]);
                    end;
                }
                field(NPRAttrTextArray_10; NPRAttrTextArray[10])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,27,10,2';
                    Editable = NPRAttrEditable;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[10] field.';
                    Visible = NPRAttrVisible10;

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
                ApplicationArea = All;
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
            part(ItemWorksheetFactBox; "NPR Item Worksheet FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Worksheet Template Name" = FIELD("Worksheet Template Name"),
                              "Worksheet Name" = FIELD("Worksheet Name"),
                              "Line No." = FIELD("Line No.");
                Visible = true;
            }
            part(NPAttribFactBox; "NPR Item Worksh. Attr. FactBox")
            {
                ApplicationArea = All;
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
                ApplicationArea = All;
                Caption = 'Existing Item';
                Image = Item;
                RunObject = Page "Item Card";
                RunPageLink = "No." = FIELD("Existing Item No.");
                RunPageView = SORTING("No.")
                              ORDER(Ascending);
                ToolTip = 'Executes the Existing Item action.';
            }
        }
        area(processing)
        {
            group("Variant")
            {
                Caption = 'Variant';
                action(Create)
                {
                    ApplicationArea = All;
                    Caption = 'Create';
                    Image = CreateForm;
                    ToolTip = 'Executes the Create action.';
                }
                action("Variant Code")
                {
                    ApplicationArea = All;
                    Caption = 'Variant code';
                    Image = ItemVariant;
                    ToolTip = 'Executes the Variant code action.';
                }
                action(Barcodes)
                {
                    ApplicationArea = All;
                    Caption = 'Barcode';
                    Image = BarCode;
                    ToolTip = 'Executes the Barcode action.';
                }
                action(SalesPrice)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Prices';
                    Image = SalesPrices;
                    ToolTip = 'Executes the Sales Prices action.';
                }
                action("Purchase Price")
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Price';
                    Image = Price;
                    ToolTip = 'Executes the Purchase Price action.';
                }
                action("Supplier barcode")
                {
                    ApplicationArea = All;
                    Caption = 'Supplier Barcode';
                    Image = "Action";
                    ToolTip = 'Executes the Supplier Barcode action.';
                }
            }
            group(Functions)
            {
                Caption = 'Functions';
                action("Suggest Worksheet Lines")
                {
                    ApplicationArea = All;
                    Caption = 'Suggest Worksheet Lines';
                    Image = ItemWorksheet;
                    ToolTip = 'Executes the Suggest Worksheet Lines action.';

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
                    ApplicationArea = All;
                    Caption = 'Create Items';
                    Image = Create;
                    ToolTip = 'Executes the Create Items action.';
                }
                action(Controller)
                {
                    ApplicationArea = All;
                    Caption = 'Controller';
                    Image = "Action";
                    ToolTip = 'Executes the Controller action.';
                }
                action("Import from Buffer")
                {
                    ApplicationArea = All;
                    Caption = 'Import from Buffer';
                    Image = Import;
                    ToolTip = 'Executes the Import from Buffer action.';
                }
            }
            group("Worksheet Line")
            {
                Caption = 'Worksheet Line';
                action(QueryItemInfo)
                {
                    ApplicationArea = All;
                    Caption = 'Request Extra Item Info';
                    Image = CoupledItem;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Executes the Request Extra Item Info action.';

                    trigger OnAction()
                    begin
                        Rec.CreateQueryItemInformation(false);
                    end;
                }
                action("Combine Varieties")
                {
                    ApplicationArea = All;
                    Caption = 'Combine Varieties';
                    Image = BankAccountRec;
                    ToolTip = 'Executes the Combine Varieties action.';

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
                    ApplicationArea = All;
                    Caption = 'Refresh Headers';
                    Image = UpdateDescription;
                    ToolTip = 'Executes the Refresh Headers action.';

                    trigger OnAction()
                    begin
                        Rec.RefreshVariants(0, true);
                        CurrPage.Update();
                    end;
                }
                action("Vendor Variety Value Mapping")
                {
                    ApplicationArea = All;
                    Caption = 'Vendor Variety Value Mapping';
                    Image = MapAccounts;
                    RunObject = Page "NPR Item Worksh. Vrty. Mapping";
                    RunPageLink = "Vendor No." = FIELD("Vendor No.");
                    ToolTip = 'Executes the Vendor Variety Value Mapping action.';
                }
                action("Suggest Existing Variants")
                {
                    ApplicationArea = All;
                    Caption = 'Suggest Existing Variants';
                    Image = SKU;
                    ToolTip = 'Executes the Suggest Existing Variants action.';

                    trigger OnAction()
                    begin
                        Rec.RefreshVariants(1, true);
                        CurrPage.Update();
                    end;
                }
                action("Suggest Varieties Without Variants")
                {
                    ApplicationArea = All;
                    Caption = 'Suggest Varieties Without Variants';
                    Image = CreateSKU;
                    ToolTip = 'Executes the Suggest Varieties Without Variants action.';

                    trigger OnAction()
                    begin
                        Rec.RefreshVariants(2, true);
                        CurrPage.Update();
                    end;
                }
                action("Suggest all Varieties")
                {
                    ApplicationArea = All;
                    Caption = 'Suggest all Varieties';
                    Image = ItemVariant;
                    ToolTip = 'Executes the Suggest all Varieties action.';

                    trigger OnAction()
                    begin
                        Rec.RefreshVariants(3, true);
                        CurrPage.Update();
                    end;
                }
                action(SetRRP)
                {
                    ApplicationArea = All;
                    Caption = 'Set Sales Price to RRP';
                    Image = TransferFunds;
                    ToolTip = 'Executes the Set Sales Price to RRP action.';

                    trigger OnAction()
                    begin
                        Rec.UpdateSalesPriceWithRRP();
                    end;
                }
                action("Shelf Label")
                {
                    ApplicationArea = All;
                    Caption = 'Shelf Label';
                    Image = BinContent;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = "Report";
                    ToolTip = 'Executes the Shelf Label action.';

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
                    ApplicationArea = All;
                    Caption = 'Price Label';
                    Image = BinLedger;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = "Report";
                    ShortCutKey = 'Ctrl+Alt+L';
                    ToolTip = 'Executes the Price Label action.';

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
                    ApplicationArea = All;
                    Caption = 'Combine All Varieties';
                    Image = BankAccountRec;
                    ToolTip = 'Executes the Combine All Varieties action.';

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
                    ApplicationArea = All;
                    Caption = 'Refresh All Headers';
                    Image = UpdateDescription;
                    ToolTip = 'Executes the Refresh All Headers action.';

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
                    ApplicationArea = All;
                    Caption = 'Suggest All Existing Variants';
                    Image = SKU;
                    ToolTip = 'Executes the Suggest All Existing Variants action.';

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
                    ApplicationArea = All;
                    Caption = 'Suggest All Varieties Without Variants';
                    Image = CreateSKU;
                    ToolTip = 'Executes the Suggest All Varieties Without Variants action.';

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
                    ApplicationArea = All;
                    Caption = 'Suggest All Varieties in Worksheet';
                    Image = ItemVariant;
                    ToolTip = 'Executes the Suggest All Varieties in Worksheet action.';

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
                    ApplicationArea = All;
                    Caption = 'Set All Sales Prices to RRP';
                    Image = TransferFunds;
                    ToolTip = 'Executes the Set All Sales Prices to RRP action.';

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
                    ApplicationArea = All;
                    Caption = 'Field Setup';
                    Image = MapAccounts;
                    ToolTip = 'Executes the Field Setup action.';

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
                    ApplicationArea = All;
                    Caption = 'Check Lines';
                    Image = CheckList;
                    ToolTip = 'Executes the Check Lines action.';

                    trigger OnAction()
                    begin
                        GetCurrentWorksheet();
                        ItemWorksheet.CheckLines(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(Register)
                {
                    ApplicationArea = All;
                    Caption = 'Register';
                    Image = Approve;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';
                    ToolTip = 'Executes the Register action.';

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
                    ApplicationArea = All;
                    Caption = 'Map Excelsheet';
                    Image = MapAccounts;
                    RunObject = Page "NPR Item Works. Excel Column";
                    RunPageLink = "Worksheet Template Name" = FIELD("Worksheet Template Name"),
                                  "Worksheet Name" = FIELD("Worksheet Name");
                    ToolTip = 'Executes the Map Excelsheet action.';
                }
                action("Export Excel")
                {
                    ApplicationArea = All;
                    Caption = 'Export Excel';
                    Image = ExportToExcel;
                    ToolTip = 'Executes the Export Excel action.';

                    trigger OnAction()
                    begin
                        REPORT.Run(REPORT::"NPR Export Excel Item Worksh.", false, true, Rec);
                    end;
                }
                action("Import Excel")
                {
                    ApplicationArea = All;
                    Caption = 'Import Excel';
                    Image = ImportExcel;
                    ToolTip = 'Executes the Import Excel action.';

                    trigger OnAction()
                    begin
                        GetCurrentWorksheet;
                        ItemWshtImpExpMgt.ImportFromExcel(ItemWorksheet);
                    end;
                }
                action("Import XML")
                {
                    ApplicationArea = All;
                    Caption = 'Import XML';
                    Image = Import;
                    ToolTip = 'Executes the Import XML action.';

                    trigger OnAction()
                    begin
                        ItemWshtImpExpMgt.Import();
                    end;
                }
                action("Export XML")
                {
                    ApplicationArea = All;
                    Caption = 'Export XML';
                    Image = Export;
                    ToolTip = 'Executes the Export XML action.';

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
        CurrPage.ItemWorksheetVarSubpage.PAGE.UpdateSubPage;
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

