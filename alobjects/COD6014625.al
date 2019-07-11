codeunit 6014625 "POS Device Proxy Manager"
{
    // NPR4.15/VB/20150904 CASE 219606 Proxy utility for handling hardware communication
    // NPR4.17/VB/20150104 CASE 225607 Changed references for compiling under NAV 2016 + New functionality to handle Assemblies
    // NPR5.22/VB/20151130 CASE 226832 Modified due to new functionality
    // NPR5.00/VB/20160106 CASE 231100 Update .NET version from 1.9.1.305 to 1.9.1.369
    // NPR5.00/NPKNAV/20160113  CASE 226832 NP Retail 2016
    // NPR5.00.02/VB/20160128 CASE 233260 Allowing Proxy Dialog to run without having Stargate on client-side
    // NPR5.00.03/VB/20160106 CASE 231100 Update .NET version from 1.9.1.369 to 5.0.398.0
    // NPR5.22/VB/20160401 CASE 236554 An issue with managing installed assemblies identified and fixed while working on 236554.
    // NPR5.29/VB/20161104 CASE 256944 Slight speed improvements by skipping unnecessary assembly check stage.

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        AssemblyTemp: Record "Proxy Assembly" temporary;
        SessionMgt: Codeunit "POS Web Session Management";
        ProtocolManagers: DotNet npNetDictionary_Of_T_U;
        EncryptionManager: DotNet npNetEncryptionManager;
        ProtocolState: DotNet npNetProtocolState;
        AvailableAssemblies: DotNet npNetList_Of_T;
        LastAssembliesModifiedTime: DateTime;
        LastStableProtocolState: Integer;
        CodeunitId: Integer;
        Text001: Label 'An invalid response was received from the device proxy service manager. Type: %1.';
        AssembliesInstalled: Boolean;
        DoSecure: Boolean;
        DoEncrypt: Boolean;
        DoInstallAssemblies: Boolean;
        SkipStargate: Boolean;
        AssemblyCheckCompleted: Boolean;

    procedure RegisterProtocolManager(Manager: DotNet npNetProtocolManager)
    begin
        if IsNull(ProtocolManagers) then
            ProtocolManagers := ProtocolManagers.Dictionary();

        if not ProtocolManagers.ContainsKey(Manager.Id) then
            ProtocolManagers.Add(Manager.Id, Manager);
    end;

    local procedure GetProtocolManager(Guid: Guid; var ProtocolManager: DotNet npNetProtocolManager)
    begin
        if ProtocolManagers.ContainsKey(Guid) then
            ProtocolManager := ProtocolManagers.Item(Guid);
    end;

    procedure ResetInstalledAssemblies()
    begin
        AssembliesInstalled := false;
    end;

    procedure SerializeSignal("Object": DotNet npNetObject; var Signal: DotNet npNetSignal)
    var
        Serializer: DotNet npNetXmlSerializer;
        MemStream: DotNet npNetMemoryStream;
        OutStream: OutStream;
    begin
        MemStream := MemStream.MemoryStream();
        Serializer := Serializer.XmlSerializer(Object.GetType());
        Serializer.Serialize(MemStream, Object);

        Signal := Signal.Signal();
        Signal.TypeName := Object.GetType().FullName;
        Signal.Data := MemStream.ToArray();
    end;

    procedure SerializeObject("Object": DotNet npNetObject; var TempBlob: Record TempBlob)
    var
        Serializer: DotNet npNetXmlSerializer;
        OutStream: OutStream;
    begin
        Serializer := Serializer.XmlSerializer(Object.GetType());
        Clear(TempBlob.Blob);
        TempBlob.Blob.CreateOutStream(OutStream);
        Serializer.Serialize(OutStream, Object);
    end;

    procedure DeserializeObject(var "Object": DotNet npNetObject; TempBlob: Record TempBlob)
    var
        Serializer: DotNet npNetXmlSerializer;
        InStream: InStream;
        NetType: DotNet npNetType;
    begin
        NetType := GetDotNetType(Object);
        Serializer := Serializer.XmlSerializer(NetType);
        TempBlob.Blob.CreateInStream(InStream);

        Object := Serializer.Deserialize(InStream);
    end;

    procedure DeserializeSignal(var "Object": DotNet npNetObject; Signal: DotNet npNetSignal)
    var
        Serializer: DotNet npNetXmlSerializer;
        MemStream: DotNet npNetMemoryStream;
        NetType: DotNet npNetType;
    begin
        NetType := GetDotNetType(Object);
        Serializer := Serializer.XmlSerializer(NetType);
        MemStream := MemStream.MemoryStream(Signal.Data);

        Object := Serializer.Deserialize(MemStream);
    end;

    local procedure DeserializeEnvelope(var Response: DotNet npNetResponse0; Envelope: DotNet npNetResponseEnvelope; Manager: DotNet npNetProtocolManager)
    var
        EncryptionManager: DotNet npNetEncryptionManager;
    begin
        EncryptionManager := Manager.EncryptionManager;
        Response := Envelope.Deserialize(GetDotNetType(Response), EncryptionManager, Manager.ResponseTypes);
    end;

    procedure DeserializeEnvelopeFromId(var Response: DotNet npNetResponse0; Envelope: DotNet npNetResponseEnvelope; ProtocolManagerId: Guid)
    var
        Manager: DotNet npNetProtocolManager;
    begin
        GetProtocolManager(ProtocolManagerId, Manager);
        DeserializeEnvelope(Response, Envelope, Manager);
    end;

    local procedure AssemblyAvailable(AssemblyName: Text): Boolean
    var
        Enumerator: DotNet npNetIEnumerator_Of_T;
    begin
        if IsNull(AvailableAssemblies) then
            exit(false);

        Enumerator := AvailableAssemblies.GetEnumerator();
        while Enumerator.MoveNext do
            if AvailableAssemblies.Contains(Enumerator.Current) then
                exit(true);

        exit(false);
    end;

    local procedure InvalidateAssemblyCache()
    begin
        AssembliesInstalled := false;
        Clear(AvailableAssemblies);
    end;

    local procedure ToInt(ProtocolState: Integer): Integer
    begin
        // This function is a workaround to avoid C# compilation issues when an Enum type is cast to integer directly.
        exit(ProtocolState);
    end;

    procedure ProcessResponse(Manager: DotNet npNetProtocolManager; Envelope: DotNet npNetResponseEnvelope)
    var
        ErrorResponse: DotNet npNetErrorResponse;
    begin
        Manager.ReceiveResponse(Envelope);

        if not Envelope.Success then begin
            InvalidateAssemblyCache();
            DeserializeEnvelope(ErrorResponse, Envelope, Manager);
            ProtocolAbort(Manager.Id, ErrorResponse.ErrorMessage);
            exit;
        end;

        case ToInt(Manager.State) of
            ToInt(ProtocolState.Securing):
                ProtocolSecureResponse(Manager, Envelope);
            ToInt(ProtocolState.CheckingAssemblies):
                ProtocolGetAssembliesResponse(Manager, Envelope);
            ToInt(ProtocolState.InstallingAssemblies):
                ProtocolInstallAssemblyResponse(Manager, Envelope);
            ToInt(ProtocolState.Messaging):
                ProtocolMessagingResponse(Manager, Envelope);
        end;
    end;

    procedure ProtocolStateChange(Manager: DotNet npNetProtocolManager; PreviousState: Integer; NewState: Integer)
    begin
        case ToInt(NewState) of
            ToInt(ProtocolState.Initiated):
                ProtocolStateEnteredInitiated(Manager, PreviousState);
            ToInt(ProtocolState.Secured):
                ProtocolStateEnteredSecured(Manager, PreviousState);
            ToInt(ProtocolState.CheckedAssemblies):
                ProtocolStateEnteredCheckedAssemblies(Manager, PreviousState);
            ToInt(ProtocolState.InstalledAssemblies):
                ProtocolStateEnteredInstalledAssemblies(Manager, PreviousState);
            ToInt(ProtocolState.Open):
                ProtocolStateEnteredOpen(Manager, PreviousState);
        end;
    end;

    procedure ProtocolBegin(Manager: DotNet npNetProtocolManager)
    begin
        SessionMgt.GetProtocolBehavior(DoEncrypt, DoSecure, DoInstallAssemblies);

        //-NPR5.00.02
        if SkipStargate then
            DoInstallAssemblies := false;
        //+NPR5.00.02

        ProtocolInitiate(Manager);
    end;

    local procedure ProtocolInitiate(Manager: DotNet npNetProtocolManager)
    begin
        Manager.State := ProtocolState.Initiating;

        if IsNull(EncryptionManager) then
            EncryptionManager := EncryptionManager.EncryptionManager();

        if DoEncrypt then
            if EncryptionManager.SymmetricEncryptionEnabled then
                Manager.EnableSymmetricEncryption(EncryptionManager);

        Manager.State := ProtocolState.Initiated;
    end;

    local procedure ProtocolSecure(Manager: DotNet npNetProtocolManager; ForceSecure: Boolean)
    var
        PublicKeyRequest: DotNet npNetPublicKeyRequest;
    begin
        if (Manager.Secure and (not ForceSecure)) or (not DoSecure) then begin
            Manager.State := ProtocolState.Secured;
            exit;
        end;

        Manager.State := ProtocolState.Securing;

        PublicKeyRequest := PublicKeyRequest.PublicKeyRequest();
        PublicKeyRequest.Modulus := EncryptionManager.PublicKey;
        PublicKeyRequest.Exponent := EncryptionManager.Exponent;
        Manager.SendMessage(PublicKeyRequest);
    end;

    local procedure ProtocolSecureResponse(Manager: DotNet npNetProtocolManager; Envelope: DotNet npNetResponseEnvelope)
    var
        PublicKeyResponse: DotNet npNetPublicKeyResponse;
    begin
        DeserializeEnvelope(PublicKeyResponse, Envelope, Manager);
        if IsNull(PublicKeyResponse) then begin
            Manager.Abort(StrSubstNo(Text001, Envelope.ResponseTypeName));
            exit;
        end;

        EncryptionManager.EnableSymmetricEncryption(
          EncryptionManager.DecryptPrivate(PublicKeyResponse.EncryptedSymmetricKey),
          EncryptionManager.DecryptPrivate(PublicKeyResponse.EncryptedSymmetricIV));
        Manager.EnableSymmetricEncryption(EncryptionManager);

        Manager.State := ProtocolState.Secured;
    end;

    local procedure ProtocolGetAssemblies(Manager: DotNet npNetProtocolManager)
    var
        Assembly: Record "Proxy Assembly";
        GetAssembliesRequest: DotNet npNetGetAssembliesRequest;
    begin
        Assembly.SetCurrentKey("Last Modified Time");
        if Assembly.FindLast() and (Assembly."Last Modified Time" > LastAssembliesModifiedTime) then begin
            AssembliesInstalled := false;
            LastAssembliesModifiedTime := Assembly."Last Modified Time";
        end;

        if (not IsNull(AvailableAssemblies)) or (not DoInstallAssemblies) then begin
            Manager.State := ProtocolState.CheckedAssemblies;
            exit;
        end;

        Manager.State := ProtocolState.CheckingAssemblies;

        Manager.SendMessage(GetAssembliesRequest.GetAssembliesRequest());
    end;

    local procedure ProtocolGetAssembliesResponse(Manager: DotNet npNetProtocolManager; Envelope: DotNet npNetResponseEnvelope)
    var
        GetAssembliesResponse: DotNet npNetGetAssembliesResponse;
        Enumerator: DotNet npNetIEnumerator;
    begin
        DeserializeEnvelope(GetAssembliesResponse, Envelope, Manager);
        AvailableAssemblies := AvailableAssemblies.List();
        Enumerator := GetAssembliesResponse.Assemblies.GetEnumerator();
        while Enumerator.MoveNext do
            AvailableAssemblies.Add(Enumerator.Current);

        Manager.State := ProtocolState.CheckedAssemblies;
    end;

    local procedure ProtocolInstallAssemblies(Manager: DotNet npNetProtocolManager)
    var
        ProxyAssembly: Record "Proxy Assembly";
        Registers: DotNet npNetString;
        InstallAssemblyRequest: DotNet npNetInstallAssemblyRequest;
        TempFile: File;
        TempFileName: Text;
        DoInstall: Boolean;
        InstallRequestSent: Boolean;
    begin
        Manager.State := ProtocolState.InstallingAssemblies;

        if (not AssembliesInstalled) and DoInstallAssemblies then begin
            if ProxyAssembly.FindSet() then
                repeat
                    if ProxyAssembly.Binary.HasValue() then begin
                        if ProxyAssembly."Register Map".HasValue() then begin
                            Registers := GetRegistersWithInstalledAssembly(ProxyAssembly);
                            DoInstall := not Registers.Contains(GetRegisterInstalledFlag()) or not AssemblyAvailable(ProxyAssembly."Full Name");
                        end else
                            DoInstall := true;

                        if DoInstall then begin
                            InstallRequestSent := true;
                            TempFile.CreateTempFile;
                            TempFileName := TempFile.Name;
                            TempFile.Close();
                            ProxyAssembly.CalcFields(Binary);
                            ProxyAssembly.Binary.Export(TempFileName);

                            InstallAssemblyRequest := InstallAssemblyRequest.InstallAssemblyRequest(TempFileName);
                            AssemblyTemp := ProxyAssembly;
                            AssemblyTemp.Guid := Manager.SendMessage(InstallAssemblyRequest);
                            //-NPR5.22
                            //AssemblyTemp.INSERT;
                            if not AssemblyTemp.Insert then;
                            //+NPR5.22
                            Erase(TempFileName);
                        end;

                    end;
                until ProxyAssembly.Next = 0;
        end;

        if not InstallRequestSent then
            Manager.State := ProtocolState.InstalledAssemblies;
    end;

    local procedure ProtocolInstallAssemblyResponse(Manager: DotNet npNetProtocolManager; Envelope: DotNet npNetResponseEnvelope)
    var
        ProxyAssembly: Record "Proxy Assembly";
        VoidResponse: DotNet npNetVoidResponse;
        Writer: DotNet npNetStreamWriter;
        OutStream: OutStream;
        Registers: Text;
    begin
        DeserializeEnvelope(VoidResponse, Envelope, Manager);
        if IsNull(VoidResponse) then begin
            Manager.Abort(StrSubstNo(Text001, Envelope.ResponseTypeName));
            exit;
        end;

        AssemblyTemp.SetRange(Guid, Envelope.MessageId);
        AssemblyTemp.FindFirst();
        ProxyAssembly := AssemblyTemp;
        ProxyAssembly.Find();
        Registers := GetRegistersWithInstalledAssembly(ProxyAssembly) + GetRegisterInstalledFlag();
        ProxyAssembly."Register Map".CreateOutStream(OutStream);
        Writer := Writer.StreamWriter(OutStream);
        Writer.Write(Registers);
        Writer.Close();
        ProxyAssembly.Modify();
        AssemblyTemp.Delete;

        Commit;

        if not Manager.AwaitingResponse then
            Manager.State := ProtocolState.InstalledAssemblies;
    end;

    local procedure ProtocolMessagingResponse(Manager: DotNet npNetProtocolManager; Envelope: DotNet npNetResponseEnvelope)
    var
        TempBlob: Record TempBlob;
        MessageResponse: DotNet npNetMessageResponse;
        Signal: DotNet npNetSignal;
    begin
        Manager.State := ProtocolState.Open;

        MessageResponse := MessageResponse.MessageResponse();
        MessageResponse.ProtocolManagerId := Manager.Id;
        MessageResponse.Envelope := Envelope;
        SerializeSignal(MessageResponse, Signal);
        Manager.Signal(Signal);
    end;

    local procedure ProtocolStateEnteredInitiated(Manager: DotNet npNetProtocolManager; PreviousState: Integer)
    begin
        ProtocolSecure(Manager, false);
    end;

    local procedure ProtocolStateEnteredSecured(Manager: DotNet npNetProtocolManager; PreviousState: Integer)
    begin
        //+NPR5.29
        if AssemblyCheckCompleted then begin
            Manager.State := ProtocolState.Open;
            exit;
        end;
        //-NPR5.29
        ProtocolGetAssemblies(Manager);
    end;

    local procedure ProtocolStateEnteredCheckedAssemblies(Manager: DotNet npNetProtocolManager; PreviousState: Integer)
    begin
        ProtocolInstallAssemblies(Manager);
    end;

    local procedure ProtocolStateEnteredInstalledAssemblies(Manager: DotNet npNetProtocolManager; PreviousState: Integer)
    begin
        AssembliesInstalled := true;
        //+NPR5.29
        AssemblyCheckCompleted := true;
        //-NPR5.29
        Manager.State := ProtocolState.Open;
    end;

    local procedure ProtocolStateEnteredOpen(Manager: DotNet npNetProtocolManager; PreviousState: Integer)
    var
        StartSignal: DotNet npNetStartSession;
        Signal: DotNet npNetSignal;
    begin
        ProtocolState := PreviousState;
        if Manager.IsInitiationProtocolState(ProtocolState) then begin
            StartSignal := StartSignal.StartSession();
            StartSignal.ProtocolManagerId := Manager.Id;
            SerializeSignal(StartSignal, Signal);
            Manager.Signal(Signal);
        end;
    end;

    procedure ProtocolClose(ProtocolManagerId: Guid)
    var
        Manager: DotNet npNetProtocolManager;
    begin
        GetProtocolManager(ProtocolManagerId, Manager);
        Manager.State := ProtocolState.Closed;
    end;

    procedure ProtocolAbort(ProtocolManagerId: Guid; ErrorMsg: Text)
    var
        Manager: DotNet npNetProtocolManager;
    begin
        GetProtocolManager(ProtocolManagerId, Manager);
        Manager.Abort(ErrorMsg);
    end;

    procedure AbortByUserRequest(ProtocolManagerId: Guid)
    var
        Manager: DotNet npNetProtocolManager;
    begin
        GetProtocolManager(ProtocolManagerId, Manager);
        Manager.State := ProtocolState.AbortedByUserRequest;
    end;

    procedure QueryClosePage(Manager: DotNet npNetProtocolManager)
    var
        QueryCloseSignal: DotNet npNetQueryClosePage;
        Signal: DotNet npNetSignal;
    begin
        QueryCloseSignal := QueryCloseSignal.QueryClosePage();
        SerializeSignal(QueryCloseSignal, Signal);
        Manager.Signal(Signal);
    end;

    local procedure GetRegisterInstalledFlag(): Text
    var
        POSWebSessionManagement: Codeunit "POS Web Session Management";
    begin
        exit(StrSubstNo('[%1]', POSWebSessionManagement.RegisterNo()));
    end;

    local procedure GetRegistersWithInstalledAssembly(ProxyAssembly: Record "Proxy Assembly") Registers: Text
    var
        Reader: DotNet npNetStreamReader;
        InStream: InStream;
    begin
        if ProxyAssembly."Register Map".HasValue() then begin
            ProxyAssembly.CalcFields("Register Map");
            ProxyAssembly."Register Map".CreateInStream(InStream);
            Reader := Reader.StreamReader(InStream);
            Registers := Reader.ReadToEnd();
        end;
    end;

    procedure SendMessage(ProtocolManagerId: Guid; Request: DotNet npNetRequest): Guid
    var
        Manager: DotNet npNetProtocolManager;
    begin
        GetProtocolManager(ProtocolManagerId, Manager);

        Manager.State := ProtocolState.Messaging;
        exit(Manager.SendMessage(Request));
    end;

    procedure SetModel(ProtocolManagerId: Guid; Model: DotNet npNetModel)
    var
        Manager: DotNet npNetProtocolManager;
    begin
        GetProtocolManager(ProtocolManagerId, Manager);
        Manager.Model := Model;
        Manager.UpdateModel();
    end;

    procedure UpdateModel(ProtocolManagerId: Guid)
    var
        Manager: DotNet npNetProtocolManager;
    begin
        GetProtocolManager(ProtocolManagerId, Manager);
        Manager.UpdateModel();
    end;

    procedure SetExpectedResponseType(ProtocolManagerId: Guid; Type: DotNet npNetType)
    var
        Manager: DotNet npNetProtocolManager;
    begin
        GetProtocolManager(ProtocolManagerId, Manager);
        Manager.RegisterResponseType(Type);
    end;

    procedure SetSkipStargate(SkipStargateIn: Boolean)
    begin
        //-NPR5.00.02
        SkipStargate := SkipStargateIn;
        //+NPR5.00.02
    end;
}

