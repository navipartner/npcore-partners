page 6151253 "NPR Activities 2"
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
            cuegroup("")
            {

                ShowCaption = false;

                field("Pending Inc. Documents"; "Pending Inc. Documents")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pending Inc. Documents field';
                }
                field("Processed Error Tasks"; "Processed Error Tasks")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Nc Task List";
                    ToolTip = 'Specifies the value of the Processed Error Tasks field';
                }
                field("Failed Webshop Payments"; "Failed Webshop Payments")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Magento Payment Line List";
                    ToolTip = 'Specifies the value of the Failed Webshop Payments field';
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

