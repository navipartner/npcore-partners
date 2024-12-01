enum 6059828 "NPR MM Subs Req Proc Status"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;
    Caption = 'Subscription Request Processing Status';

    value(0; Pending) { }
    value(10; Success) { }
    value(20; Error) { }
}
