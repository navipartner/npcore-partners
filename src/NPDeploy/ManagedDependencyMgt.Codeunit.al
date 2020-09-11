codeunit 6014627 "NPR Managed Dependency Mgt."
{
    // NPR5.01/VB/20160215 CASE 234462 Object created to support managed dependency deployment
    // NPR5.20/VB/20160225 CASE 235620 Tag filtering commented out as it does not work correctly
    //                                 User filtering for Ground Control deployment
    //                                 Permissions set on the codeunit to allow writing to managed tables
    // NPR5.26/MMV /20160905 CASE 242977 Moved ground control boolean away from user table.
    // NPR5.26/MMV /20160922 CASE 252131 Made multiple functions global so that they can be reused from new codeunits 6014628 & 6014629.
    //                                   Added handling of all NAV field types.
    //                                   Fixed some region-specific value storage.
    // NPR5.32.10/MMV /20170308 CASE 265454 Added support for stargate packages.
    //                                   Split ExportManifest into 2 functions (New function: AddToManifest) to facilitate manifests containing data from more than 1 table.
    // NPR5.32.10/MMV /20170609 CASE 280081 Handle if table doesn't exist.
    //                                   Added payload versioning support.
    //                                   Changed odata filter string from text constant to in-line string.
    // NPR5.37/MMV /20170710 CASE 283546 Synchronize dependency download across multiple sessions.
    //                                   Moved dependency download to background sessions.
    // NPR5.38/MMV /20171204 CASE 294095 Properly fixed DateTime handling by disabling newtonsoft date parsing to make it pass the exact XML NAV format back.
    // NPR5.38/MMV /20171219 CASE 299217 Don't block user login if background session cannot be started.
    // NPR5.38/MMV /20180112 CASE 302065 Better error handling & hardcoded caption that should not be translated.
    // NPR5.38/LS  /20171218 CASE 300124 Set property OnMissingLicense to Skip for function OnAfterCompanyOpen
    // NPR5.38/MMV /20180119 CASE 300683 Skip subscriber when installing extension
    // NPR5.40/MMV /20180312 CASE 307878 Skip control add-ins on tenants without write access
    // NPR5.42/MMV /20180405 CASE 314114 Fallback to user session if STARTSESSION fails
    // TM1.39/THRO/20181126 CASE 334644 Replaced Coudeunit 1 by Wrapper Codeunit

    Permissions = TableData "NPR POS Web Font" = rimd,
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
        JObject: DotNet JObject;
    begin
        GetJSON(
          DepMgtSetup,
          'ManagedDependency',
          JObject,
          '',
          false);
    end;

    procedure ExportManifest("Record": Variant; var JArray: DotNet JArray; PayloadVersion: Integer)
    var
        JObject: DotNet JObject;
        [RunOnClient]
        IOFile: DotNet NPRNetFile;
        RecRef: RecordRef;
        FileName: Text;
        Type: Text;
        Name: Text;
        Version: Text;
    begin
        RecRef.GetTable(Record);

        if IsNull(JArray) then
            exit;
        if JArray.Count = 0 then
            exit;
        if not RecRef.FindFirst then
            exit;

        GetTypeNameVersionFromRecordRef(RecRef, Type, Name, Version);
        FileName := GetExportFileName(StrSubstNo('%1 %2 %3.json', Type, Name, Version));
        if FileName = '' then
            exit;

        CreateDependencyJObject(JObject, Type, Name, '1.0');
        AddToJObject(JObject, 'Description', '');
        AddToJObject(JObject, 'Payload Version', Format(PayloadVersion));
        JObject.Add('Data', JArray);

        IOFile.WriteAllText(FileName, JObject.ToString());
    end;

    procedure RecordToJArray("Record": Variant; var JArray: DotNet JArray)
    var
        RecRef: RecordRef;
        JObject: DotNet JObject;
        JObjectRec: DotNet JObject;
        i: Integer;
        Value: Variant;
    begin
        RecRef.GetTable(Record);
        if RecRef.FindSet(false, false) then
            repeat
                JObject := JObject.JObject();
                AddToJObject(JObject, 'Record', RecRef.Number);
                JObjectRec := JObjectRec.JObject();
                for i := 1 to RecRef.FieldCount do begin
                    FieldRefToVariant(RecRef.FieldIndex(i), Value);
                    AddToJObject(
                      JObjectRec,
                      RecRef.FieldIndex(i).Name,
                      Value);
                end;
                JObject.Add('Fields', JObjectRec);
                AddToJArray(JArray, JObject);
            until RecRef.Next = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014427, 'OnAfterCompanyOpen', '', true, false)]
    local procedure OnAfterCompanyOpen()
    var
        SessionId: Integer;
    begin
        if NavApp.IsInstalling() then
            exit;

        if CurrentClientType in [CLIENTTYPE::Windows, CLIENTTYPE::Web, CLIENTTYPE::Tablet, CLIENTTYPE::Phone, CLIENTTYPE::Desktop] then begin
            //-NPR5.42 [314114]
            //IF STARTSESSION(SessionId, CODEUNIT::"Managed Dependency Mgt.") THEN
            if not StartSession(SessionId, CODEUNIT::"NPR Managed Dependency Mgt.") then
                ReadDependenciesFromGroundControl();
            //+NPR5.42 [314114]
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
        JObject: DotNet JObject;
        Dependency: DotNet JObject;
        i: Integer;
        Type: Text;
    begin
        if not DependencyManagementConfigured(DepMgtSetup) then
            exit(false);

        if not GetJSON(DepMgtSetup, 'ManagedDependencyList', JObject, GetAvailableDependenciesFilter(DepMgtSetup), false) then
            exit(false);

        if JObject.Count = 0 then
            exit(true);

        HoldSemaphore(); //Only one session should start downloading and storing dependencies, since there is no real synchronization for sessions downloading concurrently.

        //Recheck that there are still unresolved dependencies after grabbing semaphore.
        Clear(JObject);
        if not GetJSON(DepMgtSetup, 'ManagedDependencyList', JObject, GetAvailableDependenciesFilter(DepMgtSetup), false) then begin
            Commit;
            exit(false);
        end;

        Result := true;
        for i := 0 to JObject.Count - 1 do begin
            Dependency := JObject.Item(i);
            if GetJSON(
              DepMgtSetup,
              'ManagedDependency',
              Dependency,
              StrSubstNo(
                '&$filter=Type eq ''%1'' and Name eq ''%2'' and Version eq ''%3''',
                JObject.Item(i).Item('Type'),
                JObject.Item(i).Item('Name'),
                JObject.Item(i).Item('Version')),
              true)
            then begin
                if DeployDependency(Dependency.Item('BLOB').ToString()) then
                    Result := Result and UpdateLog(Dependency)
                else
                    Result := false;
            end else
                Result := false;
        end;

        Commit;

        if Result and (JObject.Count > 0) then
            OnDependenciesDeployed();
    end;

    local procedure DeployDependency(Base64: Text): Boolean
    var
        JObject: DotNet JObject;
        i: Integer;
    begin
        if not Base64StringToJObject(Base64, JObject) then
            exit(false);

        for i := 0 to JObject.Count - 1 do
            if not DeployOneDependency(JObject.Item(i)) then
                exit(false);

        exit(true);
    end;

    local procedure DeployOneDependency(JObject: DotNet JObject) Result: Boolean
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        KeyValuePair: DotNet NPRNetKeyValuePair_Of_T_U;
        "Record": Integer;
        AllObj: Record AllObj;
    begin
        Evaluate(Record, JObject.GetValue('Record').ToString());

        if not AllObj.Get(AllObj."Object Type"::Table, Record) then
            exit(false);

        RecRef.Open(Record);
        if not RecRef.WritePermission then
            exit(false);

        JObject := JObject.Item('Fields');
        foreach KeyValuePair in JObject do
            if FieldRefByName(RecRef, KeyValuePair.Key, FieldRef) then
                if not TextToFieldRef(KeyValuePair.Value, FieldRef) then
                    exit(false);

        Result := RecRef.Insert(false);
        if not Result then
            Result := RecRef.Modify;
    end;

    [TryFunction]
    procedure GetJSON(DepMgtSetup: Record "NPR Dependency Mgt. Setup"; Entity: Text; var JObject: DotNet JObject; FilterText: Text; Specific: Boolean)
    var
        WebClient: DotNet NPRNetWebClient;
        Credential: DotNet NPRNetNetworkCredential;
        Url: Text;
    begin
        WebClient := WebClient.WebClient();
        WebClient.Credentials :=
          Credential.NetworkCredential(
            DepMgtSetup.Username,
            DepMgtSetup.GetManagedDependencyPassword());

        Url := DepMgtSetup."OData URL" + '/' + Entity + '?$format=json' + FilterText;
        ParseJSON(WebClient.DownloadString(Url), JObject);
        JObject := JObject.Item('value');

        if Specific and (JObject.Count = 1) then
            JObject := JObject.Item(0);
    end;

    [TryFunction]
    procedure UpdateLog(Dependency: DotNet JObject)
    var
        DepMgtSetup: Record "NPR Dependency Mgt. Setup";
        JObject: DotNet JObject;
        HttpWebRequest: DotNet NPRNetHttpWebRequest;
        Credential: DotNet NPRNetNetworkCredential;
        StreamWriter: DotNet NPRNetStreamWriter;
        Encoding: DotNet NPRNetEncoding;
    begin
        GetDependencyMgtSetup(DepMgtSetup);

        CreateDependencyJObject(
          JObject,
          Dependency.GetValue('Type').ToString(),
          Dependency.GetValue('Name').ToString(),
          Dependency.GetValue('Version').ToString());
        AddToJObject(JObject, 'Service_Tier', GetServerID);

        HttpWebRequest := HttpWebRequest.Create(DepMgtSetup."OData URL" + '/ManagedDependenciesLog?$format=json');
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.Accept := 'application/json';
        HttpWebRequest.ContentType := 'application/json';
        HttpWebRequest.Credentials := Credential.NetworkCredential(DepMgtSetup.Username, DepMgtSetup.GetManagedDependencyPassword());

        StreamWriter := StreamWriter.StreamWriter(HttpWebRequest.GetRequestStream(), Encoding.UTF8);
        StreamWriter.Write(JObject.ToString());
        StreamWriter.Close();

        HttpWebRequest.GetResponse();
    end;

    procedure GetServerID() ID: Text
    var
        String: DotNet NPRNetString;
    begin
        ID := GetUrl(CLIENTTYPE::Windows);
        String := CopyStr(ID, StrPos(ID, '//'));
        ID := String.Replace('//', '') + '/' + TenantId;
        if ID = '' then
            Error('Invalid address returned by GETURL: %1', GetLastErrorText);
    end;

    local procedure FieldRefByName(RecRef: RecordRef; Name: Text; var FieldRef: FieldRef): Boolean
    var
        i: Integer;
    begin
        for i := 1 to RecRef.FieldCount do
            if RecRef.FieldIndex(i).Name = Name then begin
                FieldRef := RecRef.FieldIndex(i);
                exit(true);
            end;
    end;

    local procedure GetAvailableDependenciesFilter(DepMgtSetup: Record "NPR Dependency Mgt. Setup") "Filter": Text
    var
        Uri: DotNet NPRNetUri;
        "ControlAddin": Record "Add-in";
    begin
        Filter := '&$filter=' +
          SelectStr(DepMgtSetup."Accept Statuses" + 1, '(Status eq ''Released'') and ,(Status eq ''Staging'' or Status eq ''Released'') and ,') +
          'Service_Tier_Blank eq '''' and Service_Tier_Name eq ''' + Uri.EscapeDataString(GetServerID()) + '''' +
          ' and Payload_Version le ' + Format(MaxSupportedPayloadVersion());

        //Below types are deprecated starting with AL:
        Filter += ' and Type ne ''Control Add-in''';
        Filter += ' and Type ne ''.NET Assembly''';
    end;

    local procedure GetExportFileName(DefaultFileName: Text) FileName: Text
    var
        TextExportTitle: Label 'Export Managed Dependency Manifest';
        FileManagement: Codeunit "File Management";
    begin
        FileName := FileManagement.SaveFileDialog(
          TextExportTitle, DefaultFileName,
          'JSON Files (*.json)|*.json|All Files (*.*)|*.*');

        if FileName = '' then
            exit;
    end;

    local procedure GetTypeNameVersionFromRecordRef(RecRef: RecordRef; var Type: Text; var Name: Text; var Version: Text)
    var
        AddIn: Record "Add-in";
        WebClientDependency: Record "NPR Web Client Dependency";
        WebFont: Record "NPR POS Web Font";
        StargatePackage: Record "NPR POS Stargate Package";
    begin
        case RecRef.Number of
            DATABASE::"Add-in":
                begin
                    RecRef.SetTable(AddIn);
                    Type := 'Control Add-in';
                    Name := AddIn."Add-in Name";
                    Version := AddIn.Version;
                end;
            6014623: //.NET Assembly
                begin
                end;
            DATABASE::"NPR Web Client Dependency":
                begin
                    RecRef.SetTable(WebClientDependency);
                    Type := 'Web Client Dependency';
                    Name := StrSubstNo('%1 %2', WebClientDependency.Type, WebClientDependency.Code);
                    Version := '1.0';
                end;
            DATABASE::"NPR POS Web Font":
                begin
                    RecRef.SetTable(WebFont);
                    Type := 'Web Font';
                    Name := WebFont.Name;
                    Version := '1.0';
                end;
            DATABASE::"NPR POS Stargate Package":
                begin
                    RecRef.SetTable(StargatePackage);
                    Type := 'Stargate Package';
                    Name := StargatePackage.Name;
                    Version := StargatePackage.Version;
                end;
            else begin
                    Type := 'Other';
                    Name := RecRef.Name;
                    Version := '1.0';
                end;
        end;
    end;

    procedure CreateDependencyJObject(var JObject: DotNet JObject; Type: Text; Name: Text; Version: Text)
    begin
        JObject := JObject.JObject();
        AddToJObject(JObject, 'Type', Type);
        AddToJObject(JObject, 'Name', Name);
        AddToJObject(JObject, 'Version', Version);
    end;

    procedure AddToJObject(JObject: DotNet JObject; "Key": Text; Value: Variant)
    var
        JToken: DotNet JToken;
    begin
        JObject.Add(Key, JToken.FromObject(Value));
    end;

    procedure AddToJArray(JArray: DotNet JArray; JObject: DotNet JObject)
    var
        Type: DotNet NPRNetType;
        Types: DotNet NPRNetArray;
        JToken: DotNet JToken;
        MethodInfo: DotNet NPRNetMethodInfo;
        Params: DotNet NPRNetArray;
    begin
        Type := GetDotNetType(JArray);
        Types := Types.CreateInstance(GetDotNetType(GetDotNetType(0)), 1);
        Types.SetValue(GetDotNetType(JToken), 0);
        MethodInfo := Type.GetMethod('Add', Types);

        Params := Params.CreateInstance(GetDotNetType(JToken), 1);
        Params.SetValue(JObject, 0);
        MethodInfo.Invoke(JArray, Params);
    end;

    [TryFunction]
    procedure Base64StringToJObject(Base64: Text; var JObject: DotNet JObject)
    var
        JArray: DotNet JArray;
        MemStream: DotNet NPRNetMemoryStream;
        StreamReader: DotNet NPRNetStreamReader;
        Convert: DotNet NPRNetConvert;
        Encoding: DotNet NPRNetEncoding;
        JSON: Text;
        JsonTextReader: DotNet NPRNetJsonTextReader;
        DateParseHandling: DotNet NPRNetDateParseHandling;
        NetConvHelper: Variant;
    begin
        MemStream := MemStream.MemoryStream(Convert.FromBase64String(Base64));
        StreamReader := StreamReader.StreamReader(MemStream, Encoding.UTF8);
        JsonTextReader := JsonTextReader.JsonTextReader(StreamReader);
        JsonTextReader.DateParseHandling := DateParseHandling.None;
        NetConvHelper := JArray.Load(JsonTextReader);
        JObject := NetConvHelper;
    end;

    procedure FieldRefToVariant(FieldRef: FieldRef; var Value: Variant)
    begin
        case UpperCase(Format(FieldRef.Type)) of
            'BLOB':
                Value := BLOBToBase64String(FieldRef);
            'DATE', 'TIME', 'DATEFORMULA', 'DURATION', 'RECORDID', 'DATETIME':
                Value := Format(FieldRef.Value, 0, 9);
            'TABLEFILTER':
                Value := ''; //Not supported
            else
                Value := FieldRef.Value;
        end;
    end;

    [TryFunction]
    procedure TextToFieldRef(Value: Text; FieldRef: FieldRef)
    var
        TempBlob: Codeunit "Temp Blob";
        MemStream: DotNet NPRNetMemoryStream;
        Convert: DotNet NPRNetConvert;
        OutStream: OutStream;
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
        case UpperCase(Format(FieldRef.Type)) of
            'CODE', 'TEXT':
                FieldRef.Value := Value;
            'INTEGER', 'BIGINTEGER', 'OPTION':
                begin
                    Evaluate(ValueBigInt, Value);
                    FieldRef.Value := ValueBigInt;
                end;
            'DECIMAL':
                begin
                    Evaluate(ValueDec, Value);
                    FieldRef.Value := ValueDec;
                end;
            'BOOLEAN':
                begin
                    Evaluate(ValueBool, Value);
                    FieldRef.Value := ValueBool;
                end;
            'DATE':
                begin
                    Evaluate(ValueDate, Value, 9);
                    FieldRef.Value := ValueDate;
                end;
            'DATETIME':
                begin
                    if not Evaluate(ValueDateTime, Value, 9) then //Legacy: Fallback to non-XML format parse since some packages contain DateTimes in that format.
                        Evaluate(ValueDateTime, Value);
                    FieldRef.Value := ValueDateTime;
                end;
            'TIME':
                begin
                    Evaluate(ValueTime, Value, 9);
                    FieldRef.Value := ValueTime;
                end;
            'BLOB':
                begin
                    ValueText := Value;
                    MemStream := MemStream.MemoryStream(Convert.FromBase64String(ValueText));
                    TempBlob.CreateOutStream(OutStream);
                    CopyStream(OutStream, MemStream);
                    TempBlob.ToFieldRef(FieldRef);
                end;
            'DATEFORMULA':
                begin
                    Evaluate(ValueDateFormula, Value, 9);
                    FieldRef.Value := ValueDateFormula;
                end;
            'DURATION':
                begin
                    Evaluate(ValueDuration, Value, 9);
                    FieldRef.Value := ValueDuration;
                end;
            'GUID':
                begin
                    Evaluate(ValueGUID, Value);
                    FieldRef.Value := ValueGUID;
                end;
            'RECORDID':
                begin
                    Evaluate(ValueRecordID, Value, 9);
                    FieldRef.Value := ValueRecordID;
                end;
            'TABLEFILTER':
                ; //Not supported
        end;
    end;

    local procedure BLOBToBase64String(FieldRef: FieldRef) Value: Text
    var
        TempBlob: Codeunit "Temp Blob";
        MemStream: DotNet NPRNetMemoryStream;
        Convert: DotNet NPRNetConvert;
        InStream: InStream;
    begin
        Value := '';
        FieldRef.CalcField;
        TempBlob.FromFieldRef(FieldRef);
        if TempBlob.HasValue then begin
            TempBlob.CreateInStream(InStream);
            MemStream := MemStream.MemoryStream();
            CopyStream(MemStream, InStream);
            Value := Convert.ToBase64String(MemStream.ToArray);
        end;
    end;

    procedure GetDependencyMgtSetup(var DepMgtSetup: Record "NPR Dependency Mgt. Setup")
    begin
        if not DepMgtSetup.Get then
            DepMgtSetup.Insert();
    end;

    local procedure SplitString(String: DotNet NPRNetString; var IEnumerable: DotNet NPRNetIEnumerable_Of_T)
    var
        CharArray: DotNet NPRNetArray;
        Char: Char;
    begin
        Char := ',';
        CharArray := CharArray.CreateInstance(GetDotNetType(Char), 1);
        CharArray.SetValue(Char, 0);
        IEnumerable := String.Split(CharArray);
    end;

    local procedure HoldSemaphore()
    var
        DepMgtSetup: Record "NPR Dependency Mgt. Setup";
    begin
        DepMgtSetup.LockTable;
        DepMgtSetup.Get;
    end;

    [BusinessEvent(FALSE)]
    local procedure OnDependenciesDeployed()
    begin
    end;

    [BusinessEvent(false)]
    local procedure OnAfterReadDependenciesFromGroundControl()
    begin
    end;

    procedure ParseJSON(Text: Text; var JObject: DotNet JObject)
    var
        JsonTextReader: DotNet NPRNetJsonTextReader;
        StringReader: DotNet NPRNetStringReader;
        DateParseHandling: DotNet NPRNetDateParseHandling;
    begin
        StringReader := StringReader.StringReader(Text);
        JsonTextReader := JsonTextReader.JsonTextReader(StringReader);
        JsonTextReader.DateParseHandling := DateParseHandling.None;
        JObject := JObject.Load(JsonTextReader);
    end;
}

