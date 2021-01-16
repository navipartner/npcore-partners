page 6151068 "NPR Distrib. Group Member Card"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Distribution Group Member';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Distrib. Group Members";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Distribution Member Id"; "Distribution Member Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Distribution Member Id field';
                }
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
            part(Control9; "NPR Distribution Setup")
            {
                SubPageLink = "Distribution Group" = FIELD("Distribution Group");
                ApplicationArea = All;
            }
        }
    }

    actions
    {
    }
}

