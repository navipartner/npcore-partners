page 6014698 "NPR POS Posting Prof. Select"
{
    Caption = 'POS Posting Profiles';
    PageType = List;
    SourceTable = "NPR POS Posting Profile";
    SourceTableTemporary = true;
    DelayedInsert = true;
    UsageCategory = None;

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
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Automatic Item Posting field';
                }
                field("Automatic POS Posting"; "Automatic POS Posting")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Automatic POS Posting field';
                }
                field("Automatic Posting Method"; "Automatic Posting Method")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Automatic Posting Method field';
                }
                field("Default POS Entry No. Series"; "Default POS Entry No. Series")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default POS Entry No. Series field';
                }
                field("Max. POS Posting Diff. (LCY)"; "Max. POS Posting Diff. (LCY)")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Max. POS Posting Diff. (LCY) field';
                }
                field("POS Posting Diff. Account"; "POS Posting Diff. Account")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Differences Account field';
                }
            }
        }
    }

    procedure SetRec(var TempPOSPostingProfile: Record "NPR POS Posting Profile")
    begin
        if TempPOSPostingProfile.FindSet() then
            repeat
                Rec.Copy(TempPOSPostingProfile);
                Rec.Insert();
            until TempPOSPostingProfile.Next() = 0;

        if Rec.FindSet() then;
    end;
}