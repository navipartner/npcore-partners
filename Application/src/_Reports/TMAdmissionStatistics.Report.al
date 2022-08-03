report 6014433 "NPR TM Admission Statistics"
{
#IF NOT BC17
    Extensible = False; 
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/TM Admission Statistics.rdlc';
    Caption = 'TM Admission Statistics';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("TM Admission Schedule Entry"; "NPR TM Admis. Schedule Entry")
        {
            DataItemTableView = SORTING("Admission Start Date", "Admission Start Time");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "Admission Code", "Admission Start Date";
            column(AdmissionCode_TMAdmissionScheduleEntry; "TM Admission Schedule Entry"."Admission Code")
            {
                IncludeCaption = true;
            }
            column(AdmissionStartDate_TMAdmissionScheduleEntry; Format("TM Admission Schedule Entry"."Admission Start Date", 0, 1))
            {
            }
            column(AdmissionStartTime_TMAdmissionScheduleEntry; Format("TM Admission Schedule Entry"."Admission Start Time", 0, 1))
            {
            }
            column(OpenReservations_TMAdmissionScheduleEntry; "TM Admission Schedule Entry"."Open Reservations")
            {
                IncludeCaption = true;
            }
            column(OpenAdmitted_TMAdmissionScheduleEntry; "TM Admission Schedule Entry"."Open Admitted")
            {
                IncludeCaption = true;
            }
            column(TotalLbl_OpenAdmitted_TMAdmissionScheduleEntry; TotalLbl)
            {
            }
            column(TotalOpenReservations_TMAdmisSchedEntry; TotalOpenReservations)
            {
            }
            column(TotalOpenAdmitted_TMAdmisSchedEntry; TotalOpenAdmitted)
            {
            }
            column(ReportFilters; GetFilters)
            {
            }
            column(TheCompanyName; CompanyName)
            {
            }
            dataitem("TM Det. Ticket Access Entry"; "NPR TM Det. Ticket AccessEntry")
            {
                DataItemLink = "External Adm. Sch. Entry No." = FIELD("External Schedule Entry No.");
                DataItemTableView = SORTING("Entry No.") WHERE(Type = CONST(RESERVATION), Open = FILTER(true));
                PrintOnlyIfDetail = false;
                column(EntryNo_TMDetTicketAccessEntry; "TM Det. Ticket Access Entry"."Entry No.")
                {
                }
                column(Quantity_TMDetTicketAccessEntry; "TM Det. Ticket Access Entry".Quantity)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if not TempTMAdmisSchedEntry.Get("TM Admission Schedule Entry"."External Schedule Entry No.") then begin
                        TempTMAdmisSchedEntry.Init();
                        TempTMAdmisSchedEntry."Entry No." := "TM Admission Schedule Entry"."Entry No.";
                        TempTMAdmisSchedEntry."External Schedule Entry No." := "TM Admission Schedule Entry"."External Schedule Entry No.";
                        TotalOpenReservations += "TM Admission Schedule Entry"."Open Reservations";
                        TotalOpenAdmitted += "TM Admission Schedule Entry"."Open Admitted";
                        TempTMAdmisSchedEntry.Insert();
                    end;
                end;
            }
        }
    }
    requestpage
    {
        SaveValues = true;
    }

    labels
    {
        ReportName = 'Admission Statistics';
        AdmStartDate = 'Admission Start Date';
        AdmStartTime = 'Admission Start Time';
    }

    var
        TempTMAdmisSchedEntry: Record "NPR TM Admis. Schedule Entry" temporary;
        TotalOpenReservations: Integer;
        TotalOpenAdmitted: Integer;
        TotalLbl: Label 'Total';
}