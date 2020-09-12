page 6151068 "NPR Distrib. Group Member Card"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Distribution Group Member';
    PageType = Card;
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
                }
                field("Distribution Group"; "Distribution Group")
                {
                    ApplicationArea = All;
                }
                field(Location; Location)
                {
                    ApplicationArea = All;
                }
                field(Store; Store)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Distribution Share Pct."; "Distribution Share Pct.")
                {
                    ApplicationArea = All;
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

