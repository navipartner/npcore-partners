enum 6014476 "NPR TM Not. Send Status"
{
    Extensible = true;

    value(0; PENDING)
    {
        Caption = 'Pending';
    }
    value(1; SENT)
    {
        Caption = 'Sent';
    }
    value(2; CANCELED)
    {
        Caption = 'Canceled';
    }
    value(3; FAILED)
    {
        Caption = 'Failed';
    }
    value(4; NOT_SENT)
    {
        Caption = 'Not Sent';
    }
    value(5; DETAINED)
    {
        Caption = 'Detained';
    }
}