enum 6014616 "NPR IT Audit Entry Type"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; "POS Entry")
    {
        Caption = 'POS Entry';
    }
}