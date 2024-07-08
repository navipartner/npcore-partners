enum 6150752 "NPR Button Enabled State"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = false;

    value(0; Yes) { }
    value(1; Auto) { }
    value(2; No) { }
}
