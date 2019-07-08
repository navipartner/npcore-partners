page 6014510 "Accessory List"
{
    // NPR5.40/MHA /20180214  CASE 288039 Added field 85 "Unfold in Worksheet"

    Caption = 'Accessories List';
    PageType = List;
    SourceTable = "Accessory/Spare Part";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Item No.";"Item No.")
                {
                }
                field(Description;Description)
                {
                }
                field(Vendor;Vendor)
                {
                }
                field("Buy-from Vendor Name";"Buy-from Vendor Name")
                {
                }
                field(Inventory;Inventory)
                {
                }
                field(Quantity;Quantity)
                {
                }
                field("Per unit";"Per unit")
                {
                }
                field("Add Extra Line Automatically";"Add Extra Line Automatically")
                {
                }
                field("Use Alt. Price";"Use Alt. Price")
                {
                }
                field("Quantity in Dialogue";"Quantity in Dialogue")
                {
                }
                field("Show Discount";"Show Discount")
                {
                }
                field("Alt. Price";"Alt. Price")
                {
                }
                field("Unfold in Worksheet";"Unfold in Worksheet")
                {
                }
            }
        }
    }

    actions
    {
    }
}

