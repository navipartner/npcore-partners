enum 6014402 "NPR CC Transaction Status"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; PENDING)
    {
        Caption = 'Pending';
    }

    value(10; FAILED)
    {
        Caption = 'Failed';
    }

    value(20; COMPLETE)
    {
        Caption = 'Complete';
    }
}
