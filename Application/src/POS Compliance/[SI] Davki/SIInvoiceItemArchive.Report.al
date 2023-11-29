report 6014501 "NPR SI Invoice Item Archive"
{
    Caption = 'SI Archive Item Invoices';
    ApplicationArea = NPRSIFiscal;
    UsageCategory = Administration;
    ProcessingOnly = true;
#if not BC17
    Extensible = false;
#endif

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Dates)
                {
                    Caption = 'Invoice Dates';
                    field(StartDateFilter; StartDate)
                    {
                        Caption = 'Start Date';
                        ApplicationArea = NPRSIFiscal;
                        ToolTip = 'Specifies the value of the Start Date field.';
                    }
                    field(EndDateFilter; EndDate)
                    {
                        Caption = 'End Date';
                        ApplicationArea = NPRSIFiscal;
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
        SIArchiveMgt.GenerateInvoiceItemArchive(StartDate, EndDate);
    end;

    var
        StartDate: Date;
        EndDate: Date;
}