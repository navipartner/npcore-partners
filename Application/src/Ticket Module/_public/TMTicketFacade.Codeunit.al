codeunit 6248436 "NPR TM Ticket Facade"
{
    procedure GetTicketHolderFromNotificationAddress(NotificationAddress: Text[100]; var TicketHolder: Record "NPR TM TicketHolder")
    var
        NotifyParticipant: Codeunit "NPR TM Ticket Notify Particpt.";
    begin
        NotifyParticipant.GetTicketHolderFromNotificationAddress(NotificationAddress, TicketHolder);
    end;

    procedure SetTicketHolderInfo(var TicketHolder: Record "NPR TM TicketHolder")
    var
        NotifyParticipant: Codeunit "NPR TM Ticket Notify Particpt.";
    begin
        NotifyParticipant.SetTicketHolderInfo(TicketHolder);
    end;
}