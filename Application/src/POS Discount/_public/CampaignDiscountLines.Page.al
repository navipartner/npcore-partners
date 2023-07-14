page 6014454 "NPR Campaign Discount Lines"
{
    Extensible = true;
    Caption = 'Period Discount Lines';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR Period Discount Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
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
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    Editable = false;
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
                    Editable = false;
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
                    Visible = false;
                    ToolTip = 'Specifies the value of the Starting Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Closing Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price Incl. VAT"; Rec."Unit Price Incl. VAT")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Price Includes VAT field';
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
        area(processing)
        {
            action(Comment)
            {
                Caption = 'Comment';
                Image = Comment;
                RunObject = Page "NPR Retail Comments";
                RunPageLink = "Table ID" = CONST(6014413),
                                  "No." = FIELD(Code);

                ToolTip = 'Executes the Comment action';
                ApplicationArea = NPRRetail;
            }
            action("Item Card")
            {
                Caption = 'Item Card';
                Image = Item;
                ShortCutKey = 'Shift+Ctrl+C';

                ToolTip = 'Executes the Item Card action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    Item: Record Item;
                    PeriodDiscountLine: Record "NPR Period Discount Line";
                begin
                    CurrPage.GetRecord(PeriodDiscountLine);
                    Item.SetRange("No.", PeriodDiscountLine."Item No.");
                    Page.Run(Page::"Item Card", Item, Item."No.");
                end;
            }
        }
    }
}

