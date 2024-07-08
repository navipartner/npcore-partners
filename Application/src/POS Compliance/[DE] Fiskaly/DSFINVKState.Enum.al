enum 6014472 "NPR DSFINVK State"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    value(0; " ") { Caption = ' '; }
    value(1; PENDING) { Caption = 'PENDING'; }
    value(2; WORKING) { Caption = 'WORKING'; }
    value(3; COMPLETED) { Caption = 'COMPLETED'; }
    value(4; CANCELLED) { Caption = 'CANCELLED'; }
    value(5; EXPIRED) { Caption = 'EXPIRED'; }
    value(6; DELETED) { Caption = 'DELETED'; }
    value(7; ERROR) { Caption = 'ERROR'; }
}
