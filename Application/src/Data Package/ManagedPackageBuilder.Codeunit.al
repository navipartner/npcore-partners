codeunit 6014629 "NPR Managed Package Builder"
{
    // This object is made for building a generic manifest containing data from one or more tables.
    // Call AddRecord() however many times you wish, with filters on Record if you only want to add a subset, followed by either ExportToFile() or ExportToBlob() depending on your use case.
    // 
    // Exports are done here with full JSON formatting, since ground control removes it on import.

    trigger OnRun()
    begin
    end;

    var
        GlobalTableListTmp: Record AllObjWithCaption temporary;
        GlobalJArray: JsonArray;
        Error_Parameter: Label 'Invalid parameter. Pass either Record or RecordRef';
        Error_NoData: Label 'No data has been added to the manifest';
        Error_TooLarge: Label 'You cannot create a package containing above 5000 records';
        DialogValues: array[2] of Integer;
        GlobalRecCount: Integer;
        IsDialogOpen: Boolean;
        ProgressDialog: Dialog;

    procedure AddRecord(Rec: Variant)
    var
        ManagedDependencyMgt: Codeunit "NPR Managed Dependency Mgt.";
        JObject: JsonObject;
        JObjectRec: JsonObject;
        JArray: JsonArray;
        JToken: JsonToken;
        RecRef: RecordRef;
        FieldValue: Variant;
        i: Integer;
        Itt: Integer;
        Total: Integer;
    begin
        if Rec.IsRecord() then
            RecRef.GetTable(Rec)
        else
            if Rec.IsRecordRef() then
                RecRef := Rec
            else
                Error(Error_Parameter);

        if not RecRef.FindSet(false, false) then
            exit;

        Total := RecRef.Count();
        GlobalRecCount += Total;

        if GlobalRecCount > 5000 then
            Error(Error_TooLarge);

        GlobalTableListTmp."Object Type" := GlobalTableListTmp."Object Type"::Table;
        GlobalTableListTmp."Object ID" := RecRef.Number();
        if GlobalTableListTmp.Insert() then;

        repeat
            JObject.Add('Record', RecRef.Number());
            Clear(JObjectRec);
            for i := 1 to RecRef.FieldCount() do begin
                ManagedDependencyMgt.FieldRefToVariant(RecRef.FieldIndex(i), FieldValue);
                JToken := FieldValue;
                JObjectRec.Add(Format(RecRef.FieldIndex(i).Number()), JToken);
            end;
            JObject.Add('Fields', JObjectRec);
            GlobalJArray.Add(JObject);
        until RecRef.Next() = 0;
        RecRef.Close();
    end;

    procedure ExportToFile(Name: Text; FileVersion: Text; Description: Text; PrimaryPackageTable: Integer)
    var
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        FileName: Variant;
    begin
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(Base64Convert.ToBase64(CreateManifest(Name, FileVersion, Description, PrimaryPackageTable)));
        TempBlob.CreateInStream(InStr);
        FileName := StrSubstNo('%1 Package.json', Name);
        DownloadFromStream(InStr, 'Save Package Manifest', '', 'JSON File (*.json)|*.json', FileName);
    end;

    procedure ExportToBlob(Name: Text; FileVersion: Text; Description: Text; PrimaryPackageTable: Integer; var TempBlobOut: Codeunit "Temp Blob")
    var
        ManagedDependencyMgt: Codeunit "NPR Managed Dependency Mgt.";
        OutStr: OutStream;
    begin
        TempBlobOut.CreateOutStream(OutStr, TEXTENCODING::UTF8);
        OutStr.Write(CreateManifest(Name, FileVersion, Description, PrimaryPackageTable));
    end;

    local procedure CreateManifest(Name: Text; FileVersion: Text; Description: Text; PrimaryPackageTable: Integer): Text
    var
        ManagedDependencyMgt: Codeunit "NPR Managed Dependency Mgt.";
        JObject: JsonObject;
        JArray: JsonArray;
        JSON: Text;
    begin
        if GlobalJArray.Count() = 0 then
            Error(Error_NoData);

        JObject := ManagedDependencyMgt.CreateDependencyJObject('Data Package', Name, FileVersion);
        JObject.Add('Description', Description);
        JObject.Add('Primary Package Table', PrimaryPackageTable);

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

        JObject.WriteTo(JSON);
        exit(JSON);
    end;
}

