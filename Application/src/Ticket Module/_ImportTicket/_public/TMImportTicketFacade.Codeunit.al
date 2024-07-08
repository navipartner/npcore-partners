codeunit 6184690 "NPR TM Import Ticket Facade"
{
    Access = Public;
    procedure ImportTicketsFromFile(Preview: Boolean) JobId: Code[40]
    var
        ImportTicket: Codeunit "NPR TM ImportTicketControl";
    begin
        exit(ImportTicket.ImportTicketsFromFile(Preview));
    end;

    procedure ImportTicketsFromJson(
        TicketJson: JsonObject;
        Preview: Boolean;
        var ResponseMessage: Text;
        var JobId: Code[40]) Imported: Boolean
    var
        ImportTicket: Codeunit "NPR TM ImportTicketControl";
    begin
        exit(ImportTicket.ImportTicketFromJson(TicketJson, Preview, ResponseMessage, JobId));
    end;

    [CommitBehavior(CommitBehavior::Error)]
    procedure ImportTicketsFromJson(TicketJson: JsonObject) JobId: Code[40]
    var
        ImportTicket: Codeunit "NPR TM ImportTicketControl";
    begin
        JobId := ImportTicket.ImportAndCreate(TicketJson);
    end;


}