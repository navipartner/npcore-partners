table 6059944 "NaviDocs Entry Attachment"
{
    // NPR5.43/THRO/20180531 CASE 315958 Table created

    Caption = 'NaviDocs Entry Attachment';

    fields
    {
        field(1; "NaviDocs Entry No."; BigInteger)
        {
            Caption = 'NaviDocs Entry No.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(10; Data; BLOB)
        {
            Caption = 'Data';
        }
        field(20; "File Extension"; Text[10])
        {
            Caption = 'File Extension';
        }
        field(30; "Data Type"; Code[20])
        {
            Caption = 'Data Type';
        }
        field(40; Description; Text[30])
        {
            Caption = 'Description';
        }
        field(50; "Internal Type"; Option)
        {
            Caption = 'Internal Type';
            OptionCaption = ' ,Report Parameters';
            OptionMembers = " ","Report Parameters";
        }
    }

    keys
    {
        key(Key1; "NaviDocs Entry No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        NoDataText: Label 'No Data in record.';

    procedure ShowOutput()
    var
        SyncMgt: Codeunit "Nc Sync. Mgt.";
        FileMgt: Codeunit "File Management";
        StreamReader: DotNet npNetStreamReader;
        InStr: InStream;
        Path: Text;
        Content: Text;
        IsHandled: Boolean;
        TempBlob: Codeunit "Temp Blob";
    begin
        OnShowOutput(Rec, IsHandled);
        if IsHandled then
            exit;

        CalcFields(Data);
        if not Data.HasValue then begin
            Message(NoDataText);
            exit;
        end;
        TempBlob.FromRecord(Rec, FieldNo(Data));
        FileMgt.BLOBExport(TempBlob, StrSubstNo(FilenamePattern, "NaviDocs Entry No.", "File Extension"), true);
        exit;
        Data.CreateInStream(InStr, TEXTENCODING::UTF8);
        if IsWebClient() then begin
            StreamReader := StreamReader.StreamReader(InStr);
            Content := StreamReader.ReadToEnd();
            Message(Content);
        end else begin
            Path := TemporaryPath + StrSubstNo(FilenamePattern, "NaviDocs Entry No.", "File Extension");
            StreamReader := StreamReader.StreamReader(InStr);
            DownloadFromStream(InStr, 'Export', FileMgt.Magicpath, '.xml', Path);
            SyncMgt.RunProcess('notepad.exe', Path, false);
            Sleep(100);
            FileMgt.DeleteClientFile(Path);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnShowOutput(var NaviDocsEntryAttachment: Record "NaviDocs Entry Attachment"; var IsHandled: Boolean)
    begin
    end;

    local procedure IsWebClient(): Boolean
    var
        ActiveSession: Record "Active Session";
    begin
        if ActiveSession.Get(ServiceInstanceId, SessionId) then
            exit(ActiveSession."Client Type" = ActiveSession."Client Type"::"Web Client");
        exit(false);
    end;

    local procedure FilenamePattern(): Text
    begin
        exit('NaviDocs-%1.%2');
    end;
}

