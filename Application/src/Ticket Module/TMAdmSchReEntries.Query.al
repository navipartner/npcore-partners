query 6014517 "NPR TM Adm. Sch. Re-Entries"
{
    Access = Internal;
    QueryType = Normal;
    Caption = 'Admission Schedule Re-Entries';

    elements
    {
        dataitem(ScheduleEntry; "NPR TM Admis. Schedule Entry")
        {
            filter(AdmissionCode; "Admission Code")
            {
            }
            filter(Cancelled; Cancelled)
            {
            }
            filter(AdmissionStartDate; "Admission Start Date")
            {
            }
            column(ExternalScheduleEntryNo; "External Schedule Entry No.")
            {
            }

            dataitem(AdmittedEntry; "NPR TM Det. Ticket AccessEntry")
            {
                DataItemLink = "External Adm. Sch. Entry No." = ScheduleEntry."External Schedule Entry No.";
                DataItemTableFilter = Type = const(ADMITTED);
                SqlJoinType = InnerJoin;

                filter(OpenEntry; Open)
                {
                }
                column(TicketAccessEntryNo; "Ticket Access Entry No.")
                {
                }
                // Only tickets scanned in more than once on the slot.
                column(AdmissionRows)
                {
                    Method = Count;
                    ColumnFilter = AdmissionRows = filter(> 1);
                }
                column(QuantitySum; Quantity)
                {
                    Method = Sum;
                }
                column(QuantityMax; Quantity)
                {
                    Method = Max;
                }
            }
        }
    }
}
