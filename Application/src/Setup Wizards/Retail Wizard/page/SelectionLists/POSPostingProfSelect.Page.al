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

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Max. POS Posting Diff. (LCY)"; Rec."Max. POS Posting Diff. (LCY)")
                {
                    Visible = false;

                    ToolTip = 'Specifies the value of the Max. POS Posting Diff. (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Posting Diff. Account"; Rec."POS Posting Diff. Account")
                {
                    Visible = false;

                    ToolTip = 'Specifies the value of the Differences Account field';
                    ApplicationArea = NPRRetail;
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