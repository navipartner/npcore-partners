enum 6014608 "NPR EFT Planet PAX Type"
{
    Extensible = false;
#if not BC17
    Access = Internal;
#endif

    value(0; None)
    {
    }
    value(1; Payment)
    {

    }
    value(2; Refund)
    {
    }
    value(3; Void)
    {
    }
    value(4; Lookup)
    {
    }

}