﻿codeunit 6014629 "NPR Managed Package Builder"
{
    Access = Internal;
    // This object is made for building a generic manifest containing data from one or more tables.
    // Call AddRecord() however many times you wish, with filters on Record if you only want to add a subset, followed by either ExportToFile() or ExportToBlob() depending on your use case.
    // 
    // Exports are done here with full JSON formatting, since ground control removes it on import.

    var
        GlobalJArray: JsonArray;
        TempGlobalTableList: Record AllObjWithCaption temporary;
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
        ConvertHelper: Codeunit "NPR Convert Helper";
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

        TempGlobalTableList."Object Type" := TempGlobalTableList."Object Type"::Table;
        TempGlobalTableList."Object ID" := RecRef.Number;
        if TempGlobalTableList.Insert() then;


        repeat
            clear(JObject);
            JObject.Add('Record', RecRef.Number);
            clear(JObjectRec);
            for i := 1 to RecRef.FieldCount do
                if RecRef.FieldIndex(i).Class = RecRef.FieldIndex(i).Class::Normal then begin  //do not include flow fields
                    ConvertHelper.FieldRefToVariant(RecRef.FieldIndex(i), FieldValue);
                    ConvertHelper.AddToJObject(JObjectRec, Format(RecRef.FieldIndex(i).Number), FieldValue);
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
        PackageFileNameLbl: Label '%1 Package.json', Locked = true;
    begin
        TempBlob.CreateOutStream(OutStm, TextEncoding::UTF8);
        OutStm.WriteText(CreateManifest(Name, Version, Description, PrimaryPackageTable));
        TempBlob.CreateInStream(InStm, TextEncoding::UTF8);

        CopyStream(OutStm, InStm);
        FileName := StrSubstNo(PackageFileNameLbl, Name);
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
        ConvertHelper: Codeunit "NPR Convert Helper";
        JObject: JsonObject;
        JArray: JsonArray;
    begin
        if GlobalJArray.Count() = 0 then
            Error(Error_NoData);

        ConvertHelper.CreateDependencyJObject(JObject, 'Data Package', Name, Version);
        ConvertHelper.AddToJObject(JObject, 'Description', Description);
        ConvertHelper.AddToJObject(JObject, 'Primary Package Table', PrimaryPackageTable);

        TempGlobalTableList.FindSet();
        repeat
            JArray.Add(TempGlobalTableList."Object ID");
        until TempGlobalTableList.Next() = 0;

        JObject.Add('Packaged Tables', JArray);
        JObject.Add('Data', GlobalJArray);

        Clear(GlobalJArray);
        Clear(TempGlobalTableList);
        Clear(GlobalRecCount);
        Clear(DialogValues);

        JObject.WriteTo(ReturnJsonText);
    end;
}

