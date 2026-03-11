#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
page 6150943 "NPR NPRE Menus"
{
    Extensible = false;
    ApplicationArea = NPRRetail;
    Caption = 'Restaurant Menus';
    PageType = List;
    SourceTable = "NPR NPRE Menu";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the code to identify this menu.';
                }
                field("Start Time"; Rec."Start Time")
                {
                    ToolTip = 'Specifies when this menu becomes active.';
                }
                field("End Time"; Rec."End Time")
                {
                    ToolTip = 'Specifies when this menu stops accepting orders.';
                }
                field(Timezone; Rec.Timezone)
                {
                    ToolTip = 'Specifies the timezone for this menu.';
                }
                field(Active; Rec.Active)
                {
                    ToolTip = 'Specifies whether this menu is active.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(EditMenu)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Edit Restaurant Menu';
                Image = Edit;
                ToolTip = 'Open this menu for editing categories and items.';
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                RunObject = Page "NPR NPRE Menu Categories";
                RunPageLink = "Menu Code" = FIELD("Code"), "Restaurant Code" = FIELD("Restaurant Code");
            }
            action(UpsellItems)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Checkout Upsell Items';
                Image = Suggest;
                ToolTip = 'Add items to suggest when going to checkout for the entire menu.';
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                RunObject = Page "NPR NPRE Upsell List";
                RunPageLink = "External Table" = const("NPR NPRE Upsell Table"::Menu), "External System Id" = field(SystemId);
            }
        }
    }
}
#endif
