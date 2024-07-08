enum 6014521 "NPR User Login Type"
{
#IF NOT BC17  
    Access = Internal;       
#ENDIF
    Extensible = false;

    value(0; BC)
    {
        Caption = 'BC';
    }
    value(1; POS)
    {
        Caption = 'POS';
    }
}
