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
        dataitem("NPR NpRv Voucher"; "NPR NpRv Voucher")
        {
            RequestFilterFields = "No.", "Reference No.", "Issue External Document No.";
            dataitem(NPRNpRvVoucherEntry; "NPR NpRv Voucher Entry")
            {
                DataItemLink = "Voucher No." = Field("No.");

                column(VoucherNo; "Voucher No.")
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
                column(PostingDate; "Posting Date")
                {
                    IncludeCaption = true;
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

                column(Positive; Positive)
                {
                    IncludeCaption = true;
                }
                column(Amount; Amount)
                {
                    IncludeCaption = true;
                }
                column(Remaining_Amount; "Remaining Amount")
                {
                    IncludeCaption = true;
                }
                column(Open; Open)
                {
                    IncludeCaption = true;
                }
                column(ClosedbyPartnerCode; "Closed by Partner Code")
                {
                    IncludeCaption = true;
                }
                column(PartnerClearing; "Partner Clearing")
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
    }
    requestpage
    {
        SaveValues = true;
    }
    var
        TitleLbl: Label 'VOUCHER ENTRIES';
        TotalLbl: Label 'Total';
}
