enum 6014565 "NPR EFT Planet PAX Status"
{
    Extensible = false;
#if not BC17
    Access = Internal;
#endif

    value(0; Uninitialized)
    {
    }
    value(1; Running)
    {
    }
    value(2; AbortRequested)
    {
    }
    value(3; Aborted)
    {
    }
    value(4; ResponseReceived)
    {
    }
    value(5; Success)
    {
    }
    value(6; Failed)
    {
    }
    value(7; Error)
    {
    }
    value(8; Cancelled)
    {
    }
}