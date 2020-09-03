page 6151067 "NPR Distribution Orders"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Distribution Orders';
    PageType = List;
    SourceTable = "NPR Distribution Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Distribution Item"; "Distribution Item")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Location; Location)
                {
                    ApplicationArea = All;
                }
                field("Item Variant"; "Item Variant")
                {
                    ApplicationArea = All;
                }
                field("Distribution Quantity"; "Distribution Quantity")
                {
                    ApplicationArea = All;
                }
                field("Avaliable Quantity"; "Avaliable Quantity")
                {
                    ApplicationArea = All;
                }
                field("Demanded Quantity"; "Demanded Quantity")
                {
                    ApplicationArea = All;
                }
                field("Qty On PO"; "Qty On PO")
                {
                    ApplicationArea = All;
                    Caption = '<Qty On Purchase Orders>';
                }
                field("Qty On Transfer"; "Qty On Transfer")
                {
                    ApplicationArea = All;
                    Caption = '<Qty On Transfer Orders>';
                }
            }
        }
    }

    actions
    {
    }
}

