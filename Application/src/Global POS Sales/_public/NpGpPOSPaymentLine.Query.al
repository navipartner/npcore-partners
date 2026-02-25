query 6014433 "NPR NpGp POS Payment Line"
{
    Access = Public;
    Caption = 'NpGp POS Payment Line';
    QueryType = Normal;
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(NpGp_POS__Payment_Line; "NPR NpGp POS Payment Line")
        {
            column(POSEntryNo; "POS Entry No.")
            {
            }
            column(DocumentNo; "Document No.")
            {
            }
            column(LineNo; "Line No.")
            {
            }
            column(AmountLCY; "Amount (LCY)")
            {
            }
            column(CurrencyCode; "Currency Code")
            {
            }
            column(Description; Description)
            {
            }
            column(PaymentAmount; "Payment Amount")
            {
            }
            column(POSPaymentMethodCode; "POS Payment Method Code")
            {
            }
        }
    }
}