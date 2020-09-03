codeunit 6014524 "NPR SSH.NET SFTP Client"
{
    // NPR5.48/MMV /20181002 CASE 322469 Created object
    // NPR5.52/TJ  /20190909 CASE 305282 New functions ConstructPrivateKey and SearchFileAndDownload
    // NPR5.55/ALST/20200603 CASE 402502 added list directory method
    // NPR5.55/MHA /20200622 CASE 408816 Added Port to Constructors
    // NPR5.55/ALST/20200709 CASE 408285 added SetKeepAliveInterval, UploadFileFromBlob, and CreateDirectory
    // Wraps SSH.NET SFTP Client
    // MIT License: https://github.com/sshnet/SSH.NET/blob/develop/LICENSE


    trigger OnRun()
    begin
    end;

    var
        SftpClient: DotNet NPRNetSftpClient;

    procedure Construct(Host: Text; Username: Text; Password: Text; Port: Integer; TimeoutMs: Integer)
    var
        ConnectionInfo: DotNet NPRNetConnectionInfo;
        PasswordAuthenticationMethod: DotNet NPRNetPasswordAuthenticationMethod;
        AuthenticationMethodArray: DotNet NPRNetArray;
        AuthenticationMethod: DotNet NPRNetAuthenticationMethod;
    begin
        PasswordAuthenticationMethod := PasswordAuthenticationMethod.PasswordAuthenticationMethod(Username, Password);
        AuthenticationMethodArray := AuthenticationMethodArray.CreateInstance(GetDotNetType(AuthenticationMethod), 1);
        AuthenticationMethodArray.SetValue(PasswordAuthenticationMethod, 0);

        //-NPR5.55 [408816]
        if Port <> 0 then
            ConnectionInfo := ConnectionInfo.ConnectionInfo(Host, Port, Username, AuthenticationMethodArray)
        else
            ConnectionInfo := ConnectionInfo.ConnectionInfo(Host, Username, AuthenticationMethodArray);
        //+NPR5.55 [408816]
        ConnectionInfo.Timeout(TimeoutMs);

        SftpClient := SftpClient.SftpClient(ConnectionInfo);
        SftpClient.Connect();
    end;

    procedure ConstructPrivateKey(Host: Text; Username: Text; PassPhrase: Text; PrivateKeyBase64: Text; Port: Integer; TimeoutMs: Integer)
    var
        ConnectionInfo: DotNet NPRNetConnectionInfo;
        PrivateKeyAuthenticationMethod: DotNet NPRNetPrivateKeyAuthenticationMethod;
        AuthenticationMethodArray: DotNet NPRNetArray;
        AuthenticationMethod: DotNet NPRNetAuthenticationMethod;
        PrivateKeyFile: DotNet NPRNetPrivateKeyFile;
        PrivateKeyFileArray: DotNet NPRNetArray;
        MemoryStream: DotNet NPRNetMemoryStream;
        Convert: DotNet NPRNetConvert;
    begin
        //-NPR5.52 [305282]
        MemoryStream := MemoryStream.MemoryStream(Convert.FromBase64String(PrivateKeyBase64));
        if PassPhrase <> '' then
            PrivateKeyFile := PrivateKeyFile.PrivateKeyFile(MemoryStream, PassPhrase)
        else
            PrivateKeyFile := PrivateKeyFile.PrivateKeyFile(MemoryStream);
        PrivateKeyFileArray := PrivateKeyFileArray.CreateInstance(GetDotNetType(PrivateKeyFile), 1);
        PrivateKeyFileArray.SetValue(PrivateKeyFile, 0);
        PrivateKeyAuthenticationMethod := PrivateKeyAuthenticationMethod.PrivateKeyAuthenticationMethod(Username, PrivateKeyFileArray);
        AuthenticationMethodArray := AuthenticationMethodArray.CreateInstance(GetDotNetType(AuthenticationMethod), 1);
        AuthenticationMethodArray.SetValue(PrivateKeyAuthenticationMethod, 0);

        //-NPR5.55 [408816]
        if Port <> 0 then
            ConnectionInfo := ConnectionInfo.ConnectionInfo(Host, Port, Username, AuthenticationMethodArray)
        else
            ConnectionInfo := ConnectionInfo.ConnectionInfo(Host, Username, AuthenticationMethodArray);
        //+NPR5.55 [408816]
        ConnectionInfo.Timeout(TimeoutMs);

        SftpClient := SftpClient.SftpClient(ConnectionInfo);
        SftpClient.Connect();
        //+NPR5.52 [305282]
    end;

    procedure Destruct()
    begin
        SftpClient.Disconnect();
        SftpClient.Dispose();
    end;

    local procedure "// Operations"()
    begin
    end;

    procedure DownloadFile(LocalPath: Text; RemotePath: Text)
    var
        File: DotNet NPRNetFile;
        OutputStream: DotNet NPRNetFileStream;
        DownloadAsyncResult: DotNet NPRNetSftpDownloadAsyncResult;
    begin
        OutputStream := File.OpenWrite(LocalPath);
        DownloadAsyncResult := SftpClient.BeginDownloadFile(RemotePath, OutputStream);
        DownloadAsyncResult.AsyncWaitHandle.WaitOne(); //Block until download is done

        OutputStream.Close();
        OutputStream.Dispose();
    end;

    procedure UploadFile(LocalPath: Text; RemotePath: Text)
    var
        File: DotNet NPRNetFile;
        InputStream: DotNet NPRNetFileStream;
        UploadAsyncResult: DotNet NPRNetSftpDownloadAsyncResult;
    begin
        InputStream := File.OpenRead(LocalPath);
        UploadAsyncResult := SftpClient.BeginUploadFile(InputStream, RemotePath);
        UploadAsyncResult.AsyncWaitHandle.WaitOne(); //Block until upload is done

        InputStream.Close();
        InputStream.Dispose();
    end;

    procedure MoveFile(CurrentRemotePath: Text; NewRemotePath: Text)
    var
        SftpFile: DotNet NPRNetSftpFile;
    begin
        SftpFile := SftpClient.Get(CurrentRemotePath);
        SftpFile.MoveTo(NewRemotePath);
    end;

    procedure DeleteFile(RemotePath: Text)
    begin
        SftpClient.DeleteFile(RemotePath);
    end;

    procedure DownloadDirectory(LocalPath: Text; RemotePath: Text; IncludeSubFolders: Boolean)
    var
        IEnumerable: DotNet NPRNetIEnumerable;
        SftpFile: DotNet NPRNetSftpFile;
        Directory: DotNet NPRNetDirectory;
        SftpClientWrapper: DotNet NPRNetSFTPClientWrapper;
    begin
        if CopyStr(LocalPath, StrLen(LocalPath), 1) <> '\' then
            LocalPath += '\';
        if CopyStr(RemotePath, StrLen(RemotePath), 1) <> '/' then
            RemotePath += '/';

        //This wrapper is only used because C/AL DotNet interop cannot pass null to the delegate parameter to the SftpClient method directly.
        IEnumerable := SftpClientWrapper.ListDirectory(SftpClient, RemotePath);

        foreach SftpFile in IEnumerable do begin
            if SftpFile.IsDirectory then begin
                if not (SftpFile.Name in ['.', '..']) then
                    if IncludeSubFolders then begin
                        Directory.CreateDirectory(LocalPath + SftpFile.Name);
                        DownloadDirectory(LocalPath + SftpFile.Name, RemotePath + SftpFile.Name, IncludeSubFolders);
                    end
            end else
                DownloadFile(LocalPath + SftpFile.Name, RemotePath + SftpFile.Name);
        end;
    end;

    procedure DeleteDirectory(RemotePath: Text)
    begin
        SftpClient.DeleteDirectory(RemotePath);
    end;

    procedure SearchFileAndDownload(LocalPath: Text; RemotePath: Text; PartialFileName: Text)
    var
        IEnumerable: DotNet NPRNetIEnumerable;
        SftpFile: DotNet NPRNetSftpFile;
        Directory: DotNet NPRNetDirectory;
        SftpClientWrapper: DotNet NPRNetSFTPClientWrapper;
        TypeHelper: Codeunit "Type Helper";
        NoOfPatterns: Integer;
        i: Integer;
        Downloaded: Boolean;
    begin
        //-NPR5.52 [305282]
        //use comma to separate several PartialFileName
        if CopyStr(LocalPath, StrLen(LocalPath), 1) <> '\' then
            LocalPath += '\';
        if CopyStr(RemotePath, StrLen(RemotePath), 1) <> '/' then
            RemotePath += '/';

        if PartialFileName <> '' then
            NoOfPatterns := TypeHelper.GetNumberOfOptions(PartialFileName) + 1;

        IEnumerable := SftpClientWrapper.ListDirectory(SftpClient, RemotePath);
        foreach SftpFile in IEnumerable do
            if NoOfPatterns = 0 then
                DownloadFile(LocalPath + SftpFile.Name, RemotePath + SftpFile.Name)
            else begin
                Downloaded := false;
                for i := 1 to NoOfPatterns do
                    if (not Downloaded) and (StrPos(SftpFile.Name, SelectStr(i, PartialFileName)) > 0) then begin
                        DownloadFile(LocalPath + SftpFile.Name, RemotePath + SftpFile.Name);
                        Downloaded := true;
                    end;
            end;
        //+NPR5.52 [305282]
    end;

    procedure ListDirectory(RemotePath: Text; var IEnumerableSFTPFileList: DotNet NPRNetIEnumerable)
    var
        SftpClientWrapper: DotNet NPRNetSFTPClientWrapper;
    begin
        //-NPR5.55 [402502]
        IEnumerableSFTPFileList := SftpClientWrapper.ListDirectory(SftpClient, RemotePath);
        //+NPR5.55 [402502]
    end;

    procedure SetKeepAliveInterval(Hours: Integer; Minutes: Integer; Seconds: Integer)
    var
        TimeSpan: DotNet NPRNetTimeSpan;
    begin
        //-NPR5.55 [408285]
        SftpClient.KeepAliveInterval(TimeSpan.TimeSpan(Hours, Minutes, Seconds));
        //+NPR5.55 [408285]
    end;

    procedure UploadFileFromBlob(var TempBlob: Codeunit "Temp Blob"; RemoteFileName: Text)
    var
        InStr: InStream;
        Stream: DotNet NPRNetStream;
        MemoryStream: DotNet NPRNetMemoryStream;
        HashBytes: DotNet NPRNetArray;
    begin
        //-NPR5.55 [408285]
        MemoryStream := MemoryStream.MemoryStream();
        TempBlob.CreateInStream(InStr);
        CopyStream(MemoryStream, InStr);

        HashBytes := MemoryStream.ToArray();
        MemoryStream.Close();

        SftpClient.WriteAllBytes(RemoteFileName, HashBytes);
        //+NPR5.55 [408285]
    end;

    procedure CreateDirectory(RemotePath: Text)
    begin
        //-NPR5.55 [408285]
        SftpClient.CreateDirectory(RemotePath);
        //+NPR5.55 [408285]
    end;
}

