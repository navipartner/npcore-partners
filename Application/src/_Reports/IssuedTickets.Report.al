report 6014413 "NPR Issued Tickets"
{
    // TM1.17/NPKNAV/20161026  CASE 252175 Transport TM1.17
    UsageCategory = None;
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Issued Tickets.rdlc';

    Caption = 'Issued Tickets';

    dataset
    {
        dataitem("TM Ticket"; "NPR TM Ticket")
        {
            column(No_TMTicketCaption; "TM Ticket".FieldCaption("No."))
            {
            }
            column(No_TMTicket; "TM Ticket"."No.")
            {
            }
            column(ExternalTicketNo_TMTicketCaption; "TM Ticket".FieldCaption("External Ticket No."))
            {
            }
            column(ExternalTicketNo_TMTicket; "TM Ticket"."External Ticket No.")
            {
            }
            column(TicketTypeCode_TMTicketCaption; "TM Ticket".FieldCaption("Ticket Type Code"))
            {
            }
            column(TicketTypeCode_TMTicket; "TM Ticket"."Ticket Type Code")
            {
            }
            column(ValidFromDate_TMTicketCaption; "TM Ticket".FieldCaption("Valid From Date"))
            {
            }
            column(ValidFromDate_TMTicket; Format("TM Ticket"."Valid From Date", 0, '<Closing><Month,2>-<Day,2>-<Year>'))
            {
            }
            column(ValidToDate_TMTicketCaption; "TM Ticket".FieldCaption("Valid To Date"))
            {
            }
            column(ValidToDate_TMTicket; Format("TM Ticket"."Valid To Date", 0, '<Closing><Month,2>-<Day,2>-<Year>'))
            {
            }
        }
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
            column(CompanyName; CompanyName)
            {
            }
            column(GetFilters_TMTicket; "TM Ticket".GetFilters)
            {
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
        PageLbl = 'Page';
        ReportCaptionLbl = 'Issued Tickets';
    }
}

