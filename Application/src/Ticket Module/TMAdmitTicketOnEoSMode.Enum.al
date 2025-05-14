enum 6059893 "NPR TM AdmitTicketOnEoSMode"
{
    Extensible = false;
#if not BC17
    Access = Internal;
#endif
    value(0; SALE)
    {
        Caption = 'Sale';
    }
    value(10; SCAN)
    {
        Caption = 'Scan';
    }
    value(20; NO_ADMIT_ON_EOS)
    {
        Caption = 'No Admit On End Of Sale';
    }
}