page 6151058 "Distribution Grp Memb Listpart"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    AutoSplitKey = true;
    Caption = 'Distribution Group Members';
    PageType = ListPart;
    SourceTable = "Distribution Group Members";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Distribution Group";"Distribution Group")
                {
                }
                field(Location;Location)
                {
                }
                field(Store;Store)
                {
                }
                field(Description;Description)
                {
                }
                field("Distribution Share Pct.";"Distribution Share Pct.")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Distribution Items")
            {
                Caption = 'Distribution Items';
                Image = SKU;
                Promoted = true;
                RunObject = Page "Retail Replenishment SKU List";
                RunPageLink = "Location Code"=FIELD(Location);
            }
            action("Distribution Lines")
            {
                Caption = 'Distribution Lines';
                Image = ItemAvailbyLoc;
                Promoted = true;
                RunObject = Page "Distribution Lines";
                //RunPageLink = "Distribution Group Member"=FIELD("Distribution Member Id"),
                //              "Distribution Item"=FILTER(<>'');
            }
            action("Demand Lines")
            {
                Image = ItemAvailability;
                Promoted = true;
                RunObject = Page "Retail Repl. Demand Lines";
                RunPageLink = "Location Code"=FIELD(Location);
            }
        }
    }
}

