codeunit 6014585 "NPR RP Package Handler"
{
    Access = Internal;
    var
        ImportedMessage: Label 'Templates imported:\Created: %1\Replaced: %2';

    procedure ExportPackageToFile(var TemplateHeader: Record "NPR RP Template Header")
    var
        ManagedPackageBuilder: Codeunit "NPR Managed Package Builder";
        RPTemplateHeader2: Record "NPR RP Template Header";
        RPTemplateLine: Record "NPR RP Template Line";
        DataItems: Record "NPR RP Data Items";
        DataItemLinks: Record "NPR RP Data Item Links";
        DataItemConstraint: Record "NPR RP Data Item Constr.";
        DataItemConstraintLinks: Record "NPR RP Data Item Constr. Links";
        DeviceSettings: Record "NPR RP Device Settings";
        MediaInfo: Record "NPR RP Template Media Info";
        i: Integer;
        FileName: Text;
        FileNameLbl: Label '%1, Version %2', Locked = true;
    begin
        if not TemplateHeader.FindSet() then
            exit;

        repeat
            RPTemplateLine.SetRange("Template Code", TemplateHeader.Code);
            DataItems.SetRange(Code, TemplateHeader.Code);
            DataItemLinks.SetRange("Data Item Code", TemplateHeader.Code);
            DataItemConstraint.SetRange("Data Item Code", TemplateHeader.Code);
            DataItemConstraintLinks.SetRange("Data Item Code", TemplateHeader.Code);
            DeviceSettings.SetRange(Template, TemplateHeader.Code);
            MediaInfo.SetRange(Template, TemplateHeader.Code);
            RPTemplateHeader2 := TemplateHeader;
            RPTemplateHeader2.SetRecFilter();

            ManagedPackageBuilder.AddRecord(RPTemplateHeader2);
            ManagedPackageBuilder.AddRecord(RPTemplateLine);
            ManagedPackageBuilder.AddRecord(DataItems);
            ManagedPackageBuilder.AddRecord(DataItemLinks);
            ManagedPackageBuilder.AddRecord(DataItemConstraint);
            ManagedPackageBuilder.AddRecord(DataItemConstraintLinks);
            ManagedPackageBuilder.AddRecord(DeviceSettings);
            ManagedPackageBuilder.AddRecord(MediaInfo);

            i += 1;
        until TemplateHeader.Next() = 0;

        if i = 1 then
            FileName := StrSubstNo(FileNameLbl, TemplateHeader.Code, TemplateHeader.Version)
        else
            FileName := 'Retail Print Templates';

        ManagedPackageBuilder.ExportToFile(FileName, '1.0', 'Templates for the retail print module', DATABASE::"NPR RP Template Header")
    end;

    procedure ExportPackageToBlob(var TemplateHeader: Record "NPR RP Template Header"; var TempBlobOut: Codeunit "Temp Blob")
    var
        ManagedPackageBuilder: Codeunit "NPR Managed Package Builder";
        RPTemplateHeader2: Record "NPR RP Template Header";
        RPTemplateLine: Record "NPR RP Template Line";
        DataItems: Record "NPR RP Data Items";
        DataItemLinks: Record "NPR RP Data Item Links";
        DataItemConstraint: Record "NPR RP Data Item Constr.";
        DataItemConstraintLinks: Record "NPR RP Data Item Constr. Links";
        DeviceSettings: Record "NPR RP Device Settings";
        ArchTmplLbl: Label 'Archived template: %1', Locked = true;
    begin
        //Does not export media info to prevent archive bloat.

        if not TemplateHeader.FindSet() then
            exit;

        repeat
            RPTemplateLine.SetRange("Template Code", TemplateHeader.Code);
            DataItems.SetRange(Code, TemplateHeader.Code);
            DataItemLinks.SetRange("Data Item Code", TemplateHeader.Code);
            DataItemConstraint.SetRange("Data Item Code", TemplateHeader.Code);
            DataItemConstraintLinks.SetRange("Data Item Code", TemplateHeader.Code);
            DeviceSettings.SetRange(Template, TemplateHeader.Code);
            RPTemplateHeader2 := TemplateHeader;
            RPTemplateHeader2.SetRecFilter();

            ManagedPackageBuilder.AddRecord(RPTemplateHeader2);
            ManagedPackageBuilder.AddRecord(RPTemplateLine);
            ManagedPackageBuilder.AddRecord(DataItems);
            ManagedPackageBuilder.AddRecord(DataItemLinks);
            ManagedPackageBuilder.AddRecord(DataItemConstraint);
            ManagedPackageBuilder.AddRecord(DataItemConstraintLinks);
            ManagedPackageBuilder.AddRecord(DeviceSettings);
        until TemplateHeader.Next() = 0;

        ManagedPackageBuilder.ExportToBlob('RP Template Archive', '1.0', StrSubstNo(ArchTmplLbl, TemplateHeader.Code), DATABASE::"NPR RP Template Header", TempBlobOut);
    end;

    procedure ImportPackageFromFile()
    var
        ManagedPackageMgt: Codeunit "NPR Managed Package Mgt.";
    begin
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Template Header");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Template Line");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Data Items");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Data Item Links");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Data Item Constr.");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Data Item Constr. Links");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Device Settings");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Template Media Info");
        ManagedPackageMgt.ImportFromFile();
    end;

    procedure ImportPackageFromBlob(var TempBlob: Codeunit "Temp Blob")
    var
        ManagedPackageMgt: Codeunit "NPR Managed Package Mgt.";
    begin
        ManagedPackageMgt.SetLoadMethod(0);
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Template Header");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Template Line");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Data Items");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Data Item Links");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Data Item Constr.");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Data Item Constr. Links");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Device Settings");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Template Media Info");
        ManagedPackageMgt.ImportFromBlob(TempBlob);
    end;

    procedure DeployPackageFromBlobStorage()
    var
        ManagedPackageMgt: Codeunit "NPR Managed Package Mgt.";
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
    begin
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Template Header");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Template Line");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Data Items");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Data Item Links");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Data Item Constr.");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Data Item Constr. Links");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Device Settings");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR RP Template Media Info");
        ManagedPackageMgt.DeployPackageFromURL(AzureKeyVaultMgt.GetSecret('NpRetailBaseDataBaseUrl') + '/retailprinttemplates/templates.json');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Managed Package Mgt.", 'OnLoadPackage', '', false, false)]
    local procedure OnLoadPackage(var Handled: Boolean; PrimaryPackageTable: Integer; JObject: JsonToken; LoadType: Option File,Blob,Download)
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

        if not ParsePackage(JObject, TempTemplateHeader, TempTemplateLine, TempDataItem, TempDataItemLinks, TempDataItemConstraint, TempDataItemConstraintLinks, TempDeviceSettings, TempMediaInfo) then
            exit;

        repeat
            TempImportWorksheet.Init();
            TempImportWorksheet."Entry No." += 1;
            TempImportWorksheet.Template := TempTemplateHeader.Code;
            TempImportWorksheet."New Description" := TempTemplateHeader.Description;
            TempImportWorksheet."New Last Modified At" := TempTemplateHeader."Last Modified At";
            TempImportWorksheet."New Version" := TempTemplateHeader.Version;
            if RPTemplateHeader.Get(TempTemplateHeader.Code) then begin
                TempImportWorksheet."Existing Description" := RPTemplateHeader.Description;
                TempImportWorksheet."Existing Last Modified At" := RPTemplateHeader."Last Modified At";
                TempImportWorksheet."Existing Version" := RPTemplateHeader.Version;
            end;
            TempImportWorksheet.Insert(true);
        until TempTemplateHeader.Next() = 0;

        if PAGE.RunModal(PAGE::"NPR RP Imp. Worksh.", TempImportWorksheet) <> ACTION::LookupOK then
            exit;

        ImportPackage(TempImportWorksheet, TempTemplateHeader, TempTemplateLine, TempDataItem, TempDataItemLinks, TempDataItemConstraint, TempDataItemConstraintLinks, TempDeviceSettings, TempMediaInfo);
    end;

    local procedure ParsePackage(JToken: JsonToken; var tmpTemplateHeader: Record "NPR RP Template Header" temporary; var tmpTemplateLine: Record "NPR RP Template Line" temporary; var tmpDataItem: Record "NPR RP Data Items" temporary; var tmpDataItemLinks: Record "NPR RP Data Item Links" temporary; var tmpDataItemConstraint: Record "NPR RP Data Item Constr." temporary; var tmpDataItemConstraintLinks: Record "NPR RP Data Item Constr. Links" temporary; var tmpDeviceSettings: Record "NPR RP Device Settings" temporary; var tmpMediaInfo: Record "NPR RP Template Media Info" temporary): Boolean
    var
        i: Integer;
        TotalRecords: Integer;
        TableNo: Integer;
        RecRef: RecordRef;
        FieldReference: FieldRef;
        ManagedDependencyMgt: Codeunit "NPR Managed Dependency Mgt.";
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
                    if not ManagedDependencyMgt.JValueToFieldRef(JToken.AsValue(), FieldReference) then
                        Error('Unexpected field data.');
                end;

            RecRef.Insert();
            RecRef.Close();
        end;

        exit(tmpTemplateHeader.FindSet());
    end;

    local procedure ImportPackage(var tmpImportWorksheet: Record "NPR RP Imp. Worksh."; var tmpTemplateHeader: Record "NPR RP Template Header" temporary; var tmpTemplateLine: Record "NPR RP Template Line" temporary; var tmpDataItem: Record "NPR RP Data Items" temporary; var tmpDataItemLinks: Record "NPR RP Data Item Links" temporary; var tmpDataItemConstraint: Record "NPR RP Data Item Constr." temporary; var tmpDataItemConstraintLinks: Record "NPR RP Data Item Constr. Links" temporary; var tmpDeviceSettings: Record "NPR RP Device Settings" temporary; var tmpMediaInfo: Record "NPR RP Template Media Info" temporary)
    var
        RPTemplateHeader: Record "NPR RP Template Header";
        RPTemplateLine: Record "NPR RP Template Line";
        DataItems: Record "NPR RP Data Items";
        DataItemLinks: Record "NPR RP Data Item Links";
        DataItemConstraint: Record "NPR RP Data Item Constr.";
        DataItemConstraintLinks: Record "NPR RP Data Item Constr. Links";
        DeviceSettings: Record "NPR RP Device Settings";
        MediaInfo: Record "NPR RP Template Media Info";
        ReplaceCounter: Integer;
        CreateCounter: Integer;
    begin
        tmpImportWorksheet.SetFilter(Action, '<>%1', tmpImportWorksheet.Action::Skip);
        if tmpImportWorksheet.FindSet() then
            repeat
                if tmpImportWorksheet.Action = tmpImportWorksheet.Action::Replace then begin
                    DeleteTemplate(tmpImportWorksheet.Template);
                    ReplaceCounter += 1;
                end else
                    CreateCounter += 1;

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

        if (ReplaceCounter > 0) or (CreateCounter > 0) then
            Message(ImportedMessage, CreateCounter, ReplaceCounter);
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
}

