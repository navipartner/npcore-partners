enum 6014460 "NPR Magento Account Status"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; ACTIVE)
    {
        Caption = 'Active';
    }
    value(1; BLOCKED)
    {
        Caption = 'Blocked';
    }
    value(2; "CHECKOUT_BLOCKED")
    {
        Caption = 'Checkout Blocked';
    }

}
