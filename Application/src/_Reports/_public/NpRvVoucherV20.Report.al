report 6014452 "NPR NpRv VoucherV20"
{
#if (BC17 or BC18 or BC19)
    UsageCategory = None;
#else
    ApplicationArea = NPRRetail;
    Caption = 'VoucherV20';
    UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = "Excel Layout";
    Extensible = true;
    dataset
    {
        dataitem(NPRNpRvVoucher; "NPR NpRv Voucher")
        {
            column(No; "No.")
            {
            }
            column(VoucherType; "Voucher Type")
            {
            }
            column(Description; Description)
            {
            }
            column(IssueDate; "Issue Date")
            {
            }
            column(Open; Open)
            {
            }
            column(InitialAmount; "Initial Amount")
            {
            }
            column(Amount; Amount)
            {
            }
            column(StartingDate; "Starting Date")
            {
            }
            column(EndingDate; "Ending Date")
            {
            }
            column(ReferenceNo; "Reference No.")
            {
            }
            column(Name; Name)
            {
            }
            column(IssueDocumentType; "Issue Document Type")
            {
            }
            column(IssueDocumentNo; "Issue Document No.")
            {
            }
            column(IssueExternalDocumentNo; "Issue External Document No.")
            {
            }
            column(IssueUserID; "Issue User ID")
            {
            }
            column(IssuePartnerCode; "Issue Partner Code")
            {
            }
            column(PartnerClearing; "Partner Clearing")
            {
            }
        }
    }
    rendering
    {
        layout("Excel Layout")
        {
            Caption = 'Excel layout to display and work with data from table NPR NpRv Voucher .';
            LayoutFile = './src/_Reports/layouts/NPR NpRv Voucher.xlsx';
            Type = Excel;
        }
    }
#endif
}
