report 6060125 "NPR TM Visiting Report"
{
    // TM1.19/KENU/2010202 CASE 264689 Object Created
    // TM1.37/ZESO/20180925 CASE 329455 Added Columns Post Code and City.
    // #334163/JDH /20181109 CASE 334163 Added Caption to object
    // TM1.39/NPKNAV/20190125  CASE 343941 Transport TM1.39 - 25 January 2019
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/TM Visiting Report.rdlc';

    Caption = 'TM Visiting Report';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

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
                dataitem("TM Ticket"; "NPR TM Ticket")
                {
                    DataItemLink = "No." = FIELD("Ticket No.");
                    DataItemTableView = SORTING("No.");
                    PrintOnlyIfDetail = false;
                    column(TicketReservationEntryNo_TMTicket; "TM Ticket"."Ticket Reservation Entry No.")
                    {
                    }
                    dataitem("TM Ticket Reservation Request"; "NPR TM Ticket Reservation Req.")
                    {
                        DataItemLink = "Entry No." = FIELD("Ticket Reservation Entry No.");
                        DataItemTableView = SORTING("Entry No.");
                        PrintOnlyIfDetail = false;
                        column(ExternalOrderNo_TMTicketReservationRequest; "TM Ticket Reservation Request"."External Order No.")
                        {
                        }
                        dataitem("Sales Invoice Header"; "Sales Invoice Header")
                        {
                            DataItemLink = "External Document No." = FIELD("External Order No.");
                            DataItemTableView = SORTING("Sell-to Customer No.", "Order Date") ORDER(Ascending);
                            PrintOnlyIfDetail = false;
                            column(BilltoName_SalesInvoiceHeader; "Sales Invoice Header"."Bill-to Name")
                            {
                            }
                            column(SalesInvoiceHeader_SelltoCustomerName; "Sales Invoice Header"."Sell-to Customer Name")
                            {
                                IncludeCaption = true;
                            }
                            column(CompanyName; MembershipCompanyName)
                            {
                            }
                            column(BilltoCustomerNo_SalesInvoiceHeader; "Sales Invoice Header"."Bill-to Customer No.")
                            {
                                IncludeCaption = true;
                            }
                            column(SelltoAddress_SalesInvoiceHeader; "Sales Invoice Header"."Sell-to Address")
                            {
                                IncludeCaption = true;
                            }
                            column(PostCode_SalesInvoiceHeader; "Sales Invoice Header"."Sell-to Post Code")
                            {
                            }
                            column(City_SalesInvoiceHeader; "Sales Invoice Header"."Sell-to City")
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                Clear(MembershipCompanyName);
                                Membership.SetRange("Customer No.", "Bill-to Customer No.");
                                if Membership.FindFirst then
                                    MembershipCompanyName := Membership."Company Name"
                                else
                                    MembershipCompanyName := '';
                            end;
                        }
                    }
                }
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
        ReportName = 'Visting Report';
        AdmStartDate = 'Admission Start Date';
        AdmEndDate = 'Admission End Date';
        CustomerName = 'Name';
        CustomerAddress = 'Address';
        CustomerPostCode = 'Post Code';
        CustomerCity = 'City';
    }

    var
        Membership: Record "NPR MM Membership";
        MembershipCompanyName: Text;
}

