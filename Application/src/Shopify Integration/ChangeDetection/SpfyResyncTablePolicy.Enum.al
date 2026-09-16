enum 6014622 "NPR Spfy Resync Table Policy"
{
    Access = Internal;
    Extensible = false;

    value(0; "Baseline Reset") { Caption = 'Baseline Reset'; }
    value(1; "Mark-Only Requeue") { Caption = 'Mark-Only Requeue'; }
    value(2; "Fast-Forward Only") { Caption = 'Fast-Forward Only'; }
    value(3; Blocked) { Caption = 'Blocked'; }
}
