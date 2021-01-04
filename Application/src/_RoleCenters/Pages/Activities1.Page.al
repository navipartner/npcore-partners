page 6151252 "NPR Activities 1"
{

    Caption = 'Retail Activities';
    PageType = CardPart;
    UsageCategory = Administration;
    SourceTable = "NPR Retail Sales Cue";


    layout
    {

        area(content)
        {
            cuegroup("")
            {
                //CueGroupLayout = Columns;
                ShowCaption = false;
                field("Sales Orders"; "Sales Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Order List";
                    ToolTip = 'Specifies the value of the Sales Orders field';
                }
                field("Daily Sales Orders"; "Daily Sales Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Order List";
                    ToolTip = 'Specifies the value of the Daily Sales Orders field';
                }
                field("Import Pending"; "Import Pending")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Nc Import List";
                    ToolTip = 'Specifies the value of the Import Unprocessed field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Action Items")
            {
                Caption = 'Action Items';
                ApplicationArea = All;
                ToolTip = 'Executes the Action Items action';
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





