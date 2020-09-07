page 6151252 "NPR Activities 1"
{

    Caption = 'Retail Activities';
    PageType = CardPart;
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
                }
                field("Daily Sales Orders"; "Daily Sales Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Order List";
                }
                field("Import Pending"; "Import Pending")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Nc Import List";
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
                ApplicationArea=All;
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





