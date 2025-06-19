#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
enum 6059855 "NPR RetailVoucherApiFunctions"
{
    Extensible = false;
    Access = Internal;

    value(0; NOOP)
    {
        Caption = 'No operation';
    }
    value(50; FIND_VOUCHERS)
    {
        Caption = 'Find vouchers';
    }
    value(150; CREATE_VOUCHER)
    {
        Caption = 'Create voucher';
    }
    value(200; GET_VOUCHER)
    {
        Caption = 'Get voucher';
    }
    value(250; RESERVE_VOUCHER)
    {
        Caption = 'Reserve voucher';
    }
    value(300; CANCEL_RES_VOUCHER)
    {
        Caption = 'Cancel voucher reservation';
    }
}
#endif