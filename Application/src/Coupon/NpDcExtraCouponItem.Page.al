page 6151596 "NPR NpDc Extra Coupon Item"
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'Extra Coupon Item';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR NpDc Extra Coupon Item";
    ApplicationArea = NPRRetail;

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

                        ToolTip = 'Specifies the value of the Item No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Discount Type"; Rec."Discount Type")
                    {

                        ToolTip = 'Specifies the value of the Discount Type field';
                        ApplicationArea = NPRRetail;
                    }
                    group(Control6014411)
                    {
                        ShowCaption = false;
                        Visible = (Rec."Discount Type" = 0);
                        field("Discount Amount"; Rec."Discount Amount")
                        {

                            ShowMandatory = true;
                            ToolTip = 'Specifies the value of the Discount Amount field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    group(Control6014409)
                    {
                        ShowCaption = false;
                        Visible = (Rec."Discount Type" = 1);
                        field("Discount %"; Rec."Discount %")
                        {

                            ShowMandatory = true;
                            ToolTip = 'Specifies the value of the Discount % field';
                            ApplicationArea = NPRRetail;
                        }
                        field("Max. Discount Amount"; Rec."Max. Discount Amount")
                        {

                            ToolTip = 'Max. Discount Amount per Sale';
                            ApplicationArea = NPRRetail;
                        }
                    }
                }
                group(Control6014406)
                {
                    ShowCaption = false;
                    field("Item Description"; Rec."Item Description")
                    {

                        ToolTip = 'Specifies the value of the Item Description field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Unit Price"; Rec."Unit Price")
                    {

                        ToolTip = 'Specifies the value of the Unit Price field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Profit %"; Rec."Profit %")
                    {

                        ToolTip = 'Specifies the value of the Profit % field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
    }
}

