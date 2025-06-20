enum 6059906 "NPR MM Subs Termination Reason"
{
    Caption = 'Subscription Termination Reason';

    value(0; NOT_TERMINATED)
    {
        Caption = '', Locked = true;
    }
    value(1; CUSTOMER_INITIATED)
    {
        Caption = 'Customer Initiated';
    }
    value(2; FORCED_TERMINATION)
    {
        Caption = 'Forced Termination';
    }
}