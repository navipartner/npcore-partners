enum 6014447 "NPR Sales Doc. FunctionToRun"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = false;

    value(0; Default) { }
    value(1; "Invoke OnFinishCreditSale Subsribers") { }
}
