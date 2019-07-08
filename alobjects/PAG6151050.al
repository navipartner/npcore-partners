page 6151050 "Item Hierarchy List"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Item Hiearachy List';
    CardPageID = "Item Hierarchy Card";
    PageType = List;
    SourceTable = "Item Hierarchy";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Hierarchy Code";"Hierarchy Code")
                {
                }
                field(Description;Description)
                {
                }
                field("No. Of Levels";"No. Of Levels")
                {
                    Visible = false;
                }
                field(Type;Type)
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Hiearachy Lines")
            {
                Caption = 'Hiearachy Lines';
                Image = ItemLines;
                Promoted = true;
                RunObject = Page "Item Hiearachy Lines";
                RunPageLink = "Item Hierarchy Code"=FIELD("Hierarchy Code");
                RunPageView = SORTING("Item Hierarchy Code","Item Hierarchy Line No.");
            }
            action("Demand Lines")
            {
                Caption = 'Demand Lines';
                Image = ItemAvailability;
                Promoted = true;
                RunObject = Page "Retail Repl. Demand Lines";
                RunPageLink = "Item Hierachy"=FIELD("Hierarchy Code");
            }
            action("Distribution lines")
            {
                Caption = 'Distribution lines';
                Image = ItemAvailbyLoc;
                Promoted = true;
                RunObject = Page "Distribution Lines";
                RunPageLink = "Item Hiearachy"=FIELD("Hierarchy Code");
            }
        }
    }
}

