report 6151590 "NPR NpDc Request Coupon Qty."
{
    // NPR5.34/MHA /20170720  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon
    // NPR5.36/MHA /20170921  CASE 291016 Renamed object
    // NPR5.38/JLK /20180124  CASE 300892 Removed AL Error on ControlContainer Caption in Request Page

    UsageCategory = None;
    Caption = 'Request Coupon Qty.';
    ProcessingOnly = true;

    dataset
    {
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Coupons)
                {
                    Caption = 'Coupons';
                    field("Issue Coupon Qty."; IssueCouponQty)
                    {
                        Caption = 'Issue Coupon Qty.';
                        MinValue = 0;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Issue Coupon Qty. field';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        CurrReport.Break;
    end;

    var
        IssueCouponQty: Integer;

    procedure RequestCouponQty(): Integer
    begin
        if CurrReport.RunRequestPage('') = '' then
            exit(0);

        exit(IssueCouponQty);
    end;
}

