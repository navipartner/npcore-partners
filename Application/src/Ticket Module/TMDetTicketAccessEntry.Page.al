page 6060123 "NPR TM Det. Ticket AccessEntry"
{
    Caption = 'Detailed Ticket Access Entry';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR TM Det. Ticket AccessEntry";
    UsageCategory = None;
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
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Posting Date field';
                }
                field("Ticket No."; Rec."Ticket No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket No. field';
                }
                field("Ticket Access Entry No."; Rec."Ticket Access Entry No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Access Entry No. field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("External Adm. Sch. Entry No."; Rec."External Adm. Sch. Entry No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the External Adm. Sch. Entry No. field';
                }
                field("Scheduled Time"; ScheduledTime)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Scheduled Time';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Scheduled Time field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Closed By Entry No."; Rec."Closed By Entry No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Closed By Entry No. field';
                }
                field(Open; Rec.Open)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Open field';
                }
                field("Sales Channel No."; Rec."Sales Channel No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales Channel No. field';
                }
                field("Created Datetime"; Rec."Created Datetime")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Created Datetime field';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the User ID field';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Admission Schedule Entry")
            {
                ToolTip = 'Navigate to list of issued tickets for this time entry.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Admission Schedule Entry';
                Image = WorkCenterLoad;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "NPR TM Admis. Schedule Entry";
                RunPageLink = "External Schedule Entry No." = FIELD("External Adm. Sch. Entry No.");

            }
            action("Ticket Request")
            {
                ToolTip = 'Navigate to list of ticket requests for thie time entry.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Ticket Request';
                Image = Navigate;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Category4;
                trigger OnAction()
                begin
                    OpenTicketRequest(Rec);
                end;
            }
            action("Unconsume Item")
            {
                ToolTip = 'Unconsume the complimenatry item linked with this ticket.';
                ApplicationArea = NPRTicketAdvanced;
                Caption = 'Unconsume Item';
                Image = ConsumptionJournal;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    UnconsumeItem();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        ScheduledTime := '';
        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', Rec."External Adm. Sch. Entry No.");
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (AdmissionScheduleEntry.FindFirst()) then
            ScheduledTime := StrSubstNo('%1 %2', AdmissionScheduleEntry."Admission Start Date", AdmissionScheduleEntry."Admission Start Time");
    end;

    var
        ScheduledTime: Text[30];

    local procedure UnconsumeItem()
    begin

        Rec.TestField(Type, Rec.Type::CONSUMED);
        if (Rec.Type = Rec.Type::CONSUMED) then
            Rec.Delete;
    end;

    local procedure OpenTicketRequest(DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry")
    var
        Ticket: Record "NPR TM Ticket";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketRequest: Page "NPR TM Ticket Request";
    begin

        //-TM1.48 [416096]
        Ticket.Get(DetTicketAccessEntry."Ticket No.");
        TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.");

        TicketReservationRequest.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
        TicketRequest.SetTableView(TicketReservationRequest);
        TicketRequest.Run();
        //+TM1.48 [416096]
    end;
}

