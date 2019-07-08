codeunit 6059958 "MCS Webcam Proxy TSD"
{
    // NPR5.29/CLVA/20170125 CASE 264333 Added functionality to support image orientation;
    // NPR5.33/TSA/20170628  CASE 279495 Adjusted to stargate 2.0

    SingleInstance = true;

    trigger OnRun()
    begin
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
        FormClosed: Boolean;

    procedure InvokeDevice()
    begin

        Start ();
        if (not Confirm ('Click Yes to continue or No to take a new picture.', true)) then
          InvokeDevice ();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150716, 'OnDeviceResponse', '', true, true)]
    local procedure OnDeviceResponse(ActionName: Text;Step: Text;Envelope: DotNet npNetResponseEnvelope0;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    begin

        if (ActionName <> 'MCS_WebCam') then
          exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150716, 'OnAppGatewayProtocol', '', true, true)]
    local procedure OnDeviceEvent(ActionName: Text;EventName: Text;Data: Text;ResponseRequired: Boolean;var ReturnData: Text;var Handled: Boolean)
    begin

        if (ActionName <> 'MCS_WebCam') then
          exit;

        Handled := true;
        case EventName of
          'CloseForm': CloseForm(Data);
        end;
    end;

    local procedure Start()
    var
        VoidResponse: DotNet npNetVoidResponse;
        State: DotNet npNetState3;
        WebcamCaptureRequest: DotNet npNetWebcamCaptureRequest0;
        ActionEnum: DotNet npNetState_Action1;
        PersonEntity: DotNet npNetPersonEntity1;
        WebcamIdentityRequest: DotNet npNetWebcamIdentityRequest0;
        FrontEnd: Codeunit "POS Front End Management";
        POSSession: Codeunit "POS Session";
    begin
        PersonEntity := PersonEntity.PersonEntity();
        PersonEntity.PersonGroupId := WebcamArgumentTable."Person Group Id";
        PersonEntity.Name := WebcamArgumentTable.Name;
        PersonEntity.UserData := Format(CurrentDateTime);

        State := State.State();
        case WebcamArgumentTable.Action of
          WebcamArgumentTable.Action::CaptureAndIdentifyFaces : State.ActionType := ActionEnum.CaptureAndIdentifyFaces;
          WebcamArgumentTable.Action::CaptureImage : State.ActionType := ActionEnum.CaptureImage;
          WebcamArgumentTable.Action::IdentifyFaces : State.ActionType := ActionEnum.CaptureAndIdentifyFaces;
        end;

        State.InBase64Value := '';
        State.APIKey1 := WebcamArgumentTable."API Key 1";
        State.AllowSavingOnIdentifyedFaces := WebcamArgumentTable."Allow Saving On Identifyed";
        State.Person := PersonEntity;

        //-NPR5.29
        State.OrientationType := WebcamArgumentTable."Image Orientation";
        //+NPR5.29

        case WebcamArgumentTable.Action of
          WebcamArgumentTable.Action::CaptureAndIdentifyFaces :
            begin
              WebcamCaptureRequest := WebcamCaptureRequest.WebcamCaptureRequest();

              State.TextButton2 := CaptureButtonText;
              WebcamCaptureRequest.State := State;

              if (POSSession.IsActiveSession (FrontEnd)) then
                FrontEnd.InvokeDevice (WebcamCaptureRequest, 'MCS_WebCam', 'CaptureAndIdentifyFaces');

            end;

          WebcamArgumentTable.Action::CaptureImage :
            begin
              WebcamCaptureRequest := WebcamCaptureRequest.WebcamCaptureRequest();

              State.TextButton2 := CaptureButtonText;
              WebcamCaptureRequest.State := State;

              if (POSSession.IsActiveSession (FrontEnd)) then
                FrontEnd.InvokeDevice (WebcamCaptureRequest, 'MCS_WebCam', 'CaptureImage');

            end;

          WebcamArgumentTable.Action::IdentifyFaces :
            begin
              WebcamIdentityRequest := WebcamIdentityRequest.WebcamIdentityRequest();

              State.TextButton2 := IdentifyButtonText;
              WebcamIdentityRequest.State := State;

              if (POSSession.IsActiveSession (FrontEnd)) then
                FrontEnd.InvokeDevice (WebcamIdentityRequest, 'MCS_WebCam', 'IdentifyFaces');

            end;
        end;
    end;

    local procedure "--- Protocol Events"()
    begin
    end;

    local procedure CloseForm(Data: Text)
    var
        State: DotNet npNetState3;
        JsonConvert: DotNet npNetJsonConvert;
        PersonEntity: DotNet npNetPersonEntity1;
        FaceEntity: DotNet npNetFaceEntity1;
        MCSPerson: Record "MCS Person";
        MCSFaces: Record "MCS Faces";
        OutS: OutStream;
        Convert: DotNet npNetConvert;
        Bytes: DotNet npNetArray;
        MemoryStream: DotNet npNetMemoryStream;
        FacesEntity: DotNet npNetFaceEntity1;
        MCSPersonBusinessEntities: Record "MCS Person Business Entities";
    begin
        State := State.Deserialize(Data);

        Base64String := State.OutBase64Value;
        //MESSAGE ('Back with %1', STRLEN (Base64String));

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
                if not MCSPersonBusinessEntities.Get(MCSPerson.PersonId,WebcamArgumentTable."Table Id") then begin
                  MCSPersonBusinessEntities.Init;
                  MCSPersonBusinessEntities.PersonId := MCSPerson.PersonId;
                  MCSPersonBusinessEntities."Table Id" := WebcamArgumentTable."Table Id";
                  MCSPersonBusinessEntities.Key := WebcamArgumentTable.Key;
                  MCSPersonBusinessEntities.Insert(true);
                end else
                  WebcamArgumentTable.Key := MCSPersonBusinessEntities.Key;
              end else begin
                if MCSPersonBusinessEntities.Get(MCSPerson.PersonId,WebcamArgumentTable."Table Id") then
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

        FormClosed := true;
    end;

    local procedure "--- Protocol Event Handling"()
    begin
    end;

    local procedure DeserializeState(Data: Text;var State: DotNet npNetState2)
    var
        JsonConvert: DotNet npNetJsonConvert;
    begin
        State := JsonConvert.DeserializeObject(Data,GetDotNetType(State));
    end;

    local procedure SerializeJson("Object": Variant): Text
    var
        JsonConvert: DotNet npNetJsonConvert;
    begin
        exit(JsonConvert.SerializeObject(Object));
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

