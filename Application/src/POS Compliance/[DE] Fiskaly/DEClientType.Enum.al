enum 6059841 "NPR DE Client Type"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; "1")
    {
        Caption = '1 - Computergestützte/PC-Kassensysteme', Locked = true;
    }
    value(2; "2")
    {
        Caption = '2 - Tablet-/App-Kassen-Systeme', Locked = true;
    }
    value(3; "3")
    {
        Caption = '3 - Elektronische Registrierkassen', Locked = true;
    }
    value(4; "4")
    {
        Caption = '4 - Taxameter', Locked = true;
    }
    value(5; "5")
    {
        Caption = '5 - Wegstreckenzähler', Locked = true;
    }
}
