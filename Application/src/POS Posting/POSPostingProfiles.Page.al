page 6150638 "NPR POS Posting Profiles"
{
    Caption = 'POS Posting Profiles';
    CardPageID = "NPR POS Post. Profile Card";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR POS Posting Profile";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
                    Visible = false;
                    ToolTip = 'Specifies the value of the Automatic Item Posting field';
                }
                field("Automatic POS Posting"; "Automatic POS Posting")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Automatic POS Posting field';
                }
                field("Automatic Posting Method"; "Automatic Posting Method")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Automatic Posting Method field';
                }
                field("Default POS Entry No. Series"; "Default POS Entry No. Series")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Default POS Entry No. Series field';
                }
                field("Max. POS Posting Diff. (LCY)"; "Max. POS Posting Diff. (LCY)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Max. POS Posting Diff. (LCY) field';
                }
                field("POS Posting Diff. Account"; "POS Posting Diff. Account")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Differences Account field';
                }
            }
        }
    }

    actions
    {
    }
}

