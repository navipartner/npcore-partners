page 6184610 NPRPowerBIItem
{
    PageType = List;
    Caption = 'PowerBI Item';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = Item;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                    ApplicationArea = All;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                    ApplicationArea = All;
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies that the related record is blocked from being posted in transactions, for example a customer that is declared insolvent or an item that is placed in quarantine.';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies what you are selling.';
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the number of the item.';
                    ApplicationArea = All;
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ToolTip = 'Specifies the category that the item belongs to. Item categories also contain any assigned item attributes.';
                    ApplicationArea = All;
                }
                field("Sales (Qty.)"; Rec."Sales (Qty.)")
                {
                    ToolTip = 'Specifies the value of the Sales (Qty.) field';
                    ApplicationArea = All;
                }
                field("Type"; Rec."Type")
                {
                    ToolTip = 'Specifies if the item card represents a physical inventory unit (Inventory), a labor time unit (Service), or a physical unit that is not tracked in inventory (Non-Inventory).';
                    ApplicationArea = All;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ToolTip = 'Specifies the cost of one unit of the item or resource on the line.';
                    ApplicationArea = All;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ToolTip = 'Specifies the price of one unit of the item or resource. You can enter a price manually or have it entered according to the Price/Profit Calculation field on the related card.';
                    ApplicationArea = All;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ToolTip = 'Specifies the vendor code of who supplies this item by default.';
                    ApplicationArea = All;
                }
                field("Vendor Item No."; Rec."Vendor Item No.")
                {
                    ToolTip = 'Specifies the number that the vendor uses for this item.';
                    ApplicationArea = All;
                }
            }
        }
    }
}