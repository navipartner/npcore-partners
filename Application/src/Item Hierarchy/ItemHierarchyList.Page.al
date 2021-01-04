page 6151050 "NPR Item Hierarchy List"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Item Hiearachy List';
    CardPageID = "NPR Item Hierarchy Card";
    PageType = List;
    SourceTable = "NPR Item Hierarchy";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Hierarchy Code"; "Hierarchy Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Hierarchy Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("No. Of Levels"; "No. Of Levels")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the No. Of Levels field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Type field';
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
                RunObject = Page "NPR Item Hierarchy Lines";
                RunPageLink = "Item Hierarchy Code" = FIELD("Hierarchy Code");
                RunPageView = SORTING("Item Hierarchy Code", "Item Hierarchy Line No.");
                ApplicationArea = All;
                ToolTip = 'Executes the Hiearachy Lines action';
            }
            action("Demand Lines")
            {
                Caption = 'Demand Lines';
                Image = ItemAvailability;
                Promoted = true;
                RunObject = Page "NPR Retail Repl. Demand Lines";
                RunPageLink = "Item Hierachy" = FIELD("Hierarchy Code");
                ApplicationArea = All;
                ToolTip = 'Executes the Demand Lines action';
            }
            action("Distribution lines")
            {
                Caption = 'Distribution lines';
                Image = ItemAvailbyLoc;
                Promoted = true;
                RunObject = Page "NPR Distribution Lines";
                RunPageLink = "Item Hiearachy" = FIELD("Hierarchy Code");
                ApplicationArea = All;
                ToolTip = 'Executes the Distribution lines action';
            }
        }
    }
}

