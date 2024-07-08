page 6151252 "NPR Activities 1"
{
    Extensible = False;

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
                    ToolTip = 'Specifies the number of the sales orders that have been registered';

                    ApplicationArea = NPRRetail;
                }
                field("Daily Sales Orders"; Rec."Daily Sales Orders")
                {

                    DrillDownPageID = "Sales Order List";
                    ToolTip = 'Specifies the number of the daily sales orders that have been registered on todays date';

                    ApplicationArea = NPRRetail;
                }
                field("Import Pending"; Rec."Import Pending")
                {

                    DrillDownPageID = "NPR Nc Import List";
                    ToolTip = 'Specifies the number of import unprocessed entries';

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
        Rec.SetActionableImportEntryTypeFilter();
    end;
}





