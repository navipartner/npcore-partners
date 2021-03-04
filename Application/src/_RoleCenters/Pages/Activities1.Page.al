page 6151252 "NPR Activities 1"
{

    Caption = 'Retail Activities';
    PageType = CardPart;
    SourceTable = "NPR Retail Sales Cue";
    UsageCategory = None;

    layout
    {

        area(content)
        {
            cuegroup(Cue)
            {
                ShowCaption = false;
                field("Sales Orders"; Rec."Sales Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Order List";
                    ToolTip = 'Specifies the value of the Sales Orders field';
                }
                field("Daily Sales Orders"; Rec."Daily Sales Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Order List";
                    ToolTip = 'Specifies the value of the Daily Sales Orders field';
                }
                field("Import Pending"; Rec."Import Pending")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Nc Import List";
                    ToolTip = 'Specifies the value of the Import Unprocessed field';
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.Reset;
        if not Rec.Get then begin
            Rec.Init;
            Rec.Insert;
        end;
        Rec.SetFilter("Date Filter", '=%1', WorkDate);
    end;
}





