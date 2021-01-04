page 6060047 "NPR Regist. Item Worksh. Page"
{
    // NPR4.18\BR\20160209  CASE 182391 Object Created
    // NPR4.19\BR\20160308  CASE 182391 Added fields
    // NPR5.38\BR  \20171124  CASE 297587 Added fields Sales Price Start Date and Purchase Price Start Date
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action

    AutoSplitKey = true;
    Caption = 'Registered Item Worksheet Page';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Worksheet;
    UsageCategory = Administration;
    PopulateAllFields = true;
    SaveValues = true;
    SourceTable = "NPR Regist. Item Worksh Line";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Registered Worksheet No."; "Registered Worksheet No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Registered Worksheet No. field';
                }
                field("Date Time"; RegItemWorksheet."Registered Date Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the RegItemWorksheet.Registered Date Time field';
                }
                field("User ID"; RegItemWorksheet."Registered by User ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the RegItemWorksheet.Registered by User ID field';
                }
            }
            repeater(Control6150622)
            {
                ShowCaption = false;
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field("Action"; Action)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Action field';
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Vendor No. field';
                }
                field("Vendor Item No."; "Vendor Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Vendor Item No. field';
                }
                field("Internal Bar Code"; "Internal Bar Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Internal Bar Code field';
                }
                field("Vendors Bar Code"; "Vendors Bar Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Vendors Bar Code field';
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Existing Item No."; "Existing Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Existing Item No. field';
                }
                field("Item Group"; "Item Group")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Item Group field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Status Comment"; "Status Comment")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Status Comment field';
                }
                field("Sales Price Start Date"; "Sales Price Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Price Start Date field';
                }
                field("Unit Price (LCY)"; "Unit Price (LCY)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
                field("Purchase Price Start Date"; "Purchase Price Start Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Purchase Price Start Date field';
                }
                field("Direct Unit Cost"; "Direct Unit Cost")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Direct Unit Cost field';
                }
                field("Purchase Price Currency Code"; "Purchase Price Currency Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Purchase Price Currency Code field';
                }
                field("Use Variant"; "Use Variant")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Use Variant field';
                }
                field("Base Unit of Measure"; "Base Unit of Measure")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FieldsVisible;
                    ToolTip = 'Specifies the value of the Base Unit of Measure field';
                }
                field("Inventory Posting Group"; "Inventory Posting Group")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FieldsVisible;
                    ToolTip = 'Specifies the value of the Inventory Posting Group field';
                }
                field("Costing Method"; "Costing Method")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FieldsVisible;
                    ToolTip = 'Specifies the value of the Costing Method field';
                }
                field("VAT Bus. Posting Group"; "VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FieldsVisible;
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Group field';
                }
                field("VAT Bus. Posting Gr. (Price)"; "VAT Bus. Posting Gr. (Price)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FieldsVisible;
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Gr. (Price) field';
                }
                field("Gen. Prod. Posting Group"; "Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Gen. Prod. Posting Group field';
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the No. Series field';
                }
                field("Tax Group Code"; "Tax Group Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Tax Group Code field';
                }
                field("VAT Prod. Posting Group"; "VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the VAT Prod. Posting Group field';
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FieldsVisible;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                }
                field("<Global Dimension 2 Code>s"; "Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FieldsVisible;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                }
                field("Sales Unit of Measure"; "Sales Unit of Measure")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FieldsVisible;
                    ToolTip = 'Specifies the value of the Sales Unit of Measure field';
                }
                field("Purch. Unit of Measure"; "Purch. Unit of Measure")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FieldsVisible;
                    ToolTip = 'Specifies the value of the Purch. Unit of Measure field';
                }
                field("Manufacturer Code"; "Manufacturer Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FieldsVisible;
                    ToolTip = 'Specifies the value of the Manufacturer Code field';
                }
                field("Item Category Code"; "Item Category Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FieldsVisible;
                    ToolTip = 'Specifies the value of the Item Category Code field';
                }
                field("Product Group Code"; "Product Group Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FieldsVisible;
                    ToolTip = 'Specifies the value of the Product Group Code field';
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
                    Editable = false;
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
                    Editable = false;
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
                    Editable = false;
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
                    HideValue = false;
                    ToolTip = 'Specifies the value of the Create Copy of Variety 4 Table field';
                }
            }
            part(ItemWorksheetVarSubpage; "NPR Reg. ItemWsht Var.Subpage")
            {
                Editable = false;
                ShowFilter = false;
                SubPageLink = "Registered Worksheet No." = FIELD("Registered Worksheet No."),
                              "Registered Worksheet Line No." = FIELD("Line No.");
                SubPageView = SORTING("Registered Worksheet No.", "Registered Worksheet Line No.", "Variety 1 Value", "Variety 2 Value", "Variety 3 Value", "Variety 4 Value")
                              ORDER(Ascending);
                UpdatePropagation = SubPart;
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Item)
            {
                Caption = 'Item';
                Image = Item;
                RunObject = Page "Item Card";
                RunPageLink = "No." = FIELD("Item No.");
                RunPageView = SORTING("No.")
                              ORDER(Ascending);
                ApplicationArea = All;
                ToolTip = 'Executes the Item action';
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
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        if not RegItemWorksheet.Get("Registered Worksheet No.") then
            RegItemWorksheet.Init;
        SetVisibleFields;
    end;

    var
        ItemWorksheetTemplate: Record "NPR Item Worksh. Template";
        ItemWorksheetMgt: Codeunit "NPR Item Worksheet Mgt.";
        OpenedFromWorksheet: Boolean;
        CurrentWorksheetName: Code[10];
        WorksheetSelected: Boolean;
        RegItemWorksheet: Record "NPR Registered Item Works.";
        InvoiceNo: Code[20];
        InvoiceDate: Date;
        Freight: Decimal;
        ShowAllInfo: Boolean;
        [InDataSet]
        VendorItemNoEditable: Boolean;
        [InDataSet]
        FieldsEditable: Boolean;
        [InDataSet]
        FieldsVisible: Boolean;
        ShowExpanded: Option "Variety 1","Variety 1+2","Variety 1+2+3","Variety 1+2+3+4";
        SuggestItemWorksheetLines: Report "NPR Suggest Item Worksh. Lines";
        ItemWshtImpExpMgt: Codeunit "NPR Item Wsht. Imp. Exp.";

    procedure SetFieldEditable()
    begin
        //IF VendorItemNoEditable = ("Existing Item No." <> '') THEN
        //  EXIT;


        FieldsEditable := ("Existing Item No." = '');
    end;

    procedure GetCurrentWorksheet()
    begin
        RegItemWorksheet.Get(GetRangeMax("Registered Worksheet No."), CurrentWorksheetName);
        //ShowExpanded := RegItemWorksheet."Show Variety Level";
    end;

    procedure SetVisibleFields()
    begin
        FieldsVisible := ShowAllInfo;
        //CurrPage.UPDATE(FALSE);
        CurrPage.ItemWorksheetVarSubpage.PAGE.SetRecFromIW(Rec);
        CurrPage.ItemWorksheetVarSubpage.PAGE.UpdateSubPage;
    end;
}

