page 6059786 "NPR TM Ticket AccessEntry List"
{
    Caption = 'Ticket access Entry List';
    Editable = false;
    PageType = List;
    SourceTable = "NPR TM Ticket Access Entry";
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    PromotedActionCategories = 'New,Process,Report,Navigate';
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
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

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
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

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

