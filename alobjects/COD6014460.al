codeunit 6014460 "Table Import Export Media Mgt."
{
    // NPR5.48/MMV /20190215 CASE 342396 Created object
    // 
    // Since RecordRef & FieldRef does not support generically importing/exporting fields with type media / mediaset,
    // we use a temp table to call the new media functions, and pass the media GUID keys back and forth.


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014449, 'OnHandleMediaImport', '', false, false)]
    local procedure OnHandleMediaImport(var FieldRef: FieldRef; var TempBlob: Codeunit "Temp Blob")
    var
        TempImportExportMediaBuffer: Record "Import Export Media Buffer" temporary;
        InStream: InStream;
    begin
        TempBlob.CreateInStream(InStream);

        TempImportExportMediaBuffer.Init;
        TempImportExportMediaBuffer.Media.ImportStream(InStream, '');
        FieldRef.Value := TempImportExportMediaBuffer.Media;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014449, 'OnHandleMediaSetImport', '', false, false)]
    local procedure OnHandleMediaSetImport(var FieldRef: FieldRef; var TempBlob: Codeunit "Temp Blob")
    var
        TempImportExportMediaBuffer: Record "Import Export Media Buffer" temporary;
        InStream: InStream;
    begin
        TempBlob.CreateInStream(InStream);

        TempImportExportMediaBuffer.Init;
        TempImportExportMediaBuffer.MediaSet := FieldRef.Value;
        TempImportExportMediaBuffer.MediaSet.ImportStream(InStream, '');
        FieldRef.Value := TempImportExportMediaBuffer.MediaSet;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014448, 'OnHandleExportMedia', '', false, false)]
    local procedure OnHandleMediaExport(var FieldRef: FieldRef; var TempBlob: Codeunit "Temp Blob")
    var
        TempImportExportMediaBuffer: Record "Import Export Media Buffer" temporary;
        OutStream: OutStream;
    begin
        TempBlob.CreateOutStream(OutStream);

        TempImportExportMediaBuffer.Init;
        TempImportExportMediaBuffer.Media := FieldRef.Value;
        TempImportExportMediaBuffer.Media.ExportStream(OutStream);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014448, 'OnHandleExportMediaSet', '', false, false)]
    local procedure OnHandleMediaSetExport(var FieldRef: FieldRef; var TempBlob: Codeunit "Temp Blob"; Index: Integer)
    var
        TempImportExportMediaBuffer: Record "Import Export Media Buffer" temporary;
        OutStream: OutStream;
        TenantMedia: Record "Tenant Media";
        InStream: InStream;
    begin
        TempBlob.CreateOutStream(OutStream);

        TempImportExportMediaBuffer.Init;
        TempImportExportMediaBuffer.MediaSet := FieldRef.Value;

        TenantMedia.SetAutoCalcFields(Content);
        if not TenantMedia.Get(TempImportExportMediaBuffer.MediaSet.Item(Index)) then
            exit;

        TenantMedia.Content.CreateInStream(InStream);
        CopyStream(OutStream, InStream);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014448, 'OnGetMediaSetCount', '', false, false)]
    local procedure OnGetMediaSetCount(var FieldRef: FieldRef; var "Count": Integer)
    var
        TempImportExportMediaBuffer: Record "Import Export Media Buffer" temporary;
    begin
        TempImportExportMediaBuffer.Init;
        TempImportExportMediaBuffer.MediaSet := FieldRef.Value;
        Count := TempImportExportMediaBuffer.MediaSet.Count;
    end;
}

