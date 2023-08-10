query 6014427 "NPR VAT EV Entries"
{
    Access = Internal;
    QueryType = Normal;

    elements
    {
        dataitem(RSVATEntry; "NPR RS VAT Entry")
        {
            column(Amount; Amount)
            {
                Method = Sum;
            }
            column(Base; Base)
            {
                Method = Sum;
            }
            column(Non_Deductible_VAT_Base; "Non-Deductible VAT Base")
            {
                Method = Sum;
            }
            column(Non_Deductible_VAT_Amount; "Non-Deductible VAT Amount")
            {
                Method = Sum;
            }
            column(Unrealized_Amount; "Unrealized Amount")
            {
                Method = Sum;
            }
            column(VAT_Base_Full_VAT; "VAT Base Full VAT")
            {
                Method = Sum;
            }
            column(VAT_Bus__Posting_Group; "VAT Bus. Posting Group") { }
            column(VAT_Prod__Posting_Group; "VAT Prod. Posting Group") { }
            filter(VATBusPostingGroup; "VAT Bus. Posting Group") { }
            filter(VATProdPostingGroup; "VAT Prod. Posting Group") { }
            filter(VATReportingDate; "VAT Reporting Date") { }
            filter(Type; Type) { }
            filter(Document_Type; "Document Type") { }
            filter(VAT_Report_Mapping; "VAT Report Mapping") { }
            filter(VAT_Calculation_Type; "VAT Calculation Type") { }
        }
    }
}