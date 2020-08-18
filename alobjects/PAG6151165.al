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
                field("Membership Entry No.";"Membership Entry No.")
                {
                    Visible = false;
                }
                field("Earn Period Start";"Earn Period Start")
                {
                }
                field("Earn Period End";"Earn Period End")
                {
                }
                field("Burn Period Start";"Burn Period Start")
                {
                }
                field("Burn Period End";"Burn Period End")
                {
                }
                field("Points Earned";"Points Earned")
                {
                }
                field("Points Redeemed";"Points Redeemed")
                {
                }
                field("Points Expired";"Points Expired")
                {
                }
                field("Points Remaining";"Points Remaining")
                {
                }
                field("Amount Earned (LCY)";"Amount Earned (LCY)")
                {
                }
                field("Amount Redeemed (LCY)";"Amount Redeemed (LCY)")
                {
                }
                field("Amount Remaining (LCY)";"Amount Remaining (LCY)")
                {
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

        if (Rec.IsTemporary ()) then begin
          Rec.Reset ();
          Rec.DeleteAll ();
        end;

        LoyaltyPointManagement.CalculatePeriodPointsSummary (MembershipEntryNo, Rec);
        CurrPage.Update (false);
    end;
}

