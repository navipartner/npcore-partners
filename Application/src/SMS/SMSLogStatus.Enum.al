enum 6014456 "NPR SMS Log Status"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;
    value(0; Pending)
    {
        Caption = 'Pending';
    }
    value(1; Sent)
    {
        Caption = 'Sent';
    }
    value(2; Error)
    {
        Caption = 'Error';
    }
    value(3; Discard)
    {
        Caption = 'Discard';
    }
    value(4; "Timeout Discard")
    {
        Caption = 'Timeout Discard';
    }
}
