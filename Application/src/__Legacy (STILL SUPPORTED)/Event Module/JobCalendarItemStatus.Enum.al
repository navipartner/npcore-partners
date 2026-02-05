enum 6014449 "NPR Job Calendar Item Status"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; " ") { Caption = ''; }
    value(1; Send) { Caption = 'Send'; }
    value(2; Error) { Caption = 'Error'; }
    value(3; Removed) { Caption = 'Removed'; }
    value(4; Sent) { Caption = 'Sent'; }
    value(5; Received) { Caption = 'Received'; }
}
