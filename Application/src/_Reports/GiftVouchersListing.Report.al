report 6014445 "NPR Gift Vouchers Listing"
{
    // NPR5.55/ZESO/20200713  CASE 402928 Object Created.
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Gift Vouchers Listing.rdlc';

    Caption = 'Gift Vouchers Listing';
    UsageCategory = ReportsAndAnalysis;

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

    requestpage
    {

        layout
        {
            area(content)
            {
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnInitReport()
    var
        Company: Record Company;
        Counter: Integer;
        RetailSetup: Record "NPR Retail Setup";
    begin
    end;

    var
        ReportNameLbl: Label 'Cashed Gift Voucher';
        PageLbl: Label 'Page';
        GVFilters: Text[100];
        GVFiltersLbl: Label 'Filters: %1';
        TotalLbl: Label 'Total';
}

