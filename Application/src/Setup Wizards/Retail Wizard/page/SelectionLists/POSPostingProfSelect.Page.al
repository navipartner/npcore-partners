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
                field("Default POS Entry No. Series"; Rec."Default POS Entry No. Series")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default POS Entry No. Series field';
                }
                field("Max. POS Posting Diff. (LCY)"; Rec."Max. POS Posting Diff. (LCY)")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Max. POS Posting Diff. (LCY) field';
                }
                field("POS Posting Diff. Account"; Rec."POS Posting Diff. Account")
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