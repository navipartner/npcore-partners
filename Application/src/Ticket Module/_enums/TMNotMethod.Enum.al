enum 6014479 "NPR TM Not. Method"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; NA)
    {
        Caption = '';
    }
    value(1; EMAIL)
    {
        Caption = 'E-Mail';
    }
    value(2; SMS)
    {
        Caption = 'SMS';
    }
}
