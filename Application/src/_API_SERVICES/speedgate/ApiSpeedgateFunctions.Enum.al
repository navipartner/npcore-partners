#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
enum 6059826 "NPR ApiSpeedgateFunctions"
{
    Extensible = false;
    Access = Internal;
    value(0; NOOP)
    {
        Caption = 'No operation';
    }

    value(100; GET_SPEEDGATE_SETUP)
    {
        Caption = 'Get speedgate setup';
    }

    value(110; LOOKUP_REFERENCE_NUMBER)
    {
        Caption = 'Lookup reference number';
    }

    value(200; TRY_ADMIT)
    {
        Caption = 'Try admit';
    }

    value(210; ADMIT)
    {
        Caption = 'Admit';
    }

    value(220; MARK_AS_DENIED)
    {
        Caption = 'Mark as denied';
    }
}
#endif