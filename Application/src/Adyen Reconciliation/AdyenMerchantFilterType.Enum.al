enum 6014655 "NPR Adyen Merchant Filter Type"
{
    Extensible = false;
#IF NOT BC17
    Access = Internal;
#ENDIF
    value(0; allAccounts)
    {
        Caption = 'allAccounts';
    }
    value(10; includeAccounts)
    {
        Caption = 'includeAccounts';
    }
    value(20; excludeAccounts)
    {
        Caption = 'excludeAccounts';
    }
}
