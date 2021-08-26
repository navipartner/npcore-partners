codeunit 6059955 "NPR MCS Face Service API"
{
    var
        PersonGroupURI: label '/persongroups/', Locked = true;
        PersonURI: label '/persons/', Locked = true;
        TrainPersonGroupURI: label '/train/', Locked = true;
        CheckTrainingURI: label '/training/', Locked = true;
        IdentifyPersonURI: label '/identify/', Locked = true;
        PersonFaceURI: label '/persistedFaces/', Locked = true;
        DetectFaceURI: label '/detect/', Locked = true;

    procedure GetPersonGroups()
    var
        MCSAPISetup: Record "NPR MCS API Setup";
        PersonGroups: Record "NPR MCS Person Groups";
        HttpCont: HttpContent;
        HttpRespMessage: HttpResponseMessage;
        Counter: Integer;
        JsonArr: JsonArray;
        JsonObj: JsonObject;
        JsonTok: JsonToken;
        JsonTokValue: JsonToken;
        BaseUrl: Text;
        JsonResponse: Text;
        Uri: Text;
    begin
        GetFacesSetup(MCSAPISetup);
        BaseUrl := MCSAPISetup.GetBaseUrl();

        Uri := BaseUrl + PersonGroupURI;

        SendHttpRequest(HttpRespMessage, HttpCont, Uri, 'GET');

        HttpCont := HttpRespMessage.Content;
        HttpCont.ReadAs(JsonResponse);

        JsonArr.ReadFrom(JsonResponse);

        Counter := 10000;
        PersonGroups.DeleteAll();
        foreach JsonTok in JsonArr do begin
            JsonObj := JsonTok.AsObject();
            JsonObj.Get('personGroupId', JsonTokValue);
            PersonGroups.Init();
            PersonGroups.Id := Counter;
            PersonGroups.PersonGroupId := CopyStr(JsonTokValue.AsValue().AsText(), 1, MaxStrLen(PersonGroups.PersonGroupId));
            JsonObj.Get('name', JsonTokValue);
            PersonGroups.Name := CopyStr(JsonTokValue.AsValue().AsText(), 1, MaxStrLen(PersonGroups.Name));
            PersonGroups.Insert();
            Counter += 10000;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR MCS Person Groups", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeletePersonGroup(var Rec: Record "NPR MCS Person Groups"; RunTrigger: Boolean)
    var
        RecRef: RecordRef;
        MCSAPISetup: Record "NPR MCS API Setup";
        HttpRespMessage: HttpResponseMessage;
        Uri: Text;
        BaseUrl: Text;
        HttpCont: HttpContent;
    begin
        if not RunTrigger then
            exit;

        RecRef.GetTable(Rec);
        if RecRef.IsTemporary then
            exit;

        if (Rec.PersonGroupId <> '') then begin
            GetFacesSetup(MCSAPISetup);

            BaseUrl := MCSAPISetup.GetBaseUrl();
            Uri := BaseUrl + PersonGroupURI + Rec.PersonGroupId;
            SendHttpRequest(HttpRespMessage, HttpCont, Uri, 'DELETE');
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR MCS Person Groups", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertPersonGroup(var Rec: Record "NPR MCS Person Groups"; RunTrigger: Boolean)
    var
        JsonObj: JsonObject;
        HttpCont: HttpContent;
        ReqMsgInStr: InStream;
        ReqMsgOutStr: OutStream;
        ReqMsg: Text;
        MCSAPISetup: Record "NPR MCS API Setup";
        Uri: Text;
        BaseUrl: Text;
        HttpRespMessage: HttpResponseMessage;
        TempBlob: Codeunit "Temp Blob";
    begin
        if not RunTrigger then
            exit;

        if Rec.IsTemporary then
            exit;
        Rec.PersonGroupId := CopyStr(LowerCase(CreateGuid()), 1, MaxStrLen(Rec.PersonGroupId));
        Rec.PersonGroupId := CopyStr(CopyStr(Rec.PersonGroupId, 2, StrLen(Rec.PersonGroupId) - 2), 1, MaxStrLen(Rec.PersonGroupId));
        Rec.Modify(true);

        JsonObj.Add('name', Rec.Name);
        JsonObj.WriteTo(ReqMsg);

        TempBlob.CreateInStream(ReqMsgInStr);
        TempBlob.CreateOutStream(ReqMsgOutStr);
        ReqMsgOutStr.Write(ReqMsg);

        CreateHttpContent(HttpCont, 'application/json', ReqMsgInStr);

        GetFacesSetup(MCSAPISetup);
        BaseUrl := MCSAPISetup.GetBaseUrl();

        Uri := BaseURL + PersonGroupURI + Rec.PersonGroupId;

        SendHttpRequest(HttpRespMessage, HttpCont, Uri, 'PUT');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR MCS Person", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeletePerson(var Rec: Record "NPR MCS Person"; RunTrigger: Boolean)
    var
        RecRef: RecordRef;
        MCSFaces: Record "NPR MCS Faces";
        MCSPersonBusinessEntities: Record "NPR MCS Person Bus. Entit.";
        MCSAPISetup: Record "NPR MCS API Setup";
        Uri: Text;
        BaseUrl: Text;
        HttpCont: HttpContent;
        HttpRespMessage: HttpResponseMessage;
    begin
        if not RunTrigger then
            exit;

        RecRef.GetTable(Rec);
        if RecRef.IsTemporary then
            exit;

        if (Rec.PersonGroupId <> '') and (Rec.PersonId <> '') then begin
            GetFacesSetup(MCSAPISetup);
            BaseUrl := MCSAPISetup.GetBaseUrl();
            Uri := BaseUrl + PersonGroupURI + Rec.PersonGroupId + PersonURI + Rec.PersonId;
            SendHttpRequest(HttpRespMessage, HttpCont, Uri, 'DELETE');
        end;

        MCSFaces.Reset();
        MCSFaces.SetRange(PersonId, Rec.PersonId);
        MCSFaces.DeleteAll(true);
        MCSPersonBusinessEntities.Reset();
        MCSPersonBusinessEntities.SetCurrentKey(Key);
        MCSPersonBusinessEntities.SetRange(Key, Rec.RecordId);
        MCSPersonBusinessEntities.DeleteAll(true);
    end;

    procedure CreatePersonBusinessEntity(Origin: RecordID; NewRecordID: RecordID)
    var
        NewMCSPersonBusinessEntities: Record "NPR MCS Person Bus. Entit.";
        RecRef: RecordRef;
        MCSPersonBusinessEntities: Record "NPR MCS Person Bus. Entit.";
    begin
        MCSPersonBusinessEntities.Reset();
        MCSPersonBusinessEntities.SetCurrentKey(Key);
        MCSPersonBusinessEntities.SetRange(Key, NewRecordID);
        if MCSPersonBusinessEntities.FindSet() then
            exit;

        MCSPersonBusinessEntities.Reset();
        MCSPersonBusinessEntities.SetCurrentKey(Key);
        MCSPersonBusinessEntities.SetRange(Key, Origin);
        if MCSPersonBusinessEntities.FindSet() then begin
            RecRef.Get(NewRecordID);
            NewMCSPersonBusinessEntities.Init();
            NewMCSPersonBusinessEntities.PersonId := MCSPersonBusinessEntities.PersonId;
            NewMCSPersonBusinessEntities."Table Id" := RecRef.Number;
            NewMCSPersonBusinessEntities.Key := NewRecordID;
            NewMCSPersonBusinessEntities.Insert(true);
        end;
    end;

    procedure UpdatePersonInfo(MCSPerson: Record "NPR MCS Person")
    begin
        UpdatePerson(MCSPerson.PersonGroupId, MCSPerson.PersonId, MCSPerson.Name, MCSPerson.UserData);
    end;

    procedure ImportMemberPicture(var MMMember: Record "NPR MM Member")
    var
        RecRef: RecordRef;
        MemberName: Text;
        ImageInStream: InStream;
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
    begin
        RecRef.Get(MMMember.RecordId);

        UploadAndCheckImage(ImageInStream);

        MemberName := MMMember."First Name";
        if MMMember."Middle Name" <> '' then
            MemberName := MemberName + ' ' + MMMember."Middle Name";
        if MMMember."Last Name" <> '' then
            MemberName := MemberName + ' ' + MMMember."Last Name";

        DetectIdentifyPicture(RecRef, MemberName, ImageInStream);
        // RecRef.SetTable(MMMember);
        // MMMember.Image.ImportStream(ImageInStream, MMMember.FieldName(Image));
        // MMMember.Modify();
        TempBlob.CreateOutStream(OutStr);
        CopyStream(OutStr, ImageInStream);
        TempBlob.ToRecordRef(RecRef, MMMember.FieldNo(Picture));

        RecRef.Modify();
    end;

    procedure DetectIdentifyPicture(var RecRef: RecordRef; PersonName: Text; ImageInStream: InStream)
    var
        PersonGroups: Record "NPR MCS Person Groups";
        MCSPersonBusinessEntities: Record "NPR MCS Person Bus. Entit.";
        MCSAPISetup: Record "NPR MCS API Setup";
        MCSPersonGroupsSetup: Record "NPR MCS Person Groups Setup";
        MCSPerson: Record "NPR MCS Person";
        MCSFaces: Record "NPR MCS Faces";
        UserData: Text;
        PersonId: Text;
        PersonIdentified: Boolean;
        BaseUrl: Text;
        JsonFacesArr: JsonArray;
        JsonIdArr: JsonArray;
        JsonTok: JsonToken;
        JsonTokValue: JsonToken;
        JsonObj: JsonObject;
        FaceId: Text;
        SkipIdentify: Boolean;
    begin
        if ImageInStream.EOS then
            exit;
        if not MCSAPISetup.Get(MCSAPISetup.API::Face) then
            exit;

        GetFacesSetup(MCSAPISetup);
        BaseUrl := MCSAPISetup.GetBaseUrl();

        MCSPersonGroupsSetup.Get(RecRef.Number);
        PersonGroups.Get(MCSPersonGroupsSetup."Person Groups Id");
        PersonGroups.TestField(PersonGroupId);

        SkipIdentify := CheckTrainGroup(PersonGroups.PersonGroupId);

        UserData := Format(CurrentDateTime);

        DetectFaces(ImageInStream, JsonFacesArr);
        if not SkipIdentify then
            IdentifyFace(PersonGroups.PersonGroupId, JsonFacesArr, JsonIdArr);

        foreach JsonTok in JsonFacesArr do begin
            JsonObj := JsonTok.AsObject();
            JsonObj.Get('faceId', JsonTokValue);
            FaceId := JsonTokValue.AsValue().AsText();
            PersonId := IsPersonIdentified(FaceId, JsonIdArr);
            PersonIdentified := PersonId <> '';

            if PersonId = '' then
                PersonId := CreatePerson(PersonGroups.PersonGroupId, PersonName, UserData);
            AddPersonFace(PersonGroups.PersonGroupId, PersonId, ImageInStream);

            JsonObj.Get('faceRectangle', JsonTokValue);
            InitFace(MCSFaces, PersonId, FaceId, PersonIdentified, JsonTokValue.AsObject());

            JsonObj.Get('faceAttributes', JsonTokValue);
            AddFaceAttributes(MCSFaces, JsonTokValue.AsObject());

            MCSFaces.Insert(true);

            if not MCSPerson.Get(MCSFaces.PersonId) then begin
                MCSPerson.Init();
                MCSPerson.PersonId := MCSFaces.PersonId;
                MCSPerson.PersonGroupId := PersonGroups.PersonGroupId;
                MCSPerson.Name := CopyStr(PersonName, 1, MaxStrLen(MCSPerson.Name));
                MCSPerson.UserData := CopyStr(UserData, 1, MaxStrLen(MCSPerson.UserData));
                if MCSPerson.Insert(true) then begin
                    MCSPersonBusinessEntities.Init();
                    MCSPersonBusinessEntities.PersonId := MCSPerson.PersonId;
                    MCSPersonBusinessEntities."Table Id" := RecRef.Number;
                    MCSPersonBusinessEntities.Key := RecRef.RecordId;
                    MCSPersonBusinessEntities.Insert(true);
                end;
            end else begin
                if not MCSPersonBusinessEntities.Get(MCSPerson.PersonId, RecRef.Number) then begin
                    MCSPersonBusinessEntities.Init();
                    MCSPersonBusinessEntities.PersonId := MCSPerson.PersonId;
                    MCSPersonBusinessEntities."Table Id" := RecRef.Number;
                    MCSPersonBusinessEntities.Key := RecRef.RecordId;
                    MCSPersonBusinessEntities.Insert(true);
                end;
            end;
        end;
        TrainGroup(PersonGroups.PersonGroupId);
    end;

    local procedure InitFace(var MCSFaces: Record "NPR MCS Faces"; PersonId: Text; FaceID: Text; FaceIdentified: Boolean; FaceRectJsonObj: JsonObject)
    var
        JsonTokValue: JsonToken;
    begin
        MCSFaces.Init();
        MCSFaces.FaceId := CopyStr(FaceID, 1, MaxStrLen(MCSFaces.FaceId));
        MCSFaces.PersonId := CopyStr(PersonId, 1, MaxStrLen(MCSFaces.PersonId));

        MCSFaces.Identified := FaceIdentified;

        MCSFaces.Created := CurrentDateTime;

        FaceRectJsonObj.Get('height', JsonTokValue);
        MCSFaces."Face Height" := JsonTokValue.AsValue().AsDecimal();

        FaceRectJsonObj.Get('left', JsonTokValue);
        MCSFaces."Face Position X" := JsonTokValue.AsValue().AsDecimal();

        FaceRectJsonObj.Get('top', JsonTokValue);
        MCSFaces."Face Position Y" := JsonTokValue.AsValue().AsDecimal();

        FaceRectJsonObj.Get('width', JsonTokValue);
        MCSFaces."Face Width" := JsonTokValue.AsValue().AsDecimal();

        MCSFaces.Action := MCSFaces.Action::CaptureAndIdentifyFaces;
    end;

    local procedure AddFaceAttributes(var MCSFaces: Record "NPR MCS Faces"; FaceAttrJsonObj: JsonObject)
    var

        JsonTokValue: JsonToken;
        JsonObj: JsonObject;
    begin
        FaceAttrJsonObj.Get('age', JsonTokValue);
        MCSFaces.Age := JsonTokValue.AsValue().AsDecimal();

        FaceAttrJsonObj.Get('gender', JsonTokValue);
        MCSFaces.Gender := CopyStr(JsonTokValue.AsValue().AsText(), 1, MaxStrLen(MCSFaces.Gender));

        FaceAttrJsonObj.Get('smile', JsonTokValue);
        MCSFaces.IsSmiling := JsonTokValue.AsValue().AsDecimal() > 0.5;

        FaceAttrJsonObj.Get('facialHair', JsonTokValue);
        JsonObj := JsonTokValue.AsObject();

        JsonObj.Get('moustache', JsonTokValue);
        MCSFaces.Moustache := JsonTokValue.AsValue().AsDecimal();

        JsonObj.Get('beard', JsonTokValue);
        MCSFaces.Beard := JsonTokValue.AsValue().AsDecimal();

        JsonObj.Get('sideburns', JsonTokValue);
        MCSFaces.Sideburns := JsonTokValue.AsValue().AsDecimal();

        FaceAttrJsonObj.Get('glasses', JsonTokValue);
        MCSFaces.Glasses := CopyStr(JsonTokValue.AsValue().AsText(), 1, MaxStrLen(MCSFaces.Glasses));
    end;

    local procedure IsPersonIdentified(FaceID: Text; IdentifyJsonArray: JsonArray) PersonId: Text
    var
        JsonTok: JsonToken;
        JsonTokValue: JsonToken;
        JsonObj: JsonObject;
        JsonArr: JsonArray;
    begin
        foreach JsonTok in IdentifyJsonArray do begin
            JsonObj := JsonTok.AsObject();
            JsonObj.Get('faceId', JsonTokValue);
            if faceID = JsonTokValue.AsValue().AsText() then begin
                JsonObj.Get('candidates', JsonTokValue);
                JsonArr := JsonTokValue.AsArray();
                foreach JsonTokValue in JsonArr do begin
                    JsonObj := JsonTokValue.AsObject();
                    JsonObj.Get('personId', JsonTokValue);
                    PersonId := JsonTokValue.AsValue().AsText();
                    exit;
                end;
            end;
        end;
    end;

    local procedure CreatePerson(GroupID: Text; PersonName: Text; UserData: Text) PersonId: Text;
    var
        MCSAPISetup: Record "NPR MCS API Setup";
        Uri: Text;
        BaseUrl: Text;
        JsonObj: JsonObject;
        ReqMsgInStr: InStream;
        ReqMsgOutStr: OutStream;
        ReqMsg: Text;
        TempBlob: Codeunit "Temp Blob";
        HttpCont: HttpContent;
        HttpRespMessage: HttpResponseMessage;
        JsonResponse: Text;
        JsonTok: JsonToken;
    begin
        GetFacesSetup(MCSAPISetup);

        BaseUrl := MCSAPISetup.GetBaseUrl();

        Uri := BaseURL + PersonGroupURI + GroupID + PersonURI;

        JsonObj.Add('name', PersonName);
        JsonObj.Add('userData', UserData);
        JsonObj.WriteTo(ReqMsg);

        TempBlob.CreateInStream(ReqMsgInStr);
        TempBlob.CreateOutStream(ReqMsgOutStr);
        ReqMsgOutStr.Write(ReqMsg);
        CreateHttpContent(HttpCont, 'application/json', ReqMsgInStr);

        SendHttpRequest(HttpRespMessage, HttpCont, Uri, 'POST');

        HttpCont := HttpRespMessage.Content;
        HttpCont.ReadAs(JsonResponse);

        JsonObj.ReadFrom(JsonResponse);
        JsonObj.Get('personId', JsonTok);
        PersonId := JsonTok.AsValue().AsText();
    end;

    local procedure UpdatePerson(GroupID: Text; PersonId: Text; PersonName: Text; UserData: Text)
    var
        MCSAPISetup: Record "NPR MCS API Setup";
        Uri: Text;
        BaseUrl: Text;
        JsonObj: JsonObject;
        ReqMsgInStr: InStream;
        ReqMsgOutStr: OutStream;
        ReqMsg: Text;
        TempBlob: Codeunit "Temp Blob";
        HttpCont: HttpContent;
        HttpRespMessage: HttpResponseMessage;
    begin
        GetFacesSetup(MCSAPISetup);
        BaseUrl := MCSAPISetup.GetBaseUrl();

        Uri := BaseURL + PersonGroupURI + GroupID + PersonURI + PersonId;

        JsonObj.Add('name', PersonName);
        JsonObj.Add('userData', UserData);
        JsonObj.WriteTo(ReqMsg);

        TempBlob.CreateInStream(ReqMsgInStr);
        TempBlob.CreateOutStream(ReqMsgOutStr);
        ReqMsgOutStr.Write(ReqMsg);
        CreateHttpContent(HttpCont, 'application/json', ReqMsgInStr);

        SendHttpRequest(HttpRespMessage, HttpCont, Uri, 'PATCH');
    end;

    local procedure TrainGroup(GroupID: Text)
    var
        MCSAPISetup: Record "NPR MCS API Setup";
        Uri: Text;
        BaseUrl: Text;
        HttpCont: HttpContent;
        HttpRespMessage: HttpResponseMessage;
    begin
        GetFacesSetup(MCSAPISetup);
        BaseUrl := MCSAPISetup.GetBaseUrl();

        Uri := BaseURL + PersonGroupURI + GroupID + TrainPersonGroupURI;
        SendHttpRequest(HttpRespMessage, HttpCont, Uri, 'POST');
    end;

    local procedure CheckTrainGroup(GroupID: Text): Boolean
    var
        MCSAPISetup: Record "NPR MCS API Setup";
        Uri: Text;
        BaseUrl: Text;
        HttpCont: HttpContent;
        HttpRespMessage: HttpResponseMessage;
        JsonResponse: Text;
        JsonObj: JsonObject;
        JsonTok: JsonToken;
        GroupTrainingStatusErr: Label 'Current group training status is %1. Please try again later or contact your administrator.', Comment = '%1 - Returned API status';
    begin
        GetFacesSetup(MCSAPISetup);
        BaseUrl := MCSAPISetup.GetBaseUrl();

        Uri := BaseURL + PersonGroupURI + GroupID + CheckTrainingURI;
        SendHttpRequest(HttpRespMessage, HttpCont, Uri, 'GET');

        HttpCont := HttpRespMessage.Content;
        HttpCont.ReadAs(JsonResponse);

        JsonObj.ReadFrom(JsonResponse);
        JsonObj.Get('status', JsonTok);

        case JsonTok.AsValue().AsText() of
            'succeeded':
                exit(false);
            'notstarted':
                begin
                    exit(true);
                end;
            'running':
                begin
                    Error(GroupTrainingStatusErr, JsonTok.AsValue().AsText());
                end;
            else
                exit(true);
        end;
    end;

    procedure IdentifyFace(GroupID: Text; FacesJsonArray: JsonArray; var IdentifyJsonArray: JsonArray)
    var
        MCSAPISetup: Record "NPR MCS API Setup";
        Uri: Text;
        BaseUrl: Text;
        JsonObj: JsonObject;
        JsonFacesIdsArr: JsonArray;
        JsonTok: JsonToken;
        JsonTokValue: JsonToken;
        HttpCont: HttpContent;
        ReqMsgInStr: InStream;
        ReqMsgOutStr: OutStream;
        ReqMsg: Text;
        TempBlob: Codeunit "Temp Blob";
        HttpRespMessage: HttpResponseMessage;
        JsonResponse: Text;
    begin
        GetFacesSetup(MCSAPISetup);
        BaseUrl := MCSAPISetup.GetBaseUrl();

        foreach JsonTok in FacesJsonArray do begin
            JsonObj := JsonTok.AsObject();
            JsonObj.Get('faceId', JsonTokValue);
            JsonFacesIdsArr.Add(JsonTokValue.AsValue().AsText());
        end;
        Clear(JsonObj);

        JsonObj.Add('faceIds', JsonFacesIdsArr);
        JsonObj.Add('personGroupId', GroupID);
        JsonObj.Add('maxNumOfCandidatesReturned', 1);
        JsonObj.Add('confidenceThreshold', 0.5);

        Uri := BaseUrl + IdentifyPersonURI;

        JsonObj.WriteTo(ReqMsg);

        TempBlob.CreateInStream(ReqMsgInStr);
        TempBlob.CreateOutStream(ReqMsgOutStr);
        ReqMsgOutStr.Write(ReqMsg);

        CreateHttpContent(HttpCont, 'application/json', ReqMsgInStr);

        SendHttpRequest(HttpRespMessage, HttpCont, Uri, 'POST');

        HttpCont := HttpRespMessage.Content;
        HttpCont.ReadAs(JsonResponse);

        IdentifyJsonArray.ReadFrom(JsonResponse);
    end;

    local procedure AddPersonFace(GroupID: Text; PersonId: Text; ImageInStream: InStream) PersistedFaceId: Text
    var
        MCSAPISetup: Record "NPR MCS API Setup";
        Uri: Text;
        BaseUrl: Text;
        HttpCont: HttpContent;
        HttpRespMessage: HttpResponseMessage;
        JsonResponse: Text;
        JsonObj: JsonObject;
        JsonTok: JsonToken;
    begin
        GetFacesSetup(MCSAPISetup);
        BaseUrl := MCSAPISetup.GetBaseUrl();
        Uri := BaseUrl + PersonGroupURI + GroupID + PersonURI + PersonID + PersonFaceURI;

        CreateHttpContent(HttpCont, 'application/octet-stream', ImageInStream);

        SendHttpRequest(HttpRespMessage, HttpCont, Uri, 'POST');

        HttpCont := HttpRespMessage.Content;
        HttpCont.ReadAs(JsonResponse);

        JsonObj.ReadFrom(JsonResponse);
        JsonObj.Get('persistedFaceId', JsonTok);
        PersistedFaceId := JsonTok.AsValue().AsText();
    end;

    procedure DetectFaces(ImageInStream: InStream; var FacesJsonArray: JsonArray)
    var
        MCSAPISetup: Record "NPR MCS API Setup";
        Uri: Text;
        BaseUrl: Text;
        HttpCont: HttpContent;
        HttpRespMessage: HttpResponseMessage;
        PostParameters: Text;
        JsonResponse: Text;
    begin
        GetFacesSetup(MCSAPISetup);

        BaseUrl := MCSAPISetup.GetBaseUrl();

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

        Uri := BaseUrl + DetectFaceURI + '?' + PostParameters;

        CreateHttpContent(HttpCont, 'application/octet-stream', ImageInStream);

        SendHttpRequest(HttpRespMessage, HttpCont, Uri, 'POST');

        HttpCont := HttpRespMessage.Content;
        HttpCont.ReadAs(JsonResponse);

        FacesJsonArray.ReadFrom(JsonResponse);
    end;

    procedure UploadAndCheckImage(var ImageInStream: InStream)
    var
        FileExtension: Text;
#if BC17
        ReturnedFilePath: Text;
        SelectImage: Label 'Select image';
#endif
        ImageFileFilter: Label 'Image Files (*.gif;*.png;*.jpg;*.jpeg;*.bmp)|*.gif;*.png;*.jpg;*.jpeg;*.bmp';
        ImageHelpers: Codeunit "Image Helpers";
        ImgCantBeProcessed: Label 'Media not supported \ \Image can''t be processed. \Please use .gif .png .jpg .jpeg or .bmp images .';
    begin
#if BC17
        if not UploadIntoStream(SelectImage, '', ImageFileFilter, ReturnedFilePath, ImageInStream) then
#else
        if not UploadIntoStream(ImageFileFilter, ImageInStream) then
#endif
            Error('');

        FileExtension := ImageHelpers.GetImageType(ImageInStream);

        if not (LowerCase(FileExtension) in ['gif', 'jpg', 'jpeg', 'png', 'bmp']) then
            Error(ImgCantBeProcessed);
    end;

    [TryFunction]
    local procedure GetFacesSetup(var MCSAPISetup: Record "NPR MCS API Setup")
    var
        BaseUriMissingErr: Label '%1 is missing for %2 %3 setup';
    begin
        MCSAPISetup.Get(MCSAPISetup.API::Face);
        if not MCSAPISetup.BaseURL.HasValue() then
            Error(BaseUriMissingErr, MCSAPISetup.FieldCaption(BaseURL), MCSAPISetup.TableCaption, MCSAPISetup.API);
        MCSAPISetup.TestField("Key 1");
    end;

    local procedure SendHttpRequest(var HttpRespMessage: HttpResponseMessage; HttpCont: HttpContent; Uri: Text; Method: Text)
    var
        MCSAPISetup: Record "NPR MCS API Setup";
        RequestHeaders: HttpHeaders;
        HttpReqMessage: HttpRequestMessage;
        HttpClnt: HttpClient;
        Content: Text;
    begin
        GetFacesSetup(MCSAPISetup);
        HttpReqMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Ocp-Apim-Subscription-Key', MCSAPISetup.GetAPIKey1());
        HttpReqMessage.Method(Method);
        HttpCont.ReadAs(Content);
        if Content <> '' then
            HttpReqMessage.Content := HttpCont;
        HttpClnt.SetBaseAddress(Uri);
        HttpClnt.Send(HttpReqMessage, HttpRespMessage);
        ParseHttpError(HttpRespMessage);
    end;

    local procedure CreateHttpContent(var HttpCont: HttpContent; ContentType: Text; InStr: InStream)
    var
        ContentHeaders: HttpHeaders;
    begin
        HttpCont.WriteFrom(InStr);
        HttpCont.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', ContentType);
    end;

    local procedure ParseHttpError(HttpRespMessage: HttpResponseMessage)
    var
        JsonObj: JsonObject;
        JsonTok: JsonToken;
        JsonResponse: Text;
        HttpCont: HttpContent;
    begin
        HttpCont := HttpRespMessage.Content;
        HttpCont.ReadAs(JsonResponse);
        if not JsonObj.ReadFrom(JsonResponse) then
            exit;
        if not JsonObj.Get('error', JsonTok) then
            exit;

        JsonObj := JsonTok.AsObject();
        JsonObj.Get('message', JsonTok);
        Error(JsonTok.AsValue().AsText());
    end;

    procedure FindMember(PersonGroups: Record "NPR MCS Person Groups"; JsonFacesArr: JsonArray; JsonIdArr: JsonArray; PictureStream: InStream) PersonId: Text[50]
    var
        JsonTok: JsonToken;
        JsonObj: JsonObject;
        JsonTokValue: JsonToken;
        FaceId: Text;
    begin
        foreach JsonTok in JsonFacesArr do begin
            JsonObj := JsonTok.AsObject();
            JsonObj.Get('faceId', JsonTokValue);
            FaceId := JsonTokValue.AsValue().AsText();
            PersonId := CopyStr(IsPersonIdentified(FaceId, JsonIdArr), 1, MaxStrLen(PersonId));
        end;
    end;
}

