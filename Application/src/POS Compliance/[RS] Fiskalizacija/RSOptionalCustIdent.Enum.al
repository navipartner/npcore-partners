enum 6014530 "NPR RS Optional Cust. Ident."
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(20; SNPDV)
    {
        Caption = 'SNPDV', Locked = true;
    }
    value(21; LNPDV)
    {
        Caption = 'LNPDV', Locked = true;
    }
    value(30; "PPO-PDV")
    {
        Caption = 'PPO-PDV', Locked = true;
    }
    value(31; "ZPPO-PDV")
    {
        Caption = 'ZPPO-PDV', Locked = true;
    }
    value(32; "MPPO-PDV")
    {
        Caption = 'MPPO-PDV', Locked = true;
    }
    value(33; "IPPO-PDV")
    {
        Caption = 'IPPO-PDV', Locked = true;
    }
    value(50; Corporate)
    {
        Caption = 'Number of Corporate card', Locked = true;
    }
    value(60; "Virman Period")
    {
        Caption = 'Virman Period', Locked = true;
    }
}