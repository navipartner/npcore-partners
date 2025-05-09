﻿page 6151165 "NPR MM Members. Points Summary"
{
    Extensible = False;

    Caption = 'Membership Points Summary';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    UsageCategory = None;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "NPR MM Members. Points Summary";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Membership Entry No."; Rec."Membership Entry No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Membership Entry No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Earn Period Start"; Rec."Earn Period Start")
                {

                    ToolTip = 'Specifies the value of the Earn Period Start field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Earn Period End"; Rec."Earn Period End")
                {

                    ToolTip = 'Specifies the value of the Earn Period End field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Burn Period Start"; Rec."Burn Period Start")
                {

                    ToolTip = 'Specifies the value of the Burn Period Start field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Burn Period End"; Rec."Burn Period End")
                {

                    ToolTip = 'Specifies the value of the Burn Period End field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Points Earned"; Rec."Points Earned")
                {

                    ToolTip = 'Specifies the value of the Points Earned field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Points Redeemed"; Rec."Points Redeemed")
                {

                    ToolTip = 'Specifies the value of the Points Redeemed field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Points Expired"; Rec."Points Expired")
                {

                    ToolTip = 'Specifies the value of the Points Expired field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Points Remaining"; Rec."Points Remaining")
                {

                    ToolTip = 'Specifies the value of the Points Remaining field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Amount Earned (LCY)"; Rec."Amount Earned (LCY)")
                {

                    ToolTip = 'Specifies the value of the Amount Earned (LCY) field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Amount Redeemed (LCY)"; Rec."Amount Redeemed (LCY)")
                {

                    ToolTip = 'Specifies the value of the Amount Redeemed (LCY) field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Amount Remaining (LCY)"; Rec."Amount Remaining (LCY)")
                {

                    ToolTip = 'Specifies the value of the Amount Remaining (LCY) field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    actions
    {
    }

    internal procedure FillPageSummary(MembershipEntryNo: Integer)
    var
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
    begin

        if (Rec.IsTemporary()) then begin
            Rec.Reset();
            Rec.DeleteAll();
        end;

        LoyaltyPointManagement.CalculatePeriodPointsSummary(MembershipEntryNo, Rec);
        CurrPage.Update(false);
    end;
}

