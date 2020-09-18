page 6060108 "NPR RC Ticket Activities"
{
    // TM1.16/TSA/20160816  CASE 233430 Transport TM1.16 - 19 July 2016

    Caption = 'Ticket Activities';
    PageType = CardPart;
    UsageCategory = Administration;
    SourceTable = "NPR RC Ticket Cues";

    layout
    {
        area(content)
        {
            cuegroup("Events (Today)")
            {
                Caption = 'Events (Today)';
                field("Event Count 1"; "Event Count 1")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Image = Library;
                }
                field("Event Capacity 1"; "Event Capacity 1")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Image = People;
                }
                field("Event Open Reservations 1"; "Event Open Reservations 1")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Image = Person;
                }
                field("Event Admitted 1"; "Event Admitted 1")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Image = Person;
                }
                field("Event Utilization Avg. 1"; "Event Utilization Avg. 1")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(Control6150619; '')
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Image = Heart;
                    ShowCaption = false;
                }
            }
            cuegroup("Events (Tomorrow)")
            {
                Caption = 'Events (Tomorrow)';
                field("Event Count 2"; "Event Count 2")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Image = Library;
                }
                field("Event Capacity 2"; "Event Capacity 2")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Image = People;
                }
                field("Event Open Reservations 2"; "Event Open Reservations 2")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Image = Person;
                }
                field("Event Admitted 2"; "Event Admitted 2")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Image = Person;
                }
                field("Event Utilization Avg. 2"; "Event Utilization Avg. 2")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Image = Heart;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Set Up Cues")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Set Up Cues';
                Image = Setup;


                trigger OnAction()
                var
                    CueRecordRef: RecordRef;
                    CuesAndKpis: Codeunit "Cues And KPIs";
                begin
                    CueRecordRef.GetTable(Rec);
                    CuesAndKpis.OpenCustomizePageForCurrentUser(CueRecordRef.Number);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CalculateCues();
    end;

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;
    end;
}

