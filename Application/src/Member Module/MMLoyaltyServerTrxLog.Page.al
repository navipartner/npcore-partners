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
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Type field';
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company Name field';
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Store Code field';
                }
                field("POS Unit Code"; Rec."POS Unit Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit Code field';
                }
                field("Card Number"; Rec."Card Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Number field';
                }
                field("Reference Number"; Rec."Reference Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference Number field';
                }
                field("Foreign Transaction Id"; Rec."Foreign Transaction Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Foreign Transaction Id field';
                }
                field("Transaction Date"; Rec."Transaction Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction Date field';
                }
                field("Transaction Time"; Rec."Transaction Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction Time field';
                }
                field("Authorization Code"; Rec."Authorization Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Authorization Code field';
                }
                field("Earned Points"; Rec."Earned Points")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Earned Points field';
                }
                field("Burned Points"; Rec."Burned Points")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Burned Points field';
                }
                field(Balance; Rec.Balance)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balance field';
                }
                field("Reservation is Captured"; Rec."Reservation is Captured")
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

                    if (Rec."Entry Type" = Rec."Entry Type"::RECONCILE) then begin
                        Navigate.SetDoc(Rec."Transaction Date", Rec."Reference Number");
                        Navigate.Run();
                    end else begin
                        MembershipPointEntry.SetFilter("Document No.", '=%1', Rec."Reference Number");
                        MembershipPointEntryPage.SetTableView(MembershipPointEntry);
                        MembershipPointEntryPage.Run();
                    end;
                end;
            }
        }
    }
}

