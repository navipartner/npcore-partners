page 6151067 "Distribution Orders"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Distribution Orders';
    PageType = List;
    SourceTable = "Distribution Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Distribution Item";"Distribution Item")
                {
                }
                field(Description;Description)
                {
                }
                field(Location;Location)
                {
                }
                field("Item Variant";"Item Variant")
                {
                }
                field("Distribution Quantity";"Distribution Quantity")
                {
                }
                field("Avaliable Quantity";"Avaliable Quantity")
                {
                }
                field("Demanded Quantity";"Demanded Quantity")
                {
                }
                field("Qty On PO";"Qty On PO")
                {
                    Caption = '<Qty On Purchase Orders>';
                }
                field("Qty On Transfer";"Qty On Transfer")
                {
                    Caption = '<Qty On Transfer Orders>';
                }
            }
        }
    }

    actions
    {
    }
}

