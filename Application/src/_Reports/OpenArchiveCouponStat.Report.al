report 6151598 "NPR Open/Archive Coupon Stat."
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/OpenArchive Coupon Statistics.rdlc';
    Caption = 'Open/Archived Coupon Statistics';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    dataset
    {
        dataitem("NpDc Coupon Type"; "NPR NpDc Coupon Type")
        {
            RequestFilterFields = "Discount Type", Enabled;
            column(CouponTypeCode_; "NpDc Coupon Type".Code)
            {
            }
            column(CouponTypeDescription_; "NpDc Coupon Type".Description)
            {
            }
            column(Archived_; Archived)
            {
            }
            column(CouponNoCptn_; "NpDc Coupon Type".FieldCaption(Code))
            {
            }
            column(DescriptionCptn_; "NpDc Coupon Type".FieldCaption(Description))
            {
            }
            column(CouponTypeFilters; "NpDc Coupon Type".GetFilters)
            {
            }
            column(CouponTypeHasFilter; "NpDc Coupon Type".HasFilter)
            {
            }
            column(GrandTotal_; GrandTotalCptn)
            {
            }
            column(BlankCouponTypes_; RemoveBlankCouponTypes)
            {
            }
            column(StartDate_; StartDate)
            {
            }
            column(EndDate_; EndDate)
            {
            }
            column(QtyIssued_; QtyIssued)
            {
            }
            column(QtyUsed_; QtyUsed)
            {
            }

            trigger OnAfterGetRecord()
            begin
                QtyIssued := 0;
                QtyUsed := 0;
                CouponEntry.Reset();
                CouponEntry.SetCurrentKey("Entry Type", "Posting Date", "Coupon Type", "Coupon No.");
                CouponEntry.SetRange(CouponEntry."Coupon Type", "NpDc Coupon Type".Code);
                CouponEntry.SetRange("Entry Type", CouponEntry."Entry Type"::"Issue Coupon");

                if (StartDate <> 0D) and (EndDate <> 0D) then
                    CouponEntry.SetFilter(CouponEntry."Posting Date", '%1..%2', StartDate, EndDate);

                if EndDate = 0D then
                    CouponEntry.SetFilter(CouponEntry."Posting Date", '%1', StartDate);

                if CustomerFilter <> '' then
                    if CouponEntry.FindSet() then
                        repeat
                            Coupon.Reset();
                            Coupon.SetCurrentKey("Coupon Type");
                            Coupon.SetRange("Coupon Type", CouponEntry."Coupon Type");
                            Coupon.SetFilter("Customer No.", CustomerFilter);
                            Coupon.SetRange("No.", CouponEntry."Coupon No.");
                            if Coupon.FindFirst() then
                                QtyIssued += 1
                        until CouponEntry.Next() = 0;

                if CustomerFilter = '' then
                    QtyIssued := CouponEntry.Count();

                ArchCouponEntry.Reset();
                ArchCouponEntry.SetCurrentKey("Entry Type", "Posting Date", "Coupon Type", "Arch. Coupon No.");
                ArchCouponEntry.SetRange(ArchCouponEntry."Coupon Type", "NpDc Coupon Type".Code);
                ArchCouponEntry.SetRange("Entry Type", ArchCouponEntry."Entry Type"::"Issue Coupon");
                if (StartDate <> 0D) and (EndDate <> 0D) then
                    ArchCouponEntry.SetFilter(ArchCouponEntry."Posting Date", '%1..%2', StartDate, EndDate);

                if EndDate = 0D then
                    ArchCouponEntry.SetFilter(ArchCouponEntry."Posting Date", '%1', StartDate);
                if CustomerFilter <> '' then
                    if ArchCouponEntry.FindSet() then
                        repeat
                            ArchCoupon.Reset();
                            ArchCoupon.SetCurrentKey("Coupon Type");
                            ArchCoupon.SetRange("Coupon Type", ArchCouponEntry."Coupon Type");
                            ArchCoupon.SetFilter("Customer No.", CustomerFilter);
                            ArchCoupon.SetRange("No.", ArchCouponEntry."Arch. Coupon No.");
                            if ArchCoupon.FindFirst() then
                                QtyUsed += 1
                        until ArchCouponEntry.Next() = 0;

                if CustomerFilter = '' then
                    QtyUsed := ArchCouponEntry.Count();

                if RemoveBlankCouponTypes then
                    if (QtyIssued = 0) and (QtyUsed = 0) then
                        CurrReport.Skip();
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field("Start Date"; StartDate)
                {
                    Caption = 'Start Date';

                    ToolTip = 'Specifies the value of the Start Date field';
                    ApplicationArea = NPRRetail;
                }
                field("End Date"; EndDate)
                {
                    Caption = 'End Date';

                    ToolTip = 'Specifies the value of the End Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Blank CouponTypes"; RemoveBlankCouponTypes)
                {
                    Caption = 'Remove Blank Coupon Types';

                    ToolTip = 'Specifies the value of the Remove Blank Coupon Types field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer No"; CustomerFilter)
                {
                    Caption = 'Customer No';

                    ToolTip = 'Specifies the value of the Customer No field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if PAGE.RunModal(22, Customer) = ACTION::LookupOK then
                            CustomerFilter := Customer."No.";
                    end;
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
        FromDatelbl = 'From Date :';
        ToDatelbl = 'To Date :';
    }

    var
        Customer: Record Customer;
        ArchCoupon: Record "NPR NpDc Arch. Coupon";
        ArchCouponEntry: Record "NPR NpDc Arch.Coupon Entry";
        Coupon: Record "NPR NpDc Coupon";
        CouponEntry: Record "NPR NpDc Coupon Entry";
        RemoveBlankCouponTypes: Boolean;
        EndDate: Date;
        StartDate: Date;
        QtyIssued: Decimal;
        QtyUsed: Decimal;
        Archived: Integer;
        GrandTotalCptn: Label 'Grand Total';
        CustomerFilter: Text;
}

