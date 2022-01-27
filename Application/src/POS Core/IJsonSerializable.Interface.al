interface "NPR IJsonSerializable"
{
    #IF NOT BC17 
    Access = Internal;      
    #ENDIF
    procedure GetJson(): JsonObject;
}
