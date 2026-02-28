enum 6059890 "NPR TM AdmitTicketOnEoSMethod"
{
    Extensible = false;
#if not BC17
    Access = Internal;
#endif

    value(0; LEGACY)
    {
        Caption = 'Inline';
    }
    value(5; INLINE_SPEED_GATE)
    {
        Caption = 'Inline (Speed Gate)';
    }

    value(10; WORKFLOW_LEGACY)
    {
        Caption = 'Workflow';
    }
    value(20; WORKFLOW_SPEED_GATE)
    {
        Caption = 'Workflow (Speed Gate)';
    }
}