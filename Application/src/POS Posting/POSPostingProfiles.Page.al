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
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Automatic Item Posting"; "Automatic Item Posting")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Automatic POS Posting"; "Automatic POS Posting")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Automatic Posting Method"; "Automatic Posting Method")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Default POS Entry No. Series"; "Default POS Entry No. Series")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Max. POS Posting Diff. (LCY)"; "Max. POS Posting Diff. (LCY)")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("POS Posting Diff. Account"; "POS Posting Diff. Account")
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

