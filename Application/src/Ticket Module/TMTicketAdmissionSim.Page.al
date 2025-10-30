page 6059985 "NPR TM Ticket Admission Sim"
{
    Caption = 'Ticket Admission Simulation';
    PageType = Card;
    SourceTable = "NPR TM Offline Ticket Valid.";
    SourceTableTemporary = true;
    Extensible = False;
    UsageCategory = None;
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/intro/';
    DataCaptionExpression = Rec."Ticket Reference No.";
    InsertAllowed = false;
    DeleteAllowed = false;
    ShowFilter = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Ticket Reference No."; Rec."Ticket Reference No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Insert External ticket no for simulation of admission.';
                    Caption = 'External Ticket No.';
                    Editable = false;
                }
                field("Admission Code"; Rec."Admission Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Select the admission you wish to simulate for admission.';
                    Editable = true;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Ticket: Record "NPR TM Ticket";
                        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
                    begin
                        Ticket.SetRange("External Ticket No.", Rec."Ticket Reference No.");
                        if Ticket.FindFirst() then begin
                            TicketAccessEntry.SetRange("Ticket No.", Ticket."No.");
                            if PAGE.RunModal(0, TicketAccessEntry) = ACTION::LookupOK then
                                Rec."Admission Code" := TicketAccessEntry."Admission Code";
                        end;
                    end;
                }
                group(EventTime)
                {
                    Caption = 'Event Date & Time';

                    field("Event Date"; Rec."Event Date")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Select the date you wish to simulate for admission.';
                        Editable = true;
                        trigger OnValidate()
                        begin
                            FindSchedule();
                        end;

                    }
                    field("Event Time"; Rec."Event Time")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Select the time you wish to simulate for admission.';
                        Editable = true;
                        trigger OnValidate()
                        begin
                            FindSchedule();
                        end;
                    }

                    field(ScheduleSelected; _ScheduleSelected)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Schedule';
                        ToolTip = 'Schedule selected based on the ticket event date time.';
                        Editable = false;
                    }
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(SimulateTicketArrival)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Simulate Ticket Arrival';
                ToolTip = 'Simulate arrival with selected ticket parameters.';
                Image = Simulate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    TestTicket: Codeunit "NPR TM Test Ticket";
                begin
                    TestTicket.Run(Rec);
                end;
            }
        }
    }

    procedure SetTicket(ExternalTicketNo: Code[30])
    begin
        _ExternalTicketNo := ExternalTicketNo;
    end;

    trigger OnOpenPage()
    var
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
    begin
        Rec."Ticket Reference No." := _ExternalTicketNo;

        Ticket.SetRange("External Ticket No.", Rec."Ticket Reference No.");
        if Ticket.FindFirst() then begin
            TicketAccessEntry.SetRange("Ticket No.", Ticket."No.");
            if TicketAccessEntry.Count() = 1 then
                TicketAccessEntry.FindFirst();
            Rec."Admission Code" := TicketAccessEntry."Admission Code";
        end;
        Rec."Event Date" := Today();
        Rec."Event Time" := Time();
        Rec.Insert();
        FindSchedule();
    end;

    local procedure FindSchedule()
    var
        AdmissionSchedule: Record "NPR TM Admis. Schedule Entry";
        NewLabel: Label 'No matching schedule found';
    begin
        _ScheduleSelected := NewLabel;

        AdmissionSchedule.SetCurrentKey("Admission Code", "Schedule Code", "Admission Start Date");
        AdmissionSchedule.SetFilter("Admission Code", '=%1', Rec."Admission Code");
        AdmissionSchedule.SetFilter("Admission Start Date", '=%1', Rec."Event Date");
        AdmissionSchedule.SetFilter("Admission Start Time", '<=%1', Rec."Event Time");
        AdmissionSchedule.SetFilter("Admission End Time", '>=%1', Rec."Event Time");
        AdmissionSchedule.SetFilter(Cancelled, '=%1', false);
        if (AdmissionSchedule.FindFirst()) then
            _ScheduleSelected := StrSubstno('%1 - %2 to %3', AdmissionSchedule."Schedule Code", AdmissionSchedule."Admission Start Time", AdmissionSchedule."Admission End Time");
    end;

    var
        _ExternalTicketNo: Code[30];
        _ScheduleSelected: Text;
}
