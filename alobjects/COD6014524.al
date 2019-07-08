codeunit 6014524 "SSH.NET SFTP Client"
{
    // NPR5.48/MMV /20181002 CASE 322469 Created object
    // 
    // Wraps SSH.NET SFTP Client
    // MIT License: https://github.com/sshnet/SSH.NET/blob/develop/LICENSE


    trigger OnRun()
    begin
    end;

    var
        SftpClient: DotNet npNetSftpClient;

    procedure Construct(Host: Text;Username: Text;Password: Text;Port: Integer;TimeoutMs: Integer)
    var
        ConnectionInfo: DotNet npNetConnectionInfo;
        PasswordAuthenticationMethod: DotNet npNetPasswordAuthenticationMethod;
        AuthenticationMethodArray: DotNet npNetArray;
        AuthenticationMethod: DotNet npNetAuthenticationMethod;
    begin
        PasswordAuthenticationMethod := PasswordAuthenticationMethod.PasswordAuthenticationMethod(Username, Password);
        AuthenticationMethodArray := AuthenticationMethodArray.CreateInstance(GetDotNetType(AuthenticationMethod), 1);
        AuthenticationMethodArray.SetValue(PasswordAuthenticationMethod, 0);

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

    local procedure "// Operations"()
    begin
    end;

    procedure DownloadFile(LocalPath: Text;RemotePath: Text)
    var
        File: DotNet npNetFile;
        OutputStream: DotNet npNetFileStream;
        DownloadAsyncResult: DotNet npNetSftpDownloadAsyncResult;
    begin
        OutputStream := File.OpenWrite(LocalPath);
        DownloadAsyncResult := SftpClient.BeginDownloadFile(RemotePath, OutputStream);
        DownloadAsyncResult.AsyncWaitHandle.WaitOne(); //Block until download is done

        OutputStream.Close();
        OutputStream.Dispose();
    end;

    procedure UploadFile(LocalPath: Text;RemotePath: Text)
    var
        File: DotNet npNetFile;
        InputStream: DotNet npNetFileStream;
        UploadAsyncResult: DotNet npNetSftpDownloadAsyncResult;
    begin
        InputStream := File.OpenRead(LocalPath);
        UploadAsyncResult := SftpClient.BeginUploadFile(InputStream, RemotePath);
        UploadAsyncResult.AsyncWaitHandle.WaitOne(); //Block until upload is done

        InputStream.Close();
        InputStream.Dispose();
    end;

    procedure MoveFile(CurrentRemotePath: Text;NewRemotePath: Text)
    var
        SftpFile: DotNet npNetSftpFile;
    begin
        SftpFile := SftpClient.Get(CurrentRemotePath);
        SftpFile.MoveTo(NewRemotePath);
    end;

    procedure DeleteFile(RemotePath: Text)
    begin
        SftpClient.DeleteFile(RemotePath);
    end;

    procedure DownloadDirectory(LocalPath: Text;RemotePath: Text;IncludeSubFolders: Boolean)
    var
        IEnumerable: DotNet npNetIEnumerable;
        SftpFile: DotNet npNetSftpFile;
        Directory: DotNet npNetDirectory;
        SftpClientWrapper: DotNet npNetSFTPClientWrapper;
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

    trigger SftpClient::ErrorOccurred(sender: Variant;e: DotNet npNetExceptionEventArgs)
    begin
    end;

    trigger SftpClient::HostKeyReceived(sender: Variant;e: DotNet npNetHostKeyEventArgs)
    begin
    end;
}

