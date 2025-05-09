enum 6059890 "NPR TM AdmitTicketOnEoSMethod"
{
    Extensible = false;
#if not BC17
    Access = Internal;
#endif

    value(0; LEGACY)
    {
        Caption = 'Legacy';
    }
    value(10; WORKFLOW_LEGACY)
    {
        Caption = 'Workflow (Simple)';
    }
    value(20; WORKFLOW_SPEED_GATE)
    {
        Caption = 'Workflow (Speed Gate)';
    }
}