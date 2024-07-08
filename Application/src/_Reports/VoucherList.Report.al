report 6014401 "NPR Voucher List"
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    Caption = 'Voucher List';
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Voucher List.rdlc';
    ApplicationArea = NPRRetail;
    UsageCategory = ReportsAndAnalysis;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("Company Information"; "Company Information")
        {
            DataItemTableView = sorting("Primary Key");
            column(CompanyName; Name)
            {
                IncludeCaption = true;
            }
            dataitem(NPRNpRvVoucher; "NPR NpRv Voucher")
            {
                RequestFilterFields = "No.", "Reference No.", "Issue Date", Open, "Voucher Type";
                DataItemTableView = where("Arch. No." = const(''));
                CalcFields = Open;

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
                column(Arch__No_; "Arch. No.")
                {
                }
                column(ShowSummary; ShowSummary)
                {
                }
                column(Open; Format(Open))
                {
                }
                column(BoolOpen; Open)
                {
                }
                column(TotalLbl; TotalLbl)
                {
                }
                column(ClosedLbl; ClosedLbl)
                {
                }
                column(ArchivedLbl; ArchivedLbl)
                {
                }
                column(TitleLbl; TitleLbl)
                {
                }
                column(AplyedFilters; AppliedFilters)
                {
                }
                dataitem("NPR NpRv Voucher Type"; "NPR NpRv Voucher Type")
                {
                    DataItemLink = Code = field("Voucher Type");
                    column(Description2; Description)
                    {
                        IncludeCaption = true;
                    }
                }
            }
        }
    }
    requestpage
    {
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(options)
                {
                    Caption = 'Options';
                    field("Show Summary"; ShowSummary)
                    {
                        Caption = 'Show Summary';
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Show Summary field';
                    }
                }
            }
        }
    }

    labels
    {
        ExpireDate_cap = 'Expiry Date';
        DateAndTimeLbl = 'Date and Time: ';
        UserLbl = 'User: ';
        OpenLbl = 'Open';
        PageLbl = 'Page';
        OfLbl = 'of';
        TotalForLbl = 'Total for';
        FiltersLbl = 'Applied Filters: ';
    }

    trigger OnInitReport()
    begin
        ShowSummary := true;
    end;

    trigger OnPreReport()
    begin
        AppliedFilters := NPRNpRvVoucher.GetFilters;
    end;

    var
        ShowSummary: Boolean;
        TotalLbl: Label 'Total';
        ClosedLbl: Label 'Closed';
        ArchivedLbl: Label 'Archived';
        TitleLbl: Label 'Voucher List';
        AppliedFilters: Text;
}
