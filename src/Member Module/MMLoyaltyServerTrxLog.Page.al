page 6151161 "NPR MM Loyalty Server Trx Log"
{
    // MM1.38/TSA /20190522 CASE 338215 Initial Version

    Caption = 'Loyalty Server Trans. Log';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR MM Loy. LedgerEntry (Srvr)";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = All;
                }
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                }
                field("POS Store Code"; "POS Store Code")
                {
                    ApplicationArea = All;
                }
                field("POS Unit Code"; "POS Unit Code")
                {
                    ApplicationArea = All;
                }
                field("Card Number"; "Card Number")
                {
                    ApplicationArea = All;
                }
                field("Reference Number"; "Reference Number")
                {
                    ApplicationArea = All;
                }
                field("Foreign Transaction Id"; "Foreign Transaction Id")
                {
                    ApplicationArea = All;
                }
                field("Transaction Date"; "Transaction Date")
                {
                    ApplicationArea = All;
                }
                field("Transaction Time"; "Transaction Time")
                {
                    ApplicationArea = All;
                }
                field("Authorization Code"; "Authorization Code")
                {
                    ApplicationArea = All;
                }
                field("Earned Points"; "Earned Points")
                {
                    ApplicationArea = All;
                }
                field("Burned Points"; "Burned Points")
                {
                    ApplicationArea = All;
                }
                field(Balance; Balance)
                {
                    ApplicationArea = All;
                }
                field("Reservation is Captured"; "Reservation is Captured")
                {
                    ApplicationArea = All;
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
                ApplicationArea = All;

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                    MembershipPointEntryPage: Page "NPR MM Members. Point Entry";
                    MembershipPointEntry: Record "NPR MM Members. Points Entry";
                begin

                    if ("Entry Type" = "Entry Type"::RECONCILE) then begin
                        Navigate.SetDoc("Transaction Date", "Reference Number");
                        Navigate.Run;
                    end else begin
                        MembershipPointEntry.SetFilter("Document No.", '=%1', "Reference Number");
                        MembershipPointEntryPage.SetTableView(MembershipPointEntry);
                        MembershipPointEntryPage.Run();
                    end;
                end;
            }
        }
    }
}

