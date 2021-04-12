page 6060108 "NPR RC Ticket Activities"
{
    // TM1.16/TSA/20160816  CASE 233430 Transport TM1.16 - 19 July 2016

    Caption = 'Ticket Activities';
    PageType = CardPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR RC Ticket Cues";

    layout
    {
        area(content)
        {
            cuegroup("Events (Today)")
            {
                Caption = 'Events (Today)';
                field("Event Count 1"; Rec."Event Count 1")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Image = Library;
                    ToolTip = 'Specifies the value of the Events (Today) field';
                }
                field("Event Capacity 1"; Rec."Event Capacity 1")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Image = People;
                    ToolTip = 'Specifies the value of the Capacity (Today) field';
                }
                field("Event Open Reservations 1"; Rec."Event Open Reservations 1")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Image = Person;
                    ToolTip = 'Specifies the value of the Reservations (Today) field';
                }
                field("Event Admitted 1"; Rec."Event Admitted 1")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Image = Person;
                    ToolTip = 'Specifies the value of the Admitted Cnt. (Today) field';
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
                field("Event Count 2"; Rec."Event Count 2")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Image = Library;
                    ToolTip = 'Specifies the value of the Events (Tomorrow) field';
                }
                field("Event Capacity 2"; Rec."Event Capacity 2")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Image = People;
                    ToolTip = 'Specifies the value of the Capacity (Tomorrow) field';
                }
                field("Event Open Reservations 2"; Rec."Event Open Reservations 2")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Image = Person;
                    ToolTip = 'Specifies the value of the Reservations (Tomorrow) field';
                }
                field("Event Admitted 2"; Rec."Event Admitted 2")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Image = Person;
                    ToolTip = 'Specifies the value of the Admitted Cnt. (Tomorrow) field';
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
    end;

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}

