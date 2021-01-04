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
                        ToolTip = 'Specifies the value of the Item No. field';
                    }
                    field("Discount Type"; "Discount Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Discount Type field';
                    }
                    group(Control6014411)
                    {
                        ShowCaption = false;
                        Visible = ("Discount Type" = 0);
                        field("Discount Amount"; "Discount Amount")
                        {
                            ApplicationArea = All;
                            ShowMandatory = true;
                            ToolTip = 'Specifies the value of the Discount Amount field';
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
                            ToolTip = 'Specifies the value of the Discount % field';
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
                        ToolTip = 'Specifies the value of the Item Description field';
                    }
                    field("Unit Price"; "Unit Price")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Unit Price field';
                    }
                    field("Profit %"; "Profit %")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Profit % field';
                    }
                }
            }
        }
    }
}

