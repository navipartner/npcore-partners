report 6014403 "NPR Archived Voucher List"
{
    Caption = 'Archived Voucher List';
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Archived Voucher List.rdlc';
    ApplicationArea = NPRRetail;
    UsageCategory = ReportsAndAnalysis;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(NPRNpRvArchVoucher; "NPR NpRv Arch. Voucher")
        {
            RequestFilterFields = "No.", "Reference No.", "Issue Date", "Voucher Type";
            DataItemTableView = sorting("Voucher Type");
            column(No; "No.")
            {
                IncludeCaption = true;
            }
            column(VoucherType; "Voucher Type")
            {
                IncludeCaption = true;
            }
            column(Description; Description)
            {
                IncludeCaption = true;
            }
            column(IssueDate; "Issue Date")
            {
                IncludeCaption = true;
            }
            column(Initial_Amount; "Initial Amount")
            {
                IncludeCaption = true;
            }
            column(Amount; Amount)
            {
                IncludeCaption = true;
            }
            column(Arch__No_; "Arch. No.")
            {
                IncludeCaption = true;
            }
            column(StartingDate; "Starting Date")
            {
                IncludeCaption = true;
            }
            column(EndingDate; "Ending Date")
            {
                IncludeCaption = true;
            }
            column(ReferenceNo; "Reference No.")
            {
                IncludeCaption = true;
            }
            column(Name; Name)
            {
                IncludeCaption = true;
            }
            column(IssueRegisterNo; "Issue Register No.")
            {
                IncludeCaption = true;
            }
            column(IssueDocumentType; "Issue Document Type")
            {
                IncludeCaption = true;
            }
            column(IssueDocumentNo; "Issue Document No.")
            {
                IncludeCaption = true;
            }
            column(IssueExternalDocumentNo; "Issue External Document No.")
            {
                IncludeCaption = true;
            }
            column(IssueUserID; "Issue User ID")
            {
                IncludeCaption = true;
            }
            column(IssuePartnerCode; "Issue Partner Code")
            {
                IncludeCaption = true;
            }
            column(TotalLbl; TotalLbl)
            {

            }
            column(TitleLbl; TitleLbl)
            {

            }
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(options)
                {

                }
            }
        }
    }
    var
        TotalLbl: Label 'Total';
        TitleLbl: Label 'ARCHIVED VOUCHER LIST';

}
