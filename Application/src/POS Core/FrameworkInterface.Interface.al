interface "NPR Framework Interface"
{
    #IF NOT BC17 
    Access = Internal;      
    #ENDIF
    procedure InvokeFrontEndAsync(Request: JsonObject);
}
