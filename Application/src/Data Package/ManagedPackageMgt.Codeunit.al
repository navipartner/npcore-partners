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
        PlaceHolder2Lbl: Label '%1: %2', Locked = true;
    begin
        AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, ID);

        GlobalTableListTmp."Object Type" := GlobalTableListTmp."Object Type"::Table;
        GlobalTableListTmp."Object ID" := ID;
        GlobalTableListTmp.Insert();

        GlobalTableString += '\' + StrSubstNo(PlaceHolder2Lbl, AllObjWithCaption."Object ID", AllObjWithCaption."Object Caption");
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
        PrimaryPackageTable := JToken.AsValue().AsInteger();
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
        PrimaryPackageTable := Jtoken.AsValue().AsInteger();
        JObject.Get('Data', Jtoken);

        OnLoadPackage(Handled, PrimaryPackageTable, Jtoken, 1);
        if Handled then
            exit;

        LoadPackage(Jtoken);
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

        //Even though Encoding is not set, it returns same result as Dot_Net code with direct read to Text:
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
        PrimaryPackageTable := Jtoken.AsValue().AsInteger();
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
        PlaceHolder3Lbl: Label '%1,%2,%3', Locked = true;
    begin
        if JToken.IsArray then
            Total := JToken.AsArray().Count
        else
            Total := JToken.AsObject().Keys.Count();

        if Total < 1 then
            exit;

        if GlobalLoadMethodOverwritten then
            LoadMethod := GlobalLoadMethod
        else begin
            Selection := StrMenu(StrSubstNo(PlaceHolder3Lbl, Caption_OnlyInsert, Caption_InsertModify, Caption_DeleteFirst), 1, Caption_LoadMethod);
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

        if (LoadMethod = LoadMethod::DeleteFirst) and GlobalTableListTmp.FindSet() then
            repeat
                RecRef.Open(GlobalTableListTmp."Object ID");

                if not RecRef.WritePermission then
                    Error(Error_MissingPermission, RecRef.Number);

                RecRef.DeleteAll();
                RecRef.Close();
            until GlobalTableListTmp.Next() = 0;

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
        Total := JArray.Count();

        if Total < 1 then
            exit;

        OpenDialog();

        for i := 0 to Total - 1 do begin
            Itt += 1;

            JArray.Get(i, JToken);
            JObject := JToken.AsObject();
            JObject.Get('Record', JToken);
            TableNo := JToken.AsValue().AsInteger();

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

        CloseDialog();

        exit(true);
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
            ProgressDialog.Close();

        IsDialogOpen := false;
    end;
}

