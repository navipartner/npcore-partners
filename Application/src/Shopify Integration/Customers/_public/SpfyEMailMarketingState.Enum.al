#if not BC17
enum 6059953 "NPR Spfy EMail Marketing State"
{
    Caption = 'Shopify E-Mail Marketing State';
    Access = Public;
    Extensible = false;

    value(0; UNKNOWN)
    {
        Caption = ' ';
    }
    value(1; INVALID)
    {
        Caption = 'Invalid';
    }
    value(2; NOT_SUBSCRIBED)
    {
        Caption = 'Not Subscribed';
    }
    value(3; PENDING)
    {
        Caption = 'Pending';
    }
    value(4; REDACTED)
    {
        Caption = 'Redacted';
    }
    value(5; SUBSCRIBED)
    {
        Caption = 'Subscribed';
    }
    value(6; UNSUBSCRIBED)
    {
        Caption = 'Unsubscribed';
    }
}
#endif