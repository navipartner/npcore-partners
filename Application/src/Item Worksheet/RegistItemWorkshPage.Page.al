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
                }
                field("Date Time"; RegItemWorksheet."Registered Date Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("User ID"; RegItemWorksheet."Registered by User ID")
                {
                    ApplicationArea = All;
                    Editable = false;
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
                }
                field("Action"; Action)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Vendor Item No."; "Vendor Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Internal Bar Code"; "Internal Bar Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Vendors Bar Code"; "Vendors Bar Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Existing Item No."; "Existing Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Item Group"; "Item Group")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Status Comment"; "Status Comment")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Sales Price Start Date"; "Sales Price Start Date")
                {
                    ApplicationArea = All;
                }
                field("Unit Price (LCY)"; "Unit Price (LCY)")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Purchase Price Start Date"; "Purchase Price Start Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Direct Unit Cost"; "Direct Unit Cost")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Purchase Price Currency Code"; "Purchase Price Currency Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Use Variant"; "Use Variant")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Base Unit of Measure"; "Base Unit of Measure")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FieldsVisible;
                }
                field("Inventory Posting Group"; "Inventory Posting Group")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FieldsVisible;
                }
                field("Costing Method"; "Costing Method")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FieldsVisible;
                }
                field("VAT Bus. Posting Group"; "VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FieldsVisible;
                }
                field("VAT Bus. Posting Gr. (Price)"; "VAT Bus. Posting Gr. (Price)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FieldsVisible;
                }
                field("Gen. Prod. Posting Group"; "Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Tax Group Code"; "Tax Group Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("VAT Prod. Posting Group"; "VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FieldsVisible;
                }
                field("<Global Dimension 2 Code>s"; "Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FieldsVisible;
                }
                field("Sales Unit of Measure"; "Sales Unit of Measure")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FieldsVisible;
                }
                field("Purch. Unit of Measure"; "Purch. Unit of Measure")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FieldsVisible;
                }
                field("Manufacturer Code"; "Manufacturer Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FieldsVisible;
                }
                field("Item Category Code"; "Item Category Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FieldsVisible;
                }
                field("Product Group Code"; "Product Group Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FieldsVisible;
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
                    Editable = false;
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
                    Editable = false;
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
                    Editable = false;
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
                    HideValue = false;
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
                }
                action("Variant Code")
                {
                    Caption = 'Variant code';
                    Image = ItemVariant;
                    ApplicationArea = All;
                }
                action(Barcodes)
                {
                    Caption = 'Barcode';
                    Image = BarCode;
                    ApplicationArea = All;
                }
                action(SalesPrice)
                {
                    Caption = 'Sales Prices';
                    Image = SalesPrices;
                    ApplicationArea = All;
                }
                action("Purchase Price")
                {
                    Caption = 'Purchase Price';
                    Image = Price;
                    ApplicationArea = All;
                }
                action("Supplier barcode")
                {
                    Caption = 'Supplier Barcode';
                    Image = "Action";
                    ApplicationArea = All;
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
                }
                action(Controller)
                {
                    Caption = 'Controller';
                    Image = "Action";
                    ApplicationArea = All;
                }
                action("Import from Buffer")
                {
                    Caption = 'Import from Buffer';
                    Image = Import;
                    ApplicationArea = All;
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

