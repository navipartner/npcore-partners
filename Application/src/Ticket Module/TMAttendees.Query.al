query 6014404 "NPR TM Attendees"
{
    QueryType = Normal;
    Caption = 'Attendees';
    OrderBy = ascending(TicketID);

    elements
    {
        DataItem(AdmissionScheduleEntry; "NPR TM Admis. Schedule Entry")
        {
            DataItemTableFilter = Cancelled = const(false);

            column(EntryID; "Entry No.")
            {
            }
            column(ExternalScheduleEntryNo; "External Schedule Entry No.")
            {
            }
            column(AdmissionCode; "Admission Code")
            {
            }
            column(ScheduleCode; "Schedule Code")
            {
            }

            DataItem(InitialEntry; "NPR TM Det. Ticket AccessEntry")
            {
                DataItemLink = "External Adm. Sch. Entry No." = AdmissionScheduleEntry."External Schedule Entry No.";
                DataItemTableFilter = "Type" = const(INITIAL_ENTRY);

                column(TicketID; "Ticket No.")
                {
                }
                column(TicketAccessEntryID; "Ticket Access Entry No.")
                {
                }
                column(SumQuantity; Quantity)
                {
                    Method = Sum;
                }

                DataItem(Ticket; "NPR TM Ticket")
                {
                    DataItemLink = "No." = InitialEntry."Ticket No.";
                    DataItemTableFilter = "Blocked" = const(false);
                    column(ExternalTicketNo; "External Ticket No.")
                    {
                    }
                    column(MemberNumber; "External Member Card No.")
                    {
                    }
                    column(CustomerNumber; "Customer No.")
                    {
                    }

                    DataItem(TicketReservationRequest; "NPR TM Ticket Reservation Req.")
                    {
                        DataItemLink = "Entry No." = Ticket."Ticket Reservation Entry No.";
                        column(NotificationAddress; "Notification Address")
                        {
                        }
                        column(ExternalOrderNumber; "External Order No.")
                        {
                        }
                        DataItem(TicketAccessEntry; "NPR TM Ticket Access Entry")
                        {
                            DataItemLink = "Entry No." = InitialEntry."Ticket Access Entry No.";
                            column(AccessDate; "Access Date")
                            {
                            }
                            column(AccessTime; "Access Time")
                            {
                            }
                        }
                    }
                }
            }
        }
    }
}