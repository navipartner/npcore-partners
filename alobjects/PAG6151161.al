page 6151161 "MM Loyalty Server Trans. Log"
{
    // MM1.38/TSA /20190522 CASE 338215 Initial Version

    Caption = 'Loyalty Server Trans. Log';
    PageType = List;
    SourceTable = "MM Loyalty Ledger Entry (Srvr)";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                }
                field("Entry Type";"Entry Type")
                {
                }
                field("Company Name";"Company Name")
                {
                }
                field("POS Store Code";"POS Store Code")
                {
                }
                field("POS Unit Code";"POS Unit Code")
                {
                }
                field("Card Number";"Card Number")
                {
                }
                field("Reference Number";"Reference Number")
                {
                }
                field("Foreign Transaction Id";"Foreign Transaction Id")
                {
                }
                field("Transaction Date";"Transaction Date")
                {
                }
                field("Transaction Time";"Transaction Time")
                {
                }
                field("Authorization Code";"Authorization Code")
                {
                }
                field("Earned Points";"Earned Points")
                {
                }
                field("Burned Points";"Burned Points")
                {
                }
                field(Balance;Balance)
                {
                }
                field("Reservation is Captured";"Reservation is Captured")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Navigate)
            {
                Caption = '&Navigate';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                    MembershipPointEntryPage: Page "MM Membership Point Entry";
                    MembershipPointEntry: Record "MM Membership Points Entry";
                begin

                    if ("Entry Type" = "Entry Type"::RECONCILE) then begin
                      Navigate.SetDoc ("Transaction Date", "Reference Number");
                      Navigate.Run;
                    end else begin
                      MembershipPointEntry.SetFilter ("Document No.", '=%1', "Reference Number");
                      MembershipPointEntryPage.SetTableView (MembershipPointEntry);
                      MembershipPointEntryPage.Run ();
                    end;
                end;
            }
        }
    }
}

