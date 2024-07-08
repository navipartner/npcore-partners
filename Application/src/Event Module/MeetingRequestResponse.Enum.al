enum 6014451 "NPR Meeting Request Response"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; Unknown) { Caption = 'Unknown'; }
    value(2; Organizer) { Caption = 'Organizer'; }
    value(3; Tentative) { Caption = 'Tentative'; }
    value(4; Accepted) { Caption = 'Accepted'; }
    value(5; Declined) { Caption = 'Declined'; }
    value(6; "No Response") { Caption = 'No Response'; }
}
