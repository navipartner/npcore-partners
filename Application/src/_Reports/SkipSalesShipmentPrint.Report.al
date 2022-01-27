report 6014618 "NPR Skip Sales Shipment Print"
{
    #IF NOT BC17 
    Extensible = False; 
    #ENDIF
    Caption = 'Skip Sales Shipment Print';
    ProcessingOnly = true;
    UsageCategory = None;
    ShowPrintStatus = false;
    UseRequestPage = false;

    dataset
    {
        dataitem("Sales Shipment Header"; "Sales Shipment Header")
        {
        }
    }
    requestpage
    {
        SaveValues = true;
    }

    trigger OnInitReport()
    begin
        CurrReport.Quit();
    end;
}

