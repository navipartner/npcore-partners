enum 6014527 "NPR RS Customer Ident."
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(10; PIB)
    {
        Caption = 'PIB Kupca', Locked = true;
    }
    value(11; JMBG)
    {
        Caption = 'JMBG', Locked = true;
    }
    value(12; "PIB&JBKJS")
    {
        Caption = 'PIB I JBKJS', Locked = true;
    }
    value(20; "Licna karta")
    {
        Caption = 'Broj licne karte', Locked = true;
    }
    value(21; "Izbeglicka karta")
    {
        Caption = 'Broj izbeglicke karte', Locked = true;
    }
    value(22; EBS)
    {
        Caption = 'EBS', Locked = true;
    }
    value(23; "Domaci Pasos")
    {
        Caption = 'Broj pasosa - domace lice', Locked = true;
    }
    value(30; "Strani Pasos")
    {
        Caption = 'Broj pasosa - strano lice', Locked = true;
    }
    value(31; Diplomat)
    {
        Caption = 'Broj diplomatske kartice/LK', Locked = true;
    }
    value(32; "LK-MKD")
    {
        Caption = 'Broj licna karta - MKD', Locked = true;
    }
    value(33; "LK-MNE")
    {
        Caption = 'Broj licna karta - MNE', Locked = true;
    }
    value(34; "LK-ALB")
    {
        Caption = 'Broj licna karta - ALB', Locked = true;
    }
    value(35; "LK-BIH")
    {
        Caption = 'Broj licna karta - BIH', Locked = true;
    }
    value(36; "LK po odluci")
    {
        Caption = 'Broj licne karte po odluci', Locked = true;
    }
    value(40; "PIB izvan Srbije")
    {
        Caption = 'PIB izvan Srbije', Locked = true;
    }
}