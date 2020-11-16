codeunit 6014629 "NPR Managed Package Builder"
{
    // NPR5.26/MMV /20160915 CASE 252131 Created object.
    // 
    // This object is made for building a generic manifest containing data from one or more tables.
    // Call AddRecord() however many times you wish, with filters on Record if you only want to add a subset, followed by either ExportToFile() or ExportToBlob() depending on your use case.
    // 
    // Exports are done here with full JSON formatting, since ground control removes it on import.
    // 
    // NPR5.27/MMV /20161014 CASE 252131 Fixed missing UTF-8 encoding on blob export.
    // NPR5.38/MMV /20171204 CASE 294095 Removed incorrect progress dialog


    trigger OnRun()
    begin
    end;

    var
        GlobalJArray: DotNet JArray;
        GlobalTableListTmp: Record AllObjWithCaption temporary;
        Error_Parameter: Label 'Invalid parameter. Pass either Record or RecordRef';
        Error_NoData: Label 'No data has been added to the manifest';
        GlobalRecCount: Integer;
        IsDialogOpen: Boolean;
        ProgressDialog: Dialog;
        DialogValues: array[2] of Integer;
        Error_TooLarge: Label 'You cannot create a package containing above 5000 records';

    procedure AddRecord("Record": Variant)
    var
        JObject: DotNet JObject;
        JObjectRec: DotNet JObject;
        JArray: DotNet JArray;
        RecRef: RecordRef;
        Value: Variant;
        i: Integer;
        ManagedDependencyMgt: Codeunit "NPR Managed Dependency Mgt.";
        Itt: Integer;
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

        //-NPR5.38 [294095]
        // OpenDialog();
        //+NPR5.38 [294095]

        Total := RecRef.Count;
        GlobalRecCount += Total;


        if GlobalRecCount > 5000 then
            Error(Error_TooLarge);

        //-NPR5.38 [294095]
        //UpdateDialog(1,RecRef.NUMBER);
        //+NPR5.38 [294095]

        GlobalTableListTmp."Object Type" := GlobalTableListTmp."Object Type"::Table;
        GlobalTableListTmp."Object ID" := RecRef.Number;
        if GlobalTableListTmp.Insert then;

        if IsNull(GlobalJArray) then
            GlobalJArray := GlobalJArray.JArray();

        with ManagedDependencyMgt do begin
            repeat
                //-NPR5.38 [294095]
                //    Itt += 1;
                //    UpdateProgressDialog(2,Itt,Total);
                //+NPR5.38 [294095]

                JObject := JObject.JObject();
                AddToJObject(JObject, 'Record', RecRef.Number);
                JObjectRec := JObjectRec.JObject();
                for i := 1 to RecRef.FieldCount do begin
                    FieldRefToVariant(RecRef.FieldIndex(i), Value);
                    AddToJObject(JObjectRec, Format(RecRef.FieldIndex(i).Number), Value);
                end;
                JObject.Add('Fields', JObjectRec);
                AddToJArray(GlobalJArray, JObject);
            until RecRef.Next = 0;
        end;

        RecRef.Close;
    end;

    procedure ExportToFile(Name: Text; Version: Text; Description: Text; PrimaryPackageTable: Integer)
    var
        JObject: DotNet JObject;
        JArray: DotNet JArray;
        FileMgt: Codeunit "File Management";
        MemoryStream: DotNet NPRNetMemoryStream;
        Encoding: DotNet NPRNetEncoding;
        FileName: Variant;
    begin
        //-NPR5.38 [294095]
        //CloseDialog();
        //+NPR5.38 [294095]

        Encoding := Encoding.GetEncoding('utf-8');
        MemoryStream := MemoryStream.MemoryStream(Encoding.GetBytes(CreateManifest(Name, Version, Description, PrimaryPackageTable)));
        FileName := StrSubstNo('%1 Package.json', Name);
        DownloadFromStream(MemoryStream, 'Save Package Manifest', '', 'JSON File (*.json)|*.json', FileName);
    end;

    procedure ExportToBlob(Name: Text; Version: Text; Description: Text; PrimaryPackageTable: Integer; var TempBlobOut: Codeunit "Temp Blob")
    var
        ManagedDependencyMgt: Codeunit "NPR Managed Dependency Mgt.";
        JObject: DotNet JObject;
        OutStream: OutStream;
        JArray: DotNet JArray;
    begin
        //-NPR5.38 [294095]
        //CloseDialog();
        //+NPR5.38 [294095]

        //-NPR5.27 [252131]
        //TempBlobOut.Blob.CREATEOUTSTREAM(OutStream);
        TempBlobOut.CreateOutStream(OutStream, TEXTENCODING::UTF8);
        //+NPR5.27 [252131]
        OutStream.Write(CreateManifest(Name, Version, Description, PrimaryPackageTable));
    end;

    local procedure CreateManifest(Name: Text; Version: Text; Description: Text; PrimaryPackageTable: Integer): Text
    var
        ManagedDependencyMgt: Codeunit "NPR Managed Dependency Mgt.";
        JObject: DotNet JObject;
        JArray: DotNet JArray;
    begin
        if IsNull(GlobalJArray) then
            Error(Error_NoData);

        ManagedDependencyMgt.CreateDependencyJObject(JObject, 'Data Package', Name, Version);
        ManagedDependencyMgt.AddToJObject(JObject, 'Description', Description);
        ManagedDependencyMgt.AddToJObject(JObject, 'Primary Package Table', PrimaryPackageTable);

        JArray := JArray.JArray();
        GlobalTableListTmp.FindSet;
        repeat
            JArray.Add(GlobalTableListTmp."Object ID");
        until GlobalTableListTmp.Next = 0;

        JObject.Add('Packaged Tables', JArray);
        JObject.Add('Data', GlobalJArray);

        Clear(GlobalJArray);
        Clear(GlobalTableListTmp);
        Clear(GlobalRecCount);
        Clear(DialogValues);

        exit(JObject.ToString());
    end;
}

