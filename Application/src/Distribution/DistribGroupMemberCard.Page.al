page 6151068 "NPR Distrib. Group Member Card"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Distribution Group Member';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR Distrib. Group Members";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Distribution Member Id"; Rec."Distribution Member Id")
                {

                    ToolTip = 'Specifies the value of the Distribution Member Id field';
                    ApplicationArea = NPRRetail;
                }
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
            part(Control9; "NPR Distribution Setup")
            {
                SubPageLink = "Distribution Group" = FIELD("Distribution Group");
                ApplicationArea = NPRRetail;

            }
        }
    }

    actions
    {
    }
}

