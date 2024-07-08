codeunit 6060078 "NPR POS Dragonglass API"
{
    //This codeunit can be exposed as an unbound odata v4 codeunit to allow dragonglass to consume the same methods 
    //as the control addin exposes on the dragonglass page, but via HTTP from outside of BC instead of inside a BC iframe.                
    //
    //Advantages:
    //- No risk of exposing BC UI/standard ERP pages (relevant for some products such as selfservice POS)
    //- More "normal" web architecture with a frontend doing HTTP requests against a backend.
    //- Forces a stateless design in backend, which is usually also a simpler/easier to understand design.
    //- Load balanced across all webservice NSTs, no sticky sessions.
    //
    //Disadvantages:
    //- Cannot open BC pages, messages, strmenus
    //- Cannot use page background task to make async AL http requests in backend.
    //- Single instance codeunits are cleared between each HTTP request, so any POS action or functionality used must serialize to DB or
    //  return relevant data to client so the client can remember the state instead.    

    procedure InvokeMethod(method: Text; parameters: Text; lastServerId: Text) JsonResponse: Text
    var
        JavaScript: Codeunit "NPR POS JavaScript Interface";
        POSSession: Codeunit "NPR POS Session"; //This single instance codeunit is re-constructed every time we receive a new inbound HTTP request because odata sessions do not keep SingleInstance objects alive. All objects using it won't feel a difference.
        ContextJsonObject: JsonObject;
        POSUnitNo: Text;
        SalesTicketNo: Text;
        Response: JsonObject;
        POSAPIStackCheck: Codeunit "NPR POS API Stack Check";
    begin
        if ((lastServerId = '') or (lastServerId <> Format(ServiceInstanceId()))) then begin
            SelectLatestVersion(); //Unlike control addin requests, inbound webservice requests can be load balanced across multiple NSTs meaning the cache sync delay can lead to invisible records.
        end;

        if method = 'KeepAlive' then begin //every couple of minutes to prevent NST from shutting down idle POS sessions, is irrelevant here because we are using webservices.
            Response.Add('ServerID', Format(ServiceInstanceId()));
            Response.WriteTo(JsonResponse);
            exit;
        end;

        if method = 'FrameworkReady' then begin //once when POS frontend has loaded
            POSSession.ConstructFromWebserviceSession(true, '', '');
            if POSSession.GetErrorOnInitialize() then begin
                Error(GetLastErrorText());
            end;
            Response.Add('ServerID', Format(ServiceInstanceId()));
            Response.WriteTo(JsonResponse);
            exit;
        end;

        BindSubscription(POSAPIStackCheck);

        ContextJsonObject.ReadFrom(parameters);
        GetSaleKey(ContextJsonObject, POSUnitNo, SalesTicketNo);
        POSSession.ConstructFromWebserviceSession(false, POSUnitNo, SalesTicketNo);
        POSSession.DebugWithTimestamp('Method:' + method);

        JavaScript.InvokeMethod(method, ContextJsonObject, JavaScript);

        Response.Add('ServerID', Format(ServiceInstanceId()));
        Response.Add('Responses', POSSession.PopResponseQueue());
        Response.WriteTo(JsonResponse);
    end;

    local procedure GetSaleKey(Context: JsonObject; var POSUnitNoOut: Text; var SalesTicketNoOut: Text)
    var
        JToken: JsonToken;
        TempPOSSale: Record "NPR POS Sale" temporary;
        POSSaleRec: Record "NPR POS Sale";
        SaleSystemId: Guid;
    begin

        if (Context.SelectToken('context.parameters.saleSystemId', JToken)) then begin
            if (Evaluate(SaleSystemId, JToken.AsValue().AsText())) then
                if (not POSSaleRec.GetBySystemId(SaleSystemId)) then
                    exit;
            POSUnitNoOut := POSSaleRec."Register No.";
            SalesTicketNoOut := POSSaleRec."Sales Ticket No.";
            exit;
        end;

        if (Context.SelectToken('data.positions.BUILTIN_SALE', JToken)) then begin
            TempPOSSale.SetPosition(JToken.AsValue().AsText());
            POSUnitNoOut := TempPOSSale."Register No.";
            SalesTicketNoOut := TempPOSSale."Sales Ticket No.";
            exit;
        end;
    end;
}