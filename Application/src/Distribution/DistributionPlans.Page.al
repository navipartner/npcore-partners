page 6151063 "NPR Distribution Plans"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    AutoSplitKey = true;
    Caption = 'Distribution Plans';
    CardPageID = "NPR Distribution Plan";
    PageType = List;
    SourceTable = "NPR Distribution Headers";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Distribution Group"; "Distribution Group")
                {
                    ApplicationArea = All;
                }
                field("Item Hiearachy"; "Item Hiearachy")
                {
                    ApplicationArea = All;
                }
                field("Distribution Type"; "Distribution Type")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Required Date"; "Required Date")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

