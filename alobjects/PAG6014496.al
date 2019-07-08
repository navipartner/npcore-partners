page 6014496 "Exchange Label"
{
    // NPR5.26/MMV /20160810 CASE 248262 Removed deprecated fields 25 & 26
    // NPR5.26/MMV /20160802 CASE 246998 Added field 30 - Quantity.
    //                                   Added field 32 - Unit of Measure.
    // NPR5.49/MHA /20190211 CASE 345209 Added field 35 "Unit Price"

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
                field("Store ID";"Store ID")
                {
                }
                field("No.";"No.")
                {
                }
                field(Barcode;Barcode)
                {
                }
                field("Batch No.";"Batch No.")
                {
                }
                field("No. Series";"No. Series")
                {
                }
                field("Packaged Batch";"Packaged Batch")
                {
                }
                field("Valid From";"Valid From")
                {
                }
                field("Valid To";"Valid To")
                {
                }
                field("Table No.";"Table No.")
                {
                }
                field("Register No.";"Register No.")
                {
                }
                field("Sales Ticket No.";"Sales Ticket No.")
                {
                }
                field("Sales Line No.";"Sales Line No.")
                {
                }
                field("Item No.";"Item No.")
                {
                }
                field("Variant Code";"Variant Code")
                {
                }
                field(Quantity;Quantity)
                {
                }
                field("Unit Price";"Unit Price")
                {
                }
                field("Sales Price Incl. Vat";"Sales Price Incl. Vat")
                {
                }
                field("Sales Header Type";"Sales Header Type")
                {
                }
                field("Sales Header No.";"Sales Header No.")
                {
                }
                field("Unit of Measure";"Unit of Measure")
                {
                }
                field("Company Name";"Company Name")
                {
                }
                field("Printed Date";"Printed Date")
                {
                }
            }
        }
    }

    actions
    {
    }
}

