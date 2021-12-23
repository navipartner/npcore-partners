report 6014618 "NPR Skip Sales Shipment Print"
{
    Caption = 'Skip Sales Shipment Print';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
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

