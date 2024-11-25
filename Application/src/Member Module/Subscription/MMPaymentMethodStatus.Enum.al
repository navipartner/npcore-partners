enum 6059802 "NPR MM Payment Method Status"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;
    Caption = 'Member Payment Method Status';

    value(0; Active) { Caption = 'Active'; }
    value(10; Archived) { Caption = 'Archived'; }
}