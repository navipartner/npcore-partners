enum 6014423 "NPR Mag. Store Item Visibility"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; Visible)
    {
        Caption = 'Visible';
    }
    value(1; Hidden)
    {
        Caption = 'Hidden';
    }
}
