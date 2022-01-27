page 6151051 "NPR Item Hierarchy Card"
{
    Extensible = False;
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Item Hierarchy Card';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR Item Hierarchy";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
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
            part(Control6150619; "NPR Item Hierarchy Listpart")
            {
                SubPageLink = "Hierarchy Code" = FIELD("Hierarchy Code");
                SubPageView = SORTING("Hierarchy Code", "Line No.");
                ApplicationArea = NPRRetail;

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
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = Page "NPR Item Hierarchy Lines";
                RunPageLink = "Item Hierarchy Code" = FIELD("Hierarchy Code");
                RunPageView = SORTING("Item Hierarchy Code", "Item Hierarchy Line No.");

                ToolTip = 'Executes the Hierarchy Lines action';
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

