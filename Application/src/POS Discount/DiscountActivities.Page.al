page 6059987 "NPR Discount Activities"
{
    Caption = 'Discount Activities';
    PageType = CardPart;
    UsageCategory = Administration;

    SourceTable = "NPR Discount Cue";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            cuegroup(Control6150614)
            {
                ShowCaption = false;
                field("Mixed Discounts Active"; Rec."Mixed Discounts Active")
                {

                    DrillDownPageID = "NPR Mixed Discount List";
                    ToolTip = 'Specifies the value of the Mixed Discounts Active field';
                    ApplicationArea = NPRRetail;
                }
                field("Period Discounts Active"; Rec."Period Discounts Active")
                {

                    DrillDownPageID = "NPR Campaign Discount List";
                    ToolTip = 'Specifies the value of the Period Discounts Active field';
                    ApplicationArea = NPRRetail;
                }
            }
            cuegroup(Control6014404)
            {
                Caption = 'Actions';
                actions
                {
                    action("New Mixed Discount")
                    {
                        Caption = 'New Mixed Discount';
                        RunObject = Page "NPR Mixed Discount";
                        RunPageMode = Create;

                        Image = TileNew;
                        ToolTip = 'Executes the New Mixed Discount action';
                        ApplicationArea = NPRRetail;
                    }
                    action("New Period Discount")
                    {
                        Caption = 'New Perioddiscount';
                        RunObject = Page "NPR Campaign Discount";
                        RunPageMode = Create;

                        Image = TileBrickNew;
                        ToolTip = 'Executes the New Perioddiscount action';
                        ApplicationArea = NPRRetail;
                    }
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

        Rec.SetFilter("Start Date Filter", '<=%1', Today);
        Rec.SetFilter("End Date Filter", '>=%1', Today);
    end;
}

