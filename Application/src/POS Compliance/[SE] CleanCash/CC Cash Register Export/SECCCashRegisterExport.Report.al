report 6014531 "NPR SE CC Cash Register Export"
{
    ApplicationArea = NPRSECleanCash;
    Caption = 'CleanCash Cash Register Export';
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
            area(Content)
            {
                group(Dates)
                {
                    Caption = 'Export Dates';
                    field(StartDateFilter; StartDate)
                    {
                        ApplicationArea = NPRSECleanCash;
                        Caption = 'Start Date';
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Start Date field.';
                    }
                    field(EndDateFilter; EndDate)
                    {
                        ApplicationArea = NPRSECleanCash;
                        Caption = 'End Date';
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the End Date field.';
                    }
                }
                group(POSUnitFilters)
                {
                    Caption = 'POS Unit';
                    field(POSUnitNoFilter; POSUnitNo)
                    {
                        ApplicationArea = NPRSECleanCash;
                        Caption = 'POS Unit No.';
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
        SECashRegExportMgt: Codeunit "NPR SE CC Cash Reg. Exp. Mgt.";
    begin
        SECashRegExportMgt.ExportCashRegisterJournalFile(StartDate, EndDate, POSUnitNo);
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