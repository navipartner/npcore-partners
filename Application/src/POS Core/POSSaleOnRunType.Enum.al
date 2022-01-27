enum 6014448 "NPR POS Sale OnRunType"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = false;

    value(0; Undefined) { }
    value(1; RunAfterEndSale) { }
    value(2; OnFinishSale) { }
}
