codeunit 6059921 "NPR Scan Face"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Refractored to old code MCS Face Recognition';

    var
        FacialRecognitionSetup: Record "NPR Facial Recogn. Setup";
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;

    procedure ScanFace(var JsonResponse: Text)
    var
        IsError: Boolean;
        ErrorMessage: Text;
    begin
        FacialRecognitionSetup.Get();

        CreateRequest(IsError, ErrorMessage);
        if IsError then begin
            Message(ErrorMessage);
            exit;
        end;

        SendRequest();
        ParseResponse(JsonResponse);
    end;

    local procedure CreateRequest(var IsError: Boolean; var ErrorMessage: Text)
    var
        RequestHeader: HttpHeaders;
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
        PostParameters: Text;
        ImageInStream: InStream;
        Uri: Text;
        ImageMgt: Codeunit "NPR Face Image Mgt.";
    begin
        Request.GetHeaders(RequestHeader);
        RequestHeader.Add('Ocp-Apim-Subscription-Key', FacialRecognitionSetup.APIKey);

        Request.Method('POST');

        PostParameters := 'returnFaceId=true';

        Uri := FacialRecognitionSetup.BaseURL + FacialRecognitionSetup.DetectFaceURI + '?' + PostParameters;
        Request.SetRequestUri(Uri);

        RequestContent.GetHeaders(ContentHeader);
        ContentHeader.Clear();
        ContentHeader.Add('Content-Type', 'application/octet-stream');

        IsError := ImageMgt.UploadAndCheckImage(ImageInStream, ErrorMessage);
        if IsError then
            exit;

        RequestContent.WriteFrom(ImageInStream);
        Request.Content := RequestContent;
    end;

    local procedure SendRequest()
    begin
        Client.Send(Request, Response);
    end;

    local procedure ParseResponse(var JsonResponse: Text)
    var
        ResponseHeader: HttpHeaders;
        ResponseContent: HttpContent;
        JArray: JsonArray;
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        ResponseHeader := Response.Headers;
        ResponseContent := Response.Content;

        if not Response.IsSuccessStatusCode then
            exit;

        ResponseContent.ReadAs(JsonResponse);

        JArray.ReadFrom(JsonResponse);
        if not JArray.Get(0, JToken) then
            exit;
        JObject := JToken.AsObject();
        if JObject.Get('faceId', JToken) then
            JsonResponse := JToken.AsValue().AsText();
    end;
}