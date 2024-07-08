enum 6014453 "NPR Ticket Collect Status"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Not Collected") { Caption = 'Not Collected'; }
    value(2; Collected) { Caption = 'Collected'; }
    value(3; Error) { Caption = 'Error'; }
}
