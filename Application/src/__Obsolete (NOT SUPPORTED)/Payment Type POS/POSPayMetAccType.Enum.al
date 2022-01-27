enum 6014445 "NPR POS Pay. Met. Acc. Type"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF

    value(0; "G/L Account")
    {
        Caption = 'G/L Account';
    }
    value(1; Customer)
    {
        Caption = 'Customer';
    }
    value(2; Bank)
    {
        Caption = 'Bank';
    }

}
