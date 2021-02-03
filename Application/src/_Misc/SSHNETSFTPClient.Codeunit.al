codeunit 6014524 "NPR SSH.NET SFTP Client"
{
    var
        SftpClient: DotNet NPRNetSftpClient;

    procedure Construct(Host: Text; Username: Text; Password: Text; Port: Integer; TimeoutMs: Integer)
    var
        AuthenticationMethodArray: DotNet NPRNetArray;
        AuthenticationMethod: DotNet NPRNetAuthenticationMethod;
        ConnectionInfo: DotNet NPRNetConnectionInfo;
        PasswordAuthenticationMethod: DotNet NPRNetPasswordAuthenticationMethod;
    begin
        PasswordAuthenticationMethod := PasswordAuthenticationMethod.PasswordAuthenticationMethod(Username, Password);
        AuthenticationMethodArray := AuthenticationMethodArray.CreateInstance(GetDotNetType(AuthenticationMethod), 1);
        AuthenticationMethodArray.SetValue(PasswordAuthenticationMethod, 0);

        if Port <> 0 then
            ConnectionInfo := ConnectionInfo.ConnectionInfo(Host, Port, Username, AuthenticationMethodArray)
        else
            ConnectionInfo := ConnectionInfo.ConnectionInfo(Host, Username, AuthenticationMethodArray);
        ConnectionInfo.Timeout(TimeoutMs);

        SftpClient := SftpClient.SftpClient(ConnectionInfo);
        SftpClient.Connect();
    end;

    procedure ConstructPrivateKey(Host: Text; Username: Text; PassPhrase: Text; PrivateKeyBase64: Text; Port: Integer; TimeoutMs: Integer)
    var
        AuthenticationMethodArray: DotNet NPRNetArray;
        PrivateKeyFileArray: DotNet NPRNetArray;
        AuthenticationMethod: DotNet NPRNetAuthenticationMethod;
        ConnectionInfo: DotNet NPRNetConnectionInfo;
        Convert: DotNet NPRNetConvert;
        MemoryStream: DotNet NPRNetMemoryStream;
        PrivateKeyAuthenticationMethod: DotNet NPRNetPrivateKeyAuthenticationMethod;
        PrivateKeyFile: DotNet NPRNetPrivateKeyFile;
    begin
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

        if Port <> 0 then
            ConnectionInfo := ConnectionInfo.ConnectionInfo(Host, Port, Username, AuthenticationMethodArray)
        else
            ConnectionInfo := ConnectionInfo.ConnectionInfo(Host, Username, AuthenticationMethodArray);
        ConnectionInfo.Timeout(TimeoutMs);

        SftpClient := SftpClient.SftpClient(ConnectionInfo);
        SftpClient.Connect();
    end;

    procedure Destruct()
    begin
        SftpClient.Disconnect();
        SftpClient.Dispose();
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
        Directory: DotNet NPRNetDirectory;
        IEnumerable: DotNet NPRNetIEnumerable;
        SftpClientWrapper: DotNet NPRNetSFTPClientWrapper;
        SftpFile: DotNet NPRNetSftpFile;
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
        TypeHelper: Codeunit "Type Helper";
        Downloaded: Boolean;
        Directory: DotNet NPRNetDirectory;
        IEnumerable: DotNet NPRNetIEnumerable;
        SftpClientWrapper: DotNet NPRNetSFTPClientWrapper;
        SftpFile: DotNet NPRNetSftpFile;
        i: Integer;
        NoOfPatterns: Integer;
    begin
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
    end;

    procedure ListDirectory(RemotePath: Text; var IEnumerableSFTPFileList: DotNet NPRNetIEnumerable)
    var
        SftpClientWrapper: DotNet NPRNetSFTPClientWrapper;
    begin
        IEnumerableSFTPFileList := SftpClientWrapper.ListDirectory(SftpClient, RemotePath);
    end;

    procedure SetKeepAliveInterval(Hours: Integer; Minutes: Integer; Seconds: Integer)
    var
        TimeSpan: DotNet NPRNetTimeSpan;
    begin
        SftpClient.KeepAliveInterval(TimeSpan.TimeSpan(Hours, Minutes, Seconds));
    end;

    procedure UploadFileFromBlob(var TempBlob: Codeunit "Temp Blob"; RemoteFileName: Text)
    var
        HashBytes: DotNet NPRNetArray;
        MemoryStream: DotNet NPRNetMemoryStream;
        Stream: DotNet NPRNetStream;
        InStr: InStream;
    begin
        MemoryStream := MemoryStream.MemoryStream();
        TempBlob.CreateInStream(InStr);
        CopyStream(MemoryStream, InStr);

        HashBytes := MemoryStream.ToArray();
        MemoryStream.Close();

        SftpClient.WriteAllBytes(RemoteFileName, HashBytes);
    end;

    procedure CreateDirectory(RemotePath: Text)
    begin
        SftpClient.CreateDirectory(RemotePath);
    end;
}

