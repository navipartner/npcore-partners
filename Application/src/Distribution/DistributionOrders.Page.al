page 6151067 "NPR Distribution Orders"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Distribution Orders';
    PageType = List;
    UsageCategory = Administration;
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
                    ToolTip = 'Specifies the value of the Distribution Item field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Location; Location)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location field';
                }
                field("Item Variant"; "Item Variant")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Variant field';
                }
                field("Distribution Quantity"; "Distribution Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Distribution Quantity field';
                }
                field("Avaliable Quantity"; "Avaliable Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Avaliable Quantity field';
                }
                field("Demanded Quantity"; "Demanded Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Demanded Quantity field';
                }
                field("Qty On PO"; "Qty On PO")
                {
                    ApplicationArea = All;
                    Caption = '<Qty On Purchase Orders>';
                    ToolTip = 'Specifies the value of the <Qty On Purchase Orders> field';
                }
                field("Qty On Transfer"; "Qty On Transfer")
                {
                    ApplicationArea = All;
                    Caption = '<Qty On Transfer Orders>';
                    ToolTip = 'Specifies the value of the <Qty On Transfer Orders> field';
                }
            }
        }
    }

    actions
    {
    }
}

