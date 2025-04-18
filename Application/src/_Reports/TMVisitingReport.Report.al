﻿report 6060125 "NPR TM Visiting Report"
{
#IF NOT BC17
    Extensible = False; 
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/TM Visiting Report.rdlc';
    Caption = 'TM Visiting Report';
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
                        IncludeCaption = true;
                    }
                    column(ItemNo_TMTicket; "TM Ticket"."Item No.")
                    {
                        IncludeCaption = true;
                    }
                    column(VariantCode_TMTicket; "TM Ticket"."Variant Code")
                    {
                        IncludeCaption = true;
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
                                if Membership.FindFirst() then
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
        SaveValues = true;
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

