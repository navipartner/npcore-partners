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
        ObsoleteState = Pending;
        ObsoleteTag = '2026-03-22';
        ObsoleteReason = 'Ticket admission on end of sale now runs inline. The post-workflow roundtrip has been removed for performance.';
    }
    value(20; WORKFLOW_SPEED_GATE)
    {
        Caption = 'Workflow (Speed Gate)';
        ObsoleteState = Pending;
        ObsoleteTag = '2026-03-22';
        ObsoleteReason = 'Ticket admission on end of sale now runs inline. The post-workflow roundtrip has been removed for performance.';
    }
}