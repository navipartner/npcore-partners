codeunit 6059921 "NPR Scan Face"
{
    var
        FacialRecognitionSetup: Record "NPR Facial Recogn. Setup";
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;

    procedure ScanFace(var JsonResponse: Text)
    var
        ImageFilePath: Text;
        ImgCantBeProcessed: Label 'Media not supported \ \Image can''t be processed. \Please use .jpg or .png images .';
    begin
        FacialRecognitionSetup.FindFirst();

        CreateRequest(ImageFilePath);
        case ImageFilePath of
            '':
                exit;
            'WrongExtension':
                begin
                    Message(ImgCantBeProcessed);
                    exit;
                end;
        end;

        SendRequest();
        ParseResponse(JsonResponse);
    end;

    local procedure CreateRequest(var ImageFilePath: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        RequestHeader: HttpHeaders;
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
        PostParameters: Text;
        ImageInStream: InStream;
        Uri: Text;
        FileExtension: Text;
        DotPosition: Integer;
        SelectImage: Label 'Select image';
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

        ImageFilePath := FileMgt.UploadFile(SelectImage, '');

        DotPosition := StrPos(ImageFilePath, '.');
        FileExtension := CopyStr(ImageFilePath, DotPosition + 1);

        if (FileExtension <> 'png') and (FileExtension <> 'jpg') then begin
            if FileExtension <> '' then
                ImageFilePath := 'WrongExtension';
            exit;
        end;

        FileMgt.BLOBImportFromServerFile(TempBlob, ImageFilePath);
        TempBlob.CreateInStream(ImageInStream);

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