page 6151253 "NPR Activities 2"
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
                Caption = 'Activities';
                ShowCaption = false;

                field("Pending Inc. Documents"; Rec."Pending Inc. Documents")
                {

                    ToolTip = 'Specifies the list of Incoming Documents.';
                    ApplicationArea = NPRRetail;
                }
                field("Processed Error Tasks"; Rec."Processed Error Tasks")
                {

                    DrillDownPageID = "NPR Nc Task List";
                    ToolTip = 'Specifies the list of Processed Error Tasks.';
                    ApplicationArea = NPRRetail;
                }
                field("Failed Webshop Payments"; Rec."Failed Webshop Payments")
                {

                    DrillDownPageID = "NPR Magento Payment Line List";
                    ToolTip = 'Specifies the list of Failed Webshop Payments.';
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

