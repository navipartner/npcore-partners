codeunit 6059958 "NPR MCS Webcam Proxy TSD"
{
    SingleInstance = true;

    var
        WebcamArgumentTable: Record "NPR MCS Webcam Arg. Table";
        Base64String: Text;
        IdentifyButtonText: Label 'Identify';
        CaptureButtonText: Label 'Capture';
        FormClosed: Boolean;

    procedure InvokeDevice()
    var
        CaptureQst: label 'Click Yes to continue or No to take a new picture.';
    begin

        Start();
        if (not Confirm(CaptureQst, true)) then
            InvokeDevice();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Stargate Management", 'OnDeviceResponse', '', true, true)]
    local procedure OnDeviceResponse(ActionName: Text; Step: Text; Envelope: DotNet NPRNetResponseEnvelope0; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin

        if (ActionName <> 'MCS_WebCam') then
            exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Stargate Management", 'OnAppGatewayProtocol', '', true, true)]
    local procedure OnDeviceEvent(ActionName: Text; EventName: Text; Data: Text; ResponseRequired: Boolean; var ReturnData: Text; var Handled: Boolean)
    begin

        if (ActionName <> 'MCS_WebCam') then
            exit;

        Handled := true;
        case EventName of
            'CloseForm':
                CloseForm(Data);
        end;
    end;

    local procedure Start()
    var
        State: DotNet NPRNetState3;
        WebcamCaptureRequest: DotNet NPRNetWebcamCaptureRequest0;
        ActionEnum: DotNet NPRNetState_Action1;
        PersonEntity: DotNet NPRNetPersonEntity1;
        WebcamIdentityRequest: DotNet NPRNetWebcamIdentityRequest0;
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
    begin
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

        State.OrientationType := WebcamArgumentTable."Image Orientation".AsInteger();

        case WebcamArgumentTable.Action of
            WebcamArgumentTable.Action::CaptureAndIdentifyFaces:
                begin
                    WebcamCaptureRequest := WebcamCaptureRequest.WebcamCaptureRequest();

                    State.TextButton2 := CaptureButtonText;
                    WebcamCaptureRequest.State := State;

                    if (POSSession.IsActiveSession(FrontEnd)) then
                        FrontEnd.InvokeDevice(WebcamCaptureRequest, 'MCS_WebCam', 'CaptureAndIdentifyFaces');

                end;

            WebcamArgumentTable.Action::CaptureImage:
                begin
                    WebcamCaptureRequest := WebcamCaptureRequest.WebcamCaptureRequest();

                    State.TextButton2 := CaptureButtonText;
                    WebcamCaptureRequest.State := State;

                    if (POSSession.IsActiveSession(FrontEnd)) then
                        FrontEnd.InvokeDevice(WebcamCaptureRequest, 'MCS_WebCam', 'CaptureImage');

                end;

            WebcamArgumentTable.Action::IdentifyFaces:
                begin
                    WebcamIdentityRequest := WebcamIdentityRequest.WebcamIdentityRequest();

                    State.TextButton2 := IdentifyButtonText;
                    WebcamIdentityRequest.State := State;

                    if (POSSession.IsActiveSession(FrontEnd)) then
                        FrontEnd.InvokeDevice(WebcamIdentityRequest, 'MCS_WebCam', 'IdentifyFaces');

                end;
        end;
    end;

    #region Protocol Events

    local procedure CloseForm(Data: Text)
    var
        State: DotNet NPRNetState3;
        JsonConvert: DotNet JsonConvert;
        PersonEntity: DotNet NPRNetPersonEntity1;
        FaceEntity: DotNet NPRNetFaceEntity1;
        MCSPerson: Record "NPR MCS Person";
        MCSFaces: Record "NPR MCS Faces";
        OutS: OutStream;
        Convert: DotNet NPRNetConvert;
        Bytes: DotNet NPRNetArray;
        MemoryStream: DotNet NPRNetMemoryStream;
        FacesEntity: DotNet NPRNetFaceEntity1;
        MCSPersonBusinessEntities: Record "NPR MCS Person Bus. Entit.";
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

        FormClosed := true;
    end;
    #endregion
    #region Protocol Event Handling
    local procedure SerializeJson("Object": Variant): Text
    var
        JsonConvert: DotNet JsonConvert;
    begin
        exit(JsonConvert.SerializeObject(Object));
    end;
    #endregion
    #region Set Functions

    procedure SetState(var WebcamArgumentTableIn: Record "NPR MCS Webcam Arg. Table")
    begin
        WebcamArgumentTable := WebcamArgumentTableIn;
    end;
    #endregion
    #region Get Functions

    procedure GetState(var WebcamArgumentTableOut: Record "NPR MCS Webcam Arg. Table")
    begin
        WebcamArgumentTableOut := WebcamArgumentTable;
    end;

    procedure GetBase64String(): Text
    begin
        exit(Base64String);
    end;
    #endregion
}

