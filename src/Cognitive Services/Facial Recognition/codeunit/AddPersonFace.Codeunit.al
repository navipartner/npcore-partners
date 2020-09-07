codeunit 6059918 "NPR Add Person Face"
{
    var
        FacialRecognitionSetup: Record "NPR Facial Recogn. Setup";
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;

    procedure AddPersonFace(var Contact: Record Contact; var ImageFilePath: Text; var EntryNo: Integer) Imported: Boolean
    var
        JsonResponse: Text;
    begin
        FacialRecognitionSetup.FindFirst();

        CreateRequest(Contact, ImageFilePath);
        SendRequest();

        Imported := ParseResponse(JsonResponse);
        if Imported then
            SaveData(Contact, JsonResponse, EntryNo)
    end;

    local procedure CreateRequest(var Contact: Record Contact; var ImageFilePath: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        FacialRecognition: Record "NPR Facial Recognition";
        FileMgt: Codeunit "File Management";
        RequestHeaders: HttpHeaders;
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
        GroupID: Text;
        PersonID: Text;
        Uri: Text;
        ImageInStream: InStream;
    begin
        Request.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Ocp-Apim-Subscription-Key', FacialRecognitionSetup.APIKey);
        Request.Method('POST');

        GroupID := LowerCase(Contact."Company No.");

        FacialRecognition.SetRange("Contact No.", Contact."No.");
        if FacialRecognition.FindFirst() then
            PersonID := FacialRecognition."Person ID";

        Uri := FacialRecognitionSetup.BaseURL + FacialRecognitionSetup.PersonGroupURI + GroupID + FacialRecognitionSetup.PersonURI + PersonID + FacialRecognitionSetup.PersonFaceURI;
        Request.SetRequestUri(Uri);

        RequestContent.GetHeaders(ContentHeader);
        ContentHeader.Clear();
        ContentHeader.Add('Content-Type', 'application/octet-stream');

        FileMgt.BLOBImportFromServerFile(TempBlob, ImageFilePath);
        TempBlob.CreateInStream(ImageInStream);

        RequestContent.WriteFrom(ImageInStream);
        Request.Content := RequestContent;
    end;

    local procedure SendRequest()
    begin
        Client.Send(Request, Response);
    end;

    local procedure ParseResponse(var JsonResponse: Text): Boolean
    var
        ResponseHeaders: HttpHeaders;
        ResponseContent: HttpContent;
    begin
        ResponseHeaders := Response.Headers;
        ResponseContent := Response.Content;

        ResponseContent.ReadAs(JsonResponse);

        exit(Response.IsSuccessStatusCode);
    end;

    local procedure SaveData(var Contact: Record Contact; var JsonResponse: Text; var EntryNo: Integer)
    var
        FacialRecognition: Record "NPR Facial Recognition";
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        FacialRecognition.SetRange("Contact No.", Contact."No.");

        if FacialRecognition.Get(EntryNo) then begin
            if not JObject.ReadFrom(JsonResponse) then
                exit;
            if not JObject.Get('persistedFaceId', JToken) then
                exit;
            FacialRecognition."Face ID" := JToken.AsValue().AsText();
            FacialRecognition.Modify();
        end;
    end;
}