enum 6014571 "NPR Total Discount Application"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; "Discount Filters")
    {
        Caption = 'Discount Filters';
    }

    value(1; "No Filters")
    {
        Caption = 'No Filters';
    }
}
