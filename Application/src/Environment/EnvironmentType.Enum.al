enum 6014516 "NPR Environment Type"
{
#IF NOT BC17  
    Access = Internal;
#ENDIF

    value(0; PROD)
    {
        Caption = 'PROD';
    }
    value(1; DEMO)
    {
        Caption = 'Demo';
    }
    value(2; SANDBOX)
    {
        Caption = 'Sandbox/Test/Development';
    }
}
