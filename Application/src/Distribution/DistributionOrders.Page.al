page 6151067 "NPR Distribution Orders"
{
    Extensible = False;
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Distribution Orders';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Distribution Lines";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Distribution Item"; Rec."Distribution Item")
                {

                    ToolTip = 'Specifies the value of the Distribution Item field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Location; Rec.Location)
                {

                    ToolTip = 'Specifies the value of the Location field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Variant"; Rec."Item Variant")
                {

                    ToolTip = 'Specifies the value of the Item Variant field';
                    ApplicationArea = NPRRetail;
                }
                field("Distribution Quantity"; Rec."Distribution Quantity")
                {

                    ToolTip = 'Specifies the value of the Distribution Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Avaliable Quantity"; Rec."Avaliable Quantity")
                {

                    ToolTip = 'Specifies the value of the Avaliable Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Demanded Quantity"; Rec."Demanded Quantity")
                {

                    ToolTip = 'Specifies the value of the Demanded Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Qty On PO"; Rec."Qty On PO")
                {

                    Caption = '<Qty On Purchase Orders>';
                    ToolTip = 'Specifies the value of the <Qty On Purchase Orders> field';
                    ApplicationArea = NPRRetail;
                }
                field("Qty On Transfer"; Rec."Qty On Transfer")
                {

                    Caption = '<Qty On Transfer Orders>';
                    ToolTip = 'Specifies the value of the <Qty On Transfer Orders> field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

