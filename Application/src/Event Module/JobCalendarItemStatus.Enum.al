﻿enum 6014449 "NPR Job Calendar Item Status"
{
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
