page 6059985 "NPR TM Ticket Admission Sim"
{
    Caption = 'Ticket Admission Simulation';
    PageType = Card;
    SourceTable = "NPR TM Offline Ticket Valid.";
    SourceTableTemporary = true;
    Extensible = False;
    UsageCategory = None;
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/intro/';
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
                }
                field("Admission Code"; Rec."Admission Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Select the admission you wish to simulate for admission.';
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
                field("Event Date"; Rec."Event Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Select the date you wish to simulate for admission.';
                }
                field("Event Time"; Rec."Event Time")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Select the time you wish to simulate for admission.';
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
    end;


    var
        _ExternalTicketNo: Code[30];
}
