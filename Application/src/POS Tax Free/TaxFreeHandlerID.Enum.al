enum 6014418 "NPR Tax Free Handler ID" implements "NPR Tax Free Handler Interface"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; PREMIER_PI)
    {
        Implementation = "NPR Tax Free Handler Interface" = "NPR Tax Free PTF PI";
    }
    value(1; GLOBALBLUE_I2)
    {
        Implementation = "NPR Tax Free Handler Interface" = "NPR Tax Free GB I2";
    }
    value(2; "CUSTOM CASH")
    {
        Implementation = "NPR Tax Free Handler Interface" = "NPR Tax Free CC";
    }
}
