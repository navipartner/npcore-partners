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

    trigger OnRun()
    begin
    end;

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
        ManagedDependencyMgt: Codeunit "NPR Managed Dependency Mgt.";
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
        JToken := ManagedDependencyMgt.ParseJSON(JSON);
        JObject := JToken.AsObject();
        JObject.Get('Primary Package Table', JToken);
        PrimaryPackageTable := JToken.AsValue().AsInteger();
        JObject.Get('Data', JToken);

        OnLoadPackage(Handled, PrimaryPackageTable, JToken, 0);
        if Handled then
            exit;

        LoadPackage(JToken.AsArray());
    end;

    procedure ImportFromBlob(var TempBlob: Codeunit "Temp Blob")
    var
        JObject: JsonObject;
        JToken: JsonToken;
        JArray: JsonArray;
        InStr: InStream;
        JSON: Text;
        Handled: Boolean;
        PrimaryPackageTable: Integer;
        ManagedDependencyMgt: Codeunit "NPR Managed Dependency Mgt.";
    begin
        // Note: This function is made for manually importing a package manifest file/blob, so it will not expect
        // the JArray "Data" to be the root which is the case when parsing the base64 blob straight from ground control.

        TempBlob.CreateInStream(InStr, TEXTENCODING::UTF8);

        InStr.Read(JSON);

        JToken := ManagedDependencyMgt.ParseJSON(JSON);
        JObject := JToken.AsObject();
        JObject.Get('Primary Package Table', JToken);
        PrimaryPackageTable := JToken.AsValue().AsInteger();

        JObject.Get('Data', JToken);

        OnLoadPackage(Handled, PrimaryPackageTable, JToken, 1);
        if Handled then
            exit;

        LoadPackage(JToken.AsArray());
    end;

    procedure DeployPackageFromGroundControl(PrimaryPackageTable: Integer): Boolean
    var
        DepMgtSetup: Record "NPR Dependency Mgt. Setup";
        TmpManagedPackageLookup: Record "NPR Managed Package Lookup" temporary;
        ManagedDependencyMgt: Codeunit "NPR Managed Dependency Mgt.";
        FilterSpecific: Label '&$filter=Type eq ''%1'' and Name eq ''%2'' and Version eq ''%3''', Comment = '%1=Type;%2=Name;%3=Version';
        JObjects: List of [JsonObject];
        JToken: JsonToken;
        JToken2: JsonToken;
        JToken3: JsonToken;
        JToken4: JsonToken;
        JToken5: JsonToken;
        JToken6: JsonToken;
        JArray: JsonArray;
        JObject: JsonObject;
        i: Integer;
        Handled: Boolean;
    begin
        ManagedDependencyMgt.GetDependencyMgtSetup(DepMgtSetup);
        if not DepMgtSetup.Configured then
            exit(false);

        if not ManagedDependencyMgt.GetJSON(DepMgtSetup, 'ManagedDataPackageList', JToken, CreateFilterText(PrimaryPackageTable, DepMgtSetup), false) then
            exit(false);

        JArray := JToken.AsArray();
        clear(JToken);
        foreach JToken in Jarray do begin
            JObject := JToken.AsObject();
            JObject.Get('Name', JToken2);
            JObject.Get('Version', JToken3);
            JObject.Get('Description', JToken4);
            JObject.Get('Status', JToken5);
            JObject.Get('Tags', JToken6);

            TmpManagedPackageLookup.Index := i;
            TmpManagedPackageLookup.Name := JToken2.AsValue().AsText();
            TmpManagedPackageLookup.Version := JToken3.AsValue().AsText();
            TmpManagedPackageLookup.Description := JToken4.AsValue().AsText();
            TmpManagedPackageLookup.Status := JToken5.AsValue().AsText();
            TmpManagedPackageLookup.Tags := JToken6.AsValue().AsText();
            TmpManagedPackageLookup.Insert();
            JObjects.Add(JObject);
        end;

        if TmpManagedPackageLookup.IsEmpty() then
            exit(false);

        if not (PAGE.RunModal(PAGE::"NPR Managed Package Lookup", TmpManagedPackageLookup) = ACTION::LookupOK) then
            exit(false);

        JObjects.Get(TmpManagedPackageLookup.Index, JObject);
        JObject.Get('Type', JToken2);
        JObject.Get('Name', JToken3);
        JObject.Get('Version', JToken4);
        Clear(JToken);
        if ManagedDependencyMgt.GetJSON(DepMgtSetup, 'ManagedDependency', JToken, StrSubstNo(FilterSpecific, JToken2.AsValue().AsText(), JToken3.AsValue().AsText(), JToken4.AsValue().AsText()), true) then begin
            JObject := JToken.AsObject();
            JObject.Get('BLOB', JToken2);
            if ManagedDependencyMgt.Base64StringToJObject(JToken2.AsValue().AsText(), JArray) then begin
                OnLoadPackage(Handled, PrimaryPackageTable, JArray.AsToken(), 2);
                if Handled then
                    exit(ManagedDependencyMgt.UpdateLog(JObject));

                if LoadPackage(JArray) then
                    exit(ManagedDependencyMgt.UpdateLog(JObject));
            end;
        end;
        exit(false);
    end;

    procedure DeployPackageFromURL(URL: Text)
    var
        ManagedDependencyMgt: Codeunit "NPR Managed Dependency Mgt.";
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        JObject: JsonObject;
        JToken: JsonToken;
        JSON: Text;
        PrimaryPackageTable: Integer;
        Handled: Boolean;
    begin
        Client.Get(Url, ResponseMessage);
        ResponseMessage.Content().ReadAs(JSON);
        JToken := ManagedDependencyMgt.ParseJSON(JSON);
        JObject := JToken.AsObject();
        JObject.Get('Primary Package Table', JToken);
        Evaluate(PrimaryPackageTable, Format(JToken.AsValue().AsInteger()));
        JObject.get('Data', JToken);

        OnLoadPackage(Handled, PrimaryPackageTable, JToken, 0);
        if Handled then
            exit;

        LoadPackage(JToken.AsArray());
    end;

    local procedure LoadPackage(JArray: JsonArray): Boolean
    var
        RecRef: RecordRef;
        LoadMethod: Option OnlyInsert,InsertOrModify,DeleteFirst;
        Selection: Integer;
    begin
        if JArray.Count() < 1 then
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

        if not LoadRecords(JArray, LoadMethod) then
            Error(Error_PackageLoad);

        exit(true);
    end;

    local procedure LoadRecords(JArray: JsonArray; LoadMethod: Option OnlyInsert,InsertOrModify,DeleteFirst): Boolean
    var
        ManagedDependencyMgt: Codeunit "NPR Managed Dependency Mgt.";
        JTokenRecord: JsonToken;
        JToken: JsonToken;
        JTokenFieldValue: JsonToken;
        JObjectRecord: JsonObject;
        JObject: JsonObject;
        JArrayFields: JsonArray;
        RecRef: RecordRef;
        FieldReference: FieldRef;
        TableNo: Integer;
        Total: Integer;
        Itt: Integer;
        FieldName: Text;
        JObjectKeys: List of [Text];
    begin
        Total := JArray.Count();

        OpenDialog();

        foreach JTokenRecord in JArray do begin
            Itt += 1;
            JObjectRecord := JTokenRecord.AsObject();
            JObjectRecord.Get('Record', JToken);
            TableNo := JToken.AsValue().AsInteger();
            UpdateDialog(1, TableNo);
            UpdateProgressDialog(2, Itt, Total);
            if not GlobalTableListTmp.Get(GlobalTableListTmp."Object Type"::Table, TableNo) then //Only accept data for expected tables.
                exit(false);

            RecRef.Open(TableNo);
            JObjectRecord.Get('Fields', JToken);
            JObject := JToken.AsObject();
            JObjectKeys := JObject.Keys();
            foreach FieldName in JOBjectKeys do begin
                JObject.Get(FieldName, JTokenFieldValue);
                if FieldRefByID(RecRef, FieldName, FieldReference) then
                    if not ManagedDependencyMgt.TextToFieldRef(JTokenFieldValue.AsValue().AsText(), FieldReference) then
                        exit(false);

                case LoadMethod of
                    LoadMethod::DeleteFirst:
                        if not RecRef.Insert() then
                            exit(false);
                    LoadMethod::OnlyInsert:
                        if not RecRef.Insert() then
                            ;
                    LoadMethod::InsertOrModify:
                        if not RecRef.Insert() then
                            if not RecRef.Modify() then
                                exit(false);
                end;

                RecRef.Close();
            end;
        end;
        CloseDialog();

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
        //+NPR5.39 [306227]
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
    local procedure OnLoadPackage(var Handled: Boolean; PrimaryPackageTable: Integer; JToken: JsonToken; LoadType: Option File,Blob,Download)
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

