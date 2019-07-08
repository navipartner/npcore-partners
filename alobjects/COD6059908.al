codeunit 6059908 "Chilkat FTP/SFTP"
{
    // created test FTP account that can be used to test:
    // Hostname: ftp://edi.npkhosting.dk/
    // Port:     21
    // Login:    navipartner_ftp_test_user
    // Password: CAr7kYuU+1
    // 
    // TQ1.17/JDH/20141015 CASE 179044 reworked CU to be capable of beeing used from everywhere
    // TQ1.19/JDH/20141104 CASE 197498 fix for downloading without file extension filter
    //                                 Port 0 replaced by 21 + if folder does not ends with '/', it will be added
    // TQ1.20/JDH/20141205 CASE 187044 SFTP Upload
    // TQ1.27/JDH/20150701 CASE 217903 Deleted unused Variables and fields
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue

    TableNo = "Task Line";

    trigger OnRun()
    begin
        CheckForParameters(Rec);

        if GetParameterBool('USE_SFTP') then begin
          //-TQ1.20
          //SFTP not tested yet
          //SFTP_Upload(Rec);
          if GetParameterBool('FTP_DOWNLOAD') then
            Error('NOT Implemented Yet')
          else
            SFTP_UploadTQ(Rec);
          //+TQ1.20
        end else begin
          if GetParameterBool('FTP_DOWNLOAD') then
            FTP_DownloadTQ(Rec)
          else
            FTP_UploadTQ(Rec);
        end;
    end;

    var
        Text001: Label 'No Parameters found. Do you with to have empty Parameters added?';
        Text002: Label 'Empty Parameters added. Please fill in the parameters before run this task again';
        ChilkatFtp2: DotNet Ftp2;
        ChilkatSFTP: DotNet SFtp;

    local procedure FTP_UploadTQ(TaskLine: Record "Task Line")
    var
        FTPFilePath: Text[1024];
    begin
        //-TQ1.17
        with TaskLine do begin
          if not LoginFTP(GetParameterText('HOSTNAME'),
                          GetParameterInt('PORT'),
                          GetParameterText('LOGIN'),
                          GetParameterText('PASSWORD')) then
            Error(GetLastError);

          FTPFilePath := GetParameterText('FTP_FOLDER_PATH');
          if FTPFilePath <> '' then
            if not SetRemoteFolderFTP(FTPFilePath, true) then
              Error(GetLastError);

          //Find the files to upload - (From Local folder)
          if not UploadFolder2FTP(GetParameterText('LOCAL_FOLDER_PATH'),
                                  GetParameterText('FILE_EXT_FILTER'),
                                  GetParameterText('RENAME_ORG_FILE_TO'),
                                  GetParameterText('MOVE_TO_SUB_FOLDER'),
                                  GetParameterBool('DELETE_ORG_FILE')) then
            Error(GetLastError);
          DisconnectFTP;
        end;
        //+TQ1.17
    end;

    local procedure FTP_DownloadTQ(TaskLine: Record "Task Line")
    var
        FTPFileName: Text[1024];
        FTPFilePath: Text[1024];
    begin
        with TaskLine do begin
          if not LoginFTP(GetParameterText('HOSTNAME'),
                          GetParameterInt('PORT'),
                          GetParameterText('LOGIN'),
                         GetParameterText('PASSWORD')) then
            Error(GetLastError);


          FTPFilePath := GetParameterText('FTP_FOLDER_PATH');
          if FTPFilePath <> '' then
            if not SetRemoteFolderFTP(FTPFilePath, true) then
              Error(GetLastError);

          if not DownloadFolderFromFTP(GetParameterText('LOCAL_FOLDER_PATH'),
                                       GetParameterText('FILE_EXT_FILTER'),
                                       GetParameterText('RENAME_ORG_FILE_TO'),
                                       GetParameterText('MOVE_TO_SUB_FOLDER'),
                                       GetParameterBool('DELETE_ORG_FILE')) then
            Error(GetLastError);
          DisconnectFTP;
        end;
    end;

    local procedure SFTP_UploadTQ(TaskLine: Record "Task Line")
    begin
        //-TQ1.20
        with TaskLine do begin
          if not LoginSFTP(GetParameterText('HOSTNAME'),
                           GetParameterInt('PORT'),
                           GetParameterText('LOGIN'),
                           GetParameterText('PASSWORD')) then
            Error(GetLastErrorSFTP);

          //FTPFilePath := GetParameterText('FTP_FOLDER_PATH');
          //IF FTPFilePath <> '' THEN
          //  IF NOT SetRemoteFolderFTP(FTPFilePath, TRUE) THEN
          //    ERROR(GetLastError);

          //Find the files to upload - (From Local folder)
          //IF NOT UploadFile2sFTP(GetParameterText('LOCAL_FOLDER_PATH'),
          //                       GetParameterText('FILE_EXT_FILTER'),
          //                       GetParameterText('RENAME_ORG_FILE_TO'),
          //                       GetParameterText('MOVE_TO_SUB_FOLDER'),
          //                       GetParameterBool('DELETE_ORG_FILE')) THEN
          //  ERROR(GetLastError);
          DisconnectSFTP;
        end;
        //+TQ1.20
    end;

    procedure CheckForParameters(TaskLine: Record "Task Line")
    begin
        if TaskLine.ParametersExists then
          exit;

        if GuiAllowed then
          if not Confirm(Text001) then
            exit;

        TaskLine.InsertParameter('HOSTNAME',0);
        TaskLine.InsertParameter('PORT',4);
        TaskLine.InsertParameter('LOGIN',0);
        TaskLine.InsertParameter('PASSWORD',0);
        TaskLine.InsertParameter('FTP_FOLDER_PATH',0);
        TaskLine.InsertParameter('LOCAL_FOLDER_PATH',0);
        TaskLine.InsertParameter('FILE_EXT_FILTER',0);
        TaskLine.InsertParameter('UPLOAD_FILENAME',0);
        TaskLine.InsertParameter('USE_TASK_FILES',6);
        TaskLine.InsertParameter('USE_SFTP',6);
        TaskLine.InsertParameter('RENAME_ORG_FILE_TO',0);
        TaskLine.InsertParameter('MOVE_TO_SUB_FOLDER',0);
        TaskLine.InsertParameter('DELETE_ORG_FILE',6);
        TaskLine.InsertParameter('FTP_DOWNLOAD',6);

        Commit;
        Error(Text002);
    end;

    procedure GetLastError(): Text[1024]
    begin
        //-TQ1.17
        exit(CopyStr(ChilkatFtp2.LastErrorText,1,1024));
        //+TQ1.17
    end;

    procedure LoginFTP(Hostname: Text[1024];Port: Integer;UserID: Text[100];Password: Text[100]): Boolean
    begin
        //-TQ1.19
        if Port = 0 then
          Port := 21;
        //+TQ1.19

        //-TQ1.17
        ChilkatFtp2 := ChilkatFtp2.Ftp2;

        if not ChilkatFtp2.UnlockComponent('NAVIPAFTP_D6eyNQZe6Cne') then
         exit(false);

        ChilkatFtp2.Hostname := Hostname;
        ChilkatFtp2.Port     := Port;
        ChilkatFtp2.Username := UserID;
        ChilkatFtp2.Password := Password;

        exit(ChilkatFtp2.Connect);
        //+TQ1.17
    end;

    procedure SetRemoteFolderFTP(Path: Text[1024];CreateIfNotExists: Boolean): Boolean
    begin
        //-TQ1.17
        if CreateIfNotExists then begin
          // Create Remote Directory
          //If dir present, it will not create a new one
          //Error should not be catched...
          ChilkatFtp2.CreateRemoteDir(Path);
        end;
        exit(ChilkatFtp2.ChangeRemoteDir(Path));
        //+TQ1.17
    end;

    procedure UploadFile2FTP(LocalFilePath: Text[1024];LocalFileName: Text[1024];RemoteFileName: Text[1024]): Boolean
    begin
        //-TQ1.19
        if LocalFilePath[StrLen(LocalFilePath)] <> '/' then
          LocalFilePath += '/';
        //+TQ1.19

        //-TQ1.17
        exit(ChilkatFtp2.PutFile(LocalFilePath + LocalFileName, LocalFileName));
        //+TQ1.17
    end;

    procedure UploadFolder2FTP(LocalFilePath: Text[1024];FileExtfilter: Text[4];RenameToExt: Text[4];ArchiveFolder: Text[1024];DeleteOrgFile: Boolean): Boolean
    var
        Files: Record File;
        UploadFile: Boolean;
        FileExt: Text[30];
        NewFileName: Text[1024];
        OldFileName: Text[1024];
        WithError: Boolean;
    begin
        //-TQ1.17
        //usage:
        //Localfilepath = c:\temp\,
        //FileExtfilter = fob
        //RenameToExt   = old
        //ArchiveFolder = c:\temp\archive\
        //DeleteOrgFile = true

        //will upload all *.fob files from c:\Temp\
        //all fob files in "c:\temp\" will be renamed to .fob.old
        //and moved to "c:\temp\archive\"
        //and the file in the "c:\temp\" folder will be deleted

        //only the first parameter is mandatory - the rest can be blank, and will then be ignorred
        //fileextfilter = ''    -> all files will be uploaded
        //RenameToExt   = ''    -> no rename
        //ArchiveFolder = ''    -> no archive
        //DeleteOrgFile = false -> dont delete the file

        if LocalFilePath = '' then
          exit(false);

        if LocalFilePath[StrLen(LocalFilePath)] <> '\' then
          LocalFilePath += '\';

        Files.SetRange(Path, LocalFilePath);
        Files.SetRange("Is a file", true);
        if Files.FindSet then repeat
          if FileExtfilter <> '' then begin
            FileExt :=  CopyStr(Files.Name, StrLen(Files.Name) - StrLen(FileExtfilter) + 1);
            UploadFile := FileExt = FileExtfilter;
          end else
            UploadFile := true;

          if UploadFile then begin
            if not UploadFile2FTP(Files.Path, Files.Name, Files.Name) then
              WithError := true;

            OldFileName := Files.Path + Files.Name;

            if RenameToExt <> '' then begin
              NewFileName := Files.Path + Files.Name + RenameToExt;
              Rename(OldFileName, NewFileName);
              OldFileName := NewFileName;
            end;

            if ArchiveFolder <> '' then begin
              NewFileName := ArchiveFolder + Files.Name;
              FILE.Copy(OldFileName, NewFileName);
            end;

            if DeleteOrgFile then begin
              Erase(OldFileName);
            end;
          end;
        until Files.Next = 0;
        exit(not WithError);
        //+TQ1.17
    end;

    procedure DownloadFolderFromFTP(LocalFilePath: Text[1024];FileExtfilter: Text[4];RenameToExt: Text[4];ArchiveFolder: Text[1024];DeleteOrgFile: Boolean): Boolean
    var
        FileExt: Text[30];
        NewFileName: Text[1024];
        i: Integer;
        FTPFileName: Text[1024];
        DownloadFile: Boolean;
    begin
        //-TQ1.17
        //usage:
        //Localfilepath = c:\temp\,
        //FileExtfilter = fob
        //RenameToExt   = old
        //ArchiveFolder = \archive\
        //DeleteOrgFile = true

        //will download all *.fob files to c:\Temp\
        //all fob files on FTP server will be renamed to .fob.old
        //and moved to FTP subfolder \archive\"
        //and the file on the FTP server will be deleted

        //only the first parameter is mandatory - the rest can be blank, and will then be ignorred
        //fileextfilter = ''    -> all files will be downloaded
        //RenameToExt   = ''    -> no rename
        //ArchiveFolder = ''    -> no archive
        //DeleteOrgFile = false -> dont delete the file

        //Warning: Archive folder not supported Yet
        if ArchiveFolder <> '' then
          Error('NOT Supported yet');

        if LocalFilePath = '' then
          exit(false);

        for i := 0 to ChilkatFtp2.NumFilesAndDirs - 1 do begin
          if not ChilkatFtp2.GetIsDirectory(i) then begin
            //-TQ1.19
            FTPFileName := ChilkatFtp2.GetFilename(i);
            //+TQ1.19
            if FileExtfilter <> '' then begin
              //-TQ1.19
              //FTPFileName := ChilkatFtp2.GetFilename(i);
              //+TQ1.19
              FileExt :=  CopyStr(FTPFileName, StrLen(FTPFileName) - StrLen(FileExtfilter) + 1);
              DownloadFile := FileExt = FileExtfilter;
            end else
              DownloadFile := true;

            if DownloadFile then begin
              ChilkatFtp2.GetFile(FTPFileName, LocalFilePath + FTPFileName);

              if RenameToExt <> '' then begin
                NewFileName := FTPFileName + RenameToExt;
                ChilkatFtp2.RenameRemoteFile(FTPFileName, NewFileName);
              end;

              //IF MoveToFolder <> '' THEN BEGIN
              //  NewFileName := Files.Path + MoveToFolder + Files.Name;
              //  OldFileName := Files.Path + Files.Name;
              //  FILE.COPY(OldFileName, NewFileName);
              //  ERASE(Files.Path + Files.Name);
              //END;

              if DeleteOrgFile then begin
                ChilkatFtp2.DeleteRemoteFile(FTPFileName);
              end;
            end;
          end;
        end;
        exit(true);
        //+TQ1.17
    end;

    procedure DisconnectFTP()
    begin
        //-TQ1.17
        ChilkatFtp2.Disconnect;
        Clear(ChilkatFtp2);
        //+TQ1.17
    end;

    procedure GetLastErrorSFTP(): Text[1024]
    begin
        //-TQ1.20
        exit(CopyStr(ChilkatSFTP.LastErrorText,1,1024));
        //+TQ1.20
    end;

    procedure LoginSFTP(Hostname: Text[1024];Port: Integer;UserID: Text[100];Password: Text[100]): Boolean
    begin
        //-TQ1.20
        if Port = 0 then
          Port := 22;


        ChilkatSFTP := ChilkatSFTP.SFtp;

        if not ChilkatSFTP.UnlockComponent('NAVIPASSH_ELzTBVLb5InN') then
          exit(false);

        ChilkatSFTP.ConnectTimeoutMs := 5000;
        ChilkatSFTP.IdleTimeoutMs := 10000;

        if not ChilkatSFTP.Connect(Hostname,Port) then
          exit(false);


        if UserID <> '' then
          if not ChilkatSFTP.AuthenticatePw(UserID, Password) then
            exit(false);

        exit(ChilkatSFTP.InitializeSftp());
        //+TQ1.20
    end;

    procedure UploadFile2SFTP(LocalFilePath: Text[1024];LocalFileName: Text[1024];RemoteFileName: Text[1024]): Boolean
    var
        Handle: Text[50];
    begin
        //-TQ1.20
        if LocalFilePath[StrLen(LocalFilePath)] <> '/' then
          LocalFilePath += '/';

        Handle := ChilkatSFTP.OpenFile(RemoteFileName,'writeonly','Createnew');
        if Handle = '' then
          exit(false);

        if not ChilkatSFTP.UploadFile(Handle, LocalFilePath + LocalFileName) then
          exit(false);

        exit(ChilkatSFTP.CloseHandle(Handle));
        //+TQ1.20
    end;

    procedure UploadFolder2SFTP(LocalFilePath: Text[1024];FileExtfilter: Text[4];RenameToExt: Text[4];ArchiveFolder: Text[1024];DeleteOrgFile: Boolean): Boolean
    var
        Files: Record File;
        UploadFile: Boolean;
        FileExt: Text[30];
        NewFileName: Text[1024];
        OldFileName: Text[1024];
        WithError: Boolean;
    begin
        //-TQ1.20
        //usage:
        //Localfilepath = c:\temp\,
        //FileExtfilter = fob
        //RenameToExt   = old
        //ArchiveFolder = c:\temp\archive\
        //DeleteOrgFile = true

        //will upload all *.fob files from c:\Temp\
        //all fob files in "c:\temp\" will be renamed to .fob.old
        //and moved to "c:\temp\archive\"
        //and the file in the "c:\temp\" folder will be deleted

        //only the first parameter is mandatory - the rest can be blank, and will then be ignorred
        //fileextfilter = ''    -> all files will be uploaded
        //RenameToExt   = ''    -> no rename
        //ArchiveFolder = ''    -> no archive
        //DeleteOrgFile = false -> dont delete the file

        if LocalFilePath = '' then
          exit(false);

        if LocalFilePath[StrLen(LocalFilePath)] <> '\' then
          LocalFilePath += '\';

        Files.SetRange(Path, LocalFilePath);
        Files.SetRange("Is a file", true);
        if Files.FindSet then repeat
          if FileExtfilter <> '' then begin
            FileExt :=  CopyStr(Files.Name, StrLen(Files.Name) - StrLen(FileExtfilter) + 1);
            UploadFile := FileExt = FileExtfilter;
          end else
            UploadFile := true;

          if UploadFile then begin
            if not UploadFile2SFTP(Files.Path, Files.Name, Files.Name) then
              WithError := true;

            OldFileName := Files.Path + Files.Name;

            if RenameToExt <> '' then begin
              NewFileName := Files.Path + Files.Name + RenameToExt;
              Rename(OldFileName, NewFileName);
              OldFileName := NewFileName;
            end;

            if ArchiveFolder <> '' then begin
              NewFileName := ArchiveFolder + Files.Name;
              FILE.Copy(OldFileName, NewFileName);
            end;

            if DeleteOrgFile then begin
              Erase(OldFileName);
            end;
          end;
        until Files.Next = 0;
        exit(not WithError);
        //+TQ1.20
    end;

    procedure DisconnectSFTP()
    begin
        //-TQ1.20
        ChilkatSFTP.Disconnect();
        Clear(ChilkatSFTP);
        //+TQ1.20
    end;

    trigger ChilkatSFTP::OnDownloadRate(sender: Variant;args: DotNet DataRateEventArgs)
    begin
    end;

    trigger ChilkatSFTP::OnUploadRate(sender: Variant;args: DotNet DataRateEventArgs)
    begin
    end;

    trigger ChilkatSFTP::OnProgressInfo(sender: Variant;args: DotNet ProgressInfoEventArgs)
    begin
    end;

    trigger ChilkatSFTP::OnPercentDone(sender: Variant;args: DotNet PercentDoneEventArgs)
    begin
    end;

    trigger ChilkatSFTP::OnAbortCheck(sender: Variant;args: DotNet AbortCheckEventArgs)
    begin
    end;
}

