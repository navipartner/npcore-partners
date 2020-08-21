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
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Vendor; Vendor)
                {
                    ApplicationArea = All;
                }
                field("Buy-from Vendor Name"; "Buy-from Vendor Name")
                {
                    ApplicationArea = All;
                }
                field(Inventory; Inventory)
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Per unit"; "Per unit")
                {
                    ApplicationArea = All;
                }
                field("Add Extra Line Automatically"; "Add Extra Line Automatically")
                {
                    ApplicationArea = All;
                }
                field("Use Alt. Price"; "Use Alt. Price")
                {
                    ApplicationArea = All;
                }
                field("Quantity in Dialogue"; "Quantity in Dialogue")
                {
                    ApplicationArea = All;
                }
                field("Show Discount"; "Show Discount")
                {
                    ApplicationArea = All;
                }
                field("Alt. Price"; "Alt. Price")
                {
                    ApplicationArea = All;
                }
                field("Unfold in Worksheet"; "Unfold in Worksheet")
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

