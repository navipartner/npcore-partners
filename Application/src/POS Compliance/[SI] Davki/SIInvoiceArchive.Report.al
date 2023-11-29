report 6014500 "NPR SI Invoice Archive"
{
#if not BC17
    Extensible = false;
#endif
    Caption = 'SI Archive Invoices';
    ApplicationArea = NPRSIFiscal;
    UsageCategory = Administration;
    ProcessingOnly = true;

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Dates)
                {
                    Caption = 'Invoice Dates';
                    field(StartDateFilter; StartDate)
                    {
                        ApplicationArea = NPRSIFiscal;
                        Caption = 'Start Date';
                        ToolTip = 'Specifies the value of the Start Date field.';
                    }
                    field(EndDateFilter; EndDate)
                    {
                        ApplicationArea = NPRSIFiscal;
                        Caption = 'End Date';
                        ToolTip = 'Specifies the value of the End Date field.';
                    }
                }
            }
        }
    }

    trigger OnPostReport()
    var
        SIArchiveMgt: Codeunit "NPR SI Archive Mgt.";
    begin
        SIArchiveMgt.GenerateInvoiceArchive(StartDate, EndDate);
    end;

    var
        EndDate: Date;
        StartDate: Date;
}