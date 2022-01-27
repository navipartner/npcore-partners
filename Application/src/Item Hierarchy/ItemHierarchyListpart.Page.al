page 6151052 "NPR Item Hierarchy Listpart"
{
    Extensible = False;
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    AutoSplitKey = true;
    Caption = 'Item Hiearachy Levels';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;

    SourceTable = "NPR Item Hierarchy Level";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Level; Rec.Level)
                {

                    ToolTip = 'Specifies the value of the Level field';
                    ApplicationArea = NPRRetail;
                }
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Table No."; Rec."Table No.")
                {

                    Caption = 'Table No.';
                    ToolTip = 'Specifies the value of the Table No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Primary Field No."; Rec."Primary Field No.")
                {

                    LookupPageID = "NPR Field Lookup";
                    ToolTip = 'Specifies the value of the Primary Field No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Description Field No."; Rec."Description Field No.")
                {

                    LookupPageID = "NPR Field Lookup";
                    ToolTip = 'Specifies the value of the Description Field No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Level Link Table No."; Rec."Level Link Table No.")
                {

                    ToolTip = 'Specifies the value of the Level Link Table No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Level Link Field No."; Rec."Level Link Field No.")
                {

                    LookupPageID = "NPR Field Lookup";
                    ToolTip = 'Specifies the value of the Level Link Field No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Level Link Filter"; Rec."Level Link Filter")
                {

                    ToolTip = 'Specifies the value of the Level Link Filter field';
                    ApplicationArea = NPRRetail;
                }
                field("Second Level Primary Field No."; Rec."Second Level Primary Field No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Second Level Primary Field No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Second Level Link Table No."; Rec."Second Level Link Table No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Second Level Link Table No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Second Level Link Field No."; Rec."Second Level Link Field No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Second Level Link Field No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Second Level Link Filter"; Rec."Second Level Link Filter")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Second Level Link Filter field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}
