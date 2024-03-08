enum 6014647 "NPR TM TicketIdentifierType"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = true;

    // TicketIdentifierType: Option INTERNAL_TICKET_NO,EXTERNAL_TICKET_NO,PRINTED_TICKET_NO
    value(0; INTERNAL_TICKET_NO)
    {
        Caption = 'Internal Ticket No';
    }
    value(1; EXTERNAL_TICKET_NO)
    {
        Caption = 'External Ticket No';
    }
    value(2; PRINTED_TICKET_NO)
    {
        Caption = 'Printed Ticket No';
    }
    value(3; EXTERNAL_ORDER_REF)
    {
        Caption = 'External Order Reference';
    }
}

