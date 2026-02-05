enum 6060150 "NPR Event Status"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; Planning) { Caption = 'Planning'; }
    value(1; Quote) { Caption = 'Quote'; }
    value(2; "Order") { Caption = 'Order'; }
    value(3; Completed) { Caption = 'Completed'; }
    value(9; Postponed) { Caption = 'Postponed'; }
    value(10; Cancelled) { Caption = 'Cancelled'; }
    value(11; "Ready to be Invoiced") { Caption = 'Ready to be Invoiced'; }
}
