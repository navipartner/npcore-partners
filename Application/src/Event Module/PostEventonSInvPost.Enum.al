﻿enum 6014455 "NPR Post Event on S.Inv. Post"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Only Inventory") { Caption = 'Only Inventory'; }
    value(2; "Both Inventory and Job") { Caption = 'Both Inventory and Job'; }
}
