page 6151052 "NPR Item Hierarchy Listpart"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    AutoSplitKey = true;
    Caption = 'Item Hiearachy Levels';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR Item Hierarchy Level";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Level; Level)
                {
                    ApplicationArea = All;
                }
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    Caption = 'Table No.';
                }
                field("Primary Field No."; "Primary Field No.")
                {
                    ApplicationArea = All;
                    LookupPageID = "NPR Field Lookup";
                }
                field("Description Field No."; "Description Field No.")
                {
                    ApplicationArea = All;
                    LookupPageID = "NPR Field Lookup";
                }
                field("Level Link Table No."; "Level Link Table No.")
                {
                    ApplicationArea = All;
                }
                field("Level Link Field No."; "Level Link Field No.")
                {
                    ApplicationArea = All;
                    LookupPageID = "NPR Field Lookup";
                }
                field("Level Link Filter"; "Level Link Filter")
                {
                    ApplicationArea = All;
                }
                field("Second Level Primary Field No."; "Second Level Primary Field No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Second Level Link Table No."; "Second Level Link Table No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Second Level Link Field No."; "Second Level Link Field No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Second Level Link Filter"; "Second Level Link Filter")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}