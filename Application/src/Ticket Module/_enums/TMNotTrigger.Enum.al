enum 6014477 "NPR TM Not. Trigger"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; NA)
    {
        Caption = 'Not Applicable';
    }
    value(1; ETICKET_UPDATE)
    {
        Caption = 'eTicket Update';
    }
    value(2; ETICKET_CREATE)
    {
        Caption = 'eTicket Create';
    }
    value(3; STAKEHOLDER)
    {
        Caption = 'Stakeholder';
    }
    value(4; WAITINGLIST)
    {
        Caption = 'Waiting List';
    }
    value(5; TICKETSERVER)
    {
        Caption = 'TicketServer';
    }
    value(6; REMINDER)
    {
        Caption = 'Reminder';
    }
}
