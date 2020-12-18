page 6151128 "NPR NpIa ItemAddOn Line Opt."
{
    AutoSplitKey = true;
    Caption = 'Item AddOn Line Options';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR NpIa ItemAddOn Line Opt.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of an item.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the variant of the item on the line.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the entry of the product to be sold.';
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies an additional description of the entry of the product to be sold.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how many units are being sold.';
                }
                field("Per Unit"; Rec."Per Unit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how many units are being sold in base unit of measure.';
                }
                field("Fixed Quantity"; Rec."Fixed Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if quantity can be changed on POS unit. If it''s current entry have a flag fixed quantity, then POS entry will be created with predefined Quantity.';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the price of one unit of the item.';
                }
                field("Use Unit Price"; Rec."Use Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the price of one unit of the item should be used for sold item.';
                }
                field("Discount %"; Rec."Discount %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the discount percentage that is granted for the item on the line.';
                }
            }
        }
    }
}

