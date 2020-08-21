page 6151165 "MM Membership Points Summary"
{
    // MM1.45/TSA /20200629 CASE 411768 Initial Version

    Caption = 'Membership Points Summary';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "MM Membership Points Summary";
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
        LoyaltyPointManagement: Codeunit "MM Loyalty Point Management";
    begin

        if (Rec.IsTemporary()) then begin
            Rec.Reset();
            Rec.DeleteAll();
        end;

        LoyaltyPointManagement.CalculatePeriodPointsSummary(MembershipEntryNo, Rec);
        CurrPage.Update(false);
    end;
}

