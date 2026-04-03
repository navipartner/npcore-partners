enum 6014626 "NPR NPRE Mark Req. as Served"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; Default)
    {
        Caption = '<Default>';
    }
    value(10; Manual)
    {
        Caption = 'Manual';
    }
    value(20; "When Prod. Finished")
    {
        Caption = 'When Production is Finished';
    }
}
