enum 6014403 "NPR CleanCash Unit Main Status"
{
    Extensible = true;
    value(0; OK)
    {
        Caption = 'OK';
    }

    value(1; WARNING)
    {
        Caption = 'Warning condition(s) exists.';
    }

    value(2; PROTOCOL_ERROR)
    {
        Caption = 'Protocol error condition(s) exists.';
    }

    value(3; NON_FATAL_ERROR)
    {
        Caption = 'Non fatal error condition(s) exists.';
    }

    value(4; FATAL_ERROR)
    {
        Caption = 'Fatal Error condition(s) exists.';
    }

    value(5; BUSY)
    {
        Caption = 'Busy (Data is being downloaded to external memory card).';
    }

    value(99; ERROR)
    {
        Caption = 'Communications error (no connection with CleanCash unit).';
    }

    value(999; NO_VALUE)
    {
        Caption = '';
    }
}