page 6151063 "Distribution Plans"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    AutoSplitKey = true;
    Caption = 'Distribution Plans';
    CardPageID = "Distribution Plan";
    PageType = List;
    SourceTable = "Distribution Headers";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Distribution Group";"Distribution Group")
                {
                }
                field("Item Hiearachy";"Item Hiearachy")
                {
                }
                field("Distribution Type";"Distribution Type")
                {
                }
                field(Description;Description)
                {
                }
                field("Required Date";"Required Date")
                {
                }
            }
        }
    }

    actions
    {
    }
}

