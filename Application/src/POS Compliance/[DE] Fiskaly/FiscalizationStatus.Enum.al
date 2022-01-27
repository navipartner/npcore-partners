enum 6014465 "NPR Fiscalization Status"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = false;

    value(0; "Not Fiscalized") { Caption = 'Not Fiscalized'; }
    value(1; "Transaction Started") { Caption = 'Transaction Started'; }
    value(2; Fiscalized) { Caption = 'Fiscalized'; }
}
