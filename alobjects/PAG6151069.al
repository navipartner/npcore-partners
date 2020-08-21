page 6151069 "Distribution Group Member List"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Distribution Group Member List';
    PageType = List;
    SourceTable = "Distribution Group Members";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Distribution Member Id"; "Distribution Member Id")
                {
                    ApplicationArea = All;
                }
                field("Distribution Group"; "Distribution Group")
                {
                    ApplicationArea = All;
                }
                field(Location; Location)
                {
                    ApplicationArea = All;
                }
                field(Store; Store)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Distribution Share Pct."; "Distribution Share Pct.")
                {
                    ApplicationArea = All;
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
                RunPageLink = "Location Code" = FIELD(Location);
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
                Caption = 'Demand Lines';
                Image = ItemAvailability;
                Promoted = true;
                RunObject = Page "Retail Repl. Demand Lines";
                RunPageLink = "Location Code" = FIELD(Location);
            }
        }
    }
}

