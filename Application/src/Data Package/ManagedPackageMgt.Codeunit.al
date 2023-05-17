codeunit 6014628 "NPR Managed Package Mgt."
{
    Access = Internal;
    // This codeunit allows for import of data packages either manually from a manifest file/blob or straight from ground control.
    // 
    // If you wish to add custom import logic to your specific package, subscribe to event:
    // OnLoadPackage()
    // and check for a match on PrimaryPackageTable number. This will allow you to overwrite the default import flow and instead build custom merging rules for your specific tables.
    // 
    // If you wish to use the default import logic but bypass load method dialogs use:
    // SetLoadMethod()

    var
        TempGlobalTableList: Record AllObj temporary;
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

        TempGlobalTableList."Object Type" := TempGlobalTableList."Object Type"::Table;
        TempGlobalTableList."Object ID" := ID;
        TempGlobalTableList.Insert();

        GlobalTableString += '\' + StrSubstNo(PlaceHolder2Lbl, AllObjWithCaption."Object ID", AllObjWithCaption."Object Caption");
    end;

    procedure SetLoadMethod(LoadMethod: Option OnlyInsert,InsertOrModify,DeleteFirst)
    begin
        GlobalLoadMethod := LoadMethod;
        GlobalLoadMethodOverwritten := true;
    end;

    procedure ImportFromFile()
    var
        JObject: JsonObject;
        JToken: JsonToken;
        InStr: InStream;
        FileName: Text;
        Handled: Boolean;
        PrimaryPackageTable: Integer;
        JsonFileTypeDesciptionLbl: Label 'Json File %1', Comment = '%1 - json file mask';
        JsonFileTypeMaskLbl: Label '(*.json)|*.json', Locked = true;
    begin
        if not UploadIntoStream(Caption_SelectPackage, '', StrSubstNo(JsonFileTypeDesciptionLbl, JsonFileTypeMaskLbl), FileName, InStr) then
            exit;

        JObject.ReadFrom(InStr);
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

    [NonDebuggable]
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

        if (LoadMethod = LoadMethod::DeleteFirst) and TempGlobalTableList.FindSet() then
            repeat
                RecRef.Open(TempGlobalTableList."Object ID");

                if not RecRef.WritePermission then
                    Error(Error_MissingPermission, RecRef.Number);

                RecRef.DeleteAll();
                RecRef.Close();
            until TempGlobalTableList.Next() = 0;

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
        ConvertHelper: Codeunit "NPR Convert Helper";
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

            if not TempGlobalTableList.Get(TempGlobalTableList."Object Type"::Table, TableNo) then //Only accept data for expected tables.
                exit(false);

            RecRef.Open(TableNo);

            JObject.Get('Fields', JToken);
            JObject := JToken.AsObject();
            FieldIDList := JObject.Keys();

            foreach FieldID in FieldIDList do
                if FieldRefByID(RecRef, FieldID, FieldReference) then begin
                    JObject.Get(FieldID, JToken);
                    if not ConvertHelper.JValueToFieldRef(JToken.AsValue(), FieldReference) then
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

    #region ImportPrintTemplateFromWizard
    //This is the modified copy of "Download Template data" functionality from Print template list page. 
    //This copy is modified in a way that Import worksheet page is not shown, but all existing records are set with action Replace, and all new records with action create.

    //[NonDebuggable]
    procedure DeployPrintTemplatePackage(URL: Text)
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

        ResponseMessage.Content.ReadAs(JSON);

        JObject.ReadFrom(JSON);
        JObject.Get('Primary Package Table', Jtoken);
        PrimaryPackageTable := Jtoken.AsValue().AsInteger();
        JObject.Get('Data', Jtoken);

        LoadPrintTemplatePackage(Handled, PrimaryPackageTable, Jtoken, 0);
    end;

    local procedure LoadPrintTemplatePackage(var Handled: Boolean; PrimaryPackageTable: Integer; JObject: JsonToken; LoadType: Option File,Blob,Download)
    var
        TempImportWorksheet: Record "NPR RP Imp. Worksh." temporary;
        TempTemplateHeader: Record "NPR RP Template Header" temporary;
        TempTemplateLine: Record "NPR RP Template Line" temporary;
        TempDataItem: Record "NPR RP Data Items" temporary;
        TempDataItemLinks: Record "NPR RP Data Item Links" temporary;
        TempDataItemConstraint: Record "NPR RP Data Item Constr." temporary;
        TempDataItemConstraintLinks: Record "NPR RP Data Item Constr. Links" temporary;
        TempDeviceSettings: Record "NPR RP Device Settings" temporary;
        TempMediaInfo: Record "NPR RP Template Media Info" temporary;
        RPTemplateHeader: Record "NPR RP Template Header";
    begin
        if Handled then
            exit;
        if LoadType = LoadType::Blob then
            exit;
        if PrimaryPackageTable <> DATABASE::"NPR RP Template Header" then
            exit;

        Handled := true;

        if not PrintTemplateParsePackage(JObject, TempTemplateHeader, TempTemplateLine, TempDataItem, TempDataItemLinks, TempDataItemConstraint, TempDataItemConstraintLinks, TempDeviceSettings, TempMediaInfo) then
            exit;

        repeat
            TempImportWorksheet.Init();
            TempImportWorksheet."Entry No." += 1;
            TempImportWorksheet.Template := TempTemplateHeader.Code;
            TempImportWorksheet."New Description" := TempTemplateHeader.Description;
            TempImportWorksheet."New Last Modified At" := TempTemplateHeader."Last Modified At";
            TempImportWorksheet."New Version" := TempTemplateHeader.Version;
            TempImportWorksheet.Action := TempImportWorksheet.Action::Create;
            if RPTemplateHeader.Get(TempTemplateHeader.Code) then begin
                TempImportWorksheet."Existing Description" := RPTemplateHeader.Description;
                TempImportWorksheet."Existing Last Modified At" := RPTemplateHeader."Last Modified At";
                TempImportWorksheet."Existing Version" := RPTemplateHeader.Version;
                TempImportWorksheet.Action := TempImportWorksheet.Action::Replace;
            end;
            TempImportWorksheet.Insert(true);
        until TempTemplateHeader.Next() = 0;

        ImportPrintTemplatePackage(TempImportWorksheet, TempTemplateHeader, TempTemplateLine, TempDataItem, TempDataItemLinks, TempDataItemConstraint, TempDataItemConstraintLinks, TempDeviceSettings, TempMediaInfo);
    end;

    local procedure PrintTemplateParsePackage(JToken: JsonToken; var tmpTemplateHeader: Record "NPR RP Template Header" temporary; var tmpTemplateLine: Record "NPR RP Template Line" temporary; var tmpDataItem: Record "NPR RP Data Items" temporary; var tmpDataItemLinks: Record "NPR RP Data Item Links" temporary; var tmpDataItemConstraint: Record "NPR RP Data Item Constr." temporary; var tmpDataItemConstraintLinks: Record "NPR RP Data Item Constr. Links" temporary; var tmpDeviceSettings: Record "NPR RP Device Settings" temporary; var tmpMediaInfo: Record "NPR RP Template Media Info" temporary): Boolean
    var
        i: Integer;
        TotalRecords: Integer;
        TableNo: Integer;
        RecRef: RecordRef;
        FieldReference: FieldRef;
        ConvertHelper: Codeunit "NPR Convert Helper";
        ManagedPackageMgt: Codeunit "NPR Managed Package Mgt.";
        JObject: JsonObject;
        JArray: JsonArray;
        FieldIDList: List of [Text];
        FieldID: Text;
    begin
        JArray := JToken.AsArray();
        TotalRecords := JArray.Count();

        for i := 0 to TotalRecords - 1 do begin
            JArray.Get(i, JToken);
            JObject := JToken.AsObject();
            JObject.Get('Record', JToken);
            TableNo := JToken.AsValue().AsInteger();

            case TableNo of
                DATABASE::"NPR RP Template Header":
                    RecRef.GetTable(tmpTemplateHeader);
                DATABASE::"NPR RP Template Line":
                    RecRef.GetTable(tmpTemplateLine);
                DATABASE::"NPR RP Data Items":
                    RecRef.GetTable(tmpDataItem);
                DATABASE::"NPR RP Data Item Links":
                    RecRef.GetTable(tmpDataItemLinks);
                DATABASE::"NPR RP Data Item Constr.":
                    RecRef.GetTable(tmpDataItemConstraint);
                DATABASE::"NPR RP Data Item Constr. Links":
                    RecRef.GetTable(tmpDataItemConstraintLinks);
                DATABASE::"NPR RP Device Settings":
                    RecRef.GetTable(tmpDeviceSettings);
                DATABASE::"NPR RP Template Media Info":
                    RecRef.GetTable(tmpMediaInfo);
                else
                    Error('Unexpected table.');
            end;

            JObject.Get('Fields', JToken);
            JObject := JToken.AsObject();
            FieldIDList := JObject.Keys();

            foreach FieldID in FieldIDList do
                if ManagedPackageMgt.FieldRefByID(RecRef, FieldID, FieldReference) then begin
                    JObject.Get(FieldID, JToken);
                    if not ConvertHelper.JValueToFieldRef(JToken.AsValue(), FieldReference) then
                        Error('Unexpected field data.');
                end;

            RecRef.Insert();
            RecRef.Close();
        end;

        exit(tmpTemplateHeader.FindSet());
    end;

    local procedure ImportPrintTemplatePackage(var tmpImportWorksheet: Record "NPR RP Imp. Worksh."; var tmpTemplateHeader: Record "NPR RP Template Header" temporary; var tmpTemplateLine: Record "NPR RP Template Line" temporary; var tmpDataItem: Record "NPR RP Data Items" temporary; var tmpDataItemLinks: Record "NPR RP Data Item Links" temporary; var tmpDataItemConstraint: Record "NPR RP Data Item Constr." temporary; var tmpDataItemConstraintLinks: Record "NPR RP Data Item Constr. Links" temporary; var tmpDeviceSettings: Record "NPR RP Device Settings" temporary; var tmpMediaInfo: Record "NPR RP Template Media Info" temporary)
    var
        RPTemplateHeader: Record "NPR RP Template Header";
        RPTemplateLine: Record "NPR RP Template Line";
        DataItems: Record "NPR RP Data Items";
        DataItemLinks: Record "NPR RP Data Item Links";
        DataItemConstraint: Record "NPR RP Data Item Constr.";
        DataItemConstraintLinks: Record "NPR RP Data Item Constr. Links";
        DeviceSettings: Record "NPR RP Device Settings";
        MediaInfo: Record "NPR RP Template Media Info";
    begin
        tmpImportWorksheet.SetFilter(Action, '<>%1', tmpImportWorksheet.Action::Skip);
        if tmpImportWorksheet.FindSet() then
            repeat
                if tmpImportWorksheet.Action = tmpImportWorksheet.Action::Replace then
                    DeleteTemplate(tmpImportWorksheet.Template);

                tmpTemplateHeader.Get(tmpImportWorksheet.Template);
                tmpTemplateLine.SetRange("Template Code", tmpImportWorksheet.Template);
                tmpDataItem.SetRange(Code, tmpImportWorksheet.Template);
                tmpDataItemLinks.SetRange("Data Item Code", tmpImportWorksheet.Template);
                tmpDataItemConstraint.SetRange("Data Item Code", tmpImportWorksheet.Template);
                tmpDataItemConstraintLinks.SetRange("Data Item Code", tmpImportWorksheet.Template);
                tmpDeviceSettings.SetRange(Template, tmpImportWorksheet.Template);
                tmpMediaInfo.SetRange(Template, tmpImportWorksheet.Template);

                RPTemplateHeader.Init();
                RPTemplateHeader := tmpTemplateHeader;
                RPTemplateHeader.Insert();

                if tmpTemplateLine.FindSet() then
                    repeat
                        RPTemplateLine.Init();
                        RPTemplateLine := tmpTemplateLine;
                        RPTemplateLine.Insert();
                    until tmpTemplateLine.Next() = 0;

                if tmpDataItem.FindSet() then
                    repeat
                        DataItems.Init();
                        DataItems := tmpDataItem;
                        DataItems.Insert();
                    until tmpDataItem.Next() = 0;

                if tmpDataItemLinks.FindSet() then
                    repeat
                        DataItemLinks.Init();
                        DataItemLinks := tmpDataItemLinks;
                        DataItemLinks.Insert();
                    until tmpDataItemLinks.Next() = 0;

                if tmpDataItemConstraint.FindSet() then
                    repeat
                        DataItemConstraint.Init();
                        DataItemConstraint := tmpDataItemConstraint;
                        DataItemConstraint.Insert();
                    until tmpDataItemConstraint.Next() = 0;

                if tmpDataItemConstraintLinks.FindSet() then
                    repeat
                        DataItemConstraintLinks.Init();
                        DataItemConstraintLinks := tmpDataItemConstraintLinks;
                        DataItemConstraintLinks.Insert();
                    until tmpDataItemConstraintLinks.Next() = 0;

                if tmpDeviceSettings.FindSet() then
                    repeat
                        DeviceSettings.Init();
                        DeviceSettings := tmpDeviceSettings;
                        DeviceSettings.Insert();
                    until tmpDeviceSettings.Next() = 0;

                if tmpMediaInfo.FindSet() then
                    repeat
                        MediaInfo.Init();
                        MediaInfo := tmpMediaInfo;
                        MediaInfo.Insert();
                    until tmpMediaInfo.Next() = 0;

            until tmpImportWorksheet.Next() = 0;
    end;

    local procedure DeleteTemplate("Code": Text)
    var
        RPTemplateHeader: Record "NPR RP Template Header";
        RPTemplateLine: Record "NPR RP Template Line";
        DataItems: Record "NPR RP Data Items";
        DataItemLinks: Record "NPR RP Data Item Links";
        DataItemConstraint: Record "NPR RP Data Item Constr.";
        DataItemConstraintLinks: Record "NPR RP Data Item Constr. Links";
        DeviceSettings: Record "NPR RP Device Settings";
        MediaInfo: Record "NPR RP Template Media Info";
        RPTemplateArchive: Record "NPR RP Template Archive";
    begin
        RPTemplateHeader.Get(Code);
        if not RPTemplateHeader.Archived then begin
            if not RPTemplateArchive.Get(Code, RPTemplateHeader.Version) then begin
                RPTemplateHeader."Version Comments" := 'Auto archiving before import';
                RPTemplateHeader.Validate(Archived, true);
            end;
        end;

        RPTemplateHeader.SetRange(Code, Code);
        RPTemplateLine.SetRange("Template Code", Code);
        DataItems.SetRange(Code, Code);
        DataItemLinks.SetRange("Data Item Code", Code);
        DataItemConstraint.SetRange("Data Item Code", Code);
        DataItemConstraintLinks.SetRange("Data Item Code", Code);
        DeviceSettings.SetRange(Template, Code);
        MediaInfo.SetRange(Template, Code);

        RPTemplateHeader.DeleteAll();
        RPTemplateLine.DeleteAll();
        DataItems.DeleteAll();
        DataItemLinks.DeleteAll();
        DataItemConstraint.DeleteAll();
        DataItemConstraintLinks.DeleteAll();
        DeviceSettings.DeleteAll();
        MediaInfo.DeleteAll();
    end;
    #endregion
}