enum 6014401 "NPR CleanCash Receipt Type"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; normal)
    {
        Caption = 'Sales Receipt';
    }

    value(1; kopia)
    {
        Caption = 'Copy of Sales Receipt';
    }

    value(2; ovning)
    {
        Caption = 'Training mode';
    }

    value(3; profo)
    {
        Caption = 'Pro forma Receipt';
    }

    value(9999; NO_VALUE)
    {
        Caption = '';
    }
}
