#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
enum 6014580 "NPR ChannelMgrApiFunctions"
{
    Extensible = false;
    Access = Internal;

    value(0; NOOP)
    {
        Caption = 'No operation';
    }

    #region Orders
    value(100; CREATE_ORDER)
    {
        Caption = 'Create channel manager order';
    }
    value(101; REPLACE_ORDER)
    {
        Caption = 'Replace channel manager order';
    }
    value(102; DELETE_ORDER)
    {
        Caption = 'Delete channel manager order';
    }
    value(103; GET_ORDER)
    {
        Caption = 'Get channel manager order';
    }
    value(104; LIST_ORDERS_BY_PARTNER)
    {
        Caption = 'List channel manager orders by partner';
    }
    value(105; CONFIRM_ORDER)
    {
        Caption = 'Confirm channel manager order';
    }
    #endregion
}
#endif
