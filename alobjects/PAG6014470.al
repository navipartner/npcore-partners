page 6014470 "Retail Document Lines"
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
    RefreshOnActivate = true;
    SourceTable = "Retail Document Lines";
    SourceTableView = SORTING("Document Type","Document No.","Line No.");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type;Type)
                {
                }
                field("No.";"No.")
                {
                }
                field("Serial No.";"Serial No.")
                {
                }
                field(Description;Description)
                {
                }
                field("Variant Code";"Variant Code")
                {
                }
                field(Size;Size)
                {
                }
                field("Lock Code";"Lock Code")
                {
                }
                field("Serial No. not Created";"Serial No. not Created")
                {
                }
                field(Quantity;Quantity)
                {
                }
                field("Quantity in order";"Quantity in order")
                {
                    Visible = FieldQtyInOrder;
                }
                field("Quantity received";"Quantity received")
                {
                    Visible = FieldQuantityReceived;
                }
                field("Qty. to Ship";"Qty. to Ship")
                {
                }
                field("Quantity Shipped";"Quantity Shipped")
                {
                }
                field("Location Code";"Location Code")
                {
                }
                field("Received last";"Received last")
                {
                    Visible = FieldReceivedLast;
                }
                field("Letter printed";"Letter printed")
                {
                }
                field("Return Reason Code";"Return Reason Code")
                {
                }
                field("Reason Code";"Reason Code")
                {
                }
                field("Rental Amount incl. VAT";"Rental Amount incl. VAT")
                {
                    Visible = FieldRentIncVat;
                }
                field("Unit price";"Unit price")
                {
                }
                field("Line discount %";"Line discount %")
                {
                }
                field("Line discount amount";"Line discount amount")
                {
                }
                field("Amount Including VAT";"Amount Including VAT")
                {
                }
                field("Package quantity";"Package quantity")
                {
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
          Type::Item :
            begin
              //Delete Accesories and BOM
              RetailDocHandlingCU.UnfoldItemsDelete(Rec);
            end;
        end;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        "Rental Header".Get( "Document Type", "Document No." );

        case Type of
          Type::Item :
            begin
              //+Unfold Accessories
              RetailDocHandlingCU.UnfoldAccessories(Rec);
              //-Unfold Accessories

              //+Unfold BOM
              RetailDocHandlingCU.UnfoldBOM(Rec,'');
              //-Unfold BOM
            end;
        end;
    end;

    trigger OnModifyRecord(): Boolean
    begin

        case Type of
          Type::Item :
            begin
              //Update Accesories and BOM
              RetailDocHandlingCU.UnfoldItemsUpdate(Rec);
            end;
        end;
    end;

    var
        RetailDocHandlingCU: Codeunit "Retail Document Handling";
        "Rental Header": Record "Retail Document Header";
        "Retail Document Lines": Record "Retail Document Lines";
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
          "Rental Header"."Document Type"::" " :;
        
          /* SELECTION CONTRACT */
        
          "Rental Header"."Document Type"::"Selection Contract" :
            begin
                //-NPK TS
                FieldRentIncVat:= true;
                FieldQtyInOrder:= false;
                FieldQuantityReceived:= false;
                FieldReceivedLast:= false;
                //+NPK TS
            end;
        
          /* RETAIL ORDER */
        
          "Rental Header"."Document Type"::"Retail Order" :
            begin
                //-NPK TS
                FieldRentIncVat:=false;
                FieldQtyInOrder:=true;
                FieldQuantityReceived:=true;
                FieldReceivedLast:=true;
                //+NPK TS
            end;
        
          /* WISH */
        
          "Rental Header"."Document Type"::Wish :
            begin
                //-NPK TS
                FieldRentIncVat:=false;
                FieldQtyInOrder:=false;
                FieldQuantityReceived:=false;
                FieldReceivedLast:= false;
                //+NPK TS
            end;
        
          /* CUSTOMIZATION */
        
          "Rental Header"."Document Type"::Customization :
            begin
                //-NPK TS
                FieldRentIncVat:=false;
                FieldQtyInOrder:=false;
                FieldQuantityReceived:=false;
                FieldReceivedLast:= false;
                //+NPK TS
            end;
        
          "Rental Header"."Document Type"::Delivery :
            begin
                //-NPK TS
                FieldRentIncVat:=false;
                FieldQtyInOrder:=false;
                FieldQuantityReceived:=false;
                FieldReceivedLast:=false;
                //+NPK TS
            end;
        
          "Rental Header"."Document Type"::"Rental contract" :
            begin
                //-NPK TS
                FieldRentIncVat:=true;
                FieldQtyInOrder:=false;
                FieldQuantityReceived:=false;
                FieldReceivedLast:= false;
                //+NPK TS
            end;
        
          "Rental Header"."Document Type"::"Purchase contract" :
            begin
                //-NPK TS
                FieldRentIncVat:=false;
                FieldQtyInOrder:= false;
                FieldQuantityReceived:=false;
                FieldReceivedLast:=false;
                //+NPK TS
            end;
        
          "Rental Header"."Document Type"::Quote :
            begin
                //-NPK TS
                FieldRentIncVat:= false;
                FieldQtyInOrder:=  false;
                FieldQuantityReceived:=false;
                FieldReceivedLast:= false;
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

