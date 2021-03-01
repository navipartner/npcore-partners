page 6059987 "NPR Discount Activities"
{
    Caption = 'Discount Activities';
    PageType = CardPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Discount Cue";

    layout
    {
        area(content)
        {
            cuegroup(Control6150614)
            {
                ShowCaption = false;
                field("Mixed Discounts Active"; Rec."Mixed Discounts Active")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Mixed Discount List";
                    ToolTip = 'Specifies the value of the Mixed Discounts Active field';
                }
                field("Period Discounts Active"; Rec."Period Discounts Active")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Campaign Discount List";
                    ToolTip = 'Specifies the value of the Period Discounts Active field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        Rec.SetFilter("Start Date Filter", '<=%1', Today);
        Rec.SetFilter("End Date Filter", '>=%1', Today);
    end;
}

