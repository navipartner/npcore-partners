enum 6014549 "NPR NPRE Serv.Step Discovery"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = true;

    value(0; "Legacy (using print tags)")
    {
        Caption = 'Legacy (using print tags)';
    }
    value(1; "Item Routing Profiles")
    {
        Caption = 'Item Routing Profiles';
    }
}
