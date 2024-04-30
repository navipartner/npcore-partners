enum 6014672 "NPR SE CC Audit Entry Type"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = true;

    value(0; DELETE_ITEM)
    {
        Caption = 'Item deleted';
    }
}