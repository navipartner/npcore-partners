page 6151600 "NpDc Arch. Coupon Card"
{
    // NPR5.34/MHA /20170720  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon
    // NPR5.37/MHA /20171012  CASE 293232 Object renamed from "NpDc Posted Coupon Card" to "NpDc Arch. Coupon Card"
    // NPR5.51/MHA /20190724  CASE 343352 Removed field 80 "In-use Quantity"

    Caption = 'Archived Coupon Card';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NpDc Arch. Coupon";

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014426)
                {
                    ShowCaption = false;
                    field("No.";"No.")
                    {
                        Editable = false;
                    }
                    field("Coupon Type";"Coupon Type")
                    {
                        Editable = false;
                    }
                    field(Description;Description)
                    {
                    }
                    field("Discount Type";"Discount Type")
                    {
                    }
                    group(Control6014432)
                    {
                        ShowCaption = false;
                        Visible = ("Discount Type"=0);
                        field("Discount Amount";"Discount Amount")
                        {
                            ShowMandatory = true;
                        }
                    }
                    group(Control6014430)
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
                group(Control6014427)
                {
                    ShowCaption = false;
                    field(Open;Open)
                    {
                    }
                    field("Remaining Quantity";"Remaining Quantity")
                    {
                    }
                }
            }
            group("Issue Coupon")
            {
                Caption = 'Issue Coupon';
                group(Control6014405)
                {
                    ShowCaption = false;
                    field("Issue Coupon Module";"Issue Coupon Module")
                    {
                        Editable = false;
                    }
                }
                group(Control6014435)
                {
                    ShowCaption = false;
                    field("Reference No.";"Reference No.")
                    {
                        Editable = false;
                    }
                    field("Customer No.";"Customer No.")
                    {
                    }
                    field("Print Template Code";"Print Template Code")
                    {
                    }
                }
            }
            group(Validate)
            {
                Caption = 'Validate';
                group(Control6014416)
                {
                    ShowCaption = false;
                    field("Validate Coupon Module";"Validate Coupon Module")
                    {
                        Editable = false;
                    }
                }
                group(Control6014418)
                {
                    ShowCaption = false;
                    field("Starting Date";"Starting Date")
                    {
                    }
                    field("Ending Date";"Ending Date")
                    {
                    }
                }
            }
            group("Apply Discount")
            {
                Caption = 'Apply Discount';
                group(Control6014414)
                {
                    ShowCaption = false;
                    field("Apply Discount Module";"Apply Discount Module")
                    {
                        Editable = false;
                    }
                }
                group(Control6014408)
                {
                    ShowCaption = false;
                    field("Max Use per Sale";"Max Use per Sale")
                    {
                    }
                }
                group(Control6014415)
                {
                    ShowCaption = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Arch. Coupon Entries")
            {
                Caption = 'Archived Coupon Entries';
                Image = Entries;
                RunObject = Page "NpDc Arch. Coupon Entries";
                RunPageLink = "Arch. Coupon No."=FIELD("No.");
                ShortCutKey = 'Ctrl+F7';
            }
        }
    }

    var
        Text000: Label 'Are you sure you want to delete Coupons In-use?';
}

