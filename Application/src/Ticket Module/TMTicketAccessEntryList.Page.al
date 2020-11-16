page 6059786 "NPR TM Ticket AccessEntry List"
{
    // TM1.00/TSA/20151217  CASE 219658-01 NaviPartner Ticket Management
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.17/NPKNAV/20161026  CASE 256152 Transport TM1.17
    // TM1.21/TSA/20170504  CASE 274843 Added ToggleBlockUnblock() function
    // TM1.27/TSA /20180125 CASE 301140 Refactored

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
                //RunObject = Page "NPR TM Det. Ticket AccessEntry";
                //RunPageLink = "Ticket Access Entry No." = FIELD("Entry No.");

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
                    MessageId: Integer;
                    MessageText: Text;
                    NoValue: Integer;
                begin

                    //-TM1.27 [301140]
                    NoValue := -1;
                    MessageId := TicketManagement.ValidateTicketForArrival(0, "Ticket No.", "Admission Code", NoValue, true, MessageText);
                    //MessageId := TicketManagement.ValidateTicketForArrival (0, "Ticket No.", "Admission Code", -1, TRUE, MessageText);
                    //+TM1.27 [301140]
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
                    MessageId: Integer;
                    MessageText: Text;
                begin

                    MessageId := TicketManagement.ValidateTicketForDeparture(0, "Ticket No.", "Admission Code", true, MessageText);
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

