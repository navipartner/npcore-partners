enum 6014480 "NPR TM Attendee Status"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = false;

    value(0; OPEN)
    {
        Caption = 'Open';
    }
    value(1; REVOKED)
    {
        Caption = 'Revoked';
    }
    value(2; ADMITTED)
    {
        Caption = 'Admitted';
    }
}
