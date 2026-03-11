page 6248192 "NPR NpIa Item AddOn Categories"
{
    Extensible = false;
    Caption = 'Item AddOn Categories';
    PageType = List;
    SourceTable = "NPR NpIa Item AddOn Category";
    UsageCategory = None;
    SourceTableView = Sorting("Sort Key")
                      order(ascending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the category code.';
                }
                field(SortKey; Rec."Sort Key")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the sort key for the category.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Captions)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Captions';
                Image = Translation;
                RunObject = Page "NPR NpIa AddOn Cat. Trans.";
                RunPageLink = "Category Code" = field("Code");
                ToolTip = 'View or edit captions for this category.';
            }
        }
    }
}
