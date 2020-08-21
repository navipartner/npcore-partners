page 6151051 "Item Hierarchy Card"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Item Hierarchy Card';
    PageType = Card;
    SourceTable = "Item Hierarchy";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Hierarchy Code"; "Hierarchy Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("No. Of Levels"; "No. Of Levels")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
            part(Control6150619; "Item Hierarchy Listpart")
            {
                SubPageLink = "Hierarchy Code" = FIELD("Hierarchy Code");
                SubPageView = SORTING("Hierarchy Code", "Line No.");
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Hierarchy Lines")
            {
                Caption = 'Hierarchy Lines';
                Image = ItemLines;
                Promoted = true;
                RunObject = Page "Item Hiearachy Lines";
                RunPageLink = "Item Hierarchy Code" = FIELD("Hierarchy Code");
                RunPageView = SORTING("Item Hierarchy Code", "Item Hierarchy Line No.");
            }
            action("Demand Lines")
            {
                Caption = 'Demand Lines';
                Image = ItemAvailability;
                Promoted = true;
                RunObject = Page "Retail Repl. Demand Lines";
                RunPageLink = "Item Hierachy" = FIELD("Hierarchy Code");
            }
            action("Distribution lines")
            {
                Caption = 'Distribution lines';
                Image = ItemAvailbyLoc;
                Promoted = true;
                RunObject = Page "Distribution Lines";
                RunPageLink = "Item Hiearachy" = FIELD("Hierarchy Code");
            }
        }
    }
}

