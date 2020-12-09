codeunit 6014628 "NPR Managed Package Mgt."
{
    // This codeunit allows for import of data packages either manually from a manifest file/blob or straight from ground control.
    // 
    // If you wish to add custom import logic to your specific package, subscribe to event:
    // OnLoadPackage()
    // and check for a match on PrimaryPackageTable number. This will allow you to overwrite the default import flow and instead build custom merging rules for your specific tables.
    // 
    // If you wish to use the default import logic but bypass load method dialogs use:
    // SetLoadMethod()

    var
        GlobalTableListTmp: Record AllObj temporary;
        Caption_LoadMethod: Label 'Select one of the following package load methods:';
        Caption_DeleteWarning: Label 'WARNING: This will delete ALL existing data in tables:\%1.\\Are you sure you want to continue?';
        Caption_ModifyWarning: Label 'WARNING: This could change existing data in tables:\%1.\\Are you sure you want to continue?';
        Caption_DeleteFirst: Label 'Delete all data first and then insert';
        Caption_InsertModify: Label 'Insert and modify existing records';
        Caption_OnlyInsert: Label 'Only Insert';
        Caption_SelectPackage: Label 'Select JSON Package';
        Error_MissingPermission: Label 'Missing write permissions to table %1';
        Error_PackageLoad: Label 'An error occured while loading the package data. No data changes has been made.';
        DialogValues: array[2] of Integer;
        GlobalTableString: Text;
        GlobalLoadMethodOverwritten: Boolean;
        IsDialogOpen: Boolean;
        GlobalLoadMethod: Integer;
        ProgressDialog: Dialog;

    procedure AddExpectedTableID(ID: Integer)
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, ID);

        GlobalTableListTmp."Object Type" := GlobalTableListTmp."Object Type"::Table;
        GlobalTableListTmp."Object ID" := ID;
        GlobalTableListTmp.Insert;

        GlobalTableString += '\' + StrSubstNo('%1: %2', AllObjWithCaption."Object ID", AllObjWithCaption."Object Caption");
    end;

    procedure SetLoadMethod(LoadMethod: Option OnlyInsert,InsertOrModify,DeleteFirst)
    begin
        GlobalLoadMethod := LoadMethod;
        GlobalLoadMethodOverwritten := true;
    end;

    procedure ImportFromFile()
    var
        FileMgt: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        JObject: JsonObject;
        JToken: JsonToken;
        InStr: InStream;
        JSON: Text;
        Handled: Boolean;
        PrimaryPackageTable: Integer;
    begin
        if FileMgt.BLOBImportWithFilter(TempBlob, Caption_SelectPackage, '', 'JSON File (*.json)|*.json', 'json') = '' then
            exit;

        TempBlob.CreateInStream(InStr, TEXTENCODING::UTF8);

        InStr.Read(JSON);
        JObject.ReadFrom(JSON);
        JObject.Get('Primary Package Table', JToken);
        PrimaryPackageTable := JToken.AsValue.AsInteger();
        JObject.Get('Data', JToken);


        OnLoadPackage(Handled, PrimaryPackageTable, JToken, 0);
        if Handled then
            exit;

        LoadPackage(JToken);
    end;

    procedure ImportFromBlob(var TempBlob: Codeunit "Temp Blob")
    var
        JObject: JsonObject;
        Jtoken: JsonToken;
        InStr: InStream;
        JSON: Text;
        Handled: Boolean;
        PrimaryPackageTable: Integer;
    begin
        // Note: This function is made for manually importing a package manifest file/blob, so it will not expect
        // the JArray "Data" to be the root which is the case when parsing the base64 blob straight from ground control.

        TempBlob.CreateInStream(InStr, TEXTENCODING::UTF8);

        InStr.Read(JSON);
        JObject.ReadFrom(JSON);
        JObject.Get('Primary Package Table', Jtoken);
        PrimaryPackageTable := Jtoken.AsValue.AsInteger();
        JObject.Get('Data', Jtoken);

        OnLoadPackage(Handled, PrimaryPackageTable, Jtoken, 1);
        if Handled then
            exit;

        LoadPackage(Jtoken);
    end;

    procedure DeployPackageFromGroundControl(PrimaryPackageTable: Integer): Boolean
    var
        ManagedDependencyMgt: Codeunit "NPR Managed Dependency Mgt.";
        DepMgtSetup: Record "NPR Dependency Mgt. Setup";
        JObject: JsonObject;
        JArray: JsonArray;
        Jtoken: JsonToken;
        i: Integer;
        Package: JsonObject;
        PackageToken: JsonToken;
        FilterSpecific: Label '&$filter=Type eq ''%1'' and Name eq ''%2'' and Version eq ''%3''';
        DataToken: JsonToken;
        TmpManagedPackageLookup: Record "NPR Managed Package Lookup" temporary;
        Handled: Boolean;
    begin
        ManagedDependencyMgt.GetDependencyMgtSetup(DepMgtSetup);
        if not DepMgtSetup.Configured then
            exit(false);

        if not ManagedDependencyMgt.GetJSON(DepMgtSetup, 'ManagedDataPackageList', Jtoken, CreateFilterText(PrimaryPackageTable, DepMgtSetup), false) then
            exit(false);

        JArray := Jtoken.AsArray();
        for i := 0 to JArray.Count - 1 do begin
            JArray.Get(i, PackageToken);
            Package := PackageToken.AsObject();

            TmpManagedPackageLookup.Index := i;
            TmpManagedPackageLookup.Name := GetJObjectValueAsText(Package, 'Name');
            TmpManagedPackageLookup.Version := GetJObjectValueAsText(Package, 'Version');
            TmpManagedPackageLookup.Description := GetJObjectValueAsText(Package, 'Description');
            TmpManagedPackageLookup.Status := GetJObjectValueAsText(Package, 'Status');
            TmpManagedPackageLookup.Tags := GetJObjectValueAsText(Package, 'Tags');
            TmpManagedPackageLookup.Insert;
        end;

        if TmpManagedPackageLookup.IsEmpty then
            exit(false);

        if not (PAGE.RunModal(PAGE::"NPR Managed Package Lookup", TmpManagedPackageLookup) = ACTION::LookupOK) then
            exit(false);

        JArray.Get(TmpManagedPackageLookup.Index, PackageToken);
        Package := PackageToken.AsObject();

        if ManagedDependencyMgt.GetJSON(DepMgtSetup, 'ManagedDependency', PackageToken, StrSubstNo(FilterSpecific, GetJObjectValueAsText(Package, 'Type'), GetJObjectValueAsText(Package, 'Name'), GetJObjectValueAsText(Package, 'Version')), true) then
            if ManagedDependencyMgt.Base64StringToJObject(GetJObjectValueAsText(PackageToken.AsObject(), 'BLOB'), DataToken) then begin
                OnLoadPackage(Handled, PrimaryPackageTable, DataToken, 2);
                if Handled then
                    exit(ManagedDependencyMgt.UpdateLog(PackageToken.AsObject()));

                if LoadPackage(DataToken) then
                    exit(ManagedDependencyMgt.UpdateLog(PackageToken.AsObject()));
            end;

        exit(false);
    end;

    local procedure GetJObjectValueAsText(JObject: JsonObject; TokenKey: Text) JTokenValueText: text
    var
        Jtoken: JsonToken;
    begin
        if JObject.Get(TokenKey, JToken) then
            JTokenValueText := Jtoken.AsValue.AsText();
    end;

    procedure DeployPackageFromURL(URL: Text)
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        JSON: Text;
        JObject: JsonObject;
        Jtoken: JsonToken;
        PrimaryPackageTable: Integer;
        Handled: Boolean;
    begin
        if not Client.Get(URL, ResponseMessage) then
            Error('Failed to call URL: %1', URL);

        if not ResponseMessage.IsSuccessStatusCode then
            Error('Web service has returnend an error:\\' + 'Status code: %1\' + 'Status code: %2', ResponseMessage.HttpStatusCode, ResponseMessage.ReasonPhrase);

        //Even though Encoding is not set, it returns same result as DotNet code with direct read to Text:
        ResponseMessage.Content.ReadAs(JSON);

        //At the end if needed to put Encoding, instead of reading direct to Text, going through TemBlob:
        /*
        ResponseMessage.Content.ReadAs(InStr);

        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        CopyStream(OutStr, InStr);

        TempBlob.CreateInStream(EncodedInStream);
        EncodedInStream.Read(JSON);
        */

        JObject.ReadFrom(JSON);
        JObject.Get('Primary Package Table', Jtoken);
        PrimaryPackageTable := Jtoken.AsValue.AsInteger();
        JObject.Get('Data', Jtoken);

        OnLoadPackage(Handled, PrimaryPackageTable, Jtoken, 0);
        if Handled then
            exit;

        LoadPackage(Jtoken);
    end;

    local procedure LoadPackage(JToken: JsonToken): Boolean
    var
        Selection: Integer;
        LoadMethod: Option OnlyInsert,InsertOrModify,DeleteFirst;
        RecRef: RecordRef;
        Total: Integer;
    begin
        if JToken.IsArray then
            Total := JToken.AsArray.Count
        else
            Total := JToken.AsObject.Keys.Count;

        if Total < 1 then
            exit;

        if GlobalLoadMethodOverwritten then
            LoadMethod := GlobalLoadMethod
        else begin
            Selection := StrMenu(StrSubstNo('%1,%2,%3', Caption_OnlyInsert, Caption_InsertModify, Caption_DeleteFirst), 1, Caption_LoadMethod);
            if Selection = 0 then
                exit(false);

            LoadMethod := Selection - 1;

            case LoadMethod of
                LoadMethod::DeleteFirst:
                    if not Confirm(StrSubstNo(Caption_DeleteWarning, GlobalTableString), false) then
                        exit(false);
                LoadMethod::InsertOrModify:
                    if not Confirm(StrSubstNo(Caption_ModifyWarning, GlobalTableString), false) then
                        exit(false);
            end;
        end;

        if (LoadMethod = LoadMethod::DeleteFirst) and GlobalTableListTmp.FindSet then
            repeat
                RecRef.Open(GlobalTableListTmp."Object ID");

                if not RecRef.WritePermission then
                    Error(Error_MissingPermission, RecRef.Number);

                RecRef.DeleteAll;
                RecRef.Close;
            until GlobalTableListTmp.Next = 0;

        if not LoadRecords(JToken, LoadMethod) then
            Error(Error_PackageLoad);

        exit(true);
    end;

    local procedure LoadRecords(JToken: JsonToken; LoadMethod: Option OnlyInsert,InsertOrModify,DeleteFirst): Boolean
    var
        RecRef: RecordRef;
        FieldReference: FieldRef;
        TableNo: Integer;
        i: Integer;
        ManagedDependencyMgt: Codeunit "NPR Managed Dependency Mgt.";
        JObject: JsonObject;
        JArray: JsonArray;
        FieldIDList: List of [Text];
        FieldID: Text;
        Total: Integer;
        Itt: Integer;
    begin
        JArray := JToken.AsArray();
        Total := JArray.Count;

        if Total < 1 then
            exit;

        OpenDialog;

        for i := 0 to Total - 1 do begin
            Itt += 1;

            JArray.Get(i, JToken);
            JObject := JToken.AsObject();
            JObject.Get('Record', JToken);
            TableNo := JToken.AsValue.AsInteger();

            UpdateDialog(1, TableNo);
            UpdateProgressDialog(2, Itt, Total);

            if not GlobalTableListTmp.Get(GlobalTableListTmp."Object Type"::Table, TableNo) then //Only accept data for expected tables.
                exit(false);

            RecRef.Open(TableNo);

            JObject.Get('Fields', JToken);
            JObject := JToken.AsObject();
            FieldIDList := JObject.Keys();

            foreach FieldID in FieldIDList do
                if FieldRefByID(RecRef, FieldID, FieldReference) then begin
                    JObject.Get(FieldID, JToken);
                    if not ManagedDependencyMgt.JValueToFieldRef(JToken.AsValue(), FieldReference) then
                        exit(false);
                end;

            case LoadMethod of
                LoadMethod::DeleteFirst:
                    if not RecRef.Insert then
                        exit(false);
                LoadMethod::OnlyInsert:
                    if not RecRef.Insert then
                        ;
                LoadMethod::InsertOrModify:
                    if not RecRef.Insert then
                        if not RecRef.Modify then
                            exit(false);
            end;

            RecRef.Close;
        end;

        CloseDialog;

        exit(true);
    end;

    local procedure CreateFilterText(PrimaryPackageTable: Integer; var DepMgtSetup: Record "NPR Dependency Mgt. Setup") "Filter": Text
    var
        ManagedDependencyMgt: Codeunit "NPR Managed Dependency Mgt.";
        TypeHelper: Codeunit "Type Helper";
    begin
        // If we later want to add some auto-update logic for specific data packages, we will have to expand this filter with company name,
        // and expand ground control with support for individual companies in its log to as data packages are not targeted at global tables.
        Filter := StrSubstNo('&$filter=(Service_Tier_Name eq ''%1'') and ', TypeHelper.UriEscapeDataString(ManagedDependencyMgt.GetServerID()));
        Filter += SelectStr(DepMgtSetup."Accept Statuses" + 1, '(Status eq ''Released'') and ,(Status eq ''Staging'' or Status eq ''Released'') and ,');
        Filter += StrSubstNo('(Primary_Package_Table eq %1)', PrimaryPackageTable);
    end;

    procedure FieldRefByID(var RecRef: RecordRef; ID: Text; var FieldRef: FieldRef): Boolean
    var
        IntBuffer: Integer;
    begin
        if not Evaluate(IntBuffer, ID) then
            exit(false);

        if not RecRef.FieldExist(IntBuffer) then
            exit(false);

        FieldRef := RecRef.Field(IntBuffer);
        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLoadPackage(var Handled: Boolean; PrimaryPackageTable: Integer; JObject: JsonToken; LoadType: Option File,Blob,Download)
    begin
        // Use this event to overwrite default import dialog flow and logic for your specific package type.
    end;

    local procedure OpenDialog()
    begin
        if GuiAllowed then
            if not IsDialogOpen then begin
                ProgressDialog.Open('Table ##1######\@@2@@@@@@@@@@@@@@@@@');
                IsDialogOpen := true;
            end;
    end;

    local procedure UpdateDialog(ValueNo: Integer; Value: Integer)
    begin
        if GuiAllowed then
            if Value <> DialogValues[ValueNo] then begin
                DialogValues[ValueNo] := Value;
                ProgressDialog.Update(ValueNo, Value);
            end;
    end;

    local procedure UpdateProgressDialog(ValueNo: Integer; Progress: Integer; Total: Integer)
    begin
        if GuiAllowed then begin
            Progress := Round(Progress / Total * 10000, 1, '>');
            if Progress <> DialogValues[ValueNo] then begin
                DialogValues[ValueNo] := Progress;
                ProgressDialog.Update(ValueNo, DialogValues[ValueNo]);
            end;
        end;
    end;

    local procedure CloseDialog()
    begin
        if GuiAllowed then
            ProgressDialog.Close;

        IsDialogOpen := false;
    end;
}

