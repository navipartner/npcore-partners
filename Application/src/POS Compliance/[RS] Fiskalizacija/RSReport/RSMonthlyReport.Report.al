report 6014539 "NPR RS Monthly Report"
{
    Caption = 'RS Monthly Report';
    ProcessingOnly = true;
    UsageCategory = Administration;
    ApplicationArea = NPRRSFiscal;
#if not BC17
    Extensible = false;
#endif
    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Dates)
                {
                    Caption = 'Export Dates';
                    field(StartDateFilter; StartDate)
                    {
                        Caption = 'Start Date';
                        ApplicationArea = NPRRSFiscal;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Start Date field.';
                    }
                    field(EndDateFilter; EndDate)
                    {
                        Caption = 'End Date';
                        ApplicationArea = NPRRSFiscal;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the End Date field.';
                    }
                }
                group(POSUnitFilters)
                {
                    Caption = 'POS Unit';
                    field(POSUnitNoFilter; POSUnitNo)
                    {
                        Caption = 'POS Unit No.';
                        ApplicationArea = NPRRSFiscal;
                        ShowMandatory = true;
                        TableRelation = "NPR POS Unit";
                        ToolTip = 'Specifies the value of the POS Unit No. field.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            SetDefaultFiltersOnRequestPage();
        end;
    }
    trigger OnPostReport()
    var
        MonthlyReport: Codeunit "NPR RS Monthly Fiscal Print";
    begin
        MonthlyReport.PrintMonthlyStatistics(StartDate, EndDate, POSUnitNo);
    end;

    local procedure SetDefaultFiltersOnRequestPage()
    var
        POSUnit: Record "NPR POS Unit";
    begin
        StartDate := WorkDate();
        EndDate := WorkDate();

        if not POSUnit.FindFirst() then
            exit;
        POSUnitNo := POSUnit."No.";
    end;

    var
        StartDate: Date;
        EndDate: Date;
        POSUnitNo: Code[20];

}