page 6151255 "NPR Activities"

{
    Caption = 'Retail Activities';
    PageType = CardPart;
    SourceTable = "NPR Retail Sales Cue";
    UsageCategory = None;
    layout
    {

        area(content)
        {
            cuegroup(Control6150623)
            {
                Caption = 'SALES';
                ShowCaption = true;
                field("Import Pending"; Rec."Import Pending")
                {
                    ApplicationArea = All;
                    Caption = 'Import Unprocessed';
                    DrillDownPageID = "NPR Nc Import List";
                    ToolTip = 'Specifies the value of the Import Unprocessed field';

                }
                field("Task List"; Rec."Task List")
                {
                    ApplicationArea = All;
                    Caption = 'Task List';
                    DrillDownPageId = "NPR Nc Task List";
                    ToolTip = 'Specifies the value of the Task List field';
                }
                field("Daily Sales Orders"; Rec."Daily Sales Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Order List";
                    ToolTip = 'Specifies the value of the Daily Sales Orders field';
                }

                field("Sales Orders"; Rec."Sales Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Order List";
                    ToolTip = 'Specifies the value of the Sales Orders field';
                }
                field("Sales Return Orders"; Rec."Sales Return Orders")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Sales Return Order List";
                    ToolTip = 'Specifies the value of the Sales Return Orders field';
                }

                field("Shipped Sales Orders"; Rec."Shipped Sales Orders")
                {
                    ApplicationArea = All;
                    Caption = 'Shipped Sales Orders';
                    ShowCaption = true;
                    DrillDownPageId = "Sales Order List";
                    ToolTip = 'Specifies the value of the Shipped Sales Orders field';

                }
            }
        }
    }



    trigger OnOpenPage()
    begin
        Rec.Reset;
        if not Get then begin
            Rec.Init;
            Rec.Insert;
        end;
        Rec.SetFilter("Date Filter", '=%1', WorkDate);
    end;

}

