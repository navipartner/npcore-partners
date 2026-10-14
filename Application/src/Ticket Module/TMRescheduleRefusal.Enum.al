enum 6014669 "NPR TM Reschedule Refusal"
{
    Extensible = false;
    Access = Internal;

    value(0; NONE)
    {
        Caption = 'None', Locked = true;
    }
    value(10; LINE_AMBIGUOUS)
    {
        Caption = 'LINE_AMBIGUOUS', Locked = true;
    }
    value(20; TICKET_BLOCKED)
    {
        Caption = 'TICKET_BLOCKED', Locked = true;
    }
    value(30; TICKET_EXPIRED)
    {
        Caption = 'TICKET_EXPIRED', Locked = true;
    }
    value(40; SLOT_CANCELLED)
    {
        Caption = 'SLOT_CANCELLED', Locked = true;
    }
    value(45; NOT_CONFIGURED)
    {
        Caption = 'NOT_CONFIGURED', Locked = true;
    }
    value(50; NOT_ALLOWED)
    {
        Caption = 'NOT_ALLOWED', Locked = true;
    }
    value(60; ALREADY_ADMITTED)
    {
        Caption = 'ALREADY_ADMITTED', Locked = true;
    }
    value(70; CUTOFF_PASSED)
    {
        Caption = 'CUTOFF_PASSED', Locked = true;
    }
    value(80; SLOT_PASSED)
    {
        Caption = 'SLOT_PASSED', Locked = true;
    }
    value(85; LINE_NOT_CHANGEABLE)
    {
        Caption = 'LINE_NOT_CHANGEABLE', Locked = true;
    }
    value(90; NOT_RESOLVABLE)
    {
        Caption = 'NOT_RESOLVABLE', Locked = true;
    }
}
