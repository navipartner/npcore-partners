page 6060047 "NPR Regist. Item Worksh. Page"
{
    Extensible = False;
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
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Registered Worksheet No."; Rec."Registered Worksheet No.")
                {

                    ToolTip = 'Specifies the value of the Registered Worksheet No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Date Time"; RegItemWorksheet."Registered Date Time")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the RegItemWorksheet.Registered Date Time field';
                    ApplicationArea = NPRRetail;
                }
                field("User ID"; RegItemWorksheet."Registered by User ID")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the RegItemWorksheet.Registered by User ID field';
                    ApplicationArea = NPRRetail;
                }
            }
            repeater(Control6150622)
            {
                ShowCaption = false;
                field("Line No."; Rec."Line No.")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Action"; Rec.Action)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Action field';
                    ApplicationArea = NPRRetail;
                }
                field("Vendor No."; Rec."Vendor No.")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Vendor No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Vendor Item No."; Rec."Vendor Item No.")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Vendor Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Internal Bar Code"; Rec."Internal Bar Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Internal Bar Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Vendors Bar Code"; Rec."Vendors Bar Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Vendors Bar Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Item No."; Rec."Item No.")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Existing Item No."; Rec."Existing Item No.")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Existing Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Status Comment"; Rec."Status Comment")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Status Comment field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Price Start Date"; Rec."Sales Price Start Date")
                {

                    ToolTip = 'Specifies the value of the Sales Price Start Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price (LCY)"; Rec."Unit Price (LCY)")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Unit Price field';
                    ApplicationArea = NPRRetail;
                }
                field("Purchase Price Start Date"; Rec."Purchase Price Start Date")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Purchase Price Start Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Direct Unit Cost field';
                    ApplicationArea = NPRRetail;
                }
                field("Purchase Price Currency Code"; Rec."Purchase Price Currency Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Purchase Price Currency Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Use Variant"; Rec."Use Variant")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Use Variant field';
                    ApplicationArea = NPRRetail;
                }
                field("Base Unit of Measure"; Rec."Base Unit of Measure")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Base Unit of Measure field';
                    Visible = FieldsVisible;
                    ApplicationArea = NPRRetail;
                }
                field("Inventory Posting Group"; Rec."Inventory Posting Group")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Inventory Posting Group field';
                    Visible = FieldsVisible;
                    ApplicationArea = NPRRetail;
                }
                field("Costing Method"; Rec."Costing Method")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Costing Method field';
                    Visible = FieldsVisible;
                    ApplicationArea = NPRRetail;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Group field';
                    Visible = FieldsVisible;
                    ApplicationArea = NPRRetail;
                }
                field("VAT Bus. Posting Gr. (Price)"; Rec."VAT Bus. Posting Gr. (Price)")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Gr. (Price) field';
                    Visible = FieldsVisible;
                    ApplicationArea = NPRRetail;
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Gen. Prod. Posting Group field';
                    ApplicationArea = NPRRetail;
                }
                field("No. Series"; Rec."No. Series")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the No. Series field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax Group Code"; Rec."Tax Group Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Tax Group Code field';
                    ApplicationArea = NPRRetail;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the VAT Prod. Posting Group field';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                    Visible = FieldsVisible;
                    ApplicationArea = NPRRetail;
                }
                field("<Global Dimension 2 Code>s"; Rec."Global Dimension 2 Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                    Visible = FieldsVisible;
                    ApplicationArea = NPRRetail;
                }
                field("Sales Unit of Measure"; Rec."Sales Unit of Measure")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Sales Unit of Measure field';
                    Visible = FieldsVisible;
                    ApplicationArea = NPRRetail;
                }
                field("Purch. Unit of Measure"; Rec."Purch. Unit of Measure")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Purch. Unit of Measure field';
                    Visible = FieldsVisible;
                    ApplicationArea = NPRRetail;
                }
                field("Manufacturer Code"; Rec."Manufacturer Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Manufacturer Code field';
                    Visible = FieldsVisible;
                    ApplicationArea = NPRRetail;
                }
                field("Item Category Code"; Rec."Item Category Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Item Category Code field';
                    Visible = FieldsVisible;
                    ApplicationArea = NPRRetail;
                }
                field("Product Group Code"; Rec."Product Group Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Product Group Code field';
                    Visible = FieldsVisible;
                    ApplicationArea = NPRRetail;
                }
                field("Variety 1"; Rec."Variety 1")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 1 field';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 1 Table (Base)"; Rec."Variety 1 Table (Base)")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 1 Table field';
                    ApplicationArea = NPRRetail;
                }
                field("Create Copy of Variety 1 Table"; Rec."Create Copy of Variety 1 Table")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Create Copy of Variety 1 Table field';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 2"; Rec."Variety 2")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 2 Table (Base)"; Rec."Variety 2 Table (Base)")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 2 Table field';
                    ApplicationArea = NPRRetail;
                }
                field("Create Copy of Variety 2 Table"; Rec."Create Copy of Variety 2 Table")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Create Copy of Variety 2 Table field';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 3"; Rec."Variety 3")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 3 field';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 3 Table (Base)"; Rec."Variety 3 Table (Base)")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 3 Table field';
                    ApplicationArea = NPRRetail;
                }
                field("Create Copy of Variety 3 Table"; Rec."Create Copy of Variety 3 Table")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Create Copy of Variety 3 Table field';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 4"; Rec."Variety 4")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 4 field';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 4 Table (Base)"; Rec."Variety 4 Table (Base)")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 4 Table field';
                    ApplicationArea = NPRRetail;
                }
                field("Create Copy of Variety 4 Table"; Rec."Create Copy of Variety 4 Table")
                {

                    HideValue = false;
                    ToolTip = 'Specifies the value of the Create Copy of Variety 4 Table field';
                    ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;
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
                ToolTip = 'Executes the Item action';
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
                    ToolTip = 'Executes the Create action';
                    ApplicationArea = NPRRetail;
                }
                action("Variant Code")
                {

                    Caption = 'Variant code';
                    Image = ItemVariant;
                    ToolTip = 'Executes the Variant code action';
                    ApplicationArea = NPRRetail;
                }
                action(Barcodes)
                {

                    Caption = 'Barcode';
                    Image = BarCode;
                    ToolTip = 'Executes the Barcode action';
                    ApplicationArea = NPRRetail;
                }
                action(SalesPrice)
                {

                    Caption = 'Sales Prices';
                    Image = SalesPrices;
                    ToolTip = 'Executes the Sales Prices action';
                    ApplicationArea = NPRRetail;
                }
                action("Purchase Price")
                {

                    Caption = 'Purchase Price';
                    Image = Price;
                    ToolTip = 'Executes the Purchase Price action';
                    ApplicationArea = NPRRetail;
                }
                action("Supplier barcode")
                {

                    Caption = 'Supplier Barcode';
                    Image = "Action";
                    ToolTip = 'Executes the Supplier Barcode action';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Functions)
            {
                Caption = 'Functions';
                action(CreateItems)
                {

                    Caption = 'Create Items';
                    Image = Create;
                    ToolTip = 'Executes the Create Items action';
                    ApplicationArea = NPRRetail;
                }
                action(Controller)
                {

                    Caption = 'Controller';
                    Image = "Action";
                    ToolTip = 'Executes the Controller action';
                    ApplicationArea = NPRRetail;
                }
                action("Import from Buffer")
                {

                    Caption = 'Import from Buffer';
                    Image = Import;
                    ToolTip = 'Executes the Import from Buffer action';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        if not RegItemWorksheet.Get(Rec."Registered Worksheet No.") then
            RegItemWorksheet.Init();
        SetVisibleFields();
    end;

    var
        RegItemWorksheet: Record "NPR Registered Item Works.";
        [InDataSet]
        FieldsVisible: Boolean;
        ShowAllInfo: Boolean;
        CurrentWorksheetName: Code[10];

    procedure SetFieldEditable()
    begin
    end;

    procedure GetCurrentWorksheet()
    begin
        RegItemWorksheet.Get(Rec.GetRangeMax("Registered Worksheet No."), CurrentWorksheetName);
    end;

    procedure SetVisibleFields()
    begin
        FieldsVisible := ShowAllInfo;
        CurrPage.ItemWorksheetVarSubpage.PAGE.SetRecFromIW(Rec);
        CurrPage.ItemWorksheetVarSubpage.PAGE.UpdateSubPage();
    end;
}

