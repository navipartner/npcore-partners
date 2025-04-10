query 6014486 "NPR TM Admis. Schedule Entry"
{
    Access = Public;
    QueryType = Normal;
    Caption = 'Admission Schedule Entry';
    OrderBy = ascending(AdmissionStartDate, AdmissionStartTime);

    elements
    {
        dataitem(TMAdmissionScheduleEntry; "NPR TM Admis. Schedule Entry")
        {
            column(EntryNo; "Entry No.")
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
            column(Cancelled; Cancelled)
            {
            }
            column(AdmissionStartDate; "Admission Start Date")
            {
            }
            column(AdmissionStartTime; "Admission Start Time")
            {
            }
            column(EventDuration; "Event Duration")
            {
            }
            column(AdmissionIs; "Admission Is")
            {
            }
            column(ReasonCode; "Reason Code")
            {
            }
            column(AdmissionEndDate; "Admission End Date")
            {
            }
            column(AdmissionEndTime; "Admission End Time")
            {
            }
            column(MaxCapacityPerSchEntry; "Max Capacity Per Sch. Entry")
            {
            }
            column(RegenerateWith; "Regenerate With")
            {
            }
            column(VisibilityOnWeb; "Visibility On Web")
            {
            }
            column(DynamicPriceProfileCode; "Dynamic Price Profile Code")
            {
            }
            column(OpenReservations; "Open Reservations")
            {
            }
            column(OpenAdmitted; "Open Admitted")
            {
            }
            column(Departed; Departed)
            {
            }
            column(InitialEntry; "Initial Entry")
            {
            }
            column(InitialEntryAll; "Initial Entry (All)")
            {
            }
            column(OpenReservationsAll; "Open Reservations (All)")
            {
            }
            column(EventArrivalFromTime; "Event Arrival From Time")
            {
            }
            column(EventArrivalUntilTime; "Event Arrival Until Time")
            {
            }
            column(SalesFromDate; "Sales From Date")
            {
            }
            column(SalesFromTime; "Sales From Time")
            {
            }
            column(SalesUntilDate; "Sales Until Date")
            {
            }
            column(SalesUntilTime; "Sales Until Time")
            {
            }
            column(AllocationBy; "Allocation By")
            {
            }
            column(WaitingListQueue; "Waiting List Queue")
            {
            }
        }
    }
}