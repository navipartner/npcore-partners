page 6151052 "NPR Item Hierarchy Listpart"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    AutoSplitKey = true;
    Caption = 'Item Hiearachy Levels';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Item Hierarchy Level";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Level; Rec.Level)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Level field';
                }
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                    Caption = 'Table No.';
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("Primary Field No."; Rec."Primary Field No.")
                {
                    ApplicationArea = All;
                    LookupPageID = "NPR Field Lookup";
                    ToolTip = 'Specifies the value of the Primary Field No. field';
                }
                field("Description Field No."; Rec."Description Field No.")
                {
                    ApplicationArea = All;
                    LookupPageID = "NPR Field Lookup";
                    ToolTip = 'Specifies the value of the Description Field No. field';
                }
                field("Level Link Table No."; Rec."Level Link Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Level Link Table No. field';
                }
                field("Level Link Field No."; Rec."Level Link Field No.")
                {
                    ApplicationArea = All;
                    LookupPageID = "NPR Field Lookup";
                    ToolTip = 'Specifies the value of the Level Link Field No. field';
                }
                field("Level Link Filter"; Rec."Level Link Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Level Link Filter field';
                }
                field("Second Level Primary Field No."; Rec."Second Level Primary Field No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Second Level Primary Field No. field';
                }
                field("Second Level Link Table No."; Rec."Second Level Link Table No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Second Level Link Table No. field';
                }
                field("Second Level Link Field No."; Rec."Second Level Link Field No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Second Level Link Field No. field';
                }
                field("Second Level Link Filter"; Rec."Second Level Link Filter")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Second Level Link Filter field';
                }
            }
        }
    }

    actions
    {
    }
}
