enum 6014505 "NPR POS Background Task" implements "NPR POS Background Task"
{
    Extensible = false;
#if not BC17
    Access = Internal;
    UnknownValueImplementation = "NPR POS Background Task" = "NPR Unknown POS Bgnd. Task";
#endif

    value(0; Example)
    {
        Caption = 'Example';
        Implementation = "NPR POS Background Task" = "NPR POSAction - Task Example";
    }
}