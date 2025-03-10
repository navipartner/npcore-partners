enum 6014552 "NPR POS Webhook"
{
    Extensible = false;
#if not BC17
    Access = Internal;
#endif

    value(0; POSSaleCompleted) { }
    value(1; POSUnitBalanced) { }
}