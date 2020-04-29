page 6151596 "NpDc Extra Coupon Item"
{
    // NPR5.34/MHA /20170724  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon

    AutoSplitKey = true;
    Caption = 'Extra Coupon Item';
    PageType = Card;
    SourceTable = "NpDc Extra Coupon Item";

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014405)
                {
                    ShowCaption = false;
                    field("Item No.";"Item No.")
                    {
                    }
                    field("Discount Type";"Discount Type")
                    {
                    }
                    group(Control6014411)
                    {
                        ShowCaption = false;
                        Visible = ("Discount Type"=0);
                        field("Discount Amount";"Discount Amount")
                        {
                            ShowMandatory = true;
                        }
                    }
                    group(Control6014409)
                    {
                        ShowCaption = false;
                        Visible = ("Discount Type"=1);
                        field("Discount %";"Discount %")
                        {
                            ShowMandatory = true;
                        }
                        field("Max. Discount Amount";"Max. Discount Amount")
                        {
                            ToolTip = 'Max. Discount Amount per Sale';
                        }
                    }
                }
                group(Control6014406)
                {
                    ShowCaption = false;
                    field("Item Description";"Item Description")
                    {
                    }
                    field("Unit Price";"Unit Price")
                    {
                    }
                    field("Profit %";"Profit %")
                    {
                    }
                }
            }
        }
    }

    actions
    {
    }
}

