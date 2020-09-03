page 6059788 "NPR Ticket Access Reserv. List"
{
    Caption = 'Ticket Access Reservation';
    PageType = List;
    SourceTable = "NPR Ticket Access Reserv.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(StartTime; StartTime)
                {
                    ApplicationArea = All;
                    Caption = 'From Time';
                    Editable = false;
                }
                field(EndTime; EndTime)
                {
                    ApplicationArea = All;
                    Caption = 'To Time';
                    Editable = false;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Print Ticket")
            {
                Caption = 'Print Ticket';
                Image = Print;
                ShortCutKey = 'Ctrl+P';

                trigger OnAction()
                var
                    TicketAccessReservation: Record "NPR Ticket Access Reserv.";
                begin

                    TicketAccessReservation := Rec;
                    TicketAccessReservation.SetRecFilter;
                    TicketAccessReservationMgt.PrintReservation(TicketAccessReservation);
                end;
            }
            action("Print Selected Tickets")
            {
                Caption = 'Print Selected Tickets';
                Image = Print;
                ShortCutKey = 'Shift+Ctrl+P';

                trigger OnAction()
                var
                    TicketAccessReservation: Record "NPR Ticket Access Reserv.";
                begin

                    CurrPage.SetSelectionFilter(TicketAccessReservation);
                    TicketAccessReservationMgt.PrintReservation(TicketAccessReservation);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin

        TicketAccessCapacitySlots.Get("Ticket Access Capacity Slot ID");
        StartTime := TicketAccessCapacitySlots."Access Start";
        EndTime := TicketAccessCapacitySlots."Access End";
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin

        if (GetFilter("Ticket Access Capacity Slot ID") <> '') and
           (GetRangeMin("Ticket Access Capacity Slot ID") = GetRangeMax("Ticket Access Capacity Slot ID")) then
            Validate("Ticket Access Capacity Slot ID", GetRangeMin("Ticket Access Capacity Slot ID"));
    end;

    var
        TicketAccessCapacitySlots: Record "NPR Ticket Access Cap. Slots";
        TicketAccessReservationMgt: Codeunit "NPR Ticket AccessReserv.Mgt";
        StartTime: Time;
        EndTime: Time;
}

