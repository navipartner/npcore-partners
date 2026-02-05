enum 6014450 "NPR Job Mail Item Status"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; " ") { Caption = ''; }
    value(1; Sent) { Caption = 'Sent'; }
    value(2; Error) { Caption = 'Error'; }
}
