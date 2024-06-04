page 6151161 "NPR MM Loyalty Server Trx Log"
{
    Extensible = False;

    Caption = 'Loyalty Server Trans. Log';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM Loy. LedgerEntry (Srvr)";
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ToolTip = 'Specifies the value of the Entry Type field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Company Name"; Rec."Company Name")
                {
                    ToolTip = 'Specifies the value of the Company Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ToolTip = 'Specifies the value of the POS Store Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("POS Unit Code"; Rec."POS Unit Code")
                {
                    ToolTip = 'Specifies the value of the POS Unit Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Card Number"; Rec."Card Number")
                {
                    ToolTip = 'Specifies the value of the Card Number field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Reference Number"; Rec."Reference Number")
                {
                    ToolTip = 'Specifies the value of the Reference Number field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Foreign Transaction Id"; Rec."Foreign Transaction Id")
                {
                    ToolTip = 'Specifies the value of the Foreign Transaction Id field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Transaction Date"; Rec."Transaction Date")
                {
                    ToolTip = 'Specifies the value of the Transaction Date field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Transaction Time"; Rec."Transaction Time")
                {
                    ToolTip = 'Specifies the value of the Transaction Time field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Authorization Code"; Rec."Authorization Code")
                {
                    ToolTip = 'Specifies the value of the Authorization Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Earned Points"; Rec."Earned Points")
                {
                    ToolTip = 'Specifies the value of the Earned Points field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Burned Points"; Rec."Burned Points")
                {
                    ToolTip = 'Specifies the value of the Burned Points field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Balance; Rec.Balance)
                {
                    ToolTip = 'Specifies the value of the Balance field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Reservation is Captured"; Rec."Reservation is Captured")
                {
                    ToolTip = 'Specifies the value of the Reservation is Captured field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Reservation is Cancelled"; Rec."Reservation is Cancelled")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Reservation is Cancelled field.', Comment = '%';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Navi&gate")
            {
                Caption = 'Find entries...';
                Image = Navigate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                ToolTip = 'Executes the Find entries action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

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
        area(Processing)
        {
            action(CancelReservation)
            {
                Caption = 'Cancel Reservation';
                Image = Cancel;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = "Process";
                PromotedIsBig = true;

                ToolTip = 'Executes the Cancel Reservation action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                var
                    CancelReservePoints: Codeunit "NPR MM Loy. Point Mgr (Server)";
                    StoreSetup: Record "NPR MM Loyalty Store Setup";
                    TempLoyaltyStoreLedger: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
                    TempCancelLinesIn: Record "NPR MM Reg. Sales Buffer" temporary;
                    TempPointsOut: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
                    ResponseMessage, ResponseMessageId : Text;
                begin
                    Rec.TestField("Entry Type", Rec."Entry Type"::RESERVE);

                    StoreSetup.Get(Rec."Company Name", Rec."POS Store Code", Rec."POS Unit Code");
                    TempLoyaltyStoreLedger.TransferFields(Rec, true);
                    TempLoyaltyStoreLedger."Authorization Code" := StoreSetup."Authorization Code";
                    TempLoyaltyStoreLedger.Insert();

                    TempCancelLinesIn."Entry No." := 0;
                    TempCancelLinesIn.Type := TempCancelLinesIn.Type::CANCEL_RESERVATION;
                    TempCancelLinesIn."Authorization Code" := Rec."Authorization Code";
                    TempCancelLinesIn.Insert();

                    if (not CancelReservePoints.CancelReservation(TempLoyaltyStoreLedger, TempCancelLinesIn, TempPointsOut, ResponseMessage, ResponseMessageId)) then
                        Message(ResponseMessage);
                end;
            }
        }
    }
}

