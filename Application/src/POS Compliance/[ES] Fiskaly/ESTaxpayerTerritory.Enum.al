enum 6059769 "NPR ES Taxpayer Territory"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; ARABA)
    {
        Caption = 'Araba/Álava (Basque Country)';
    }
    value(2; BIZKAIA)
    {
        Caption = 'Bizkaia/Biscay (Basque Country)';
    }
    value(3; GIPUZKOA)
    {
        Caption = 'Gipuzkoa (Basque Country)';
    }
    value(4; NAVARRE)
    {
        Caption = 'Nafarroa/Navarre';
    }
    value(5; CANARY_ISLANDS)
    {
        Caption = 'Canary Islands';
    }
    value(6; CEUTA)
    {
        Caption = 'Ceuta';
    }
    value(7; MELILLA)
    {
        Caption = 'Melilla';
    }
    value(8; "SPAIN_OTHER")
    {
        Caption = 'Any other territory in Spain';
    }
}
