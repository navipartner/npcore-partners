#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not B
codeunit 6248470 "NPR TicketingImportAgent"
{

    Access = Internal;

    internal procedure ImportTickets(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        TicketImport: Codeunit "NPR TM ImportTicketControl";
        ImportLog: Record "NPR TM ImportTicketLog";

        ResponseMessage: Text;
        JobId: Code[40];
        JsonTicketBatch: JsonObject;
    begin
        if (not Request.BodyJson().IsObject()) then begin
            Response.RespondBadRequest('Invalid request body -The request body is empty or not valid JSON.');
            exit;
        end;

        JsonTicketBatch := Request.BodyJson().AsObject();
        TicketImport.ImportTicketFromJson(JsonTicketBatch, false, ResponseMessage, JobId);

        ImportLog.SetFilter(JobId, '=%1', JobId);
        Response.RespondOk(GetImportLog(ImportLog).Build());
    end;

    local procedure GetImportLog(var ImportLogWithFilter: Record "NPR TM ImportTicketLog") ResponseJson: Codeunit "NPR JSON Builder";
    var
        ImportLog: Record "NPR TM ImportTicketLog";
        ImportOrder: Record "NPR TM ImportTicketHeader";
    begin
        if (not ImportLogWithFilter.HasFilter()) then
            exit;

        ImportLog.CopyFilters(ImportLogWithFilter);
        if (ImportLog.FindSet()) then begin
            repeat
                ResponseJson
                    .AddProperty('id', Format(ImportLog.SystemId, 0, 4).ToLower())
                    .AddProperty('jobId', ImportLog.JobId)
                    .AddProperty('numberOfTickets', ImportLog.NumberOfTickets)
                    .AddProperty('success', ImportLog.Success)
                    .AddProperty('responseMessage', ImportLog.ResponseMessage)
                    .AddProperty('durationMs', ImportLog.ImportDuration)
                    .AddProperty('importedBy', ImportLog.ImportedBy);

                if (ImportLog.Success) then begin
                    ImportOrder.SetFilter(JobId, '=%1', ImportLog.JobId);
                    ImportOrder.FindSet();
                    ResponseJson.StartArray('orders');
                    repeat
                        ResponseJson
                            .StartObject()
                            .AddProperty('id', Format(ImportOrder.SystemId, 0, 4).ToLower())
                            .AddProperty('orderNumber', ImportOrder.OrderId)
                            .AddProperty('orderDate', ImportOrder.SalesDate)
                            .AddProperty('reservationToken', ImportOrder.TicketRequestToken)
                            .EndObject();
                    until (ImportOrder.Next() = 0);
                    ResponseJson.EndArray();
                end;
            until (ImportLog.Next() = 0);
        end;
    end;
}
#endif