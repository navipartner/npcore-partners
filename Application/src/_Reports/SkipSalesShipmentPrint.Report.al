report 6014618 "NPR Skip Sales Shipment Print"
{
    Caption = 'Skip Sales Shipment Print';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ShowPrintStatus = false;
    UseRequestPage = false;

    dataset
    {
        dataitem("Sales Shipment Header"; "Sales Shipment Header")
        {
        }
    }

    trigger OnInitReport()
    begin
        CurrReport.Quit();
    end;
}

