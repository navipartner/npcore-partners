interface "NPR Front-End Async Request"
{
    #IF NOT BC17 
    Access = Internal;      
    #ENDIF
    procedure GetContent(): JsonObject;
    procedure GetJson(): JsonObject;
}
