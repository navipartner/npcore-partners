enum 6014454 "NPR Over Capacitate Resource"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; Allow) { Caption = 'Allow'; }
    value(2; Warn) { Caption = 'Warn'; }
    value(3; Disallow) { Caption = 'Disallow'; }
}
