enum 6014468 "NPR MobilePayV10 Log Level"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-06-13';
    ObsoleteReason = 'No longer supported';

    value(0; "Errors")
    {
    }
    value(1; "All")
    {
    }
}
