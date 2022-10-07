enum 6014508 "NPR EFT NETSCloud Trx Status"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; Initiated)
    {
    }
    value(1; ResponseReceived)
    {
    }
    value(2; LookupNeeded)
    {
    }
    value(3; LookupInitiated)
    {
    }
}