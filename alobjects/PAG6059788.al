page 6059788 "Ticket Access Reservation List"
{
    Caption = 'Ticket Access Reservation';
    PageType = List;
    SourceTable = "Ticket Access Reservation";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Description;Description)
                {
                }
                field(StartTime;StartTime)
                {
                    Caption = 'From Time';
                    Editable = false;
                }
                field(EndTime;EndTime)
                {
                    Caption = 'To Time';
                    Editable = false;
                }
                field("Customer No.";"Customer No.")
                {
                }
                field(Quantity;Quantity)
                {
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
                    TicketAccessReservation: Record "Ticket Access Reservation";
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
                    TicketAccessReservation: Record "Ticket Access Reservation";
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
        EndTime   := TicketAccessCapacitySlots."Access End";
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin

        if (GetFilter("Ticket Access Capacity Slot ID") <> '') and
           (GetRangeMin("Ticket Access Capacity Slot ID")  = GetRangeMax("Ticket Access Capacity Slot ID")) then
          Validate("Ticket Access Capacity Slot ID",GetRangeMin("Ticket Access Capacity Slot ID"));
    end;

    var
        TicketAccessCapacitySlots: Record "Ticket Access Capacity Slots";
        TicketAccessReservationMgt: Codeunit "Ticket Access Reservation Mgt.";
        StartTime: Time;
        EndTime: Time;
}

