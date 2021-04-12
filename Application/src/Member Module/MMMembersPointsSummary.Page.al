page 6151165 "NPR MM Members. Points Summary"
{

    Caption = 'Membership Points Summary';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Membership Entry No. field';
                }
                field("Earn Period Start"; Rec."Earn Period Start")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Earn Period Start field';
                }
                field("Earn Period End"; Rec."Earn Period End")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Earn Period End field';
                }
                field("Burn Period Start"; Rec."Burn Period Start")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Burn Period Start field';
                }
                field("Burn Period End"; Rec."Burn Period End")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Burn Period End field';
                }
                field("Points Earned"; Rec."Points Earned")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Points Earned field';
                }
                field("Points Redeemed"; Rec."Points Redeemed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Points Redeemed field';
                }
                field("Points Expired"; Rec."Points Expired")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Points Expired field';
                }
                field("Points Remaining"; Rec."Points Remaining")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Points Remaining field';
                }
                field("Amount Earned (LCY)"; Rec."Amount Earned (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Earned (LCY) field';
                }
                field("Amount Redeemed (LCY)"; Rec."Amount Redeemed (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Redeemed (LCY) field';
                }
                field("Amount Remaining (LCY)"; Rec."Amount Remaining (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Remaining (LCY) field';
                }
            }
        }
    }

    actions
    {
    }

    procedure FillPageSummary(MembershipEntryNo: Integer)
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

