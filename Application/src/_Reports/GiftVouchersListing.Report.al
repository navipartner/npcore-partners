report 6014445 "NPR Gift Vouchers Listing"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Gift Vouchers Listing.rdlc';
    Caption = 'Gift Vouchers Listing';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    dataset
    {
        dataitem("Gift Voucher"; "NPR Gift Voucher")
        {
            RequestFilterFields = "Issue Date", "Cashed Date", Status, "Shortcut Dimension 1 Code";
            column(No_GiftVoucher; "Gift Voucher"."No.")
            {
                IncludeCaption = true;
            }
            column(SalesTicketNo_GiftVoucher; "Gift Voucher"."Sales Ticket No.")
            {
                IncludeCaption = true;
            }
            column(IssueDate_GiftVoucher; "Gift Voucher"."Issue Date")
            {
                IncludeCaption = true;
            }
            column(Amount_GiftVoucher; "Gift Voucher".Amount)
            {
                IncludeCaption = true;
            }
            column(CashedDate_GiftVoucher; "Gift Voucher"."Cashed Date")
            {
                IncludeCaption = true;
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(ReportNameLbl; ReportNameLbl)
            {
            }
            column(PageLbl; PageLbl)
            {
            }
            column(GVFilters; StrSubstNo(GVFiltersLbl, GVFilters))
            {
            }
            column(TotalLbl; TotalLbl)
            {
            }

            trigger OnPreDataItem()
            begin
                GVFilters := "Gift Voucher".GetFilters;
            end;
        }
    }

    var
        ReportNameLbl: Label 'Cashed Gift Voucher';
        GVFiltersLbl: Label 'Filters: %1', Comment = '%1 = Filters';
        PageLbl: Label 'Page';
        TotalLbl: Label 'Total';
        GVFilters: Text[100];
}

