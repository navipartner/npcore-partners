page 6150639 "NPR POS Post. Profile Card"
{
    Caption = 'POS Posting Profile Card';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR POS Posting Profile";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Automatic Item Posting"; "Automatic Item Posting")
                {
                    ApplicationArea = All;
                }
                field("Automatic POS Posting"; "Automatic POS Posting")
                {
                    ApplicationArea = All;
                }
                field("Automatic Posting Method"; "Automatic Posting Method")
                {
                    ApplicationArea = All;
                }
                group("Posting Difference")
                {
                    Caption = 'Posting Difference';
                    field("Max. POS Posting Diff. (LCY)"; "Max. POS Posting Diff. (LCY)")
                    {
                        ApplicationArea = All;
                    }
                    field("POS Posting Diff. Account"; "POS Posting Diff. Account")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Rounding)
                {
                    Caption = 'Rounding';
                    field("POS Sales Rounding Account"; "POS Sales Rounding Account")
                    {
                        ApplicationArea = All;
                    }
                    field("POS Sales Amt. Rndng Precision"; "POS Sales Amt. Rndng Precision")
                    {
                        ApplicationArea = All;
                    }
                    field("Rounding Type"; "Rounding Type")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(Numbering)
            {
                Caption = 'Numbering';
                field("Default POS Entry No. Series"; "Default POS Entry No. Series")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014413; Notes)
            {
                ApplicationArea = All;
            }
            systempart(Control6014414; Links)
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
    }
}

