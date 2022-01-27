enum 6014438 "NPR Stock Calculation Method"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; "Standard")
    {
        Caption = 'Standard';
    }
    value(1; "Function")
    {
        Caption = 'Function';
    }
}
