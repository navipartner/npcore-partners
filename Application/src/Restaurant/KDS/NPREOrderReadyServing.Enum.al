enum 6014543 "NPR NPRE Order Ready Serving"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = true;

    value(0; Default)
    {
        Caption = '<Default>';
    }
    value(1; "All Requests")
    {
        Caption = 'When All Requests Are Ready';
    }
    value(2; "Any Request")
    {
        Caption = 'When Any Request Is Ready';
    }
}
