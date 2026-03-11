#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
page 6248195 "NPR NPRE Menu Categories"
{
    Extensible = false;
    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = None;
    SourceTable = "NPR NPRE Menu Category";
    SourceTableView = Sorting("Sort Key")
                      order(ascending);

    layout
    {
        area(Content)
        {
            repeater(Fields)
            {
                field("Code"; Rec."Category Code")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Code';
                    ToolTip = 'Specifies the category code.';
                }
                field("Captions Filled"; Rec."Captions Filled")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether captions have been filled.';
                    DrillDown = false;
                }
            }
            part(MenuCategoryItems; "NPR NPRE Menu Items Part")
            {
                Caption = 'Menu Items';
                SubPageLink = "Restaurant Code" = Field("Restaurant Code"), "Menu Code" = Field("Menu Code"), "Category Code" = FIELD("Category Code");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Captions)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Captions';
                Image = Edit;
                ToolTip = 'Edit the captions for this category.';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = page "NPR NPRE Menu Cat Captions";
                RunPageLink = "Restaurant Code" = field("Restaurant Code"), "Menu Code" = field("Menu Code"), "Category Code" = field("Category Code");
            }
            action(MoveUp)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Move Up';
                Image = MoveUp;
                ToolTip = 'Move this category up in the sort order.';
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
                ToolTip = 'Move this category down in the sort order.';
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
