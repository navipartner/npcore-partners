page 6151057 "Distribution Header"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    AutoSplitKey = true;
    Caption = 'Distribution Group Setup';
    PageType = List;
    SourceTable = "Distribution Headers";

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
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Distribution Lines")
            {
                Caption = 'Distribution Lines';
                Image = List;
                Promoted = true;
                RunObject = Page "Distribution Lines";
                RunPageLink = "Distribution Id"=FIELD("Distribution Id");
            }
        }
    }
}

