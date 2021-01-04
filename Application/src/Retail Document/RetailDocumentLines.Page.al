page 6014470 "NPR Retail Document Lines"
{
    // 
    // NPK, MIM 01-09-2007: Rettet form til at overholde GUI retningslinjer.
    // NPR4.000.002, NPK, 01-05-09, MH, Tilf¢jet lookup på alternativt varenummer.
    // NPR4.000.004, NPK, 11-06-09, MH - Tilf¢jet feltet "Lock Code" (sag 65422).
    // 
    // NPK TS 18.10.12  : Commented code Update Control to use Page Property RefreshonActivate
    // NPK TS 18.10.12  : The Visible property of these fields have bben commented and replace by boolean variables to allow the valu to be set on the page
    // 
    // NPR4.12/TSA/20150630 CASE 217683 - Auto-Merge problem, Removed empty/blank function name
    // NPR5.29/TS/20161110  CASE 257587 Added Location Code
    // NPR5.48/TS  /20181220 CASE 335677 Enabled AutoSplitKey
    // NPR5.52/YAHA/20191010 CASE 372273 Added field size and moved variant code after description

    AutoSplitKey = true;
    Caption = 'Rental Sub Form';
    Editable = true;
    PageType = ListPart;
    UsageCategory = Administration;
    RefreshOnActivate = true;
    SourceTable = "NPR Retail Document Lines";
    SourceTableView = SORTING("Document Type", "Document No.", "Line No.");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Serial No."; "Serial No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Serial No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field(Size; Size)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Size field';
                }
                field("Lock Code"; "Lock Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Lock Code field';
                }
                field("Serial No. not Created"; "Serial No. not Created")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Serial No. not Created field';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Quantity in order"; "Quantity in order")
                {
                    ApplicationArea = All;
                    Visible = FieldQtyInOrder;
                    ToolTip = 'Specifies the value of the Quantity in order field';
                }
                field("Quantity received"; "Quantity received")
                {
                    ApplicationArea = All;
                    Visible = FieldQuantityReceived;
                    ToolTip = 'Specifies the value of the Quantity received field';
                }
                field("Qty. to Ship"; "Qty. to Ship")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Qty. to Ship field';
                }
                field("Quantity Shipped"; "Quantity Shipped")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity Shipped field';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field("Received last"; "Received last")
                {
                    ApplicationArea = All;
                    Visible = FieldReceivedLast;
                    ToolTip = 'Specifies the value of the Received last field';
                }
                field("Letter printed"; "Letter printed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Letter printed field';
                }
                field("Return Reason Code"; "Return Reason Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Return Reason Code field';
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reason Code field';
                }
                field("Rental Amount incl. VAT"; "Rental Amount incl. VAT")
                {
                    ApplicationArea = All;
                    Visible = FieldRentIncVat;
                    ToolTip = 'Specifies the value of the Rental Amount incl. VAT field';
                }
                field("Unit price"; "Unit price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
                field("Line discount %"; "Line discount %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Discount % field';
                }
                field("Line discount amount"; "Line discount amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Discount Amount field';
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Including VAT field';
                }
                field("Package quantity"; "Package quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Package quantity field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnDeleteRecord(): Boolean
    begin

        case Type of
            Type::Item:
                begin
                    //Delete Accesories and BOM
                    RetailDocHandlingCU.UnfoldItemsDelete(Rec);
                end;
        end;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        "Rental Header".Get("Document Type", "Document No.");

        case Type of
            Type::Item:
                begin
                    //+Unfold Accessories
                    RetailDocHandlingCU.UnfoldAccessories(Rec);
                    //-Unfold Accessories

                    //+Unfold BOM
                    RetailDocHandlingCU.UnfoldBOM(Rec, '');
                    //-Unfold BOM
                end;
        end;
    end;

    trigger OnModifyRecord(): Boolean
    begin

        case Type of
            Type::Item:
                begin
                    //Update Accesories and BOM
                    RetailDocHandlingCU.UnfoldItemsUpdate(Rec);
                end;
        end;
    end;

    var
        RetailDocHandlingCU: Codeunit "NPR Retail Document Handling";
        "Rental Header": Record "NPR Retail Document Header";
        "Retail Document Lines": Record "NPR Retail Document Lines";
        Text1060001: Label 'In a retail order sold using the register (Via = POS), it is only possible to add extra items using the register.';
        [InDataSet]
        FieldRentIncVat: Boolean;
        [InDataSet]
        FieldQuantityReceived: Boolean;
        [InDataSet]
        FieldReceivedLast: Boolean;
        [InDataSet]
        FieldQtyInOrder: Boolean;

    procedure setRetailDocType(int1: Integer)
    begin
        //setRetailDocType

        case int1 of
            "Rental Header"."Document Type"::" ":
                ;

            /* SELECTION CONTRACT */

            "Rental Header"."Document Type"::"Selection Contract":
                begin
                    //-NPK TS
                    FieldRentIncVat := true;
                    FieldQtyInOrder := false;
                    FieldQuantityReceived := false;
                    FieldReceivedLast := false;
                    //+NPK TS
                end;

            /* RETAIL ORDER */

            "Rental Header"."Document Type"::"Retail Order":
                begin
                    //-NPK TS
                    FieldRentIncVat := false;
                    FieldQtyInOrder := true;
                    FieldQuantityReceived := true;
                    FieldReceivedLast := true;
                    //+NPK TS
                end;

            /* WISH */

            "Rental Header"."Document Type"::Wish:
                begin
                    //-NPK TS
                    FieldRentIncVat := false;
                    FieldQtyInOrder := false;
                    FieldQuantityReceived := false;
                    FieldReceivedLast := false;
                    //+NPK TS
                end;

            /* CUSTOMIZATION */

            "Rental Header"."Document Type"::Customization:
                begin
                    //-NPK TS
                    FieldRentIncVat := false;
                    FieldQtyInOrder := false;
                    FieldQuantityReceived := false;
                    FieldReceivedLast := false;
                    //+NPK TS
                end;

            "Rental Header"."Document Type"::Delivery:
                begin
                    //-NPK TS
                    FieldRentIncVat := false;
                    FieldQtyInOrder := false;
                    FieldQuantityReceived := false;
                    FieldReceivedLast := false;
                    //+NPK TS
                end;

            "Rental Header"."Document Type"::"Rental contract":
                begin
                    //-NPK TS
                    FieldRentIncVat := true;
                    FieldQtyInOrder := false;
                    FieldQuantityReceived := false;
                    FieldReceivedLast := false;
                    //+NPK TS
                end;

            "Rental Header"."Document Type"::"Purchase contract":
                begin
                    //-NPK TS
                    FieldRentIncVat := false;
                    FieldQtyInOrder := false;
                    FieldQuantityReceived := false;
                    FieldReceivedLast := false;
                    //+NPK TS
                end;

            "Rental Header"."Document Type"::Quote:
                begin
                    //-NPK TS
                    FieldRentIncVat := false;
                    FieldQtyInOrder := false;
                    FieldQuantityReceived := false;
                    FieldReceivedLast := false;
                    //+NPK TS
                end;



        end;

    end;

    procedure Update()
    begin
        //Update
        //-NPK TS
        //CurrForm.UPDATECONTROLS;
        //+NPK TS
    end;
}

