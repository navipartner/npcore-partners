enum 6014452 "NPR Ticket Status"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; Registered) { Caption = 'Registered'; }
    value(2; Issued) { Caption = 'Issued'; }
    value(3; Revoked) { Caption = 'Revoked'; }
    value(4; Confirmed) { Caption = 'Confirmed'; }
}
