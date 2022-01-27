enum 6014440 "NPR M2 Acc. Com. Template Type"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; NA)
    {
        Caption = ' ';
    }
    value(1; WELCOME)
    {
        Caption = 'Welcome';
    }
    value(2; "PW_RESET")
    {
        Caption = 'Password Reset';
    }
}
