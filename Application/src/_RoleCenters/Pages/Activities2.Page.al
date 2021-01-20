page 6151253 "NPR Activities 2"
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

                field("Pending Inc. Documents"; Rec."Pending Inc. Documents")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pending Inc. Documents field';
                }
                field("Processed Error Tasks"; Rec."Processed Error Tasks")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Nc Task List";
                    ToolTip = 'Specifies the value of the Processed Error Tasks field';
                }
                field("Failed Webshop Payments"; Rec."Failed Webshop Payments")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Magento Payment Line List";
                    ToolTip = 'Specifies the value of the Failed Webshop Payments field';
                }

            }
        }
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Rec.Get then begin
            Rec.Init;
            Rec.Insert;
        end;
        Rec.SetFilter("Date Filter", '=%1', WorkDate);
    end;

    var
        PING: Label '''';
        NPRetailSetup: Record "NPR NP Retail Setup";


}

