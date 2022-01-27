enum 6014416 "NPR BTF Environment"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; "sandbox")
    {
        Caption = 'sandbox';
    }

    value(1; "production")
    {
        Caption = 'production';
    }
}
