page 6060047 "Registered Item Worksheet Page"
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
    PopulateAllFields = true;
    SaveValues = true;
    SourceTable = "Registered Item Worksheet Line";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Registered Worksheet No.";"Registered Worksheet No.")
                {
                }
                field("Date Time";RegItemWorksheet."Registered Date Time")
                {
                    Editable = false;
                }
                field("User ID";RegItemWorksheet."Registered by User ID")
                {
                    Editable = false;
                }
            }
            repeater(Control6150622)
            {
                ShowCaption = false;
                field("Line No.";"Line No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Action";Action)
                {
                    Editable = false;
                }
                field("Vendor No.";"Vendor No.")
                {
                    Editable = false;
                }
                field("Vendor Item No.";"Vendor Item No.")
                {
                    Editable = false;
                }
                field("Internal Bar Code";"Internal Bar Code")
                {
                    Editable = false;
                }
                field("Vendors Bar Code";"Vendors Bar Code")
                {
                    Editable = false;
                }
                field("Item No.";"Item No.")
                {
                    Editable = false;
                }
                field("Existing Item No.";"Existing Item No.")
                {
                    Editable = false;
                }
                field("Item Group";"Item Group")
                {
                    Editable = false;
                }
                field(Description;Description)
                {
                    Editable = false;
                }
                field(Status;Status)
                {
                    Editable = false;
                }
                field("Status Comment";"Status Comment")
                {
                    Editable = false;
                }
                field("Sales Price Start Date";"Sales Price Start Date")
                {
                }
                field("Unit Price (LCY)";"Unit Price (LCY)")
                {
                    Editable = false;
                }
                field("Purchase Price Start Date";"Purchase Price Start Date")
                {
                    Editable = false;
                }
                field("Direct Unit Cost";"Direct Unit Cost")
                {
                    Editable = false;
                }
                field("Purchase Price Currency Code";"Purchase Price Currency Code")
                {
                    Editable = false;
                }
                field("Use Variant";"Use Variant")
                {
                    Editable = false;
                }
                field("Base Unit of Measure";"Base Unit of Measure")
                {
                    Editable = false;
                    Visible = FieldsVisible;
                }
                field("Inventory Posting Group";"Inventory Posting Group")
                {
                    Editable = false;
                    Visible = FieldsVisible;
                }
                field("Costing Method";"Costing Method")
                {
                    Editable = false;
                    Visible = FieldsVisible;
                }
                field("VAT Bus. Posting Group";"VAT Bus. Posting Group")
                {
                    Editable = false;
                    Visible = FieldsVisible;
                }
                field("VAT Bus. Posting Gr. (Price)";"VAT Bus. Posting Gr. (Price)")
                {
                    Editable = false;
                    Visible = FieldsVisible;
                }
                field("Gen. Prod. Posting Group";"Gen. Prod. Posting Group")
                {
                    Editable = false;
                }
                field("No. Series";"No. Series")
                {
                    Editable = false;
                }
                field("Tax Group Code";"Tax Group Code")
                {
                    Editable = false;
                }
                field("VAT Prod. Posting Group";"VAT Prod. Posting Group")
                {
                    Editable = false;
                }
                field("Global Dimension 1 Code";"Global Dimension 1 Code")
                {
                    Editable = false;
                    Visible = FieldsVisible;
                }
                field("<Global Dimension 2 Code>s";"Global Dimension 2 Code")
                {
                    Editable = false;
                    Visible = FieldsVisible;
                }
                field("Sales Unit of Measure";"Sales Unit of Measure")
                {
                    Editable = false;
                    Visible = FieldsVisible;
                }
                field("Purch. Unit of Measure";"Purch. Unit of Measure")
                {
                    Editable = false;
                    Visible = FieldsVisible;
                }
                field("Manufacturer Code";"Manufacturer Code")
                {
                    Editable = false;
                    Visible = FieldsVisible;
                }
                field("Item Category Code";"Item Category Code")
                {
                    Editable = false;
                    Visible = FieldsVisible;
                }
                field("Product Group Code";"Product Group Code")
                {
                    Editable = false;
                    Visible = FieldsVisible;
                }
                field("Variety 1";"Variety 1")
                {
                    Editable = false;
                }
                field("Variety 1 Table (Base)";"Variety 1 Table (Base)")
                {
                    Editable = false;
                }
                field("Create Copy of Variety 1 Table";"Create Copy of Variety 1 Table")
                {
                    Editable = false;
                }
                field("Variety 2";"Variety 2")
                {
                    Editable = false;
                }
                field("Variety 2 Table (Base)";"Variety 2 Table (Base)")
                {
                    Editable = false;
                }
                field("Create Copy of Variety 2 Table";"Create Copy of Variety 2 Table")
                {
                    Editable = false;
                }
                field("Variety 3";"Variety 3")
                {
                    Editable = false;
                }
                field("Variety 3 Table (Base)";"Variety 3 Table (Base)")
                {
                    Editable = false;
                }
                field("Create Copy of Variety 3 Table";"Create Copy of Variety 3 Table")
                {
                    Editable = false;
                }
                field("Variety 4";"Variety 4")
                {
                    Editable = false;
                }
                field("Variety 4 Table (Base)";"Variety 4 Table (Base)")
                {
                    Editable = false;
                }
                field("Create Copy of Variety 4 Table";"Create Copy of Variety 4 Table")
                {
                    HideValue = false;
                }
            }
            part(ItemWorksheetVarSubpage;"Reg. Item Wsht Variety Subpage")
            {
                Editable = false;
                ShowFilter = false;
                SubPageLink = "Registered Worksheet No."=FIELD("Registered Worksheet No."),
                              "Registered Worksheet Line No."=FIELD("Line No.");
                SubPageView = SORTING("Registered Worksheet No.","Registered Worksheet Line No.","Variety 1 Value","Variety 2 Value","Variety 3 Value","Variety 4 Value")
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
                Caption = 'Item';
                Image = Item;
                RunObject = Page "Retail Item Card";
                RunPageLink = "No."=FIELD("Item No.");
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
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        if not RegItemWorksheet.Get("Registered Worksheet No.") then
          RegItemWorksheet.Init;
        SetVisibleFields;
    end;

    var
        ItemWorksheetTemplate: Record "Item Worksheet Template";
        ItemWorksheetMgt: Codeunit "Item Worksheet Management";
        OpenedFromWorksheet: Boolean;
        CurrentWorksheetName: Code[10];
        WorksheetSelected: Boolean;
        RegItemWorksheet: Record "Registered Item Worksheet";
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
        SuggestItemWorksheetLines: Report "Suggest Item Worksheet Lines";
        ItemWshtImpExpMgt: Codeunit "Item Wsht. Imp. Exp. Mgt.";

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
        FieldsVisible:=ShowAllInfo;
        //CurrPage.UPDATE(FALSE);
        CurrPage.ItemWorksheetVarSubpage.PAGE.SetRecFromIW(Rec);
        CurrPage.ItemWorksheetVarSubpage.PAGE.UpdateSubPage;
    end;
}

