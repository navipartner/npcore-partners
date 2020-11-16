codeunit 6059916 "NPR Create Person"
{
    var
        FacialRecognitionSetup: Record "NPR Facial Recogn. Setup";
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;

    procedure CreatePerson(var Contact: Record Contact; CalledFromSubscriber: Boolean)
    var
        JsonResponse: Text;
    begin
        FacialRecognitionSetup.FindFirst();

        if CheckIfPersonExists(Contact) then
            exit;

        CreateRequest(Contact);
        SendRequest();
        ParseResponse(JsonResponse, CalledFromSubscriber);
        SaveData(Contact, JsonResponse)
    end;

    local procedure CheckIfPersonExists(var Contact: Record Contact): Boolean
    var
        FacialRecognition: Record "NPR Facial Recognition";
        Req: HttpRequestMessage;
        Resp: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        ResponseHeaders: HttpHeaders;
        Uri: Text;
    begin
        FacialRecognition.SetRange("Contact No.", Contact."No.");
        if not FacialRecognition.FindFirst() then
            exit;

        Req.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Ocp-Apim-Subscription-Key', FacialRecognitionSetup.APIKey);
        Req.Method('GET');

        Uri := FacialRecognitionSetup.BaseURL + FacialRecognitionSetup.PersonGroupURI + LowerCase(Contact."Company No.") + FacialRecognitionSetup.PersonURI + FacialRecognition."Person ID";
        Client.SetBaseAddress(Uri);
        Client.Send(Req, Resp);

        ResponseHeaders := Resp.Headers;
        exit(Resp.IsSuccessStatusCode);
    end;

    local procedure CreateRequest(var Contact: Record Contact)
    var
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        RequestHeaders: HttpHeaders;
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
        InStr: InStream;
        GroupID: Text;
        PersonParameters: Text;
        TempFilename: Text;
        Uri: Text;
    begin
        Request.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Ocp-Apim-Subscription-Key', FacialRecognitionSetup.APIKey);
        Request.Method('POST');

        GroupID := LowerCase(Contact."Company No.");

        Uri := FacialRecognitionSetup.BaseURL + FacialRecognitionSetup.PersonGroupURI + GroupID + FacialRecognitionSetup.PersonURI;
        Request.SetRequestUri(Uri);

        RequestContent.GetHeaders(ContentHeader);
        ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'application/json');

        PersonParameters := '{' +
                            '"name":' +
                            StrSubstNo('"%1"', Contact."No.") +
                            ',' +
                            '"userData":' +
                            StrSubstNo('"%1"', Contact.Name) +
                            '}';

        TempFilename := FileMgt.CreateAndWriteToServerFile(PersonParameters, '.txt');
        FileMgt.BLOBImportFromServerFile(TempBlob, TempFilename);
        TempBlob.CreateInStream(InStr);

        RequestContent.WriteFrom(InStr);
        Request.Content := RequestContent;
        FileMgt.DeleteServerFile(TempFilename);
    end;

    local procedure SendRequest()
    begin
        Client.Send(Request, Response);
    end;

    local procedure ParseResponse(var JsonResponse: Text; CalledFromSubscriber: Boolean)
    var
        ResponseHeaders: HttpHeaders;
        ResponseContent: HttpContent;
    begin
        ResponseHeaders := Response.Headers;
        ResponseContent := Response.Content;

        if not Response.IsSuccessStatusCode then begin
            if not CalledFromSubscriber then
                Error(Response.ReasonPhrase);
            exit;
        end;

        ResponseContent.ReadAs(JsonResponse);
    end;

    local procedure SaveData(var Contact: Record Contact; var JsonResponse: Text)
    var
        FacialRecognition: Record "NPR Facial Recognition";
        FacialRecognition2: Record "NPR Facial Recognition";
        JObject: JsonObject;
        JToken: JsonToken;
        EntryNo: Integer;
    begin
        EntryNo := 1;
        if FacialRecognition2.FindLast() then
            EntryNo := FacialRecognition2."Entry No." + 1;

        with FacialRecognition do begin
            Init();
            "Entry No." := EntryNo;
            "Contact No." := Contact."No.";
            "Person Group" := Contact."Company No.";

            if not JObject.ReadFrom(JsonResponse) then
                exit;
            if not JObject.Get('personId', JToken) then
                exit;
            "Person ID" := JToken.AsValue().AsText();
            Insert();
        end;
    end;
}