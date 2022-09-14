enum 6014507 "NPR EFT Request Mechanism"
{
    Extensible = false;
#if not BC17
    Access = Internal;
#endif

    value(0; Undefined)
    {
    }
    value(1; POSWorkflow)
    {
    }
    value(2; Synchronous)
    {
    }
}