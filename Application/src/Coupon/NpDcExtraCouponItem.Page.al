page 6151596 "NPR NpDc Extra Coupon Item"
{
    AutoSplitKey = true;
    Caption = 'Extra Coupon Item';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR NpDc Extra Coupon Item";

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014405)
                {
                    ShowCaption = false;
                    field("Item No."; "Item No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Discount Type"; "Discount Type")
                    {
                        ApplicationArea = All;
                    }
                    group(Control6014411)
                    {
                        ShowCaption = false;
                        Visible = ("Discount Type" = 0);
                        field("Discount Amount"; "Discount Amount")
                        {
                            ApplicationArea = All;
                            ShowMandatory = true;
                        }
                    }
                    group(Control6014409)
                    {
                        ShowCaption = false;
                        Visible = ("Discount Type" = 1);
                        field("Discount %"; "Discount %")
                        {
                            ApplicationArea = All;
                            ShowMandatory = true;
                        }
                        field("Max. Discount Amount"; "Max. Discount Amount")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Max. Discount Amount per Sale';
                        }
                    }
                }
                group(Control6014406)
                {
                    ShowCaption = false;
                    field("Item Description"; "Item Description")
                    {
                        ApplicationArea = All;
                    }
                    field("Unit Price"; "Unit Price")
                    {
                        ApplicationArea = All;
                    }
                    field("Profit %"; "Profit %")
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
    }
}

