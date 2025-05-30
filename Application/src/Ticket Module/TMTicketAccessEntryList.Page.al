﻿page 6059786 "NPR TM Ticket AccessEntry List"
{
    Extensible = False;
    Caption = 'Ticket access Entry List';
    Editable = false;
    PageType = List;
    SourceTable = "NPR TM Ticket Access Entry";
    UsageCategory = ReportsAndAnalysis;
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/intro/';
    PromotedActionCategories = 'New,Process,Report,Navigate';
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Ticket No."; Rec."Ticket No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket No. field';
                }
                field("Ticket Type Code"; Rec."Ticket Type Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Type Code field';
                }
                field("Admission Code"; Rec."Admission Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field("Access Date"; Rec."Access Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Access Date field';
                }
                field("Access Time"; Rec."Access Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Access Time field';
                }
                field(DurationUntilDate; Rec.DurationUntilDate)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies if the validity is limited by duration rather than the scheduled end date.';
                }
                field(DurationUntilTime; Rec.DurationUntilTime)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies if the validity is limited by duration rather than the scheduled end time.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Member Card Code"; Rec."Member Card Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Member Card Code field';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Qty. field';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Detailed Access Entries")
            {
                ToolTip = 'Navigate to ticket admission details.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Detailed Access Entries';
                Image = LedgerEntries;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;

                trigger OnAction()
                var
                    PageDetAccessEntry: Page "NPR TM Det. Ticket AccessEntry";
                    DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
                begin
                    DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', Rec."Entry No.");
                    PageDetAccessEntry.SetTableView(DetTicketAccessEntry);
                    PageDetAccessEntry.Run();
                end;
            }
            action("Register Arrival")
            {
                ToolTip = 'Register arrival event for selected admission.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Register Arrival';
                Image = Approve;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    Ticket: Record "NPR TM Ticket";
                    SpeedGate: Codeunit "NPR SG SpeedGate";
                    GateId: Code[10];
                    AdmitToken: Guid;
                    ReasonMessage: Text;
                begin
                    GateId := SpeedGate.CreateSystemGate(6059786);
                    Ticket.Get(Rec."Ticket No.");
                    AdmitToken := SpeedGate.CreateAdmitToken(Ticket."External Ticket No.", Rec."Admission Code", GateId);
                    Commit();

                    if (not SpeedGate.CheckAdmit(AdmitToken, 1, ReasonMessage)) then begin
                        Commit(); // commit the transactions log entry before showing the error message
                        Error(ReasonMessage);
                    end;
                end;
            }
            action("Register Departure")
            {
                ToolTip = 'Register departure event for selected admission.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Register Departure';
                Image = DefaultFault;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    TicketManagement: Codeunit "NPR TM Ticket Management";
                begin

                    TicketManagement.ValidateTicketForDeparture("NPR TM TicketIdentifierType"::INTERNAL_TICKET_NO, Rec."Ticket No.", Rec."Admission Code");
                end;
            }
            action("Block/Unblock")
            {
                ToolTip = 'Prevents the tickets from being used (reversible).';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Block/Unblock';
                Image = Change;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    ToggleBlockUnblock();
                end;
            }
            action(SubmitToDeferral)
            {
                ToolTip = 'Manually submit this ticket access entry to revenue deferral.';
                ApplicationArea = NPRTicketAdvanced;
                Caption = 'Submit to Deferral';
                Image = Revenue;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    DeferRevenue: Codeunit "NPR TM RevenueDeferral";
                begin
                    DeferRevenue.CreateDeferRevenueRequest(Rec."Entry No.", Today());
                    if (Rec."Access Date" <> 0D) then
                        DeferRevenue.ReadyToRecognize(Rec."Entry No.", Rec."Access Date");
                end;
            }
        }
    }

    local procedure ToggleBlockUnblock()
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        TicketAccessEntry2: Record "NPR TM Ticket Access Entry";
    begin

        CurrPage.SetSelectionFilter(TicketAccessEntry);
        if (TicketAccessEntry.FindSet()) then begin
            repeat
                TicketAccessEntry2.Get(TicketAccessEntry."Entry No.");

                case TicketAccessEntry.Status of
                    TicketAccessEntry.Status::ACCESS:
                        TicketAccessEntry2.Status := TicketAccessEntry2.Status::BLOCKED;
                    TicketAccessEntry.Status::BLOCKED:
                        TicketAccessEntry2.Status := TicketAccessEntry2.Status::ACCESS;
                end;

                TicketAccessEntry2.Modify();
            until (TicketAccessEntry.Next() = 0);
        end;
    end;
}

