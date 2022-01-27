enum 6014441 "NPR MCS API Setup API"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; Face)
    {
        Caption = 'Face';
    }
    value(1; Speech)
    {
        Caption = 'Speech';
    }
    value(2; Recommendation)
    {
        Caption = 'Recommendation';
    }

}
