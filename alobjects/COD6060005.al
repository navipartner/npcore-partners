codeunit 6060005 "GIM - File Fetch"
{

    trigger OnRun()
    var
        SearchFolder: Text[250];
        LocalFolder: Text[250];
        ArchiveFolder: Text[250];
    begin
        if not DataSourceSpecified then begin
            RunFTPSearch := true;
            RunLFUSearch := true;
            RunWSSearch := true;
        end else begin
            case DataSource of
                DataSource::"File upload":
                    RunLFUSearch := true;
                DataSource::FTP:
                    RunFTPSearch := true;
                DataSource::"Web Service":
                    RunWSSearch := true;
            end;
        end;

        if RunFTPSearch then begin
            DocType.SetRange("FTP Active", RunFTPSearch);
            if DocType.FindSet then
                repeat
                    SearchFolder := CheckFolderPath(DocType."FTP Search Folder");
                    LocalFolder := CheckFolderPath(DocType."FTP Local Folder");
                    ArchiveFolder := CheckFolderPath(DocType."FTP Archive Folder");
                    ChillkatFTP.LoginFTP(DocType."FTP Host Name", DocType."FTP Port", DocType."FTP Username", DocType."FTP Password");
                    ChillkatFTP.SetRemoteFolderFTP(SearchFolder, false);
                    case DocType."FTP File Action After Read" of
                        DocType."FTP File Action After Read"::Archive:
                            ChillkatFTP.DownloadFolderFromFTP(LocalFolder, '', '', ArchiveFolder, false);
                        DocType."FTP File Action After Read"::Delete:
                            ChillkatFTP.DownloadFolderFromFTP(LocalFolder, '', '', '', true);
                    end;
                    FetchAndProcess(1, LocalFolder, 1, '', 1);
                until DocType.Next = 0;
        end;

        if RunLFUSearch then begin
            DocType.Reset;
            DocType.SetRange("LFU Folder Active", RunLFUSearch);
            if DocType.FindSet then
                repeat
                    SearchFolder := CheckFolderPath(DocType."LFU Search Folder");
                    ArchiveFolder := CheckFolderPath(DocType."LFU Archive Folder");
                    FetchAndProcess(1, SearchFolder, DocType."LFU File Action After Read", ArchiveFolder, 0);
                until DocType.Next = 0;
        end;

        if RunWSSearch then begin
            DocType.Reset;
            if WSFileReceiveProvided then begin
                DocType.SetRange(Code, WSFileReceive."Doc. Type Code");
                DocType.SetRange("Sender ID", WSFileReceive."Sender ID");
            end;

            DocType.SetRange("WS Active", RunWSSearch);
            if DocType.FindSet then
                repeat
                    if WSFileReceiveProvided then begin
                        CreateImpDocAndStartProcess(WebServiceText, DataSource, WSFileReceive."File Name", WSFileReceive."File Extension");
                        WSFileReceive."File Processed" := true;
                        WSFileReceive.Modify;
                    end else begin
                        WSFileReceive.Reset;
                        WSFileReceive.SetRange("Doc. Type Code", DocType.Code);
                        WSFileReceive.SetRange("Sender ID", DocType."Sender ID");
                        WSFileReceive.SetRange("File Processed", false);
                        if WSFileReceive.FindSet then
                            repeat
                                CreateImpDocAndStartProcess(WebServiceText, DataSource, WSFileReceive."File Name", WSFileReceive."File Extension");
                                WSFileReceive2.Get(WSFileReceive."Entry No.");  //just to be sure it's not messing up repeat loop
                                WSFileReceive2."File Processed" := true;
                                WSFileReceive2.Modify;
                            until WSFileReceive.Next = 0;
                    end;
                until DocType.Next = 0;
        end;
    end;

    var
        DocType: Record "GIM - Document Type";
        ChillkatFTP: Codeunit "Chilkat FTP/SFTP";
        FileMgt: Codeunit "File Management";
        TempBLOB: Record TempBlob temporary;
        DataSource: Option "File upload",FTP,"Web Service",Mail;
        DataSourceSpecified: Boolean;
        RunFTPSearch: Boolean;
        RunLFUSearch: Boolean;
        RunWSSearch: Boolean;
        WSFileReceive: Record "GIM - WS Received File";
        WSFileReceiveProvided: Boolean;
        WebServiceText: Label 'Web Service';
        WSFileReceive2: Record "GIM - WS Received File";

    local procedure CreateImpDocAndStartProcess(FilePath: Text[250]; DataSourceHere: Option "File upload",FTP,"Web service",Mail; FileNameHere: Text[250]; FileExtensionHere: Text[30])
    var
        ImpDoc: Record "GIM - Import Document";
    begin
        ImpDoc.Init;
        ImpDoc."No." := '';
        ImpDoc.Insert(true);
        ImpDoc."Document Type" := DocType.Code;
        ImpDoc."Sender ID" := DocType."Sender ID";
        ImpDoc."Data Source" := DataSourceHere;
        ImpDoc."File Path" := FilePath;
        ImpDoc."File Name" := FileNameHere;
        ImpDoc."File Extension" := DelChr(FileExtensionHere, '=', '.');
        case DataSourceHere of
            DataSourceHere::"File upload", DataSourceHere::FTP:
                begin
                    FileMgt.BLOBImportFromServerFile(TempBLOB, FilePath);
                    ImpDoc."File Container" := TempBLOB.Blob;
                end;
            DataSourceHere::"Web service":
                begin
                    WSFileReceive.CalcFields("File Container");
                    ImpDoc."File Container" := WSFileReceive."File Container";
                end;
        end;
        ImpDoc.Modify;
        Commit;
        ImpDoc.StartProcess();
    end;

    local procedure FetchAndProcess(ObjectType: Option File,Folder; FolderPathOrFileName: Text; FileAction: Option Archive,Delete; ArchiveFolderPath: Text; DataSourceHere: Integer)
    var
        [RunOnClient]
        DirectoryInfo: DotNet npNetDirectoryInfo;
        [RunOnClient]
        FileInfo: DotNet npNetFileInfo;
        [RunOnClient]
        List: DotNet npNetList_Of_T;
        [RunOnClient]
        Enumerator: DotNet npNetIEnumerator;
        [RunOnClient]
        Obj: DotNet npNetObject;
        [RunOnClient]
        Folder: DotNet npNetDirectory;
        i: Integer;
        [RunOnClient]
        FileDotNet: DotNet npNetFile;
        NetConvHelper: Variant;
    begin
        case ObjectType of
            ObjectType::File:
                begin
                    FileInfo := FileInfo.FileInfo(FolderPathOrFileName);
                    CreateImpDocAndStartProcess(FileMgt.UploadFileSilent(FileInfo.FullName), DataSourceHere, FileInfo.Name, FileInfo.Extension);
                end;
            ObjectType::Folder:
                begin
                    DirectoryInfo := DirectoryInfo.DirectoryInfo(FolderPathOrFileName);
                    NetConvHelper := DirectoryInfo.GetFiles();
                    List := NetConvHelper;
                    Enumerator := List.GetEnumerator();
                    while Enumerator.MoveNext do begin
                        FileInfo := Enumerator.Current();
                        CreateImpDocAndStartProcess(FileMgt.UploadFileSilent(FileInfo.FullName), DataSourceHere, FileInfo.Name, FileInfo.Extension);
                        case FileAction of
                            FileAction::Archive:
                                begin
                                    if not FileDotNet.Exists(ArchiveFolderPath + FileInfo.Name) then
                                        FileInfo.MoveTo(ArchiveFolderPath + FileInfo.Name)
                                    else
                                        FileInfo.MoveTo(ArchiveFolderPath + CopyStr(FileInfo.Name, 1, StrPos(FileInfo.Name, FileInfo.Extension) - 1) + DelChr(Format(CurrentDateTime), '=', ' -:') + FileInfo.Extension);
                                end;
                            FileAction::Delete:
                                FileInfo.Delete();
                        end;
                    end;
                end;
        end;

        //keeping this code for reference if upper code won't work on NAS then we can try this one instead
        /*
        Obj := Folder.GetFiles(FolderPath);
        List := List.List();
        List.AddRange(Obj);
        IF List.Count > 0 THEN
          FOR i := 0 TO List.Count - 1 DO BEGIN
        
            FileInfo := List.Item(i);
            CreateImpDocAndStartProcess(FileMgt.UploadFileSilent(FileInfo.FullName),DataSourceHere);
            CASE FileAction OF
              FileAction::Archive: FileInfo.MoveTo(ArchiveFolderPath + FileInfo.Name());
              FileAction::Delete: FileInfo.Delete();
            END;
          END;
        */

    end;

    local procedure CheckFolderPath(FolderPath: Text): Text[250]
    begin
        if FolderPath <> '' then
            if CopyStr(FolderPath, StrLen(FolderPath), 1) <> '\' then
                FolderPath := FolderPath + '\';
        exit(FolderPath);
    end;

    procedure SetDataSource(DataSourceHere: Integer)
    begin
        DataSource := DataSourceHere;
        DataSourceSpecified := true;
    end;

    procedure SetWebServiceFile(WSFileReceiveHere: Record "GIM - WS Received File")
    begin
        WSFileReceive := WSFileReceiveHere;
        WSFileReceiveProvided := true;
    end;
}

