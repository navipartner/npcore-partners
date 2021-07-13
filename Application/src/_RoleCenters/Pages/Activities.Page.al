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
                Caption = 'miscellaneous';
                ShowCaption = false;
                field("Import Pending"; Rec."Import Pending")
                {

                    Caption = 'Import Unprocessed';
                    DrillDownPageID = "NPR Nc Import List";
                    ToolTip = 'Specifies the value of the Import Unprocessed field';
                    ApplicationArea = NPRRetail;

                }
                field("Task List"; Rec."Task List")
                {

                    Caption = 'Task List';
                    DrillDownPageId = "NPR Nc Task List";
                    ToolTip = 'Specifies the value of the Task List field';
                    ApplicationArea = NPRRetail;
                }
            }
            cuegroup(Control6150624)
            {
                Caption = 'SALES';
                ShowCaption = true;
                field("Daily Sales Orders"; Rec."Daily Sales Orders")
                {

                    DrillDownPageID = "Sales Order List";
                    ToolTip = 'Specifies the value of the Daily Sales Orders field';
                    ApplicationArea = NPRRetail;
                }

                field("Sales Orders"; Rec."Sales Orders")
                {

                    DrillDownPageID = "Sales Order List";
                    ToolTip = 'Specifies the value of the Sales Orders field';
                    ApplicationArea = NPRRetail;
                }
                field("Shipped Sales Orders"; Rec."Shipped Sales Orders")
                {

                    Caption = 'Shipped Sales Orders';
                    ShowCaption = true;
                    DrillDownPageId = "Sales Order List";
                    ToolTip = 'Specifies the value of the Shipped Sales Orders field';
                    ApplicationArea = NPRRetail;

                }
                field("Sales Return Orders"; Rec."Sales Return Orders")
                {
                    ApplicationArea = NPRRetail;
                    DrillDownPageID = "Sales Return Order List";
                    ToolTip = 'Specifies the value of the Sales Return Orders field';
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

