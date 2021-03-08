page 6060047 "NPR Regist. Item Worksh. Page"
{
    AutoSplitKey = true;
    Caption = 'Registered Item Worksheet Page';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Worksheet;
    PopulateAllFields = true;
    SaveValues = true;
    SourceTable = "NPR Regist. Item Worksh Line";
    UsageCategory = Administration;
    ApplicationArea = All; 

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Registered Worksheet No."; Rec."Registered Worksheet No.")
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
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                    Visible = false;
                }
                field("Action"; Rec.Action)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Action field';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Vendor No. field';
                }
                field("Vendor Item No."; Rec."Vendor Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Vendor Item No. field';
                }
                field("Internal Bar Code"; Rec."Internal Bar Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Internal Bar Code field';
                }
                field("Vendors Bar Code"; Rec."Vendors Bar Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Vendors Bar Code field';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Existing Item No."; Rec."Existing Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Existing Item No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Status Comment"; Rec."Status Comment")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Status Comment field';
                }
                field("Sales Price Start Date"; Rec."Sales Price Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Price Start Date field';
                }
                field("Unit Price (LCY)"; Rec."Unit Price (LCY)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
                field("Purchase Price Start Date"; Rec."Purchase Price Start Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Purchase Price Start Date field';
                }
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Direct Unit Cost field';
                }
                field("Purchase Price Currency Code"; Rec."Purchase Price Currency Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Purchase Price Currency Code field';
                }
                field("Use Variant"; Rec."Use Variant")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Use Variant field';
                }
                field("Base Unit of Measure"; Rec."Base Unit of Measure")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Base Unit of Measure field';
                    Visible = FieldsVisible;
                }
                field("Inventory Posting Group"; Rec."Inventory Posting Group")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Inventory Posting Group field';
                    Visible = FieldsVisible;
                }
                field("Costing Method"; Rec."Costing Method")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Costing Method field';
                    Visible = FieldsVisible;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Group field';
                    Visible = FieldsVisible;
                }
                field("VAT Bus. Posting Gr. (Price)"; Rec."VAT Bus. Posting Gr. (Price)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Gr. (Price) field';
                    Visible = FieldsVisible;
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Gen. Prod. Posting Group field';
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the No. Series field';
                }
                field("Tax Group Code"; Rec."Tax Group Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Tax Group Code field';
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the VAT Prod. Posting Group field';
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                    Visible = FieldsVisible;
                }
                field("<Global Dimension 2 Code>s"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                    Visible = FieldsVisible;
                }
                field("Sales Unit of Measure"; Rec."Sales Unit of Measure")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Sales Unit of Measure field';
                    Visible = FieldsVisible;
                }
                field("Purch. Unit of Measure"; Rec."Purch. Unit of Measure")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Purch. Unit of Measure field';
                    Visible = FieldsVisible;
                }
                field("Manufacturer Code"; Rec."Manufacturer Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Manufacturer Code field';
                    Visible = FieldsVisible;
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Item Category Code field';
                    Visible = FieldsVisible;
                }
                field("Product Group Code"; Rec."Product Group Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Product Group Code field';
                    Visible = FieldsVisible;
                }
                field("Variety 1"; Rec."Variety 1")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 1 field';
                }
                field("Variety 1 Table (Base)"; Rec."Variety 1 Table (Base)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 1 Table field';
                }
                field("Create Copy of Variety 1 Table"; Rec."Create Copy of Variety 1 Table")
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
                field("Variety 2 Table (Base)"; Rec."Variety 2 Table (Base)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 2 Table field';
                }
                field("Create Copy of Variety 2 Table"; Rec."Create Copy of Variety 2 Table")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Create Copy of Variety 2 Table field';
                }
                field("Variety 3"; Rec."Variety 3")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 3 field';
                }
                field("Variety 3 Table (Base)"; Rec."Variety 3 Table (Base)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 3 Table field';
                }
                field("Create Copy of Variety 3 Table"; Rec."Create Copy of Variety 3 Table")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Create Copy of Variety 3 Table field';
                }
                field("Variety 4"; Rec."Variety 4")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 4 field';
                }
                field("Variety 4 Table (Base)"; Rec."Variety 4 Table (Base)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 4 Table field';
                }
                field("Create Copy of Variety 4 Table"; Rec."Create Copy of Variety 4 Table")
                {
                    ApplicationArea = All;
                    HideValue = false;
                    ToolTip = 'Specifies the value of the Create Copy of Variety 4 Table field';
                }
            }
            part(ItemWorksheetVarSubpage; "NPR Reg. ItemWsht Var.Subpage")
            {
                ApplicationArea = All;
                Editable = false;
                ShowFilter = false;
                SubPageLink = "Registered Worksheet No." = FIELD("Registered Worksheet No."),
                              "Registered Worksheet Line No." = FIELD("Line No.");
                SubPageView = SORTING("Registered Worksheet No.", "Registered Worksheet Line No.", "Variety 1 Value", "Variety 2 Value", "Variety 3 Value", "Variety 4 Value")
                              ORDER(Ascending);
                UpdatePropagation = SubPart;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Item)
            {
                ApplicationArea = All;
                Caption = 'Item';
                Image = Item;
                RunObject = Page "Item Card";
                RunPageLink = "No." = FIELD("Item No.");
                RunPageView = SORTING("No.")
                              ORDER(Ascending);
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
                    ApplicationArea = All;
                    Caption = 'Create';
                    Image = CreateForm;
                    ToolTip = 'Executes the Create action';
                }
                action("Variant Code")
                {
                    ApplicationArea = All;
                    Caption = 'Variant code';
                    Image = ItemVariant;
                    ToolTip = 'Executes the Variant code action';
                }
                action(Barcodes)
                {
                    ApplicationArea = All;
                    Caption = 'Barcode';
                    Image = BarCode;
                    ToolTip = 'Executes the Barcode action';
                }
                action(SalesPrice)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Prices';
                    Image = SalesPrices;
                    ToolTip = 'Executes the Sales Prices action';
                }
                action("Purchase Price")
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Price';
                    Image = Price;
                    ToolTip = 'Executes the Purchase Price action';
                }
                action("Supplier barcode")
                {
                    ApplicationArea = All;
                    Caption = 'Supplier Barcode';
                    Image = "Action";
                    ToolTip = 'Executes the Supplier Barcode action';
                }
            }
            group(Functions)
            {
                Caption = 'Functions';
                action(CreateItems)
                {
                    ApplicationArea = All;
                    Caption = 'Create Items';
                    Image = Create;
                    ToolTip = 'Executes the Create Items action';
                }
                action(Controller)
                {
                    ApplicationArea = All;
                    Caption = 'Controller';
                    Image = "Action";
                    ToolTip = 'Executes the Controller action';
                }
                action("Import from Buffer")
                {
                    ApplicationArea = All;
                    Caption = 'Import from Buffer';
                    Image = Import;
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
        RegItemWorksheet: Record "NPR Registered Item Works.";
        SuggestItemWorksheetLines: Report "NPR Suggest Item Worksh. Lines";
        ItemWorksheetMgt: Codeunit "NPR Item Worksheet Mgt.";
        ItemWshtImpExpMgt: Codeunit "NPR Item Wsht. Imp. Exp.";
        [InDataSet]
        FieldsEditable: Boolean;
        [InDataSet]
        FieldsVisible: Boolean;
        OpenedFromWorksheet: Boolean;
        ShowAllInfo: Boolean;
        [InDataSet]
        VendorItemNoEditable: Boolean;
        WorksheetSelected: Boolean;
        CurrentWorksheetName: Code[10];
        InvoiceNo: Code[20];
        InvoiceDate: Date;
        Freight: Decimal;
        ShowExpanded: Option "Variety 1","Variety 1+2","Variety 1+2+3","Variety 1+2+3+4";

    procedure SetFieldEditable()
    begin
        FieldsEditable := (Rec."Existing Item No." = '');
    end;

    procedure GetCurrentWorksheet()
    begin
        RegItemWorksheet.Get(GetRangeMax("Registered Worksheet No."), CurrentWorksheetName);
    end;

    procedure SetVisibleFields()
    begin
        FieldsVisible := ShowAllInfo;
        CurrPage.ItemWorksheetVarSubpage.PAGE.SetRecFromIW(Rec);
        CurrPage.ItemWorksheetVarSubpage.PAGE.UpdateSubPage();
    end;
}

