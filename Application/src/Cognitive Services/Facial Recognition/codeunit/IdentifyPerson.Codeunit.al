codeunit 6059920 "NPR Identify Person"
{
    var
        FacialRecognitionSetup: Record "NPR Facial Recogn. Setup";
        Response: HttpResponseMessage;
        ThisIs: Label 'This is: %1 (%2)';
        NotRecognised: Label 'Person isn''t recogised.';
        NoData: Label 'There''s no enough data for identification. \Please upload more pictures.';

    procedure IdentifyPersonFace(CalledFrom: Option Contact,Member)
    var
        FacialRecognition: Record "NPR Facial Recognition";
        FacialRecognitionScanFace: Codeunit "NPR Scan Face";
        Contact: Record Contact;
        Member: Record "NPR MM Member";
        JsonResponse: Text;
        FaceID: Text;
        PersonId: Text;
        GroupID: array[250] of Text;
        i: Integer;
        j: Integer;
        NoOfElements: Integer;
        NoOfGroups: Integer;
        Same: Boolean;
        Found: Boolean;
    begin
        FacialRecognitionSetup.FindFirst();

        if not FacialRecognition.FindSet() then begin
            Message(NoData);
            exit;
        end;

        FacialRecognitionScanFace.ScanFace(FaceID);
        if FaceID = '' then
            exit;

        NoOfElements := 0;
        repeat
            Same := false;
            for i := 1 to NoOfElements do begin
                if GroupID[i] = FacialRecognition."Person Group" then begin
                    Same := true;
                    break;
                end;
            end;
            if not Same then begin
                GroupID[NoOfElements + 1] := FacialRecognition."Person Group";
                NoOfElements += 1;
            end;
        until FacialRecognition.Next() = 0;

        for i := 1 to NoOfElements do begin
            CreateAndSendRequest(GroupID[i], FaceID);
            ParseResponse(Found, PersonId);

            if Found then begin
                case CalledFrom of
                    CalledFrom::Contact:
                        begin
                            FacialRecognition.SetRange("Person ID", PersonId);
                            if FacialRecognition.FindFirst() then
                                if Contact.Get(FacialRecognition."Contact No.") then
                                    Message(ThisIs, Contact.Name, Contact."No.");
                        end;
                    CalledFrom::Member:
                        begin
                            Member.SetRange("Contact No.", FacialRecognition."Contact No.");
                            if Member.FindFirst() then
                                Message(ThisIs, Member."Display Name", Member."External Member No.");
                        end;
                end;
                exit;
            end;

            if (i = NoOfElements) and not Found then
                Message(NotRecognised);
        end;
    end;

    local procedure CreateAndSendRequest(GroupID: Text; FaceID: Text)
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        RequestHeaders: HttpHeaders;
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
        PersonParameters: Text;
        TempFilename: Text;
        Uri: Text;
        InStr: InStream;
    begin
        Request.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Ocp-Apim-Subscription-Key', FacialRecognitionSetup.APIKey);
        Request.Method('POST');

        Uri := FacialRecognitionSetup.BaseURL + FacialRecognitionSetup.IdentifyPersonURI;
        Request.SetRequestUri(Uri);

        RequestContent.GetHeaders(ContentHeader);
        ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'application/json');

        PersonParameters := '{"faceIds":["' +
                            FaceID +
                            '"],"personGroupId":"' +
                            LowerCase(GroupID) +
                            '"}';

        TempFilename := FileMgt.CreateAndWriteToServerFile(PersonParameters, '.txt');
        FileMgt.BLOBImportFromServerFile(TempBlob, TempFilename);
        TempBlob.CreateInStream(InStr);

        RequestContent.WriteFrom(InStr);
        Request.Content := RequestContent;
        FileMgt.DeleteServerFile(TempFilename);

        Client.Send(Request, Response);
    end;

    local procedure ParseResponse(var Found: Boolean; var PersonId: Text)
    var
        ResponseHeaders: HttpHeaders;
        ResponseContent: HttpContent;
        JArray: JsonArray;
        JObject: JsonObject;
        JToken: JsonToken;
        JsonResponse: Text;
    begin
        ResponseHeaders := Response.Headers;
        ResponseContent := Response.Content;

        if not Response.IsSuccessStatusCode then
            exit;

        ResponseContent.ReadAs(JsonResponse);

        JArray.ReadFrom(JsonResponse);
        JArray.Get(0, JToken);
        JObject := JToken.AsObject();
        if JObject.Get('candidates', JToken) then
            JArray := JToken.AsArray();
        If not JArray.Get(0, JToken) then
            exit;
        JObject := JToken.AsObject();
        if JObject.Get('personId', JToken) then
            PersonId := JToken.AsValue().AsText();
        Found := true;
    end;
}