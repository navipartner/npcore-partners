report 6014413 "NPR Issued Tickets"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Issued Tickets.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Issued Tickets';
    DataAccessIntent = ReadOnly;
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

    labels
    {
        PageLbl = 'Page';
        ReportCaptionLbl = 'Issued Tickets';
    }
}

