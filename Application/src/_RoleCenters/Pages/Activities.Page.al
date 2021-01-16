page 6151255 "NPR Activities"

{
    Caption = 'Retail Activities';
    PageType = CardPart;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Daily Sales Orders field';
                }

                field("Sales Orders"; "Sales Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Order List";
                    ToolTip = 'Specifies the value of the Sales Orders field';
                }
                field("Sales Return Orders"; "Sales Return Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Return Order List";
                    ToolTip = 'Specifies the value of the Sales Return Orders field';
                }

                field("Shipped Sales Orders"; "Shipped Sales Orders")
                {
                    ApplicationArea = All;
                    Caption = 'Shipped Sales Orders';
                    ShowCaption = true;
                    DrillDownPageId = "Sales Order List";
                    ToolTip = 'Specifies the value of the Shipped Sales Orders field';

                }

                field("Import Pending"; "Import Pending")
                {
                    ApplicationArea = All;
                    Caption = 'Import Unprocessed';
                    DrillDownPageID = "NPR Nc Import List";
                    ToolTip = 'Specifies the value of the Import Unprocessed field';

                }
                field("Task List"; "Task List")
                {
                    ApplicationArea = All;
                    Caption = 'Task List';
                    DrillDownPageId = "NPR Nc Task List";
                    ToolTip = 'Specifies the value of the Task List field';
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

