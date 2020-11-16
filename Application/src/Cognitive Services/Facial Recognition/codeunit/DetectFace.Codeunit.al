codeunit 6059917 "NPR Detect Face"
{
    var
        FacialRecognitionSetup: Record "NPR Facial Recogn. Setup";
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;

    procedure DetectFace(var Contact: Record Contact; var ImageFilePath: Text; var EntryNo: Integer; CalledFromSubscriber: Boolean; CalledFrom: Option Contact,Member)
    var
        JsonResponse: Text;
    begin
        FacialRecognitionSetup.FindFirst();

        CreateRequest(Contact, ImageFilePath, CalledFromSubscriber, CalledFrom);
        if (ImageFilePath = '') or (ImageFilePath = 'false') then
            exit;

        SendRequest();
        if ParseResponse(JsonResponse) then
            SaveData(Contact, JsonResponse, EntryNo);
    end;

    local procedure CreateRequest(var Contact: Record Contact; var ImageFilePath: Text; CalledFromSubscriber: Boolean; CalledFrom: Option Contact,Member)
    var
        Member: Record "NPR MM Member";
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        RecRef: RecordRef;
        RequestHeader: HttpHeaders;
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
        PostParameters: Text;
        ImageInStream: InStream;
        OStream: OutStream;
        Uri: Text;
        FileExtension: Text;
        DotPosition: Integer;
        SelectImage: Label 'Select image';
    begin
        Request.GetHeaders(RequestHeader);
        RequestHeader.Add('Ocp-Apim-Subscription-Key', FacialRecognitionSetup.APIKey);

        Request.Method('POST');

        PostParameters := 'returnFaceId=true' +
                          '&returnFaceLandmarks=false' +
                          '&returnFaceAttributes=' +
                          'age,' +
                          'gender,' +
                          'headPose,' +
                          'smile,' +
                          'facialHair,' +
                          'glasses,' +
                          'emotion,' +
                          'hair,' +
                          'makeup,' +
                          'occlusion,' +
                          'accessories,' +
                          'blur,' +
                          'exposure,' +
                          'noise';

        Uri := FacialRecognitionSetup.BaseURL + FacialRecognitionSetup.DetectFaceURI + '?' + PostParameters;
        Request.SetRequestUri(Uri);

        RequestContent.GetHeaders(ContentHeader);
        ContentHeader.Clear();
        ContentHeader.Add('Content-Type', 'application/octet-stream');

        if not CalledFromSubscriber then begin
            ImageFilePath := FileMgt.UploadFile(SelectImage, '');

            DotPosition := StrPos(ImageFilePath, '.');
            FileExtension := CopyStr(ImageFilePath, DotPosition + 1);

            if (FileExtension <> 'png') and (FileExtension <> 'jpg') then begin
                if FileExtension <> '' then
                    ImageFilePath := 'WrongExtension';
                exit;
            end;

            FileMgt.BLOBImportFromServerFile(TempBlob, ImageFilePath);
        end
        else begin
            TempBlob.CreateOutStream(OStream);
            case CalledFrom of
                CalledFrom::Contact:
                    Contact.Image.ExportStream(OStream);
                CalledFrom::Member:
                    begin
                        Member.SetRange("Contact No.", Contact."No.");
                        if Member.FindFirst() then begin
                            Member.CalcFields(Picture);
                            RecRef.GetTable(Member);
                            TempBlob.FromFieldRef(RecRef.Field(Member.FieldNo(Picture)));
                        end;
                    end;
            end;
            ImageFilePath := FileMgt.ServerTempFileName('.jpg');
            FileMgt.BLOBExportToServerFile(TempBlob, ImageFilePath);
        end;
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
        ResponseHeader: HttpHeaders;
        ResponseContent: HttpContent;
    begin
        ResponseHeader := Response.Headers;
        ResponseContent := Response.Content;

        ResponseContent.ReadAs(JsonResponse);

        exit(Response.IsSuccessStatusCode);
    end;

    local procedure SaveData(var Contact: Record Contact; JsonResponse: Text; var EntryNo: Integer)
    var
        FacialRecognition: Record "NPR Facial Recognition";
        FacialRecognition2: Record "NPR Facial Recognition";
        NewFacialRecognition: Record "NPR Facial Recognition";
        JArray: JsonArray;
        JObject: JsonObject;
        JToken: JsonToken;
        JsonResponseTXT: text;
        InStr: InStream;
        OStr: OutStream;
    begin
        JArray.ReadFrom(JsonResponse);
        if not JArray.Get(0, JToken) then
            exit;

        JObject := JToken.AsObject();
        if JObject.Get('faceAttributes', JToken) then
            JObject := JToken.AsObject();

        FacialRecognition.SetRange("Contact No.", Contact."No.");
        if FacialRecognition.FindLast() then
            EntryNo := FacialRecognition."Entry No.";

        FacialRecognition.CalcFields("Json Response");
        FacialRecognition."Json Response".CreateInStream(InStr);
        InStr.ReadText(JsonResponseTXT);
        if JsonResponseTXT <> '' then begin
            EntryNo := 1;
            if FacialRecognition2.FindLast() then
                EntryNo := FacialRecognition2."Entry No." + 1;
            with NewFacialRecognition do begin
                Init();
                "Entry No." := EntryNo;
                "Contact No." := Contact."No.";
                "Person Group" := Contact."Company No.";
                "Person ID" := FacialRecognition."Person ID";
                Insert();
            end;
        end;
        if FacialRecognition.Get(EntryNo) then
            with FacialRecognition do begin
                FacialRecognition."Json Response".CreateOutStream(OStr);
                OStr.WriteText(JsonResponse);

                if JObject.Get('gender', JToken) then
                    Gender := JToken.AsValue().AsText();

                if JObject.Get('age', JToken) then
                    Age := JToken.AsValue().AsText();
                Modify();
            end;
    end;
}