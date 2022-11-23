report 6014413 "NPR Issued Tickets"
{
#if not BC17 
#if BC18 or BC19
    Extensible = false;
#else
    Extensible = true;
#endif
#endif
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Issued Tickets';
    DataAccessIntent = ReadOnly;
#if BC17 or BC18 or BC19
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Issued Tickets.rdlc';
#else
    DefaultRenderingLayout = "RDLC Layout";
#endif

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
        SaveValues = true;
    }

#if not (BC17 or BC18 or BC19)
    rendering
    {
        layout("RDLC Layout")
        {
            Caption = 'RDLC layout';
            LayoutFile = './src/_Reports/layouts/Issued Tickets.rdlc';
            Type = RDLC;
        }
        layout("Excel Layout")
        {
            Caption = 'Excel layout';
            LayoutFile = './src/_Reports/layouts/Issued Tickets.xlsx';
            Type = Excel;
        }
    }
#endif

    labels
    {
        PageLbl = 'Page';
        ReportCaptionLbl = 'Issued Tickets';
    }
}

