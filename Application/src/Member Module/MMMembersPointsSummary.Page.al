page 6151165 "NPR MM Members. Points Summary"
{

    Caption = 'Membership Points Summary';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    UsageCategory = Administration;
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
                field("Membership Entry No."; "Membership Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Earn Period Start"; "Earn Period Start")
                {
                    ApplicationArea = All;
                }
                field("Earn Period End"; "Earn Period End")
                {
                    ApplicationArea = All;
                }
                field("Burn Period Start"; "Burn Period Start")
                {
                    ApplicationArea = All;
                }
                field("Burn Period End"; "Burn Period End")
                {
                    ApplicationArea = All;
                }
                field("Points Earned"; "Points Earned")
                {
                    ApplicationArea = All;
                }
                field("Points Redeemed"; "Points Redeemed")
                {
                    ApplicationArea = All;
                }
                field("Points Expired"; "Points Expired")
                {
                    ApplicationArea = All;
                }
                field("Points Remaining"; "Points Remaining")
                {
                    ApplicationArea = All;
                }
                field("Amount Earned (LCY)"; "Amount Earned (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Amount Redeemed (LCY)"; "Amount Redeemed (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Amount Remaining (LCY)"; "Amount Remaining (LCY)")
                {
                    ApplicationArea = All;
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

