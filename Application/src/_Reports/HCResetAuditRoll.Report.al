report 6150901 "NPR HC Reset Audit Roll"
{
    // NPR5.37/BR  /20171027 CASE 267552 HQ Connector Created Object

    UsageCategory = None;
    Caption = 'HC Reset Audit Roll';
    ProcessingOnly = true;

    dataset
    {
        dataitem("HC Audit Roll"; "NPR HC Audit Roll")
        {
            DataItemTableView = SORTING("Register No.", "Sales Ticket No.", "Sale Type", "Line No.", "No.", "Sale Date") ORDER(Ascending) WHERE("No." = FILTER(<> ''));
            RequestFilterFields = "Sale Date", "Register No.", "Sales Ticket No.";

            trigger OnAfterGetRecord()
            begin
                "HC Audit Roll".Posted := false;
                "HC Audit Roll"."Item Entry Posted" := false;
                "HC Audit Roll".Modify(true);
            end;
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
}

