page 6151128 "NPR NpIa ItemAddOn Line Opt."
{
    Extensible = False;
    UsageCategory = None;
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
                    ToolTip = 'Specifies the number of an item.';
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    ToolTip = 'Specifies the variant of the item on the line.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the entry of the product to be sold.';
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                }
                field("Description 2"; Rec."Description 2")
                {

                    ToolTip = 'Specifies an additional description of the entry of the product to be sold.';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {

                    ToolTip = 'Specifies how many units are being sold.';
                    ApplicationArea = NPRRetail;
                }
                field("Per Unit"; Rec."Per Unit")
                {

                    ToolTip = 'Specifies how many units are being sold in base unit of measure.';
                    ApplicationArea = NPRRetail;
                }
                field("Fixed Quantity"; Rec."Fixed Quantity")
                {

                    ToolTip = 'Specifies if quantity can be changed on POS unit. If it''s current entry have a flag fixed quantity, then POS entry will be created with predefined Quantity.';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price"; Rec."Unit Price")
                {

                    ToolTip = 'Specifies the price of one unit of the item.';
                    ApplicationArea = NPRRetail;
                }
                field("Use Unit Price"; Rec."Use Unit Price")
                {

                    ToolTip = 'Specifies if the price of one unit of the item should be used for sold item.';
                    ApplicationArea = NPRRetail;
                }
                field("Discount %"; Rec."Discount %")
                {

                    ToolTip = 'Specifies the discount percentage that is granted for the item on the line.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

