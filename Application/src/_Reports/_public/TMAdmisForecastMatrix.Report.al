report 6014447 "NPR TM Admis. Forecast Matrix"
{
#if (BC17 or BC18 or BC19)
    UsageCategory = None;
#else
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    Caption = 'Admission Forecast Matrix Excel';
    UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = "Excel Layout";
    Extensible = true;

    dataset
    {
        dataitem(AdmisScheduleEntry; "NPR TM Admis. Schedule Entry")
        {
            DataItemTableView = WHERE(Cancelled = const(false));
            column(AdmissionCode; "Admission Code")
            {
            }
            column(AdmissionEndDate; "Admission End Date")
            {
            }
            column(AdmissionEndTime; "Admission End Time")
            {
            }
            column(AdmissionIs; "Admission Is")
            {
            }
            column(AdmissionStartDate; "Admission Start Date")
            {
            }
            column(AdmissionStartTime; "Admission Start Time")
            {
            }
            column(AllocationBy; "Allocation By")
            {
            }
            column(Cancelled; Cancelled)
            {
            }
            column(Departed; Departed)
            {
            }
            column(DynamicPriceProfileCode; "Dynamic Price Profile Code")
            {
            }
            column(EntryNo; "Entry No.")
            {
            }
            column(EventArrivalFromTime; "Event Arrival From Time")
            {
            }
            column(EventArrivalUntilTime; "Event Arrival Until Time")
            {
            }
            column(EventDuration; "Event Duration")
            {
            }
            column(ExternalScheduleEntryNo; "External Schedule Entry No.")
            {
            }
            column(InitialEntry; "Initial Entry")
            {
            }
            column(InitialEntryAll; "Initial Entry (All)")
            {
            }
            column(MaxCapacityPerSchEntry; "Max Capacity Per Sch. Entry")
            {
            }
            column(OpenAdmitted; "Open Admitted")
            {
            }
            column(OpenReservations; "Open Reservations")
            {
            }
            column(OpenReservationsAll; "Open Reservations (All)")
            {
            }
            column(ReasonCode; "Reason Code")
            {
            }
            column(RegenerateWith; "Regenerate With")
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
            column(ScheduleCode; "Schedule Code")
            {
            }
            column(VisibilityOnWeb; "Visibility On Web")
            {
            }
            column(WaitingListQueue; "Waiting List Queue")
            {
            }
            dataitem(AdmissionSchedule; "NPR TM Admis. Schedule")
            {
                DataItemLink = "Schedule Code" = field("Schedule Code");
                DataItemLinkReference = AdmisScheduleEntry;
                DataItemTableView = sorting("Schedule Code");
                column(Description; Description)
                {
                }
            }
            trigger OnAfterGetRecord()
            begin
                if "Admission Code" = '' then
                    CurrReport.Skip();
            end;
        }
    }
    rendering
    {
        layout("Excel Layout")
        {
            Caption = 'Excel layout to display and work with data from table NPR TM Admis. Schedule Entry.';
            LayoutFile = './src/_Reports/layouts/TM Admission Forecast Matrix.xlsx';
            Type = Excel;
        }
    }
#endif
}