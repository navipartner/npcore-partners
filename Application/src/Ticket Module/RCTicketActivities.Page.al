page 6060108 "NPR RC Ticket Activities"
{
    Extensible = False;
    Caption = 'Ticket Activities';
    PageType = CardPart;
    UsageCategory = Administration;

    SourceTable = "NPR RC Ticket Cues";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            cuegroup("Events (Today)")
            {
                Caption = 'Events (Today)';
                field("Event Count 1"; EventsToday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Image = Library;
                    ToolTip = 'Specifies the value of the Events (Today) field';
                    Caption = 'Events (Today)';
                    DecimalPlaces = 0 : 0;
                }
                field("Event Capacity 1"; CapacityToday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Image = People;
                    ToolTip = 'Specifies the value of the Capacity (Today) field';
                    Caption = 'Capacity (Today)';
                    DecimalPlaces = 0 : 0;
                }
                field("Event Open Reservations 1"; ReservationsToday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Image = Person;
                    ToolTip = 'Specifies the value of the Reservations (Today) field';
                    Caption = 'Reservations (Today)';
                    DecimalPlaces = 0 : 0;
                }
                field("Event Admitted 1"; AdmittedToday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Image = Person;
                    ToolTip = 'Specifies the value of the Admitted Cnt. (Today) field';
                    Caption = 'Admitted Cnt. (Today)';
                    DecimalPlaces = 0 : 0;
                }
                field("Event Utilization Avg. 1"; Rec."Event Utilization Avg. 1")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Utilization % (Today) field';
                }
            }
            cuegroup("Events (Tomorrow)")
            {
                Caption = 'Events (Tomorrow)';
                field("Event Count 2"; EventsTomorrow)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Image = Library;
                    ToolTip = 'Specifies the value of the Events (Tomorrow) field';
                    Caption = 'Events (Tomorrow)';
                    DecimalPlaces = 0 : 0;
                }
                field("Event Capacity 2"; CapacityTomorrow)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Image = People;
                    ToolTip = 'Specifies the value of the Capacity (Tomorrow) field';
                    Caption = 'Capacity (Tomorrow)';
                    DecimalPlaces = 0 : 0;
                }
                field("Event Open Reservations 2"; ReservationsTomorrow)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Image = Person;
                    ToolTip = 'Specifies the value of the Reservations (Tomorrow) field';
                    Caption = 'Reservations (Tomorrow)';
                    DecimalPlaces = 0 : 0;
                }
                field("Event Admitted 2"; AdmittedTomorrow)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Image = Person;
                    ToolTip = 'Specifies the value of the Admitted Cnt. (Tomorrow) field';
                    Caption = 'Reservations (Tomorrow)';
                    DecimalPlaces = 0 : 0;
                }
                field("Event Utilization Avg. 2"; Rec."Event Utilization Avg. 2")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Image = Heart;
                    ToolTip = 'Specifies the value of the Utilization % (Tomorrow) field';
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
                ToolTip = 'Executes the Set Up Cues action';


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
        Rec.CalculateCues();
        CapacityToday := Rec."Event Capacity 1";
        CapacityTomorrow := Rec."Event Capacity 2";
        ReservationsToday := Rec."Event Open Reservations 1";
        ReservationsTomorrow := Rec."Event Open Reservations 2";
        EventsToday := Rec."Event Count 1";
        EventsTomorrow := Rec."Event Count 2";
        AdmittedToday := Rec."Event Admitted 1";
        AdmittedTomorrow := Rec."Event Admitted 2";
    end;

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

    var
        CapacityToday, CapacityTomorrow : Decimal;
        ReservationsToday, ReservationsTomorrow : Decimal;
        EventsToday, EventsTomorrow : Decimal;
        AdmittedToday, AdmittedTomorrow : Decimal;

}

