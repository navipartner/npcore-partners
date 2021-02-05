page 6151058 "NPR Distrib. Grp Memb Listpart"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    AutoSplitKey = true;
    Caption = 'Distribution Group Members';
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Distrib. Group Members";

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
                field(Location; Location)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location field';
                }
                field(Store; Store)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Distribution Share Pct."; "Distribution Share Pct.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Distribution Share Pct. field';
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
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = Page "NPR Retail Replenish. SKU List";
                RunPageLink = "Location Code" = FIELD(Location);
                ApplicationArea = All;
                ToolTip = 'Executes the Distribution Items action';
            }
            action("Distribution Lines")
            {
                Caption = 'Distribution Lines';
                Image = ItemAvailbyLoc;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = Page "NPR Distribution Lines";
                ApplicationArea = All;
                ToolTip = 'Executes the Distribution Lines action';
                //RunPageLink = "Distribution Group Member"=FIELD("Distribution Member Id"),
                //              "Distribution Item"=FILTER(<>'');
            }
            action("Demand Lines")
            {
                Image = ItemAvailability;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = Page "NPR Retail Repl. Demand Lines";
                RunPageLink = "Location Code" = FIELD(Location);
                ApplicationArea = All;
                ToolTip = 'Executes the Demand Lines action';
            }
        }
    }
}

