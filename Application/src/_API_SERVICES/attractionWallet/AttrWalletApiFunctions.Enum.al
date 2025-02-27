#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
enum 6059842 "NPR AttrWalletApiFunctions"
{
    Extensible = false;
    Access = Internal;
    value(0; NOOP)
    {
        Caption = 'No operation';
    }

    value(10; FIND_WALLET_USING_REFERENCE_NUMBER)
    {
        Caption = 'Get wallet using number';
    }

    value(11; GET_WALLET_USING_ID)
    {
        Caption = 'Get wallet using ID';
    }

    value(12; GET_ASSET_HISTORY)
    {
        Caption = 'Get asset history';
    }

    value(20; ADD_WALLET_ASSETS)
    {
        Caption = 'Add wallet assets';
    }

    value(21; CREATE_WALLET)
    {
        Caption = 'Create wallet';
    }
}
#endif