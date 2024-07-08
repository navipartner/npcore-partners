enum 6014606 "NPR EFT Adyen Request Type"
{
    Extensible = false;
#if not BC17
    Access = internal;
#endif    
    value(0; Payment)
    {
        Caption = 'Payment';
    }
    value(1; Refund)
    {
        Caption = 'Refund';
    }
    value(2; Void)
    {
        Caption = 'Void';
    }
    value(3; AbortTransaction)
    {
        Caption = 'Abort Transaction';
    }
    value(4; AcquireCard)
    {
        Caption = 'Acquire Card';
    }
    value(5; AbortAcquireCard)
    {
        Caption = 'Abort Acquire Card';
    }
    value(6; TransactionLookup)
    {
        Caption = 'Transaction Lookup';
    }
    value(7; DiagnoseTerminal)
    {
        Caption = 'Diagnose Terminal';
    }
    value(8; DisableRecurringContract)
    {
        Caption = 'Disable Recurring Contract';
    }
}