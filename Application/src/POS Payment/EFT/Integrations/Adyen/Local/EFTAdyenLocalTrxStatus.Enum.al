enum 6014611 "NPR EFT Adyen Local Trx Status"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; AcquireCardInitiated)
    {
    }
    value(1; AcquireCardResponseReceived)
    {
    }
    value(2; Initiated)
    {
    }
    value(3; ResultReceived)
    {
    }
    value(4; LookupNeeded)
    {
    }
    value(5; LookupInitiated)
    {
    }
}