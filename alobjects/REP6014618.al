report 6014618 "Skip Sales Shipment Print"
{
    // NPR5.43/TS  /20180625 CASE 318572  Object created.Empty report for not receiving Sales Shipment prints

    Caption = 'Skip Sales Shipment Print';
    ProcessingOnly = true;
    ShowPrintStatus = false;
    UseRequestPage = false;

    dataset
    {
        dataitem("Sales Shipment Header";"Sales Shipment Header")
        {
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
    }

    trigger OnInitReport()
    begin
        CurrReport.Quit;
    end;
}

