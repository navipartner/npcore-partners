report 6014407 "NPR Voucher Entries"
{
#IF NOT BC17
    Extensible = False; 
#ENDIF

    Caption = 'Voucher Entries';
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Voucher Entries.rdlc';
    ApplicationArea = NPRRetail;
    UsageCategory = ReportsAndAnalysis;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("Company Information"; "Company Information")
        {
            DataItemTableView = sorting("Primary Key");
            column(Name; Name)
            {
            }
            column(AplyedFilters; AppliedFilters)
            {
            }
        }
        dataitem("NPR NpRv Voucher"; "NPR NpRv Voucher")
        {
            RequestFilterFields = "No.", "Reference No.", "Issue External Document No.";
            dataitem(NPRNpRvVoucherEntry; "NPR NpRv Voucher Entry")
            {
                DataItemLink = "Voucher No." = Field("No.");
                DataItemTableView = sorting("Entry No.");

                column(VoucherNo;
                "Voucher No.")
                {
                    IncludeCaption = true;
                }
                column(VoucherType; "Voucher Type")
                {
                    IncludeCaption = true;
                }
                column(RegisterNo; "Register No.")
                {
                    IncludeCaption = true;
                }
                column(EntryType; "Entry Type")
                {
                    IncludeCaption = true;
                }
                column(EntryNo; "Entry No.")
                {
                    IncludeCaption = true;
                }
                column(ClosedbyEntryNo; "Closed by Entry No.")
                {
                    IncludeCaption = true;
                }
                column(PostingDate; Format("Posting Date"))
                {
                }
                column(DocumentType; "Document Type")
                {
                    IncludeCaption = true;
                }
                column(DocumentNo; "Document No.")
                {
                    IncludeCaption = true;
                }
                column(ExternalDocumentNo; "External Document No.")
                {
                    IncludeCaption = true;
                }
                column(ReferenceNo_Voucher; "NPR NpRv Voucher"."Reference No.")
                {
                    IncludeCaption = true;
                }
                column(PartnerCode; "Partner Code")
                {
                    IncludeCaption = true;
                }
                column(Positive; Format(Positive))
                {
                }
                column(Amount; Amount)
                {
                    IncludeCaption = true;
                }
                column(Remaining_Amount; "Remaining Amount")
                {
                    IncludeCaption = true;
                }
                column(Open; Format(Open))
                {
                }
                column(ClosedbyPartnerCode; "Closed by Partner Code")
                {
                    IncludeCaption = true;
                }
                column(PartnerClearing; format("Partner Clearing"))
                {
                }

            }

        }

    }
    requestpage
    {
        SaveValues = true;
    }

    labels
    {
        CompanyLbl = 'Company: ';
        DateAndTimeLbl = 'Date and Time: ';
        UserLbl = 'User: ';
        PageLbl = 'Page';
        TitleLbl = 'VOUCHER ENTRIES';
        TotalLbl = 'Total';
        FiltersLbl = 'Applied Filters: ';
        PositiveLbl = 'Positive';
        OpenLbl = 'Open';
        PartnerClearingLbl = 'Partner Clearing';
        PostingDateLbl = 'Posting Date';
        TotalForVoucherLbl = 'Total for Voucher ';
        OfLbl = 'of';
    }

    trigger OnPreReport()
    begin
        AppliedFilters := "NPR NpRv Voucher".GetFilters;
    end;

    var
        AppliedFilters: Text;
}
