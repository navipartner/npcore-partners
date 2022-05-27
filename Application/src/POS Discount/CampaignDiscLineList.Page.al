page 6059878 "NPR Campaign Disc. Line List"
{
    Extensible = false;
    Caption = 'Period Discount Lines';
    Editable = false;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR Period Discount Line";
    DataCaptionFields = Code;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Cross-Reference No."; Rec."Cross-Reference No.")
                {
                    ToolTip = 'Specifies the value of the Cross-Reference No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ToolTip = 'Specifies the value of the Unit Price field';
                    ApplicationArea = NPRRetail;
                }
                field("Campaign Unit Price"; Rec."Campaign Unit Price")
                {
                    ToolTip = 'Specifies the value of the Period Price field';
                    ApplicationArea = NPRRetail;
                }
                field("Campaign Profit"; Rec."Campaign Profit")
                {
                    ToolTip = 'Specifies the value of the Campaign Profit field';
                    ApplicationArea = NPRRetail;
                }
                field(Inventory; Rec.Inventory)
                {
                    Caption = 'Inventory';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Inventory field';
                    ApplicationArea = NPRRetail;
                }
                field("Quantity On Purchase Order"; Rec."Quantity On Purchase Order")
                {
                    ToolTip = 'Specifies the value of the Quantity in Purchase Order field';
                    ApplicationArea = NPRRetail;
                }
                field("Campaign Unit Cost"; Rec."Campaign Unit Cost")
                {
                    ToolTip = 'Specifies the value of the Period Cost field';
                    ApplicationArea = NPRRetail;
                }
                field(Profit; Rec.Profit)
                {
                    Caption = 'Revenue of period';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Revenue of period field';
                    ApplicationArea = NPRRetail;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ToolTip = 'Specifies the value of the Vendor No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ToolTip = 'Specifies the value of the Starting Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ToolTip = 'Specifies the value of the Closing Date field';
                    ApplicationArea = NPRRetail;
                }
                field(Priority; Rec.Priority)
                {
                    ToolTip = 'Specifies the value of the Priority field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(PeriodDiscount)
            {
                Caption = 'Period Discount';
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies Period Discount';
                Image = Period;
                RunObject = Page "NPR Campaign Discount";
                RunPageLink = Code = field(Code);
            }
        }
    }
}

