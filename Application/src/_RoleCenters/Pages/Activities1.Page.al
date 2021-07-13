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

                    DrillDownPageID = "Sales Order List";
                    ToolTip = 'Specifies the value of the Sales Orders field';
                    ApplicationArea = NPRRetail;
                }
                field("Daily Sales Orders"; Rec."Daily Sales Orders")
                {

                    DrillDownPageID = "Sales Order List";
                    ToolTip = 'Specifies the value of the Daily Sales Orders field';
                    ApplicationArea = NPRRetail;
                }
                field("Import Pending"; Rec."Import Pending")
                {

                    DrillDownPageID = "NPR Nc Import List";
                    ToolTip = 'Specifies the value of the Import Unprocessed field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        Rec.SetFilter("Date Filter", '=%1', WorkDate());
    end;
}





