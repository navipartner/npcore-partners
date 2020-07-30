page 6151255 "NP Retail Activities"

{
    Caption = 'Retail Activities';
    PageType = CardPart;
    SourceTable = "Retail Sales Cue";

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
                    DrillDownPageID = "Sales Order List";
                }

                field("Sales Orders"; "Sales Orders")
                {
                    DrillDownPageID = "Sales Order List";
                }
                field("Sales Return Orders"; "Sales Return Orders")
                {
                    DrillDownPageID = "Sales Return Order List";
                }

                field("Shipped Sales Orders"; "Shipped Sales Orders")
                {
                    Caption = 'Shipped Sales Orders';
                    ShowCaption = true;
                    DrillDownPageId = "Sales Order List";

                }

                field("Import Pending"; "Import Pending")
                {
                    Caption = 'Import Unprocessed';
                    DrillDownPageID = "Nc Import List";

                }
                field("Task List"; "Task List")
                {
                    Caption = 'Task List';
                    DrillDownPageId = "Nc Task List";
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
        NPRetailSetup: Record "NP Retail Setup";


}

