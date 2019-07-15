codeunit 6059957 "MCS Webcam Proxy"
{
    // NPR5.29/CLVA/20170125 CASE 264333 Added functionality to support image orientation;

    SingleInstance = true;
    TableNo = TempBlob;

    trigger OnRun()
    begin
        ProcessSignal(Rec);
    end;

    var
        POSDeviceProxyManager: Codeunit "POS Device Proxy Manager";
        ProtocolStage: Integer;
        ExpectedResponseType: DotNet npNetType;
        ExpectedResponseId: Guid;
        QueuedRequests: DotNet npNetStack;
        QueuedResponseTypes: DotNet npNetStack;
        ProtocolManagerId: Guid;
        WebcamArgumentTable: Record "MCS Webcam Argument Table";
        Base64String: Text;
        IdentifyButtonText: Label 'Identify';
        CaptureButtonText: Label 'Capture';

    local procedure "--- Protocol functions"()
    begin
    end;

    procedure InitializeProtocol()
    begin
        ClearAll();
    end;

    local procedure ProcessSignal(var TempBlob: Record TempBlob)
    var
        Signal: DotNet npNetSignal;
        StartSignal: DotNet npNetStartSession;
        Response: DotNet npNetMessageResponse;
        ProtocolManagerId: Guid;
        QueryCloseSignal: DotNet npNetQueryClosePage;
    begin
        POSDeviceProxyManager.DeserializeObject(Signal, TempBlob);
        case true of
            Signal.TypeName = Format(GetDotNetType(StartSignal)):
                begin
                    QueuedRequests := QueuedRequests.Stack();
                    QueuedResponseTypes := QueuedResponseTypes.Stack();

                    POSDeviceProxyManager.DeserializeSignal(StartSignal, Signal);
                    Start(StartSignal.ProtocolManagerId);
                end;
            Signal.TypeName = Format(GetDotNetType(Response)):
                begin
                    POSDeviceProxyManager.DeserializeSignal(Response, Signal);
                    MessageResponse(Response.Envelope);
                end;
            Signal.TypeName = Format(GetDotNetType(QueryCloseSignal)):
                if QueryClosePage() then
                    POSDeviceProxyManager.AbortByUserRequest(ProtocolManagerId);
        end;
    end;

    local procedure Start(ProtocolManagerIdIn: Guid)
    var
        VoidResponse: DotNet npNetVoidResponse;
        State: DotNet npNetState2;
        WebcamCaptureRequest: DotNet npNetWebcamCaptureRequest;
        ActionEnum: DotNet npNetState_Action0;
        PersonEntity: DotNet npNetPersonEntity0;
        WebcamIdentityRequest: DotNet npNetWebcamIdentityRequest;
    begin
        ProtocolManagerId := ProtocolManagerIdIn;

        PersonEntity := PersonEntity.PersonEntity();
        PersonEntity.PersonGroupId := WebcamArgumentTable."Person Group Id";
        PersonEntity.Name := WebcamArgumentTable.Name;
        PersonEntity.UserData := Format(CurrentDateTime);

        State := State.State();
        case WebcamArgumentTable.Action of
            WebcamArgumentTable.Action::CaptureAndIdentifyFaces:
                State.ActionType := ActionEnum.CaptureAndIdentifyFaces;
            WebcamArgumentTable.Action::CaptureImage:
                State.ActionType := ActionEnum.CaptureImage;
            WebcamArgumentTable.Action::IdentifyFaces:
                State.ActionType := ActionEnum.CaptureAndIdentifyFaces;
        end;

        State.InBase64Value := '';
        State.APIKey1 := WebcamArgumentTable."API Key 1";
        State.AllowSavingOnIdentifyedFaces := WebcamArgumentTable."Allow Saving On Identifyed";
        State.Person := PersonEntity;

        //-NPR5.29
        State.OrientationType := WebcamArgumentTable."Image Orientation";
        //+NPR5.29

        case WebcamArgumentTable.Action of
            WebcamArgumentTable.Action::CaptureAndIdentifyFaces:
                begin
                    WebcamCaptureRequest := WebcamCaptureRequest.WebcamCaptureRequest();

                    State.TextButton2 := CaptureButtonText;
                    WebcamCaptureRequest.State := State;

                    AwaitResponse(
                      GetDotNetType(VoidResponse),
                      POSDeviceProxyManager.SendMessage(
                        ProtocolManagerId, WebcamCaptureRequest));

                end;

            WebcamArgumentTable.Action::CaptureImage:
                begin
                    WebcamCaptureRequest := WebcamCaptureRequest.WebcamCaptureRequest();

                    State.TextButton2 := CaptureButtonText;
                    WebcamCaptureRequest.State := State;

                    AwaitResponse(
                      GetDotNetType(VoidResponse),
                      POSDeviceProxyManager.SendMessage(
                        ProtocolManagerId, WebcamCaptureRequest));

                end;

            WebcamArgumentTable.Action::IdentifyFaces:
                begin
                    WebcamIdentityRequest := WebcamIdentityRequest.WebcamIdentityRequest();

                    State.TextButton2 := IdentifyButtonText;
                    WebcamIdentityRequest.State := State;

                    AwaitResponse(
                      GetDotNetType(VoidResponse),
                      POSDeviceProxyManager.SendMessage(
                        ProtocolManagerId, WebcamIdentityRequest));

                end;
        end;
    end;

    local procedure MessageResponse(Envelope: DotNet npNetResponseEnvelope)
    begin
        if Envelope.ResponseTypeName <> Format(ExpectedResponseType) then
            Error('Unknown response type: %1 (expected %2)', Envelope.ResponseTypeName, Format(ExpectedResponseType));
    end;

    local procedure QueryClosePage(): Boolean
    begin
        exit(true);
    end;

    local procedure CloseProtocol()
    begin
        POSDeviceProxyManager.ProtocolClose(ProtocolManagerId);
    end;

    local procedure AwaitResponse(Type: DotNet npNetType; Id: Guid)
    begin
        ExpectedResponseType := Type;
        ExpectedResponseId := Id;
    end;

    local procedure "--- Protocol Events"()
    begin
    end;

    local procedure CloseForm(Data: Text)
    var
        State: DotNet npNetState2;
        JsonConvert: DotNet JsonConvert;
        PersonEntity: DotNet npNetPersonEntity0;
        FaceEntity: DotNet npNetFaceEntity0;
        MCSPerson: Record "MCS Person";
        MCSFaces: Record "MCS Faces";
        OutS: OutStream;
        Convert: DotNet npNetConvert;
        Bytes: DotNet npNetArray;
        MemoryStream: DotNet npNetMemoryStream;
        FacesEntity: DotNet npNetFaceEntity0;
        MCSPersonBusinessEntities: Record "MCS Person Business Entities";
    begin
        State := State.Deserialize(Data);

        Base64String := State.OutBase64Value;

        if Base64String <> '' then begin
            PersonEntity := PersonEntity.PersonEntity;
            PersonEntity := State.Person;

            if PersonEntity.PersonId <> '' then begin

                WebcamArgumentTable."Person Id" := PersonEntity.PersonId;

                if not MCSPerson.Get(PersonEntity.PersonId) then begin
                    MCSPerson.Init;
                    MCSPerson.PersonId := PersonEntity.PersonId;
                    MCSPerson.PersonGroupId := PersonEntity.PersonGroupId;
                    MCSPerson.Name := PersonEntity.Name;
                    MCSPerson.UserData := PersonEntity.UserData;
                    if MCSPerson.Insert(true) then begin
                        if (WebcamArgumentTable.Action <> WebcamArgumentTable.Action::IdentifyFaces) then begin
                            MCSPersonBusinessEntities.Init;
                            MCSPersonBusinessEntities.PersonId := MCSPerson.PersonId;
                            MCSPersonBusinessEntities."Table Id" := WebcamArgumentTable."Table Id";
                            MCSPersonBusinessEntities.Key := WebcamArgumentTable.Key;
                            MCSPersonBusinessEntities.Insert(true);
                        end;
                    end;
                end else begin
                    if (WebcamArgumentTable.Action <> WebcamArgumentTable.Action::IdentifyFaces) then begin
                        if not MCSPersonBusinessEntities.Get(MCSPerson.PersonId, WebcamArgumentTable."Table Id") then begin
                            MCSPersonBusinessEntities.Init;
                            MCSPersonBusinessEntities.PersonId := MCSPerson.PersonId;
                            MCSPersonBusinessEntities."Table Id" := WebcamArgumentTable."Table Id";
                            MCSPersonBusinessEntities.Key := WebcamArgumentTable.Key;
                            MCSPersonBusinessEntities.Insert(true);
                        end else
                            WebcamArgumentTable.Key := MCSPersonBusinessEntities.Key;
                    end else begin
                        if MCSPersonBusinessEntities.Get(MCSPerson.PersonId, WebcamArgumentTable."Table Id") then
                            WebcamArgumentTable.Key := MCSPersonBusinessEntities.Key;
                    end;
                end;

                //MESSAGE(JsonConvert.SerializeObject(State.Faces));
                FaceEntity := FaceEntity.FaceEntity;

                foreach FaceEntity in State.Faces do begin

                    MCSFaces.Init;
                    MCSFaces.Age := Convert.ToDecimal(FaceEntity.Age);
                    MCSFaces.Beard := Convert.ToDecimal(FaceEntity.Beard);
                    MCSFaces.Created := CurrentDateTime;
                    MCSFaces.Sideburns := Convert.ToDecimal(FaceEntity.Sideburns);
                    MCSFaces.Moustache := Convert.ToDecimal(FaceEntity.Moustache);
                    MCSFaces."Face Height" := FaceEntity.Height;
                    MCSFaces."Face Position X" := FaceEntity.Left;
                    MCSFaces."Face Position Y" := FaceEntity.Top;
                    MCSFaces."Face Width" := FaceEntity.Width;
                    MCSFaces.FaceId := FaceEntity.FaceId;
                    MCSFaces.PersonId := MCSPerson.PersonId;
                    MCSFaces.IsSmiling := FaceEntity.IsSmiling;
                    MCSFaces.Gender := FaceEntity.Gender;
                    MCSFaces.Glasses := FaceEntity.Glasses;
                    MCSFaces.Identified := FaceEntity.Identified;
                    MCSFaces.Action := WebcamArgumentTable.Action;

                    WebcamArgumentTable."Is Identified" := MCSFaces.Identified;

                    Bytes := Convert.FromBase64String(Base64String);
                    MemoryStream := MemoryStream.MemoryStream(Bytes);
                    MCSFaces.Picture.CreateOutStream(OutS);
                    MemoryStream.WriteTo(OutS);

                    MCSFaces.Insert(true);
                end;
            end;
        end;

        CloseProtocol();
    end;

    local procedure "--- Protocol Event Handling"()
    begin
    end;

    local procedure SerializeJson("Object": Variant): Text
    var
        JsonConvert: DotNet JsonConvert;
    begin
        exit(JsonConvert.SerializeObject(Object));
    end;

    [EventSubscriber(ObjectType::Page, 6014657, 'ProtocolEvent', '', false, false)]
    local procedure ProtocolEvent(ProtocolCodeunitID: Integer; EventName: Text; Data: Text; ResponseRequired: Boolean; var ReturnData: Text)
    begin
        if (ProtocolCodeunitID <> CODEUNIT::"MCS Webcam Proxy") then
            exit;

        case EventName of
            'CloseForm':
                CloseForm(Data);
        end;
    end;

    local procedure "-- Set Functions"()
    begin
    end;

    procedure SetState(var WebcamArgumentTableIn: Record "MCS Webcam Argument Table")
    begin
        WebcamArgumentTable := WebcamArgumentTableIn;
    end;

    local procedure "-- Get Functions"()
    begin
    end;

    procedure GetStatus(): Integer
    begin
    end;

    procedure GetState(var WebcamArgumentTableOut: Record "MCS Webcam Argument Table")
    begin
        WebcamArgumentTableOut := WebcamArgumentTable;
    end;

    procedure GetBase64String(): Text
    begin
        exit(Base64String);
    end;
}

