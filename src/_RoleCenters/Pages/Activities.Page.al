page 6151255 "NPR Activities"

{
    Caption = 'Retail Activities';
    PageType = CardPart;
    UsageCategory = Administration;
    SourceTable = "NPR Retail Sales Cue";

    layout
    {

        area(content)
        {
            cuegroup(Control6150623)
            {
                Caption = 'SALES';
                ShowCaption = true;
                field("Daily Sales Orders"; "Daily Sales Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Order List";
                }

                field("Sales Orders"; "Sales Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Order List";
                }
                field("Sales Return Orders"; "Sales Return Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Return Order List";
                }

                field("Shipped Sales Orders"; "Shipped Sales Orders")
                {
                    ApplicationArea = All;
                    Caption = 'Shipped Sales Orders';
                    ShowCaption = true;
                    DrillDownPageId = "Sales Order List";

                }

                field("Import Pending"; "Import Pending")
                {
                    ApplicationArea = All;
                    Caption = 'Import Unprocessed';
                    DrillDownPageID = "NPR Nc Import List";

                }
                field("Task List"; "Task List")
                {
                    ApplicationArea = All;
                    Caption = 'Task List';
                    DrillDownPageId = "NPR Nc Task List";
                }


            }



        }
    }



    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;
        SetFilter("Date Filter", '=%1', WorkDate);
    end;

    var
        PING: Label '''';
        NPRetailSetup: Record "NPR NP Retail Setup";


}

