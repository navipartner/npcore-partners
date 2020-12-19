page 6059786 "NPR TM Ticket AccessEntry List"
{
    Caption = 'Ticket access Entry List';
    Editable = false;
    PageType = List;
    SourceTable = "NPR TM Ticket Access Entry";
    UsageCategory = ReportsAndAnalysis;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Ticket No."; "Ticket No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Ticket Type Code"; "Ticket Type Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Access Date"; "Access Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Access Time"; "Access Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(Description; Description)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Member Card Code"; "Member Card Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field(Status; Status)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
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
                PromotedCategory = Process;

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
        }
        area(processing)
        {
            action("Register Arrival")
            {
                ToolTip = 'Register arrival event for selected admission.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Register Arrival';
                Image = Approve;


                trigger OnAction()
                var
                    TicketManagement: Codeunit "NPR TM Ticket Management";
                begin
                    TicketManagement.ValidateTicketForArrival(0, Rec."Ticket No.", Rec."Admission Code", -1);
                end;
            }
            action("Register Departure")
            {
                ToolTip = 'Register departure event for selected admission.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Register Departure';
                Image = DefaultFault;


                trigger OnAction()
                var
                    TicketManagement: Codeunit "NPR TM Ticket Management";
                begin

                    TicketManagement.ValidateTicketForDeparture(0, Rec."Ticket No.", Rec."Admission Code");
                end;
            }
            action("Block/Unblock")
            {
                ToolTip = 'Prevents the tickets from being used (reversible).';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Block/Unblock';
                Image = Change;


                trigger OnAction()
                begin
                    ToggleBlockUnblock();
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

