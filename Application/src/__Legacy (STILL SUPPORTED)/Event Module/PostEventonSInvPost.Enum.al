enum 6014455 "NPR Post Event on S.Inv. Post"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Only Inventory") { Caption = 'Only Inventory'; }
    value(2; "Both Inventory and Job") { Caption = 'Both Inventory and Job'; }
}
