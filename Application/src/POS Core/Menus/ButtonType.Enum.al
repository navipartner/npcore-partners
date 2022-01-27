// TODO: This entire type might be unnecessary. It may have been used in .NET, but it may not be used at all in AL+Json

enum 6150751 "NPR Button Type"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = false;

    value(0; Unspecified) { }
    value(1; Ok) { }
    value(2; Yes) { }
    value(3; No) { }
    value(4; Cancel) { }
    value(5; Abort) { }
    value(6; Retry) { }
    value(7; Back) { }
}
