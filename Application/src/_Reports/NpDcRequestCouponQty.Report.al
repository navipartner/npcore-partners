report 6151590 "NPR NpDc Request Coupon Qty."
{
    Caption = 'Request Coupon Qty.';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
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

                        ToolTip = 'Specifies the value of the Issue Coupon Qty. field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }

    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        CurrReport.Break();
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

