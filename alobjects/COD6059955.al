codeunit 6059955 "MCS Face Service API"
{
    // NPR5.37/TJ  /20170802 CASE 285617 Updated all variables using NaviPartner.Cognitive.Services assembly to use version 1.0.0.7 instead 1.0.0.5
    //                                   Added code to InitializeEntities()


    trigger OnRun()
    begin
    end;

    var
        FaceServiceAPI: DotNet npNetFaceServiceAPI;
        GroupEntity: DotNet npNetGroupEntity;
        ErrorEntity: DotNet npNetErrorEntity;
        PersonEntity: DotNet npNetPersonEntity;
        ResponseEntity: DotNet npNetFaceResponseEntity;
        DebugString: Text;
        JsonConvert: DotNet npNetJsonConvert;
        PersonGroups: Record "MCS Person Groups";
        Counter: Integer;
        FaceEntity: DotNet npNetFaceEntity;
        InnerFaceEntity: DotNet npNetFaceEntity;

    procedure GetPersonGroups()
    begin
        InitializeEntities();
        InitializeClient();

        ResponseEntity := FaceServiceAPI.GetPersonGroups;
        ErrorEntity := ResponseEntity.Error;

        //DebugString := JsonConvert.SerializeObject(ResponseEntity);
        //MESSAGE('GetPersonGroup: ' + DebugString);

        if ErrorEntity.ErrorCode <> '' then
          Error(ErrorEntity.ErrorCode + ' - ' + ErrorEntity.ErrorMessage);

        Counter := 10000;
        PersonGroups.DeleteAll;

        foreach GroupEntity in ResponseEntity.Groups do begin
          PersonGroups.Init;
          PersonGroups.Id := Counter;
          PersonGroups.PersonGroupId := GroupEntity.Id;
          PersonGroups.Name := GroupEntity.Name;
          PersonGroups.Insert;
          Counter += 10000;
        end;
    end;

    procedure GetPersonGroup(PersonGroups: Record "MCS Person Groups")
    begin
        PersonGroups.TestField(PersonGroupId);

        InitializeEntities();
        InitializeClient();

        ResponseEntity := FaceServiceAPI.GetPersonGroup(PersonGroups.PersonGroupId);
        ErrorEntity := ResponseEntity.Error;

        if ErrorEntity.ErrorCode <> '' then
          Error(ErrorEntity.ErrorCode + ' - ' + ErrorEntity.ErrorMessage);
    end;

    [EventSubscriber(ObjectType::Table, 6059957, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeletePersonGroup(var Rec: Record "MCS Person Groups";RunTrigger: Boolean)
    var
        RecRef: RecordRef;
    begin
        if not RunTrigger then
          exit;

        RecRef.GetTable(Rec);
        if RecRef.IsTemporary then
          exit;

        InitializeEntities();
        InitializeClient();

        if (Rec.PersonGroupId <> '') then begin
          ResponseEntity := FaceServiceAPI.DeletePersonGroup(Rec.PersonGroupId);
          ErrorEntity := ResponseEntity.Error;
        end;

        if ErrorEntity.ErrorCode <> '' then
          Error(ErrorEntity.ErrorCode + ' - ' + ErrorEntity.ErrorMessage);
    end;

    [EventSubscriber(ObjectType::Table, 6059957, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertPersonGroup(var Rec: Record "MCS Person Groups";RunTrigger: Boolean)
    var
        RecRef: RecordRef;
    begin
        if not RunTrigger then
          exit;

        RecRef.GetTable(Rec);
        if RecRef.IsTemporary then
          exit;

        InitializeEntities();
        InitializeClient();

        ResponseEntity := FaceServiceAPI.CreatePersonGroup(Rec.Name);
        ErrorEntity := ResponseEntity.Error;

        if ErrorEntity.ErrorCode <> '' then
          Error(ErrorEntity.ErrorCode + ' - ' + ErrorEntity.ErrorMessage);

        foreach GroupEntity in ResponseEntity.Groups do begin
          Rec.PersonGroupId := GroupEntity.Id;
          Rec.Modify(true);
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6059958, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeletePerson(var Rec: Record "MCS Person";RunTrigger: Boolean)
    var
        RecRef: RecordRef;
        MCSFaces: Record "MCS Faces";
        MCSPersonBusinessEntities: Record "MCS Person Business Entities";
    begin
        if not RunTrigger then
          exit;

        RecRef.GetTable(Rec);
        if RecRef.IsTemporary then
          exit;

        InitializeEntities();
        InitializeClient();

        if (Rec.PersonGroupId <> '') and (Rec.PersonId <> '') then begin
          ResponseEntity := FaceServiceAPI.DeletePerson(Rec.PersonGroupId,Rec.PersonId);
          ErrorEntity := ResponseEntity.Error;
        end;

        if ErrorEntity.ErrorCode <> '' then begin
          Error(ErrorEntity.ErrorCode + ' - ' + ErrorEntity.ErrorMessage);
        end else begin
          MCSFaces.Reset;
          MCSFaces.SetRange(PersonId,Rec.PersonId);
          MCSFaces.DeleteAll(true);
          MCSPersonBusinessEntities.Reset;
          MCSPersonBusinessEntities.SetCurrentKey(Key);
          MCSPersonBusinessEntities.SetRange(Key,Rec.RecordId);
          MCSPersonBusinessEntities.DeleteAll(true);
        end;
    end;

    local procedure InitializeClient()
    var
        CognitivityAPISetup: Record "MCS API Setup";
    begin
        CognitivityAPISetup.Get(CognitivityAPISetup.API::Face);
        FaceServiceAPI := FaceServiceAPI.FaceServiceAPI(CognitivityAPISetup."Key 1");
        ResponseEntity := FaceServiceAPI.response;
        ErrorEntity := ResponseEntity.Error;

        if ErrorEntity.ErrorCode <> '' then
          Error(ErrorEntity.ErrorCode + ' - ' + ErrorEntity.ErrorMessage);
    end;

    local procedure InitializeEntities()
    begin
        ErrorEntity := ErrorEntity.ErrorEntity;
        GroupEntity := GroupEntity.GroupEntity;
        PersonEntity := PersonEntity.PersonEntity;
        //-NPR5.37 [285617]
        //ResponseEntity := ResponseEntity.ResponseEntity;
        ResponseEntity := ResponseEntity.FaceResponseEntity;
        //+NPR5.37 [285617]
        FaceEntity := FaceEntity.FaceEntity;
    end;

    procedure CreatePersonBusinessEntity(Origin: RecordID;NewRecordID: RecordID)
    var
        NewMCSPersonBusinessEntities: Record "MCS Person Business Entities";
        RecRef: RecordRef;
        MCSPersonBusinessEntities: Record "MCS Person Business Entities";
    begin
        MCSPersonBusinessEntities.Reset;
        MCSPersonBusinessEntities.SetCurrentKey(Key);
        MCSPersonBusinessEntities.SetRange(Key,NewRecordID);
        if MCSPersonBusinessEntities.FindSet then
          exit;

        MCSPersonBusinessEntities.Reset;
        MCSPersonBusinessEntities.SetCurrentKey(Key);
        MCSPersonBusinessEntities.SetRange(Key,Origin);
        if MCSPersonBusinessEntities.FindSet then begin
          RecRef.Get(NewRecordID);
          NewMCSPersonBusinessEntities.Init;
          NewMCSPersonBusinessEntities.PersonId := MCSPersonBusinessEntities.PersonId;
          NewMCSPersonBusinessEntities."Table Id" := RecRef.Number;
          NewMCSPersonBusinessEntities.Key := NewRecordID;
          NewMCSPersonBusinessEntities.Insert(true);
        end;
    end;

    procedure UpdatePersonInfo(MCSPerson: Record "MCS Person")
    begin
        InitializeEntities();
        InitializeClient();

        ResponseEntity := FaceServiceAPI.UpdatePerson(MCSPerson.PersonGroupId, MCSPerson.PersonId, MCSPerson.Name, MCSPerson.UserData);
        ErrorEntity := ResponseEntity.Error;

        if ErrorEntity.ErrorCode <> '' then
          Error(ErrorEntity.ErrorCode + ' - ' + ErrorEntity.ErrorMessage);
    end;

    procedure ImportPersonPicture(var MMMember: Record "MM Member";ModifyVar: Boolean)
    var
        ServerFileName: Text;
        FileManagement: Codeunit "File Management";
        MemberName: Text;
        TempBlob: Record TempBlob;
        MCSPersonBusinessEntities: Record "MCS Person Business Entities";
        RecRef: RecordRef;
        MCSAPISetup: Record "MCS API Setup";
        MCSPersonGroupsSetup: Record "MCS Person Groups Setup";
        MCSPerson: Record "MCS Person";
        StreamDotNet1: DotNet npNetStream;
        FileDotNet: DotNet npNetFile;
        MCSFaces: Record "MCS Faces";
        Convert: DotNet npNetConvert;
        StreamDotNet2: DotNet npNetStream;
        StreamDotNet3: DotNet npNetStream;
        UserData: Text;
        PersonId: Text;
    begin
        RecRef := MMMember.RecordId.GetRecord;

        if MCSAPISetup.Get(MCSAPISetup.API::Face) then begin
          MMMember.TestField("Entry No.");
          MMMember.TestField("First Name");

          MCSAPISetup.TestField("Key 1");
          MCSAPISetup.TestField("Key 2");

          MCSPersonGroupsSetup.Get(RecRef.Number);
          PersonGroups.Get(MCSPersonGroupsSetup."Person Groups Id");
          PersonGroups.TestField(PersonGroupId);

          MemberName := MMMember."First Name";
          if MMMember."Middle Name" <> ''  then
            MemberName := MemberName + ' ' + MMMember."Middle Name";
          if MMMember."Last Name" <> '' then
            MemberName := MemberName + ' ' + MMMember."Last Name";

          UserData := Format(CurrentDateTime);

          ServerFileName := FileManagement.UploadFile('Import Picture','');
          if ServerFileName <> '' then begin

            //3 streams because of NAV memory leak error if only one stream is used
            StreamDotNet1 := FileDotNet.OpenRead(ServerFileName);
            StreamDotNet2 := FileDotNet.OpenRead(ServerFileName);
            StreamDotNet3 := FileDotNet.OpenRead(ServerFileName);
            FileManagement.BLOBImportFromServerFile(TempBlob, ServerFileName);

            InitializeEntities();
            InitializeClient();

            ResponseEntity := FaceServiceAPI.UploadAndIdentifyFaces(PersonGroups.PersonGroupId, StreamDotNet1);
            if ErrorEntity.ErrorCode <> '' then
              Error(ErrorEntity.ErrorCode + ' - ' + ErrorEntity.ErrorMessage);
            //DebugString := JsonConvert.SerializeObject(ResponseEntity);
            //    MESSAGE('UploadAndIdentifyFaces: ' + DebugString);

            foreach FaceEntity in ResponseEntity.Faces do begin

              PersonId := FaceEntity.PersonId;

              if FaceEntity.Identified then begin
                ResponseEntity := FaceServiceAPI.AddPersonFace(PersonGroups.PersonGroupId, FaceEntity.PersonId, StreamDotNet2);
                ErrorEntity := ResponseEntity.Error;
                if ErrorEntity.ErrorCode <> '' then
                  Error(ErrorEntity.ErrorCode + ' - ' + ErrorEntity.ErrorMessage);
                //DebugString := JsonConvert.SerializeObject(ResponseEntity);
                //MESSAGE('AddPersonFace: ' + DebugString);
              end else begin
                ResponseEntity := FaceServiceAPI.CreatePerson(PersonGroups.PersonGroupId, MemberName, UserData, StreamDotNet2, StreamDotNet3);
                ErrorEntity := ResponseEntity.Error;
                if ErrorEntity.ErrorCode <> '' then
                  Error(ErrorEntity.ErrorCode + ' - ' + ErrorEntity.ErrorMessage);

                foreach InnerFaceEntity in ResponseEntity.Faces do begin
                  PersonId := InnerFaceEntity.PersonId;
                end;

                //DebugString := JsonConvert.SerializeObject(ResponseEntity);
                //MESSAGE('CreatePerson: ' + DebugString);
              end;

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
              MCSFaces.PersonId := PersonId;
              MCSFaces.IsSmiling := FaceEntity.IsSmiling;
              MCSFaces.Gender := FaceEntity.Gender;
              MCSFaces.Glasses := FaceEntity.Glasses;
              MCSFaces.Identified := FaceEntity.Identified;
              MCSFaces.Action := MCSFaces.Action::CaptureAndIdentifyFaces;
              MCSFaces.Picture := TempBlob.Blob;
              MCSFaces.Insert(true);

              if not MCSPerson.Get(MCSFaces.PersonId) then begin
                MCSPerson.Init;
                MCSPerson.PersonId := MCSFaces.PersonId;
                MCSPerson.PersonGroupId := PersonGroups.PersonGroupId;
                MCSPerson.Name := MemberName;
                MCSPerson.UserData := UserData;
                if MCSPerson.Insert(true) then begin
                  MCSPersonBusinessEntities.Init;
                  MCSPersonBusinessEntities.PersonId := MCSPerson.PersonId;
                  MCSPersonBusinessEntities."Table Id" := RecRef.Number;
                  MCSPersonBusinessEntities.Key := MMMember.RecordId;
                  MCSPersonBusinessEntities.Insert(true);
                end;
              end else begin
                if not MCSPersonBusinessEntities.Get(MCSPerson.PersonId,RecRef.Number) then begin
                  MCSPersonBusinessEntities.Init;
                  MCSPersonBusinessEntities.PersonId := MCSPerson.PersonId;
                  MCSPersonBusinessEntities."Table Id" := RecRef.Number;
                  MCSPersonBusinessEntities.Key := MMMember.RecordId;
                  MCSPersonBusinessEntities.Insert(true);
                end;
              end;
            end;

            MMMember.Picture := TempBlob.Blob;
            MMMember.Modify;
            if FILE.Erase(ServerFileName) then;
          end;
        end;
    end;
}

