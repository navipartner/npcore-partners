page 6151161 "NPR MM Loyalty Server Trx Log"
{

    Caption = 'Loyalty Server Trans. Log';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Type field';
                }
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company Name field';
                }
                field("POS Store Code"; "POS Store Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Store Code field';
                }
                field("POS Unit Code"; "POS Unit Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit Code field';
                }
                field("Card Number"; "Card Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Number field';
                }
                field("Reference Number"; "Reference Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference Number field';
                }
                field("Foreign Transaction Id"; "Foreign Transaction Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Foreign Transaction Id field';
                }
                field("Transaction Date"; "Transaction Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction Date field';
                }
                field("Transaction Time"; "Transaction Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction Time field';
                }
                field("Authorization Code"; "Authorization Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Authorization Code field';
                }
                field("Earned Points"; "Earned Points")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Earned Points field';
                }
                field("Burned Points"; "Burned Points")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Burned Points field';
                }
                field(Balance; Balance)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balance field';
                }
                field("Reservation is Captured"; "Reservation is Captured")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reservation is Captured field';
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
				PromotedOnly = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the &Navigate action';

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

