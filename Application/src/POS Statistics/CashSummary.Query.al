query 6014410 "NPR Cash Summary"
{
    Access = Internal;
    Caption = 'Cash Summary';
    QueryType = Normal;

    elements
    {
        dataitem(POSBinEntry; "NPR POS Bin Entry")
        {
            DataItemTableFilter = Type = filter('OUTPAYMENT' | 'INPAYMENT' | 'FLOAT' | 'BANK_TRANSFER_OUT' | 'BANK_TRANSFER_IN' | 'BIN_TRANSFER_OUT' | 'BIN_TRANSFER_IN');

            filter(EntryNo; "Entry No.") { }
            filter(POSUnitNo; "POS Unit No.") { }
            column(PaymentMethodCode; "Payment Method Code") { }
            column(PaymentBinNo; "Payment Bin No.") { }
            column(TransactionAmount; "Transaction Amount") { Method = Sum; }
            column(TransactionAmountLCY; "Transaction Amount (LCY)") { Method = Sum; }
        }
    }
}