enum 6014444 "NPR POS View LockTimeout"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    value(0; NEVER)
    {
        Caption = 'Never';
    }
    value(1; "30S")
    {
        Caption = '30 Seconds';
    }
    value(2; "60S")
    {
        Caption = '60 Seconds';
    }
    value(3; "90S")
    {
        Caption = '90 Seconds';
    }
    value(4; "120S")
    {
        Caption = '120 Seconds';
    }
    value(5; "600S")
    {
        Caption = '600 Seconds';
    }
}
