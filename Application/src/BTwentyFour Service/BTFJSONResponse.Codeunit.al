codeunit 6014647 "NPR BTF JSON Response" implements "NPR BTF IFormatResponse"
{
    procedure FormatInternalError(ErrorCode: Text; ErrorDescription: Text; var Result: Codeunit "Temp Blob")
    var
        JObject: JsonObject;
        Json: Text;
        OutStr: OutStream;
    begin
        JObject.Add('error', ErrorCode);
        JObject.Add('error_description', ErrorDescription);
        JObject.WriteTo(Json);
        Result.CreateOutStream(OutStr);
        OutStr.WriteText(Json);
    end;

    procedure FoundErrorInResponse(Response: Codeunit "Temp Blob"): Boolean;
    var
        JObject: JsonObject;
        JToken: JsonToken;
        InStr: InStream;
        Json: Text;
    begin
        Response.CreateInStream(InStr);
        InStr.ReadText(Json);
        if not JObject.ReadFrom(Json) then
            exit(true);
        if (JObject.Contains('error') or JObject.Contains('Error')) then
            exit(true);
        if JObject.Contains('exceptionMessage') then
            exit(true);
        if JObject.Get('message', JTOken) then
            exit(JToken.IsObject());
        if JObject.Get('Message', JTOken) then
            exit(JToken.IsObject());
    end;

    procedure GetErrorDescription(Response: Codeunit "Temp Blob"): Text
    var
        JObject: JsonObject;
        JToken: JsonToken;
        InStr: InStream;
        Json: Text;
    begin
        Response.CreateInStream(InStr);
        InStr.ReadText(Json);
        if not JObject.ReadFrom(Json) then
            exit;
        if JObject.Get('error_description', JToken) then
            exit(JToken.AsValue().AsText());
        if JObject.Get('message', JToken) then
            exit(JToken.AsValue().AsText());
    end;

    [NonDebuggable]
    procedure GetToken(Response: Codeunit "Temp Blob"): Text
    var
        JObject: JsonObject;
        JToken: JsonToken;
        InStr: InStream;
        Json: Text;
    begin
        Response.CreateInStream(InStr);
        InStr.ReadText(Json);
        if not JObject.ReadFrom(Json) then
            exit;
        if not JObject.Get('access_token', JToken) then
            exit;
        exit(JToken.AsValue().AsText());
    end;

    [NonDebuggable]
    procedure FoundToken(Response: Codeunit "Temp Blob"): Boolean
    var
        JObject: JsonObject;
        JToken: JsonToken;
        InStr: InStream;
        Json: Text;
    begin
        Response.CreateInStream(InStr);
        InStr.ReadText(Json);
        if not JObject.ReadFrom(Json) then
            exit;
        exit(JObject.Contains('access_token'));
    end;

    procedure GetFileExtension(): Text
    begin
        exit('json');
    end;

    procedure GetResourcesUri(Content: Codeunit "Temp Blob"; var ResourcesUri: List of [Text]): Boolean
    var
        JObject: JsonObject;
        JToken: JsonToken;
        JArray: JsonArray;
        InStr: InStream;
        Json: Text;
        JPath: Text;
    begin
        clear(ResourcesUri);
        Content.CreateInStream(InStr);
        InStr.ReadText(Json);
        if not JObject.ReadFrom(Json) then
            exit;
        JPath := '$.messages.message';
        JObject.SelectToken(JPath, JToken);
        if not JToken.IsArray() then
            exit;
        JArray := JToken.AsArray();
        foreach JToken in JArray do begin
            JObject := JToken.AsObject();
            if JObject.Get('resourceUri', JToken) then begin
                ResourcesUri.Add(JToken.AsValue().AsText())
            end;
        end;
        exit(ResourcesUri.Count() <> 0);
    end;

    procedure GetDocument(Content: Codeunit "Temp Blob"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"): Boolean
    var
        JObject: JsonObject;
        JToken: JsonToken;
        JArray: JsonArray;
        InStr: InStream;
        Json: Text;
        JPath: Text;
        DocumentType: Text;
        LineParameter: Text;
    begin
        Content.CreateInStream(InStr);
        InStr.ReadText(Json);
        if not JObject.ReadFrom(Json) then
            exit;
        DocumentType := 'b24Order';
        JPath := '$.order.documentReference[?(@.documentType==''' + DocumentType + ''')].id';
        JObject.SelectToken(JPath, JToken);
        SalesHeader."No." := JToken.AsValue().AsText();

        JPath := '$.order.documentReference[?(@.documentType==''' + DocumentType + ''')].date';
        JObject.SelectToken(JPath, JToken);
        evaluate(SalesHeader."Posting Date", JToken.AsValue().AsText(), 9);

        DocumentType := 'BuyerOrder';
        JPath := '$.order.documentReference[?(@.documentType==''' + DocumentType + ''')].id';
        JObject.SelectToken(JPath, JToken);
        SalesHeader."External Document No." := JToken.AsValue().AsText();

        JPath := '$.order.buyer.gln';
        JObject.SelectToken(JPath, JToken);
        SalesHeader."Sell-to Customer No." := JToken.AsValue().AsText();

        JPath := '$.order.item';
        JObject.SelectToken(JPath, JToken);
        JArray := JToken.AsArray();
        foreach JToken in JArray do begin
            JObject := JToken.AsObject();
            SalesLine."Document No." := SalesHeader."No.";
            SalesLine."Line No." += 10000;
            SalesLine.Init();
            SalesLine.Type := SalesLine.Type::Item;
            JObject.Get('id', JToken);
            SalesLine."No." := JToken.AsValue().AsText();

            JObject.Get('quantity', JToken);
            evaluate(SalesLine.Quantity, JToken.AsValue().AsText(), 9);

            JObject.Get('deliveryDate', JToken);
            evaluate(SalesLine."Shipment Date", JToken.AsValue().AsText(), 9);

            LineParameter := 'unitOfMeasure';
            JPath := '$.order.item[?(@.id==''' + SalesLine."No." + ''')].property[?(@.name==''' + LineParameter + ''')].data';
            JObject.SelectToken(JPath, JToken);
            SalesLine."Unit of Measure Code" := JToken.AsValue().AsText();

            LineParameter := 'Supplier';
            JPath := '$.order.item[?(@.id==''' + SalesLine."No." + ''')].itemReference[?(@.registry==''' + LineParameter + ''')].data';
            JObject.SelectToken(JPath, JToken);
            SalesLine."Item Reference No." := JToken.AsValue().AsText();

            LineParameter := 'netPrice';
            JPath := '$.order.item[?(@.id==''' + SalesLine."No." + ''')].price[?(@.type==''' + LineParameter + ''')].value';
            JObject.SelectToken(JPath, JToken);
            evaluate(SalesLine."Unit Price", JToken.AsValue().AsText(), 9);

            SalesLine.Insert();
        end;
    end;
}