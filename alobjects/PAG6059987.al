page 6059987 "Discount Activities"
{
    Caption = 'Discount Activities';
    PageType = CardPart;
    SourceTable = "Discount Cue";

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
                    DrillDownPageID = "Mixed Discount List";
                }
                field("Period Discounts Active"; "Period Discounts Active")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Campaign Discount List";
                }

                actions
                {
                    action("New Mixed Discount")
                    {
                        Caption = 'New Mixed Discount';
                        RunObject = Page "Mixed Discount";
                        RunPageMode = Create;
                    }
                    action("New Period Discount")
                    {
                        Caption = 'New Perioddiscount';
                        RunObject = Page "Campaign Discount";
                        RunPageMode = Create;
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

