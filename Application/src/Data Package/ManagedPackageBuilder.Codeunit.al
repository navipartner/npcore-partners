codeunit 6014629 "NPR Managed Package Builder"
{
    // This object is made for building a generic manifest containing data from one or more tables.
    // Call AddRecord() however many times you wish, with filters on Record if you only want to add a subset, followed by either ExportToFile() or ExportToBlob() depending on your use case.
    // 
    // Exports are done here with full JSON formatting, since ground control removes it on import.

    var
        GlobalJArray: JsonArray;
        GlobalTableListTmp: Record AllObjWithCaption temporary;
        Error_Parameter: Label 'Invalid parameter. Pass either Record or RecordRef';
        Error_NoData: Label 'No data has been added to the manifest';
        DialogValues: array[2] of Integer;
        GlobalRecCount: Integer;

    procedure AddRecord("Record": Variant)
    var
        JObject: JsonObject;
        JObjectRec: JsonObject;
        RecRef: RecordRef;
        FieldValue: Variant;
        i: Integer;
        ManagedDependencyMgt: Codeunit "NPR Managed Dependency Mgt.";
        Total: Integer;
    begin
        if Record.IsRecord then
            RecRef.GetTable(Record)
        else
            if Record.IsRecordRef then
                RecRef := Record
            else
                Error(Error_Parameter);

        if not RecRef.FindSet(false, false) then
            exit;

        Total := RecRef.Count();
        GlobalRecCount += Total;

        GlobalTableListTmp."Object Type" := GlobalTableListTmp."Object Type"::Table;
        GlobalTableListTmp."Object ID" := RecRef.Number;
        if GlobalTableListTmp.Insert() then;


        repeat
            clear(JObject);
            JObject.Add('Record', RecRef.Number);
            clear(JObjectRec);
            for i := 1 to RecRef.FieldCount do begin
                ManagedDependencyMgt.FieldRefToVariant(RecRef.FieldIndex(i), FieldValue);
                ManagedDependencyMgt.AddToJObject(JObjectRec, Format(RecRef.FieldIndex(i).Number), FieldValue);
            end;
            JObject.Add('Fields', JObjectRec);
            GlobalJArray.Add(JObject);
        until RecRef.Next() = 0;

        RecRef.Close();
    end;


    procedure ExportToFile(Name: Text; Version: Text; Description: Text; PrimaryPackageTable: Integer)
    var
        InStm: InStream;
        OutStm: OutStream;
        FileName: Variant;
        TempBlob: Codeunit "Temp Blob";
    begin
        TempBlob.CreateOutStream(OutStm);
        OutStm.WriteText(CreateManifest(Name, Version, Description, PrimaryPackageTable));
        TempBlob.CreateInStream(InStm);

        CopyStream(OutStm, InStm);
        FileName := StrSubstNo('%1 Package.json', Name);
        DownloadFromStream(InStm, 'Save Package Manifest', '', 'JSON File (*.json)|*.json', FileName);
    end;

    procedure ExportToBlob(Name: Text; FileVersion: Text; Description: Text; PrimaryPackageTable: Integer; var TempBlobOut: Codeunit "Temp Blob")
    var
        OutStr: OutStream;
    begin
        TempBlobOut.CreateOutStream(OutStr, TEXTENCODING::UTF8);
        OutStr.Write(CreateManifest(Name, FileVersion, Description, PrimaryPackageTable));
    end;

    local procedure CreateManifest(Name: Text; Version: Text; Description: Text; PrimaryPackageTable: Integer) ReturnJsonText: Text
    var
        ManagedDependencyMgt: Codeunit "NPR Managed Dependency Mgt.";
        JObject: JsonObject;
        JArray: JsonArray;
    begin
        if GlobalJArray.Count() = 0 then
            Error(Error_NoData);

        ManagedDependencyMgt.CreateDependencyJObject(JObject, 'Data Package', Name, Version);
        ManagedDependencyMgt.AddToJObject(JObject, 'Description', Description);
        ManagedDependencyMgt.AddToJObject(JObject, 'Primary Package Table', PrimaryPackageTable);

        GlobalTableListTmp.FindSet();
        repeat
            JArray.Add(GlobalTableListTmp."Object ID");
        until GlobalTableListTmp.Next() = 0;

        JObject.Add('Packaged Tables', JArray);
        JObject.Add('Data', GlobalJArray);

        Clear(GlobalJArray);
        Clear(GlobalTableListTmp);
        Clear(GlobalRecCount);
        Clear(DialogValues);

        JObject.WriteTo(ReturnJsonText);
    end;
}

