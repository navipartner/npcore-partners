page 6151253 "NP Retail Activities 2"
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

                ShowCaption = false;

                field("Pending Inc. Documents"; "Pending Inc. Documents")
                {
                    ApplicationArea = All;
                }
                field("Processed Error Tasks"; "Processed Error Tasks")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Nc Task List";
                }
                field("Failed Webshop Payments"; "Failed Webshop Payments")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Magento Payment Line List";
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

