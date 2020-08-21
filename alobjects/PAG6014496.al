page 6014496 "Exchange Label"
{
    // NPR5.26/MMV /20160810 CASE 248262 Removed deprecated fields 25 & 26
    // NPR5.26/MMV /20160802 CASE 246998 Added field 30 - Quantity.
    //                                   Added field 32 - Unit of Measure.
    // NPR5.49/MHA /20190211 CASE 345209 Added field 35 "Unit Price"
    // NPR5.51/ALST/20190628 CASE 337539 Added field 35 "Retail Cross Reference No."

    Caption = 'Exchange Label';
    Editable = false;
    PageType = List;
    SourceTable = "Exchange Label";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Store ID"; "Store ID")
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Barcode; Barcode)
                {
                    ApplicationArea = All;
                }
                field("Batch No."; "Batch No.")
                {
                    ApplicationArea = All;
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = All;
                }
                field("Packaged Batch"; "Packaged Batch")
                {
                    ApplicationArea = All;
                }
                field("Valid From"; "Valid From")
                {
                    ApplicationArea = All;
                }
                field("Valid To"; "Valid To")
                {
                    ApplicationArea = All;
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                }
                field("Sales Line No."; "Sales Line No.")
                {
                    ApplicationArea = All;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Sales Price Incl. Vat"; "Sales Price Incl. Vat")
                {
                    ApplicationArea = All;
                }
                field("Sales Header Type"; "Sales Header Type")
                {
                    ApplicationArea = All;
                }
                field("Sales Header No."; "Sales Header No.")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure"; "Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                }
                field("Printed Date"; "Printed Date")
                {
                    ApplicationArea = All;
                }
                field("Retail Cross Reference No."; "Retail Cross Reference No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

