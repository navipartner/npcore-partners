codeunit 6014627 "NPR Managed Dependency Mgt."
{
    Permissions = TableData "NPR POS Web Font" = rimd,
                  TableData "NPR .NET Assembly" = rimd,
                  TableData "NPR Web Client Dependency" = rimd,
                  TableData "Add-in" = rimd;

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
        FileMgt: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
        JObject: JsonObject;
        OuStr: OutStream;
        JObjectToString: Text;
        FileName: Text;
        FileType: Text;
        Name: Text;
        FileVersion: Text;
    begin
        if JArray.Count() = 0 then
            exit;

        RecRef.GetTable(Record);
        if not RecRef.FindFirst() then
            exit;

        GetTypeNameVersionFromRecordRef(RecRef, FileType, Name, FileVersion);
        FileName := StrSubstNo('%1 %2 %3.json', FileType, Name, FileVersion);

        JObject := CreateDependencyJObject(FileType, Name, '1.0');
        JObject.Add('Description', '');
        JObject.Add('Payload Version', Format(PayloadVersion));
        JObject.Add('Data', JArray);

        JObject.WriteTo(JObjectToString);
        TempBlob.CreateOutStream(OuStr);
        OuStr.WriteText(JObjectToString);
        FileMgt.BLOBExport(TempBlob, FileName, true);
    end;

    procedure RecordToJArray(Rec: Variant; var JArray: JsonArray)
    var
        RecRef: RecordRef;
        JObject: JsonObject;
        JObjectRec: JsonObject;
        FieldValue: Variant;
        i: Integer;
        FieldName: Text;
    begin
        RecRef.GetTable(Rec);
        if RecRef.FindSet(false, false) then
            repeat
                Clear(JObject);
                JObject.Add('Record', RecRef.Number());
                Clear(JObjectRec);
                for i := 1 to RecRef.FieldCount() do begin
                    FieldRefToVariant(RecRef.FieldIndex(i), FieldValue);
                    JObjectRec.Add(Strsubstno('%1', RecRef.FieldIndex(i).Name()), format(FieldValue, 0, 9));
                end;
                JObject.Add('Fields', JObjectRec);
                JArray.Add(JObject);
            until RecRef.Next = 0;
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
    var
        UserSetup: Record "User Setup";
    begin
        GetDependencyMgtSetup(DepMgtSetup);
        exit(DepMgtSetup.Configured and not DepMgtSetup."Disable Deployment");
    end;

    local procedure ReadDependenciesFromGroundControl() Result: Boolean
    var
        DepMgtSetup: Record "NPR Dependency Mgt. Setup";
        JObject: JsonObject;
        JArray: JsonArray;
        Dependency: JsonObject;
        JToken: JsonToken;
        JToken2: JsonToken;
        JToken3: JsonToken;
        JToken4: JsonToken;
        DependencyFilter: Text;
    begin
        if not DependencyManagementConfigured(DepMgtSetup) then
            exit(false);

        if not GetJSON(DepMgtSetup, 'ManagedDependencyList', JToken, GetAvailableDependenciesFilter(DepMgtSetup), false) then
            exit(false);

        if not JToken.IsArray() then
            exit;

        JArray := JToken.AsArray();
        if JArray.Count() = 0 then
            exit(true);

        HoldSemaphore(); //Only one session should start downloading and storing dependencies, since there is no real synchronization for sessions downloading concurrently.

        //Recheck that there are still unresolved dependencies after grabbing semaphore.
        Clear(JToken);
        if not GetJSON(DepMgtSetup, 'ManagedDependencyList', JToken, GetAvailableDependenciesFilter(DepMgtSetup), false) then begin
            Commit();
            exit(false);
        end;

        JArray := JToken.AsArray();
        Result := true;
        Clear(JToken);
        foreach JToken in JArray do begin
            Dependency := JToken.AsObject();
            Dependency.Get('Type', JToken2);
            Dependency.Get('Name', JToken3);
            Dependency.Get('Version', JToken4);
            DependencyFilter := StrSubstNo('&$filter=Type eq ''%1'' and Name eq ''%2'' and Version eq ''%3''',
                                            JToken2.AsValue().AsText(),
                                            JToken3.AsValue().AsText(),
                                            JToken4.AsValue().AsText());
            JToken2 := Dependency.AsToken();
            if GetJSON(DepMgtSetup, 'ManagedDependency', JToken2, DependencyFilter, true) then begin
                Dependency := JToken2.AsObject();
                Dependency.Get('BLOB', JToken2);
                if DeployDependency(JToken2.AsValue().AsText()) then
                    Result := Result and UpdateLog(Dependency)
                else
                    Result := false;
            end else begin
                Result := false;
            end;
        end;

        Commit();

        if Result and (JArray.Count() > 0) then
            OnDependenciesDeployed();
    end;

    local procedure DeployDependency(Base64: Text): Boolean
    var
        JArray: JsonArray;
        JToken: JsonToken;
        JObject: JsonObject;
    begin
        if not Base64StringToJObject(Base64, JArray) then
            exit(false);

        foreach JToken in JArray do begin
            if not DeployOneDependency(JToken.AsObject()) then
                exit(false);
        end;

        exit(true);
    end;

    local procedure DeployOneDependency(JObject: JsonObject) Result: Boolean
    var
        AllObj: Record AllObj;
        JToken: JsonToken;
        JTokenFieldValue: JsonToken;
        JArray: JsonArray;
        RecRef: RecordRef;
        FieldReference: FieldRef;
        TableNo: Integer;
        FieldName: Text;
        JObjectKeys: List of [Text];
    begin
        JObject.Get('Record', JToken);
        TableNo := JToken.AsValue().AsInteger();

        if not AllObj.Get(AllObj."Object Type"::Table, TableNo) then
            exit(false);

        RecRef.Open(TableNo);
        if not RecRef.WritePermission() then
            exit(false);

        JObject.Get('Fields', JToken);
        JObject := JToken.AsObject();
        JObjectKeys := JObject.Keys();
        foreach FieldName in JObjectKeys do begin
            JObject.Get(FieldName, JTokenFieldValue);
            if FieldRefByName(RecRef, FieldName, FieldReference) then
                if not TextToFieldRef(JTokenFieldValue.AsValue().AsText(), FieldReference) then
                    exit(false);
        end;

        Result := RecRef.Insert(false);
        if not Result then
            Result := RecRef.Modify();
    end;

    [TryFunction]
    procedure GetJSON(DepMgtSetup: Record "NPR Dependency Mgt. Setup"; Entity: Text; var JToken: JsonToken; FilterText: Text; Specific: Boolean)
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        JObject: JsonObject;
        JArray: JsonArray;
        Response: Text;
        Url: Text;
    begin
        Client.UseWindowsAuthentication(DepMgtSetup.Username, DepMgtSetup.GetManagedDependencyPassword());
        Url := DepMgtSetup."OData URL" + '/' + Entity + '?$format=json' + FilterText;
        Client.Get(Url, ResponseMessage);
        ResponseMessage.Content().ReadAs(Response);
        JToken := ParseJSON(Response);
        JObject := JToken.AsObject();
        JObject.Get('value', JToken);
        JArray := JToken.AsArray();
        if Specific and (JArray.Count() = 1) then begin
            JArray.Get(0, JToken);
        end;
    end;

    [TryFunction]
    procedure UpdateLog(Dependency: JsonObject)
    var
        DepMgtSetup: Record "NPR Dependency Mgt. Setup";
        JObject: JsonObject;
        JToken: JsonToken;
        JToken2: JsonToken;
        JToken3: JsonToken;
        Client: HttpClient;
        Headers: HttpHeaders;
        Content: HttpContent;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Request: Text;
    begin
        GetDependencyMgtSetup(DepMgtSetup);
        Dependency.Get('Type', JToken);
        Dependency.Get('Name', JToken2);
        Dependency.Get('Version', JToken3);

        JObject := CreateDependencyJObject(
                        JToken.AsValue().AsText(),
                        JToken2.AsValue().AsText(),
                        JToken3.AsValue().AsText());
        JObject.Add('Service_Tier', GetServerID());
        JObject.WriteTo(Request);

        RequestMessage.Method := 'POST';
        RequestMessage.SetRequestUri(DepMgtSetup."OData URL" + '/ManagedDependenciesLog?$format=json');
        RequestMessage.GetHeaders(Headers);
        Headers.Add('Accept', 'application/json');
        Content.WriteFrom(Request);
        RequestMessage.Content := Content;
        Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/json');

        Client.UseWindowsAuthentication(DepMgtSetup.Username, DepMgtSetup.GetManagedDependencyPassword());
        Client.Send(RequestMessage, ResponseMessage);
    end;

    procedure GetServerID() ID: Text
    var
        String: Text;
    begin
        ID := GetUrl(CLIENTTYPE::Default);
        String := CopyStr(ID, StrPos(ID, '//'));
        ID := String.Replace('//', '') + '/' + TenantId;
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

        //Below types are deprecated starting with AL:
        DependencyFilter += ' and Type ne ''Control Add-in''';
    end;

    local procedure GetTypeNameVersionFromRecordRef(RecRef: RecordRef; var FileType: Text; var Name: Text; var FileVersion: Text)
    var
        AddIn: Record "Add-in";
        DotNetLibrary: Record "NPR .NET Assembly";
        WebClientDependency: Record "NPR Web Client Dependency";
        WebFont: Record "NPR POS Web Font";
        StargatePackage: Record "NPR POS Stargate Package";
    begin
        case RecRef.Number() of
            DATABASE::"Add-in":
                begin
                    RecRef.SetTable(AddIn);
                    FileType := 'Control Add-in';
                    Name := AddIn."Add-in Name";
                    FileVersion := AddIn.Version;
                end;
            DATABASE::"NPR .NET Assembly":
                begin
                    RecRef.SetTable(DotNetLibrary);
                    FileType := '.NET Assembly';
                    Name := DotNetLibrary."Assembly Name";
                    FileVersion := '1.0';
                end;
            DATABASE::"NPR Web Client Dependency":
                begin
                    RecRef.SetTable(WebClientDependency);
                    FileType := 'Web Client Dependency';
                    Name := StrSubstNo('%1 %2', WebClientDependency.Type, WebClientDependency.Code);
                    FileVersion := '1.0';
                end;
            DATABASE::"NPR POS Web Font":
                begin
                    RecRef.SetTable(WebFont);
                    FileType := 'Web Font';
                    Name := WebFont.Name;
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

    procedure CreateDependencyJObject(FileType: Text; Name: Text; FileVersion: Text): JsonObject
    var
        JObject: JsonObject;
    begin
        JObject.Add('Type', FileType);
        JObject.Add('Name', Name);
        JObject.Add('Version', FileVersion);
        exit(JObject);
    end;

    [TryFunction]
    procedure Base64StringToJObject(Base64: Text; var JArray: JsonArray)
    var
        Base64Convert: Codeunit "Base64 Convert";
    begin
        JArray.ReadFrom(Base64Convert.FromBase64(Base64));
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
    procedure TextToFieldRef(FieldValue: Text; FieldReference: FieldRef)
    var
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        ValueInt: Integer;
        ValueBigInt: BigInteger;
        ValueDec: Decimal;
        ValueBool: Boolean;
        ValueDate: Date;
        ValueDateTime: DateTime;
        ValueTime: Time;
        ValueText: Text;
        ValueDateFormula: DateFormula;
        ValueDuration: Duration;
        ValueGUID: Guid;
        ValueRecordID: RecordID;
    begin
        case UpperCase(Format(FieldReference.Type())) of
            'CODE', 'TEXT':
                FieldReference.Value := FieldValue;
            'INTEGER', 'BIGINTEGER', 'OPTION':
                begin
                    Evaluate(ValueBigInt, FieldValue);
                    FieldReference.Value := ValueBigInt;
                end;
            'DECIMAL':
                begin
                    Evaluate(ValueDec, FieldValue);
                    FieldReference.Value := ValueDec;
                end;
            'BOOLEAN':
                begin
                    Evaluate(ValueBool, FieldValue);
                    FieldReference.Value := ValueBool;
                end;
            'DATE':
                begin
                    Evaluate(ValueDate, FieldValue, 9);
                    FieldReference.Value := ValueDate;
                end;
            'DATETIME':
                begin
                    if not Evaluate(ValueDateTime, FIeldValue, 9) then //Legacy: Fallback to non-XML format parse since some packages contain DateTimes in that format.
                        Evaluate(ValueDateTime, FieldValue);
                    FieldReference.Value := ValueDateTime;
                end;
            'TIME':
                begin
                    Evaluate(ValueTime, FieldValue, 9);
                    FieldReference.Value := ValueTime;
                end;
            'BLOB':
                begin
                    ValueText := FieldValue;
                    TempBlob.CreateOutStream(OutStr);
                    OutStr.WriteText(Base64Convert.FromBase64(ValueText));
                    TempBlob.ToFieldRef(FieldReference);
                end;
            'DATEFORMULA':
                begin
                    Evaluate(ValueDateFormula, FieldValue, 9);
                    FieldReference.Value := ValueDateFormula;
                end;
            'DURATION':
                begin
                    Evaluate(ValueDuration, FieldValue, 9);
                    FieldReference.Value := ValueDuration;
                end;
            'GUID':
                begin
                    Evaluate(ValueGUID, FieldValue);
                    FieldReference.Value := ValueGUID;
                end;
            'RECORDID':
                begin
                    Evaluate(ValueRecordID, FieldValue, 9);
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

    [BusinessEvent(false)]
    local procedure OnAfterReadDependenciesFromGroundControl()
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
}

