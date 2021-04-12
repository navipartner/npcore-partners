codeunit 6014585 "NPR RP Package Handler"
{
    var
        ImportedMessage: Label 'Templates imported:\Created: %1\Replaced: %2';

    procedure ExportPackageToFile(var TemplateHeader: Record "NPR RP Template Header")
    var
        ManagedPackageBuilder: Codeunit "NPR Managed Package Builder";
        TemplateHeader2: Record "NPR RP Template Header";
        TemplateLine: Record "NPR RP Template Line";
        DataItems: Record "NPR RP Data Items";
        DataItemLinks: Record "NPR RP Data Item Links";
        DataItemConstraint: Record "NPR RP Data Item Constr.";
        DataItemConstraintLinks: Record "NPR RP Data Item Constr. Links";
        DeviceSettings: Record "NPR RP Device Settings";
        MediaInfo: Record "NPR RP Template Media Info";
        i: Integer;
        FileName: Text;
    begin
        if not TemplateHeader.FindSet() then
            exit;

        repeat
            TemplateLine.SetRange("Template Code", TemplateHeader.Code);
            DataItems.SetRange(Code, TemplateHeader.Code);
            DataItemLinks.SetRange("Data Item Code", TemplateHeader.Code);
            DataItemConstraint.SetRange("Data Item Code", TemplateHeader.Code);
            DataItemConstraintLinks.SetRange("Data Item Code", TemplateHeader.Code);
            DeviceSettings.SetRange(Template, TemplateHeader.Code);
            MediaInfo.SetRange(Template, TemplateHeader.Code);
            TemplateHeader2 := TemplateHeader;
            TemplateHeader2.SetRecFilter();

            ManagedPackageBuilder.AddRecord(TemplateHeader2);
            ManagedPackageBuilder.AddRecord(TemplateLine);
            ManagedPackageBuilder.AddRecord(DataItems);
            ManagedPackageBuilder.AddRecord(DataItemLinks);
            ManagedPackageBuilder.AddRecord(DataItemConstraint);
            ManagedPackageBuilder.AddRecord(DataItemConstraintLinks);
            ManagedPackageBuilder.AddRecord(DeviceSettings);
            ManagedPackageBuilder.AddRecord(MediaInfo);

            i += 1;
        until TemplateHeader.Next() = 0;

        if i = 1 then
            FileName := StrSubstNo('%1, Version %2', TemplateHeader.Code, TemplateHeader.Version)
        else
            FileName := 'Retail Print Templates';

        ManagedPackageBuilder.ExportToFile(FileName, '1.0', 'Templates for the retail print module', DATABASE::"NPR RP Template Header")
    end;

    procedure ExportPackageToBlob(var TemplateHeader: Record "NPR RP Template Header"; var TempBlobOut: Codeunit "Temp Blob")
    var
        ManagedPackageBuilder: Codeunit "NPR Managed Package Builder";
        TemplateHeader2: Record "NPR RP Template Header";
        TemplateLine: Record "NPR RP Template Line";
        DataItems: Record "NPR RP Data Items";
        DataItemLinks: Record "NPR RP Data Item Links";
        DataItemConstraint: Record "NPR RP Data Item Constr.";
        DataItemConstraintLinks: Record "NPR RP Data Item Constr. Links";
        DeviceSettings: Record "NPR RP Device Settings";
    begin
        //Does not export media info to prevent archive bloat.

        if not TemplateHeader.FindSet() then
            exit;

        repeat
            TemplateLine.SetRange("Template Code", TemplateHeader.Code);
            DataItems.SetRange(Code, TemplateHeader.Code);
            DataItemLinks.SetRange("Data Item Code", TemplateHeader.Code);
            DataItemConstraint.SetRange("Data Item Code", TemplateHeader.Code);
            DataItemConstraintLinks.SetRange("Data Item Code", TemplateHeader.Code);
            DeviceSettings.SetRange(Template, TemplateHeader.Code);
            TemplateHeader2 := TemplateHeader;
            TemplateHeader2.SetRecFilter();

            ManagedPackageBuilder.AddRecord(TemplateHeader2);
            ManagedPackageBuilder.AddRecord(TemplateLine);
            ManagedPackageBuilder.AddRecord(DataItems);
            ManagedPackageBuilder.AddRecord(DataItemLinks);
            ManagedPackageBuilder.AddRecord(DataItemConstraint);
            ManagedPackageBuilder.AddRecord(DataItemConstraintLinks);
            ManagedPackageBuilder.AddRecord(DeviceSettings);
        until TemplateHeader.Next() = 0;

        ManagedPackageBuilder.ExportToBlob('RP Template Archive', '1.0', StrSubstNo('Archived template: %1', TemplateHeader.Code), DATABASE::"NPR RP Template Header", TempBlobOut);
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

    [EventSubscriber(ObjectType::Codeunit, 6014628, 'OnLoadPackage', '', false, false)]
    local procedure OnLoadPackage(var Handled: Boolean; PrimaryPackageTable: Integer; JObject: JsonToken; LoadType: Option File,Blob,Download)
    var
        tmpImportWorksheet: Record "NPR RP Imp. Worksh." temporary;
        tmpTemplateHeader: Record "NPR RP Template Header" temporary;
        tmpTemplateLine: Record "NPR RP Template Line" temporary;
        tmpDataItem: Record "NPR RP Data Items" temporary;
        tmpDataItemLinks: Record "NPR RP Data Item Links" temporary;
        tmpDataItemConstraint: Record "NPR RP Data Item Constr." temporary;
        tmpDataItemConstraintLinks: Record "NPR RP Data Item Constr. Links" temporary;
        tmpDeviceSettings: Record "NPR RP Device Settings" temporary;
        tmpMediaInfo: Record "NPR RP Template Media Info" temporary;
        TemplateHeader: Record "NPR RP Template Header";
    begin
        if Handled then
            exit;
        if LoadType = LoadType::Blob then
            exit;
        if PrimaryPackageTable <> DATABASE::"NPR RP Template Header" then
            exit;

        Handled := true;

        if not ParsePackage(JObject, tmpTemplateHeader, tmpTemplateLine, tmpDataItem, tmpDataItemLinks, tmpDataItemConstraint, tmpDataItemConstraintLinks, tmpDeviceSettings, tmpMediaInfo) then
            exit;

        repeat
            tmpImportWorksheet.Init();
            tmpImportWorksheet."Entry No." += 1;
            tmpImportWorksheet.Template := tmpTemplateHeader.Code;
            tmpImportWorksheet."New Description" := tmpTemplateHeader.Description;
            tmpImportWorksheet."New Last Modified At" := tmpTemplateHeader."Last Modified At";
            tmpImportWorksheet."New Version" := tmpTemplateHeader.Version;
            if TemplateHeader.Get(tmpTemplateHeader.Code) then begin
                tmpImportWorksheet."Existing Description" := TemplateHeader.Description;
                tmpImportWorksheet."Existing Last Modified At" := TemplateHeader."Last Modified At";
                tmpImportWorksheet."Existing Version" := TemplateHeader.Version;
            end;
            tmpImportWorksheet.Insert(true);
        until tmpTemplateHeader.Next() = 0;

        if PAGE.RunModal(PAGE::"NPR RP Imp. Worksh.", tmpImportWorksheet) <> ACTION::LookupOK then
            exit;

        ImportPackage(tmpImportWorksheet, tmpTemplateHeader, tmpTemplateLine, tmpDataItem, tmpDataItemLinks, tmpDataItemConstraint, tmpDataItemConstraintLinks, tmpDeviceSettings, tmpMediaInfo);
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
            TableNo := JToken.AsValue.AsInteger();

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

        exit(tmpTemplateHeader.FindSet);
    end;

    local procedure ImportPackage(var tmpImportWorksheet: Record "NPR RP Imp. Worksh."; var tmpTemplateHeader: Record "NPR RP Template Header" temporary; var tmpTemplateLine: Record "NPR RP Template Line" temporary; var tmpDataItem: Record "NPR RP Data Items" temporary; var tmpDataItemLinks: Record "NPR RP Data Item Links" temporary; var tmpDataItemConstraint: Record "NPR RP Data Item Constr." temporary; var tmpDataItemConstraintLinks: Record "NPR RP Data Item Constr. Links" temporary; var tmpDeviceSettings: Record "NPR RP Device Settings" temporary; var tmpMediaInfo: Record "NPR RP Template Media Info" temporary)
    var
        TemplateHeader: Record "NPR RP Template Header";
        TemplateLine: Record "NPR RP Template Line";
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

                TemplateHeader.Init();
                TemplateHeader := tmpTemplateHeader;
                TemplateHeader.Insert();

                if tmpTemplateLine.FindSet() then
                    repeat
                        TemplateLine.Init();
                        TemplateLine := tmpTemplateLine;
                        TemplateLine.Insert();
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

                tmpMediaInfo.SetAutoCalcFields(Picture);
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
        TemplateHeader: Record "NPR RP Template Header";
        TemplateLine: Record "NPR RP Template Line";
        DataItems: Record "NPR RP Data Items";
        DataItemLinks: Record "NPR RP Data Item Links";
        DataItemConstraint: Record "NPR RP Data Item Constr.";
        DataItemConstraintLinks: Record "NPR RP Data Item Constr. Links";
        DeviceSettings: Record "NPR RP Device Settings";
        MediaInfo: Record "NPR RP Template Media Info";
        TemplateArchive: Record "NPR RP Template Archive";
    begin
        TemplateHeader.Get(Code);
        if not TemplateHeader.Archived then begin
            if not TemplateArchive.Get(Code, TemplateHeader.Version) then begin
                TemplateHeader."Version Comments" := 'Auto archiving before import';
                TemplateHeader.Validate(Archived, true);
            end;
        end;

        TemplateHeader.SetRange(Code, Code);
        TemplateLine.SetRange("Template Code", Code);
        DataItems.SetRange(Code, Code);
        DataItemLinks.SetRange("Data Item Code", Code);
        DataItemConstraint.SetRange("Data Item Code", Code);
        DataItemConstraintLinks.SetRange("Data Item Code", Code);
        DeviceSettings.SetRange(Template, Code);
        MediaInfo.SetRange(Template, Code);

        TemplateHeader.DeleteAll();
        TemplateLine.DeleteAll();
        DataItems.DeleteAll();
        DataItemLinks.DeleteAll();
        DataItemConstraint.DeleteAll();
        DataItemConstraintLinks.DeleteAll();
        DeviceSettings.DeleteAll();
        MediaInfo.DeleteAll();
    end;
}

