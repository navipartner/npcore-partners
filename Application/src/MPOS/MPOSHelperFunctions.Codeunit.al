codeunit 6059984 "NPR MPOS Helper Functions"
{
    Access = Internal;

    var
        ActiveSession: Record "Active Session";

    procedure GetUsername(): Text
    begin
        FindMySession();
        exit(ActiveSession."User ID");
    end;

    procedure GetDatabaseName(): Text
    begin
        FindMySession();
        exit(ActiveSession."Database Name")
    end;

    procedure GetTenantID(): Text
    begin
        exit(TenantId());
    end;

    local procedure FindMySession()
    begin
        if (ActiveSession."Server Instance ID" = ServiceInstanceId()) and
           (ActiveSession."Session ID" = SessionId()) then
            exit;

        SelectLatestVersion();

        ActiveSession.SetRange("Server Instance ID", ServiceInstanceId());
        ActiveSession.SetRange("Session ID", SessionId());
        if not ActiveSession.FindFirst() then begin
            Sleep(500);
            if not GuiAllowed then
                exit;
            ActiveSession.FindFirst();
        end;
    end;

    internal procedure BuildJSONParams(RequestMethod: Text;
                                       BaseAddress: Text;
                                       Endpoint: Text;
                                       PrintJob: Text;
                                       RequestType: Text;
                                       ErrorCaption: Text) JSON: JsonObject
    begin
        JSON.Add('RequestMethod', RequestMethod);
        JSON.Add('BaseAddress', BaseAddress);
        JSON.Add('Endpoint', Endpoint);
        JSON.Add('PrintJob', PrintJob);
        JSON.Add('RequestType', RequestType);
        JSON.Add('ErrorCaption', ErrorCaption);
    end;
}

