page 6151071 "Retail Replenishment SKU List"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Retail Replenishment SKUs';
    PageType = List;
    SourceTable = "Stockkeeping Unit";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No.";"Item No.")
                {
                }
                field("Variant Code";"Variant Code")
                {
                }
                field("Location Code";"Location Code")
                {
                }
                field(Description;Description)
                {
                }
                field("Reordering Policy";"Reordering Policy")
                {
                }
                field("Reorder Point";"Reorder Point")
                {
                }
                field("Replenishment System";"Replenishment System")
                {
                }
                field("Reorder Quantity";"Reorder Quantity")
                {
                }
                field("Maximum Inventory";"Maximum Inventory")
                {
                }
                field("Minimum Order Quantity";"Minimum Order Quantity")
                {
                }
                field("Maximum Order Quantity";"Maximum Order Quantity")
                {
                }
                field("Safety Stock Quantity";"Safety Stock Quantity")
                {
                }
            }
        }
    }

    actions
    {
    }

    var
        ItemHierachy: Code[10];
        DistributionGroup: Code[10];
}

