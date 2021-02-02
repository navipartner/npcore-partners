enum 6014404 "NPR CleanCash Unit Storage Status"
{
    Extensible = true;
    value(0; OK)
    {
        Caption = 'OK';
    }

    value(1; WARNING)
    {
        Caption = 'High level warning.';
    }

    value(2; MEMORY)
    {
        Caption = 'Transaction memory full.';
    }

    value(999; NO_VALUE)
    {
        Caption = '';
    }
}