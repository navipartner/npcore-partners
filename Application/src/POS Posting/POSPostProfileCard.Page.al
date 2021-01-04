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
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Automatic Item Posting"; "Automatic Item Posting")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Automatic Item Posting field';
                }
                field("Automatic POS Posting"; "Automatic POS Posting")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Automatic POS Posting field';
                }
                field("Automatic Posting Method"; "Automatic Posting Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Automatic Posting Method field';
                }
                group("Posting Difference")
                {
                    Caption = 'Posting Difference';
                    field("Max. POS Posting Diff. (LCY)"; "Max. POS Posting Diff. (LCY)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Max. POS Posting Diff. (LCY) field';
                    }
                    field("POS Posting Diff. Account"; "POS Posting Diff. Account")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Differences Account field';
                    }
                }
                group(Rounding)
                {
                    Caption = 'Rounding';
                    field("POS Sales Rounding Account"; "POS Sales Rounding Account")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the POS Sales Rounding Account field';
                    }
                    field("POS Sales Amt. Rndng Precision"; "POS Sales Amt. Rndng Precision")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the POS Sales Amt. Rndng Precision field';
                    }
                    field("Rounding Type"; "Rounding Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Rounding Type field';
                    }
                }
            }
            group(Numbering)
            {
                Caption = 'Numbering';
                field("Default POS Entry No. Series"; "Default POS Entry No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default POS Entry No. Series field';
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

