enum 6014415 "NPR Mag. Contact ShToAdr. Vis."
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; Private)
    {
        Caption = 'Private';
    }
    value(1; Public)
    {
        Caption = 'Public';
    }
}
