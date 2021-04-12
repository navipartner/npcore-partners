page 6151596 "NPR NpDc Extra Coupon Item"
{
    AutoSplitKey = true;
    Caption = 'Extra Coupon Item';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    field("Item No."; Rec."Item No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Item No. field';
                    }
                    field("Discount Type"; Rec."Discount Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Discount Type field';
                    }
                    group(Control6014411)
                    {
                        ShowCaption = false;
                        Visible = (Rec."Discount Type" = 0);
                        field("Discount Amount"; Rec."Discount Amount")
                        {
                            ApplicationArea = All;
                            ShowMandatory = true;
                            ToolTip = 'Specifies the value of the Discount Amount field';
                        }
                    }
                    group(Control6014409)
                    {
                        ShowCaption = false;
                        Visible = (Rec."Discount Type" = 1);
                        field("Discount %"; Rec."Discount %")
                        {
                            ApplicationArea = All;
                            ShowMandatory = true;
                            ToolTip = 'Specifies the value of the Discount % field';
                        }
                        field("Max. Discount Amount"; Rec."Max. Discount Amount")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Max. Discount Amount per Sale';
                        }
                    }
                }
                group(Control6014406)
                {
                    ShowCaption = false;
                    field("Item Description"; Rec."Item Description")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Item Description field';
                    }
                    field("Unit Price"; Rec."Unit Price")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Unit Price field';
                    }
                    field("Profit %"; Rec."Profit %")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Profit % field';
                    }
                }
            }
        }
    }
}

