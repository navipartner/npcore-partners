codeunit 6014627 "NPR Managed Dependency Mgt."
{
    Access = Internal;
    Permissions = TableData "NPR Web Client Dependency" = rimd,
                  TableData "NPR POS Stargate Package" = rimd;

    trigger OnRun()
    begin
        ClearLastError();

        if not ReadDependenciesFromGroundControl() then
            Error('Error when downloading dependencies from ground control: %1', GetLastErrorText);
    end;

    local procedure MaxSupportedPayloadVersion(): Integer
    begin
        exit(1);
    end;

    procedure ValidateGroundControlConfiguration(DepMgtSetup: Record "NPR Dependency Mgt. Setup")
    var
        JToken: JsonToken;
    begin
        GetJSON(
          DepMgtSetup,
          'ManagedDependency',
          JToken,
          '',
          false);
    end;

    procedure ExportManifest("Record": Variant; var JArray: JsonArray; PayloadVersion: Integer)
    var
        JObject: JsonObject;
        RecRef: RecordRef;
        FileName: Text;
        FileType: Text;
        Name: Text;
        FileVersion: Text;
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        FileNameLbl: Label '%1 %2 %3.json', Locked = true;
    begin
        RecRef.GetTable(Record);

        if JArray.Count() = 0 then
            exit;
        if not RecRef.FindFirst() then
            exit;

        GetTypeNameVersionFromRecordRef(RecRef, FileType, Name, FileVersion);
        FileName := StrSubstNo(FileNameLbl, FileType, Name, FileVersion);

        CreateDependencyJObject(JObject, FileType, Name, '1.0');
        JObject.Add('Description', '');
        JObject.Add('Payload Version', Format(PayloadVersion));
        JObject.Add('Data', JArray);

        TempBlob.CreateOutStream(OutStr);
        JObject.WriteTo(OutStr);
        TempBlob.CreateInStream(InStr);
        DownloadFromStream(InStr, 'TextExportTitle', '', 'JSON Files (*.json)|*.json|All Files (*.*)|*.*', FileName);
    end;

    procedure RecordToJArray("Record": Variant; var JArray: JsonArray)
    var
        RecRef: RecordRef;
        JObject: JsonObject;
        JObjectRec: JsonObject;
        i: Integer;
        FieldValue: Variant;
    begin
        RecRef.GetTable(Record);
        if RecRef.FindSet(false, false) then
            repeat
                Clear(JObject);
                AddToJObject(JObject, 'Record', RecRef.Number);
                Clear(JObjectRec);
                for i := 1 to RecRef.FieldCount do begin
                    FieldRefToVariant(RecRef.FieldIndex(i), FieldValue);
                    AddToJObject(JObjectRec, RecRef.FieldIndex(i).Name, FieldValue);
                end;
                JObject.Add('Fields', JObjectRec);
                JArray.Add(JObject);
            until RecRef.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnAfterInitialization', '', true, false)]
    local procedure OnAfterInitialization()
    var
        SessionId: Integer;
    begin
        if NavApp.IsInstalling() then
            exit;

        if CurrentClientType in [CLIENTTYPE::Windows, CLIENTTYPE::Web, CLIENTTYPE::Tablet, CLIENTTYPE::Phone, CLIENTTYPE::Desktop] then begin
            if not StartSession(SessionId, CODEUNIT::"NPR Managed Dependency Mgt.") then
                ReadDependenciesFromGroundControl();
        end;
    end;

    local procedure DependencyManagementConfigured(var DepMgtSetup: Record "NPR Dependency Mgt. Setup"): Boolean
    begin
        GetDependencyMgtSetup(DepMgtSetup);
        exit(not DepMgtSetup."Disable Deployment");
    end;

    local procedure ReadDependenciesFromGroundControl() Result: Boolean
    var
        DepMgtSetup: Record "NPR Dependency Mgt. Setup";
        JArray: JsonArray;
        JToken: JsonToken;
        DependencyObject: JsonObject;
        DependencyToken: JsonToken;
        i: Integer;
        KeysCount: Integer;
        JFilterLbl: Label '&$filter=Type eq ''%1'' and Name eq ''%2'' and Version eq ''%3''', Locked = true;
    begin
        if not DependencyManagementConfigured(DepMgtSetup) then
            exit(false);

        if not GetJSON(DepMgtSetup, 'ManagedDependencyList', JToken, GetAvailableDependenciesFilter(DepMgtSetup), false) then
            exit(false);

        if JToken.IsArray then
            KeysCount := JToken.AsArray().Count()
        else
            KeysCount := JToken.AsObject().Keys.Count();

        if KeysCount = 0 then
            exit(true);

        HoldSemaphore(); //Only one session should start downloading and storing dependencies, since there is no real synchronization for sessions downloading concurrently.

        //Recheck that there are still unresolved dependencies after grabbing semaphore.
        Clear(JToken);
        if not GetJSON(DepMgtSetup, 'ManagedDependencyList', JToken, GetAvailableDependenciesFilter(DepMgtSetup), false) then begin
            Commit();
            exit(false);
        end;

        Result := true;
        KeysCount := 0;

        JArray := JToken.AsArray();
        KeysCount := JArray.Count();

        for i := 0 to JArray.Count() - 1 do begin
            JArray.Get(i, JToken);
            DependencyObject := JToken.AsObject();
            if GetJSON(
              DepMgtSetup,
              'ManagedDependency',
              DependencyToken,
              StrSubstNo(
                JFilterLbl,
                GetJObjectValueAsText(DependencyObject, 'Type'),
                GetJObjectValueAsText(DependencyObject, 'Name'),
                GetJObjectValueAsText(DependencyObject, 'Version')),
              true)
            then begin
                if DeployDependency(GetJObjectValueAsText(DependencyToken.AsObject(), 'BLOB')) then
                    Result := Result and UpdateLog(DependencyToken.AsObject())
                else
                    Result := false;
            end else
                Result := false;
        end;

        Commit();

        if Result and (KeysCount > 0) then
            OnDependenciesDeployed();
    end;

    local procedure DeployDependency(Base64: Text): Boolean
    var
        JObject: JsonObject;
        JArray: JsonArray;
        Jtoken: JsonToken;
        i: Integer;
    begin
        if not Base64StringToJObject(Base64, Jtoken) then
            exit(false);

        JArray := Jtoken.AsArray();
        for i := 0 to JArray.Count() - 1 do begin
            JArray.Get(i, Jtoken);
            JObject := Jtoken.AsObject();
            if not DeployOneDependency(JObject) then
                exit(false);
        end;

        exit(true);
    end;

    local procedure DeployOneDependency(JObject: JsonObject) Result: Boolean
    var
        RecRef: RecordRef;
        FieldReference: FieldRef;
        "Record": Integer;
        AllObj: Record AllObj;
        JToken: JsonToken;
        FieldIDList: List of [Text];
        FieldID: Text;
    begin
        Evaluate(Record, GetJObjectValueAsText(JObject, 'Record'));

        if not AllObj.Get(AllObj."Object Type"::Table, Record) then
            exit(false);

        RecRef.Open(Record);
        if not RecRef.WritePermission then
            exit(false);

        JObject.Get('Fields', JToken);
        JObject := JToken.AsObject();
        FieldIDList := JObject.Keys();

        foreach FieldID in FieldIDList do
            if FieldRefByName(RecRef, FieldID, FieldReference) then begin
                JObject.Get(FieldID, JToken);
                if not JValueToFieldRef(JToken.AsValue(), FieldReference) then
                    exit(false);
            end;

        Result := RecRef.Insert(false);
        if not Result then
            Result := RecRef.Modify();
    end;

    [NonDebuggable]
    [TryFunction]
    procedure GetJSON(DepMgtSetup: Record "NPR Dependency Mgt. Setup"; Entity: Text; var JToken: JsonToken; FilterText: Text; Specific: Boolean)
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        Url: Text;
        JObject: JsonObject;
        JSON: Text;

    begin
        Client.UseWindowsAuthentication(AzureKeyVaultMgt.GetAzureKeyVaultSecret('NpDeployOdataUsername'), AzureKeyVaultMgt.GetAzureKeyVaultSecret('NpDeployOdataPassword'));
        Url := 'https://npdeploy.dynamics-retail.com:7088/NPDeploy/OData/Company(''RetailDemo'')/' + Entity + '?$format=json' + FilterText;

        if not Client.Get(URL, ResponseMessage) then
            Error('Failed to call URL: %1', URL);

        if not ResponseMessage.IsSuccessStatusCode then
            Error('Web service has returnend an error:\\' + 'Status code: %1\' + 'Status code: %2', ResponseMessage.HttpStatusCode, ResponseMessage.ReasonPhrase);

        ResponseMessage.Content.ReadAs(JSON);
        JObject.ReadFrom(JSON);
        JObject.Get('value', JToken);

        if Specific and (JToken.AsArray().Count() = 1) then
            JToken.AsArray().Get(0, JToken);
    end;

    [NonDebuggable]
    [TryFunction]
    procedure UpdateLog(Dependency: Jsonobject)
    var
        DepMgtSetup: Record "NPR Dependency Mgt. Setup";
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        JObject: JsonObject;
        JSON: text;
        Client: HttpClient;
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
        Response: HttpResponseMessage;
    begin
        GetDependencyMgtSetup(DepMgtSetup);

        CreateDependencyJObject(
          JObject,
          GetJObjectValueAsText(Dependency, 'Type'),
          GetJObjectValueAsText(Dependency, 'Name'),
          GetJObjectValueAsText(Dependency, 'Version'));
        JObject.Add('Service_Tier', GetServerID());

        JObject.WriteTo(JSON);

        RequestContent.WriteFrom(JSON);
        RequestContent.GetHeaders(ContentHeader);

        ContentHeader.Clear();
        ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'application/json');
        ContentHeader := Client.DefaultRequestHeaders();

        Client.UseWindowsAuthentication(AzureKeyVaultMgt.GetAzureKeyVaultSecret('NpDeployOdataUsername'), AzureKeyVaultMgt.GetAzureKeyVaultSecret('NpDeployOdataPassword'));
        Client.Post('https://npdeploy.dynamics-retail.com:7088/NPDeploy/OData/Company(''RetailDemo'')/' + 'ManagedDependenciesLog?$format=json', RequestContent, Response);

        if not Response.IsSuccessStatusCode then
            Error(Response.ReasonPhrase);
    end;

    local procedure GetJObjectValueAsText(JObject: JsonObject; TokenKey: Text) JTokenValueText: text
    var
        Jtoken: JsonToken;
    begin
        if JObject.Get(TokenKey, JToken) then
            JTokenValueText := Jtoken.AsValue().AsText();
    end;

    procedure GetServerID() ID: Text
    var
        String: Text;
    begin

        ID := GetUrl(CLIENTTYPE::Windows);
        String := CopyStr(ID, StrPos(ID, '//'));
        ID := String.Replace('//', '') + '/' + TenantId();

        if ID = '' then
            Error('Invalid address returned by GETURL: %1', GetLastErrorText);
    end;

    local procedure FieldRefByName(RecRef: RecordRef; Name: Text; var FieldReference: FieldRef): Boolean
    var
        i: Integer;
    begin
        for i := 1 to RecRef.FieldCount do
            if RecRef.FieldIndex(i).Name = Name then begin
                FieldReference := RecRef.FieldIndex(i);
                exit(true);
            end;
    end;

    local procedure GetAvailableDependenciesFilter(DepMgtSetup: Record "NPR Dependency Mgt. Setup") DependencyFilter: Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        DependencyFilter := '&$filter=' +
          SelectStr(DepMgtSetup."Accept Statuses" + 1, '(Status eq ''Released'') and ,(Status eq ''Staging'' or Status eq ''Released'') and ,') +
          'Service_Tier_Blank eq '''' and Service_Tier_Name eq ''' + TypeHelper.UriEscapeDataString(GetServerID()) + '''' +
          ' and Payload_Version le ' + Format(MaxSupportedPayloadVersion());
    end;

    local procedure GetTypeNameVersionFromRecordRef(RecRef: RecordRef; var FileType: Text; var Name: Text; var FileVersion: Text)
    var
        WebClientDependency: Record "NPR Web Client Dependency";
        StargatePackage: Record "NPR POS Stargate Package";
        FileNameLbl: Label '%1 %2', Locked = true;
    begin
        case RecRef.Number() of
            DATABASE::"NPR Web Client Dependency":
                begin
                    RecRef.SetTable(WebClientDependency);
                    FileType := 'Web Client Dependency';
                    Name := StrSubstNo(FileNameLbl, WebClientDependency.Type, WebClientDependency.Code);
                    FileVersion := '1.0';
                end;
            DATABASE::"NPR POS Stargate Package":
                begin
                    RecRef.SetTable(StargatePackage);
                    FileType := 'Stargate Package';
                    Name := StargatePackage.Name;
                    FileVersion := StargatePackage.Version;
                end;
            else begin
                    FileType := 'Other';
                    Name := RecRef.Name;
                    FileVersion := '1.0';
                end;
        end;
    end;

    procedure CreateDependencyJObject(var JObject: JsonObject; Type: Text; Name: Text; Version: Text)
    begin
        JObject.Add('Type', Type);
        JObject.Add('Name', Name);
        JObject.Add('Version', Version);
    end;

    procedure AddToJObject(JObject: JsonObject; "Key": Text; Value: Variant)
    var
        ValueInt: Integer;
        ValueBigInt: BigInteger;
        ValueOption: Option;
        ValueDec: Decimal;
        ValueBool: Boolean;
        ValueDate: Date;
        ValueDateTime: DateTime;
        ValueTime: Time;
        ValueDuration: Duration;
    begin
        case TRUE of
            Value.IsInteger:
                begin
                    ValueInt := Value;
                    JObject.Add(Key, ValueInt);
                end;
            Value.IsBigInteger:
                begin
                    ValueBigInt := Value;
                    JObject.Add(Key, ValueBigInt);
                end;
            Value.IsOption:
                begin
                    ValueOption := Value;
                    JObject.Add(Key, ValueOption);
                end;
            Value.IsDuration:
                begin
                    ValueDuration := Value;
                    JObject.Add(Key, ValueDuration);
                end;
            Value.IsDecimal:
                begin
                    ValueDec := Value;
                    JObject.Add(Key, ValueDec);
                end;
            Value.IsBoolean:
                begin
                    ValueBool := Value;
                    JObject.Add(Key, ValueBool);
                end;
            Value.IsDate:
                begin
                    ValueDate := Value;
                    JObject.Add(Key, ValueDate);
                end;
            Value.IsDateTime:
                begin
                    ValueDateTime := Value;
                    JObject.Add(Key, ValueDateTime);
                end;
            Value.IsTime:
                begin
                    ValueTime := Value;
                    JObject.Add(Key, ValueTime);
                end;
            else
                JObject.Add(Key, Format(Value));
        end;
    end;

    [TryFunction]
    procedure Base64StringToJObject(Base64: Text; var Jtoken: JsonToken)
    var
        Convert: Codeunit "Base64 Convert";
        JSON: Text;
    begin
        JSON := Convert.FromBase64(Base64, TextEncoding::UTF8);
        Jtoken.ReadFrom(JSON);
    end;

    procedure FieldRefToVariant(FieldReference: FieldRef; var FieldValue: Variant)
    begin
        case UpperCase(Format(FieldReference.Type())) of
            'BLOB':
                FieldValue := BLOBToBase64String(FieldReference);
            'DATE', 'TIME', 'DATEFORMULA', 'DURATION', 'RECORDID', 'DATETIME':
                FieldValue := Format(FieldReference.Value(), 0, 9);
            'TABLEFILTER':
                FieldValue := ''; //Not supported
            else
                FieldValue := FieldReference.Value();
        end;
    end;

    [TryFunction]
    procedure JValueToFieldRef(JValue: JsonValue; FieldReference: FieldRef)
    var
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        OutStr: OutStream;
        ValueText: Text;
        ValueDateFormula: DateFormula;
        ValueDuration: Duration;
        ValueGUID: Guid;
        ValueRecordID: RecordID;
    begin
        case UpperCase(Format(FieldReference.Type)) of
            'CODE', 'TEXT':
                FieldReference.Value := JValue.AsText();
            'OPTION':
                FieldReference.Value := JValue.AsOption();
            'INTEGER', 'BIGINTEGER':
                FieldReference.Value := JValue.AsBigInteger();
            'DECIMAL':
                FieldReference.Value := JValue.AsDecimal();
            'BOOLEAN':
                FieldReference.Value := JValue.AsBoolean();
            'DATE':
                FieldReference.Value := JValue.AsDate();
            'DATETIME':
                FieldReference.Value := JValue.AsDateTime();
            'TIME':
                FieldReference.Value := JValue.AsTime();
            'BLOB':
                begin
                    ValueText := JValue.AsText();
                    TempBlob.CreateOutStream(OutStr);
                    OutStr.WriteText(Base64Convert.FromBase64(ValueText));
                    TempBlob.ToFieldRef(FieldReference);
                end;
            'DATEFORMULA':
                begin
                    Evaluate(ValueDateFormula, JValue.AsText(), 9);
                    FieldReference.Value := ValueDateFormula;
                end;
            'DURATION':
                begin
                    Evaluate(ValueDuration, JValue.AsText(), 9);
                    FieldReference.Value := ValueDuration;
                end;
            'GUID':
                begin
                    Evaluate(ValueGUID, JValue.AsText());
                    FieldReference.Value := ValueGUID;
                end;
            'RECORDID':
                begin
                    Evaluate(ValueRecordID, JValue.AsText(), 9);
                    FieldReference.Value := ValueRecordID;
                end;
            'TABLEFILTER':
                ; //Not supported
        end;
    end;

    local procedure BLOBToBase64String(FieldReference: FieldRef) FieldValue: Text
    var
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        InStr: InStream;
        StreamContent: Text;
    begin
        FieldValue := '';
        FieldReference.CalcField();
        TempBlob.FromFieldRef(FieldReference);
        if TempBlob.HasValue() then begin
            TempBlob.CreateInStream(InStr);
            InStr.ReadText(StreamContent);
            FieldValue := Base64Convert.ToBase64(StreamContent);
        end;
    end;

    procedure GetDependencyMgtSetup(var DepMgtSetup: Record "NPR Dependency Mgt. Setup")
    begin
        if not DepMgtSetup.Get() then
            DepMgtSetup.Insert();
    end;

    local procedure HoldSemaphore()
    var
        DepMgtSetup: Record "NPR Dependency Mgt. Setup";
    begin
        DepMgtSetup.LockTable();
        DepMgtSetup.Get();
    end;

    [BusinessEvent(FALSE)]
    local procedure OnDependenciesDeployed()
    begin
    end;

    procedure ParseJSON(JSON: Text): JsonToken
    var
        JObject: JsonObject;
        JArray: JsonArray;
    begin
        if JObject.ReadFrom(JSON) then
            exit(JObject.AsToken());
        if JArray.ReadFrom(JSON) then
            exit(JArray.AsToken());
    end;

    procedure DownloadFileFromAzureBlobToUserDevice(URL: Text; DialogTitle: Text; ToFolder: Text; ToFilter: Text; var ToFile: Text; var ErrorReasonPhrase: Text): Boolean
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        InStr: InStream;
        FileDownloaded: Boolean;
    begin
        Client.Get(URL, ResponseMessage);

        if ResponseMessage.IsSuccessStatusCode then begin
            ResponseMessage.Content.ReadAs(InStr);
            FileDownloaded := DownloadFromStream(InStr, DialogTitle, ToFolder, ToFilter, ToFile);
            if not FileDownloaded then
                //Bypass warning message for EXE files: The file that you are trying to access cannot be downloaded. The destination file has an extension that may be blocked. Contact your system administrator
                exit(true)
            else
                exit(true);
        end;

        ErrorReasonPhrase := ResponseMessage.ReasonPhrase;
        exit(false);
    end;


}

