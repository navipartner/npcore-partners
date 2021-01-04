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
                    ToolTip = 'Specifies the value of the Distribution Group field';
                }
                field("Item Hiearachy"; "Item Hiearachy")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Hiearachy field';
                }
                field("Distribution Type"; "Distribution Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Distribution Type field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Required Date"; "Required Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Required Date field';
                }
            }
        }
    }

    actions
    {
    }
}

