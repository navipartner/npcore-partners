#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
page 6248198 "NPR NPRE Upsell List"
{
    Extensible = false;
    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = None;
    SourceTable = "NPR NPRE Upsell";
    AutoSplitKey = true;
    SourceTableView = sorting("External Table", "External System Id", "Sort Key")
                      order(ascending);

    layout
    {
        area(Content)
        {
            repeater(Fields)
            {
                field("Menu Item"; Rec."Menu Item System Id")
                {
                    ToolTip = 'Specifies the menu item system id.';
                }
                field("Item No."; Rec."Menu Item Item No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the item number of the upsell menu item.';
                    DrillDown = false;
                }
                field("Item Description"; Rec."Menu Item Item Description")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the description of the upsell menu item.';
                    DrillDown = false;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(MoveUp)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Move Up';
                Image = MoveUp;
                ToolTip = 'Move this upsell item up in the sort order.';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    Rec.MoveUp();
                    CurrPage.Update(true);
                end;
            }
            action(MoveDown)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Move Down';
                Image = MoveDown;
                ToolTip = 'Move this upsell item down in the sort order.';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    Rec.MoveDown();
                    CurrPage.Update(true);
                end;
            }
        }
    }
}
#endif
