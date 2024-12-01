enum 6059809 "NPR Message Severity"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;
    Caption = 'Message Severity';

    value(0; Verbose) { Caption = 'Verbose'; }
    value(1; Normal) { Caption = 'Message'; }
    value(2; Warning) { Caption = 'Warning'; }
    value(3; Error) { Caption = 'Error'; }
    value(4; Critical) { Caption = 'Critical'; }
}