page 6059987 "NPR Discount Activities"
{
    Caption = 'Discount Activities';
    PageType = CardPart;
    SourceTable = "NPR Discount Cue";

    layout
    {
        area(content)
        {
            cuegroup(Control6150614)
            {
                ShowCaption = false;
                field("Mixed Discounts Active"; "Mixed Discounts Active")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Mixed Discount List";
                }
                field("Period Discounts Active"; "Period Discounts Active")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Campaign Discount List";
                }

                actions
                {
                    action("New Mixed Discount")
                    {
                        Caption = 'New Mixed Discount';
                        RunObject = Page "NPR Mixed Discount";
                        RunPageMode = Create;
                        ApplicationArea=All;
                    }
                    action("New Period Discount")
                    {
                        Caption = 'New Perioddiscount';
                        RunObject = Page "NPR Campaign Discount";
                        RunPageMode = Create;
                        ApplicationArea=All;
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;

        SetFilter("Start Date Filter", '<=%1', Today);
        SetFilter("End Date Filter", '>=%1', Today);
    end;
}

