enum 6014671 "NPR Adyen Trans. Rec. Table"
{
    Extensible = false;
#IF NOT BC17
    Access = Internal;
#ENDIF

    value(0; "To Be Determined")
    {
        Caption = 'To Be Determined';
    }
    value(10; "EFT Transaction")
    {
        Caption = 'EFT Transaction';
    }
    value(20; "Magento Payment Line")
    {
        Caption = 'Magento Payment Line';
    }
    value(30; "G/L Entry")
    {
        Caption = 'G/L Entry';
    }
    value(40; "Subscription Payment")
    {
        Caption = 'Subscription Payment';
    }
}
