enum 6014467 "NPR MobilePayV10 Environment"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = false;
    value(0; Production)
    {
        Caption = 'Production';
    }
    value(1; Sandbox)
    {
        Caption = 'Sandbox';
    }
}
