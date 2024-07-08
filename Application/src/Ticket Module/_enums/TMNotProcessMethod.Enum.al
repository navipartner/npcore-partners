enum 6014478 "NPR TM Not. Process Method"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; MANUAL)
    {
        Caption = 'Manual';
    }
    value(1; INLINE)
    {
        Caption = 'Inline';
    }
    value(2; BATCH)
    {
        Caption = 'Batch';
    }
    value(3; EXTERNAL)
    {
        Caption = 'External';
    }
}
