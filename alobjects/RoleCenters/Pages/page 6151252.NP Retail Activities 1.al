page 6151252 "NP Retail Activities 1"
{

    Caption = 'Retail Activities';
    PageType = CardPart;
    SourceTable = "Retail Sales Cue";


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
                    DrillDownPageID = "Sales Order List";
                }
                field("Daily Sales Orders"; "Daily Sales Orders")
                {
                    DrillDownPageID = "Sales Order List";
                }
                field("Import Pending"; "Import Pending")
                {
                    DrillDownPageID = "Nc Import List";
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





