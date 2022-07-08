report 6151598 "NPR Open/Archive Coupon Stat."
{
#IF NOT BC17
    Extensible = false;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/OpenArchive Coupon Statistics.rdlc';
    Caption = 'Open/Archived Coupon Statistics';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(CompanyInformation; "Company Information")
        {
            DataItemTableView = sorting("Primary Key");
            column(Name; Name)
            {
                IncludeCaption = true;
            }
            column(CouponTypeFilters; "NpDc Coupon Type".GetFilters)
            {
            }
        }
        dataitem("NpDc Coupon Type"; "NPR NpDc Coupon Type")
        {
            RequestFilterFields = "Discount Type", "Starting Date", "Ending Date", Enabled;
            column(CouponTypeCode_; "NpDc Coupon Type".Code)
            {
                IncludeCaption = true;
            }
            column(CouponTypeDescription_; "NpDc Coupon Type".Description)
            {
                IncludeCaption = true;
            }
            column(QtyIssued_; QtyIssued)
            {
            }
            column(QtyUsed_; QtyUsed)
            {
            }

            trigger OnAfterGetRecord()
            var
                NpDcCoupon: Record "NPR NpDc Coupon";
                NpDcArchCoupon: Record "NPR NpDc Arch. Coupon";
            begin
                NpDcCoupon.setrange("Coupon Type", "NpDc Coupon Type".Code);
                NpDcCoupon.setrange("Coupon Issued", true);
                NpDcCoupon.SetFilter("Customer No.", CustomerFilter);
                NpDcCoupon.SetFilter("Starting Date", "NpDc Coupon Type".GetFilter("Starting Date"));
                NpDcCoupon.SetFilter("Ending Date", "NpDc Coupon Type".GetFilter("Ending Date"));

                QtyIssued := NpDcCoupon.Count();

                NpDcArchCoupon.SetRange("Coupon Type", "NpDc Coupon Type".Code);
                NpDcArchCoupon.SetRange("Coupon Issued", true);
                NpDcArchCoupon.SetFilter("Customer No.", CustomerFilter);
                NpDcArchCoupon.SetFilter("Starting Date", "NpDc Coupon Type".GetFilter("Starting Date"));
                NpDcArchCoupon.SetFilter("Ending Date", "NpDc Coupon Type".GetFilter("Ending Date"));

                QtyUsed := NpDcArchCoupon.Count();

                if RemoveCouponsWithZeroResult and ((QtyIssued = 0) and (QtyUsed = 0)) then
                    CurrReport.Skip();
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                field("Remove_Coupons_With_Zero_Result"; RemoveCouponsWithZeroResult)
                {
                    Caption = 'Not show Coupons with zero result';

                    ToolTip = 'Not showing Coupon with zero result';
                    ApplicationArea = NPRRetail;
                }
                field("Customer No"; CustomerFilter)
                {
                    Caption = 'Customer No';

                    ToolTip = 'Specifies the value of the Customer No field';
                    ApplicationArea = NPRRetail;
                    TableRelation = Customer;
                }
            }
        }
    }

    labels
    {
        QtyIssuedLbl = 'Open';
        QtyUsedLbl = 'Archived';
        TotalLbl = 'Total';
        ReportTitle = 'Open and Archived Coupons Report';
    }

    var
        RemoveCouponsWithZeroResult: Boolean;
        CustomerFilter: Text;
        QtyIssued: Decimal;
        QtyUsed: Decimal;
}