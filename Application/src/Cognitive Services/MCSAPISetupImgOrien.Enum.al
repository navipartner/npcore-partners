enum 6014442 "NPR MCS API Setup Img Orien."
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; Landscape)
    {
        Caption = 'Landscape';
    }
    value(1; Portrait)
    {
        Caption = 'Portrait';
    }

}
