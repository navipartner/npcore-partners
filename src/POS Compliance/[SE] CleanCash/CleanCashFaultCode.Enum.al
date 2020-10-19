enum 6014406 "NPR CleanCash Fault Code"
{
    Extensible = true;

    value(2; UnknownRequest)
    {
        Caption = 'Unknown request';
    }

    value(3; Invalid)
    {
        Caption = 'Invalid data or parameter';
    }

    value(6; NotOperational)
    {
        Caption = 'CleanCash unit not operational';
    }

    value(7; InvalidPosId)
    {
        Caption = 'Invalid POS Id';
    }

    value(8; InternalError)
    {
        Caption = 'CleanCash Internal Error';
    }

    value(9; LicenseExceeded)
    {
        Caption = 'License Exceeded';
    }

    value(10; MemoryFull)
    {
        Caption = 'Internal storage in CleanCash full';
    }

    value(98; ServerInternalError)
    {
        Caption = 'CleanCash server internal error';
    }

    value(99; CleanCashComError)
    {
        Caption = 'No connection with CleanCash unit';
    }
}