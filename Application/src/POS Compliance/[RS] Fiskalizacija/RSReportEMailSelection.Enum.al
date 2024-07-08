enum 6014529 "NPR RS Report E-Mail Selection"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; "Fiscal Bill A4")
    {
        Caption = 'Fiscal Bill A4';
    }
    value(1; "Thermal printing receipt")
    {
        Caption = 'Thermal printing receipt';
    }
    value(2; "Both")
    {
        Caption = 'Both';
    }
}