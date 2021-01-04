page 6059987 "NPR Discount Activities"
{
    Caption = 'Discount Activities';
    PageType = CardPart;
    UsageCategory = Administration;
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
                    ToolTip = 'Specifies the value of the Mixed Discounts Active field';
                }
                field("Period Discounts Active"; "Period Discounts Active")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Campaign Discount List";
                    ToolTip = 'Specifies the value of the Period Discounts Active field';
                }

                actions
                {
                    action("New Mixed Discount")
                    {
                        Caption = 'New Mixed Discount';
                        RunObject = Page "NPR Mixed Discount";
                        RunPageMode = Create;
                        ApplicationArea = All;
                        ToolTip = 'Executes the New Mixed Discount action';
                    }
                    action("New Period Discount")
                    {
                        Caption = 'New Perioddiscount';
                        RunObject = Page "NPR Campaign Discount";
                        RunPageMode = Create;
                        ApplicationArea = All;
                        ToolTip = 'Executes the New Perioddiscount action';
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

