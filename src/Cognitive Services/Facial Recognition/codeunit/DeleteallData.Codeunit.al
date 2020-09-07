codeunit 6059925 "NPR Delete all Data"
{
    trigger OnRun()
    var
        FacialRecognition: Record "NPR Facial Recognition";
        Resp: HttpResponseMessage;
        PersonGroups: List of [text];
    begin
        FacialRecognition.DeleteAll();


        GetAllPersonGroups(Resp);
        ParseResponse(Resp, PersonGroups);
        if PersonGroups.Count > 0 then
            DeletePersons(PersonGroups);
    end;

    local procedure GetAllPersonGroups(var Resp: HttpResponseMessage)
    var
        FRSetup: Record "NPR Facial Recogn. Setup";
        Uri: Text;
        Req: HttpRequestMessage;
        ReqHdr: HttpHeaders;
        Client: HttpClient;
        RespHdr: HttpHeaders;
    begin
        if not FRSetup.FindFirst() then
            exit;

        Req.GetHeaders(ReqHdr);
        ReqHdr.Add('Ocp-Apim-Subscription-Key', FRSetup.APIKey);
        Req.Method('GET');

        Uri := FRSetup.BaseURL + FRSetup.PersonGroupURI;
        Client.SetBaseAddress(Uri);
        Client.Send(Req, Resp);

        RespHdr := Resp.Headers;
    end;

    local procedure ParseResponse(var Resp: HttpResponseMessage; var PersonGroups: List of [text])
    var
        RespContent: HttpContent;
        ResponseTxt: Text;
        JArray: JsonArray;
        JObject: JsonObject;
        JToken: JsonToken;
        i: Integer;
    begin
        if not Resp.IsSuccessStatusCode then
            Error(Resp.ReasonPhrase);

        RespContent := Resp.Content;
        RespContent.ReadAs(ResponseTxt);

        JArray.ReadFrom(ResponseTxt);

        for i := 0 to JArray.Count - 1 do begin
            if not JArray.Get(i, JToken) then
                exit;

            JObject := JToken.AsObject();
            if JObject.Get('personGroupId', JToken) then
                PersonGroups.Add(JToken.AsValue().AsText());
        end;
    end;

    local procedure DeletePersons(var PersonGroups: List of [text])
    var
        i: Integer;
        PersonGroupId: Text;
    begin
        for i := 1 to PersonGroups.Count do begin
            PersonGroups.Get(i, PersonGroupId);
            DeletePerson(PersonGroupId);
        end;
    end;

    local procedure DeletePerson(PersonGroupID: Text)
    var
        FRSetup: Record "NPR Facial Recogn. Setup";
        Uri: Text;
        Req: HttpRequestMessage;
        ReqHdr: HttpHeaders;
        Client: HttpClient;
        RespHdr: HttpHeaders;
        Resp: HttpResponseMessage;
    begin
        if not FRSetup.FindFirst() then
            exit;

        Req.GetHeaders(ReqHdr);
        ReqHdr.Add('Ocp-Apim-Subscription-Key', FRSetup.APIKey);
        Req.Method('DELETE');

        Uri := FRSetup.BaseURL + FRSetup.PersonGroupURI + PersonGroupID;
        Client.SetBaseAddress(Uri);
        Client.Send(Req, Resp);

        RespHdr := Resp.Headers;
        if Resp.IsSuccessStatusCode Then;
    end;
}