enum 6014654 "NPR RS E-Invoice Status"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; NEW)
    {
        Caption = 'New';
    }
    value(2; SEEN)
    {
        Caption = 'Seen';
    }
    value(3; RENOTIFIED)
    {
        Caption = 'ReNotified';
    }
    value(4; APPROVED)
    {
        Caption = 'Approved';
    }
    value(5; REJECTED)
    {
        Caption = 'Rejected';
    }
    value(6; STORNO)
    {
        Caption = 'Storno';
    }
    value(7; DRAFT)
    {
        Caption = 'Draft';
    }
    value(8; SENT)
    {
        Caption = 'Sent';
    }
    value(9; MISTAKE)
    {
        Caption = 'Mistake';
    }
    value(10; SENDING)
    {
        Caption = 'Sending';
    }
    value(11; CANCELLED)
    {
        Caption = 'Cancelled';
    }
}