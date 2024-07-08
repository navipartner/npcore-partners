page 6151050 "NPR Item Hierarchy List"
{
    Extensible = False;
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Item Hiearachy List';
    CardPageID = "NPR Item Hierarchy Card";
    PageType = List;
    SourceTable = "NPR Item Hierarchy";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Hierarchy Code"; Rec."Hierarchy Code")
                {

                    ToolTip = 'Specifies the value of the Hierarchy Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("No. Of Levels"; Rec."No. Of Levels")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the No. Of Levels field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
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
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = Page "NPR Item Hierarchy Lines";
                RunPageLink = "Item Hierarchy Code" = FIELD("Hierarchy Code");
                RunPageView = SORTING("Item Hierarchy Code", "Item Hierarchy Line No.");

                ToolTip = 'Executes the Hiearachy Lines action';
                ApplicationArea = NPRRetail;
            }
            action("Demand Lines")
            {
                Caption = 'Demand Lines';
                Image = ItemAvailability;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = Page "NPR Retail Repl. Demand Lines";
                RunPageLink = "Item Hierachy" = FIELD("Hierarchy Code");

                ToolTip = 'Executes the Demand Lines action';
                ApplicationArea = NPRRetail;
            }
            action("Distribution lines")
            {
                Caption = 'Distribution lines';
                Image = ItemAvailbyLoc;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = Page "NPR Distribution Lines";
                RunPageLink = "Item Hiearachy" = FIELD("Hierarchy Code");

                ToolTip = 'Executes the Distribution lines action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

