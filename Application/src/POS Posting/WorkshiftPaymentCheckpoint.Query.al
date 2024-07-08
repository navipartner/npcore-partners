query 6014431 "NPR WorkshiftPaymentCheckpoint"
{
    Access = Internal;
    Caption = 'Payment Checkpoints for Workshift';

    elements
    {
        dataitem(PaymentBinCheckpoint; "NPR POS Payment Bin Checkp.")
        {
            filter(WorkshiftCheckpointEntryNo; "Workshift Checkpoint Entry No.") { }
            filter(Status; Status) { }
            filter(IncludeInCounting; "Include In Counting") { }
            filter(PaymentBinNo; "Payment Bin No.") { }
            filter(PaymentMethodNo; "Payment Method No.") { }
            column(EntryNo; "Entry No.") { }
        }
    }
}