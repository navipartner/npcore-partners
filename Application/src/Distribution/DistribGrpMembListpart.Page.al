page 6151058 "NPR Distrib. Grp Memb Listpart"
{
    Extensible = False;
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    AutoSplitKey = true;
    Caption = 'Distribution Group Members';
    PageType = ListPart;
    UsageCategory = Administration;

    SourceTable = "NPR Distrib. Group Members";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Distribution Group"; Rec."Distribution Group")
                {

                    ToolTip = 'Specifies the value of the Distribution Group field';
                    ApplicationArea = NPRRetail;
                }
                field(Location; Rec.Location)
                {

                    ToolTip = 'Specifies the value of the Location field';
                    ApplicationArea = NPRRetail;
                }
                field(Store; Rec.Store)
                {

                    ToolTip = 'Specifies the value of the Store field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Distribution Share Pct."; Rec."Distribution Share Pct.")
                {

                    ToolTip = 'Specifies the value of the Distribution Share Pct. field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Distribution Items action';
                ApplicationArea = NPRRetail;
            }
            action("Distribution Lines")
            {
                Caption = 'Distribution Lines';
                Image = ItemAvailbyLoc;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = Page "NPR Distribution Lines";

                ToolTip = 'Executes the Distribution Lines action';
                ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Demand Lines action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

