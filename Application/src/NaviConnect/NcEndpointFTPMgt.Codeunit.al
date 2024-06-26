codeunit 6151524 "NPR Nc Endpoint FTP Mgt."
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = 'NPR23.0';
    ObsoleteReason = 'Going ot switch to use Ftp Connection and Sftp Connection.';

    var
        FTPClient: Codeunit "NPR AF FTP Client";
        SFTPClient: Codeunit "NPR AF Sftp Client";
        SftpReq: JsonObject;
        AuthorizationFailedErrorErr: Label 'Authorization failed. Wrong FTP username/password.';
        UploadedFileRenameLblErr: Label 'File %1 could not be renamed back to original file name %2 after it was uploaded with temporrary extension .%3.';

    local procedure SendFtpOutput(NcTaskOutput: Record "NPR Nc Task Output"; NcEndpointFTP: Record "NPR Nc Endpoint FTP"; var Response: Text)
    begin
        if not NcEndpointFTP.Enabled then
            exit;
        if NcEndpointFTP.Server = '' then
            exit;

        case NcEndpointFTP."Protocol Type" of
            NcEndpointFTP."Protocol Type"::FTP:
                SendAzureFtpOutput(NcTaskOutput, NcEndpointFTP, Response);
            NcEndpointFTP."Protocol Type"::SFTP:
                SendAzureSFTPOutput(NcTaskOutput, NcEndpointFTP, Response);
        end;
    end;

    local procedure SendAzureFtpOutput(NcTaskOutput: Record "NPR Nc Task Output"; NcEndpointFTP: Record "NPR Nc Endpoint FTP"; var ResponseErrorDescriptionText: Text)
    var
        FtpPort: Integer;
        InStr: InStream;
        FTPResponse: JsonObject;
        JToken: JsonToken;
        ServerName: Text;
        FilePath: Text;
        OriginalFileName: Text;
        ResponseCodeText: Text;
    begin
        ServerName := BuildFTPServerName(NcEndpointFTP.Server);

        if NcEndpointFTP."File Temporary Extension" <> '' then begin
            OriginalFileName := NcTaskOutput.Name;
#pragma warning disable AA0139
            NcTaskOutput.Name := NcTaskOutput.Name + '.' + NcEndpointFTP."File Temporary Extension";
#pragma warning restore AA0139
        end;

        if NcEndpointFTP.Directory <> '' then
            FilePath := '/' + NcEndpointFTP.Directory.TrimStart('/').TrimEnd('/') + '/'
        else
            FilePath := '/';

        NcTaskOutput.Data.CreateInStream(InStr);

        FtpPort := NcEndpointFTP.Port;
        If FtpPort = 0 then
            FtpPort := 21;

        InitializeFTP(ServerName, NcEndpointFTP.Username, NcEndpointFTP.Password, FtpPort, NcEndpointFTP.Passive, NcEndpointFTP.EncMode);
        FTPResponse := FTPClient.UploadFile(InStr, FilePath + NcTaskOutput.Name);

        if FTPResponse.Get('StatusCode', JToken) then
            ResponseCodeText := JToken.AsValue().AsText();

        case ResponseCodeText of
            '200':
                begin
                    if NcEndpointFTP."File Temporary Extension" <> '' then begin
                        FTPResponse := FTPClient.RenameFile(FilePath + NcTaskOutput.Name, FilePath + OriginalFileName);

                        if FTPResponse.Get('StatusCode', JToken) then
                            ResponseCodeText := JToken.AsValue().AsText();

                        if ResponseCodeText <> '200' then begin
                            FTPClient.Destruct();
                            ResponseErrorDescriptionText := StrSubstNo(UploadedFileRenameLblErr, NcTaskOutput.Name, OriginalFileName, NcEndpointFTP."File Temporary Extension");
                            Error(ResponseErrorDescriptionText);
                        end;
                    end;

                    FTPClient.Destruct();
                    exit;
                end;
            '401':
                ResponseErrorDescriptionText := AuthorizationFailedErrorErr;
            else begin
                FTPResponse.Get('Error', JToken);
                ResponseErrorDescriptionText := JToken.AsValue().AsText();
            end;
        end;
        FTPClient.Destruct();
        Error(ResponseErrorDescriptionText);
    end;

    local procedure BuildFTPServerName(Servername: Text): Text
    begin
        //Remove trailing slash
        if Servername[StrLen(Servername)] = '/' then
            Servername := CopyStr(Servername, 1, StrLen(Servername) - 1);
        if StrPos(UpperCase(Servername), 'FTP://') = 1 then
            exit(Servername);
        //Remove leading slash
        if Servername[1] = '/' then
            Servername := CopyStr(Servername, 2);
        if Servername[1] = '/' then
            Servername := CopyStr(Servername, 2);
        exit('ftp://' + Servername);
    end;

    local procedure InitEndpoint(NcEndpointFTP: Record "NPR Nc Endpoint FTP")
    var
        FtpFolders: Text;
        FtpPath: Text;
        DirectoryList: List of [Text];
        FtpPort: Integer;
        IsSecureFTP: Boolean;
    begin
        FtpPath := '/';
        IsSecureFTP := NcEndpointFTP."Protocol Type" = NcEndpointFTP."Protocol Type"::SFTP;

        if IsSecureFTP then begin
            if (NcEndpointFTP.Port = 0) then
                FtpPort := 22;
            SFTPClient.GetFileServerJsonRequest(NcEndpointFTP.Server, FtpPort, NcEndpointFTP.Username, NcEndpointFTP.Password, '', true);
        end else begin
            if (NcEndpointFTP.Port = 0) then
                FtpPort := 21;
            InitializeFTP(NcEndpointFTP.Server, NcEndpointFTP.Username, NcEndpointFTP.Password, FtpPort, NcEndpointFTP.Passive, NcEndpointFTP.EncMode);
        end;

        TryListFtpOrSftpDirectory(DirectoryList, IsSecureFTP);

        if NcEndpointFTP.Directory = '' then
            exit;

        FtpFolders := NcEndpointFTP.Directory;
        CreateFtpOrSftpFolders(NcEndpointFTP.Server, FtpFolders, IsSecureFTP);
    end;

    local procedure CreateFtpOrSftpFolders(FtpServer: Text; FtpFolders: Text; IsSecureFTP: Boolean)
    var
        FtpFolder: Text;
        FtpPath: Text;
        DirectoryList: List of [Text];
    begin
        FtpPath := FtpServer;
        while CutNextFtpFolder(FtpFolders, FtpFolder) do begin
            FtpPath += '/' + FtpFolder;
            if (not TryListFtpOrSftpDirectory(DirectoryList, IsSecureFTP)) or (DirectoryList.Count = 0) then
                TryCreateFtpOrSftpFolder(FtpPath, IsSecureFTP);
        end;
    end;

    local procedure CutNextFtpFolder(var FtpFolders: Text; var FtpFolder: Text): Boolean
    var
        Position: Integer;
    begin
        Position := StrPos(FtpFolders, '/');
        while Position = 1 do begin
            FtpFolders := DelStr(FtpFolders, 1, 1);
            Position := StrPos(FtpFolders, '/');
        end;

        if FtpFolders = '' then
            exit(false);

        if Position = 0 then begin
            FtpFolder := FtpFolders;
            FtpFolders := '';
        end else begin
            FtpFolder := CopyStr(FtpFolders, 1, Position - 1);
            FtpFolders := DelStr(FtpFolders, 1, Position);
        end;
        exit(true);
    end;

    [TryFunction]
    local procedure TryCreateFtpOrSftpFolder(FtpPath: Text; IsSecureFTP: Boolean)
    var
        FTPResponse: JsonObject;
        ResponseCodeText: Text;
        JToken: JsonToken;
    begin
        if IsSecureFTP then begin
            if (SFTPClient.CreateDirectory(FtpPath, SftpReq)) then
                exit
            else
                Error(GetLastErrorText());
        end else
            FTPResponse := FTPClient.CreateDirectory(FtpPath);

        if FTPResponse.Get('StatusCode', JToken) then
            ResponseCodeText := JToken.AsValue().AsText();

        case ResponseCodeText of
            '200':
                exit;
            '401':
                Error(AuthorizationFailedErrorErr);
            else begin
                FTPResponse.Get('Error', JToken);
                Error(JToken.AsValue().AsText());
            end;
        end;
    end;

    [TryFunction]
    local procedure TryListFtpOrSftpDirectory(var DirectoryList: List of [Text]; IsSecureFTP: Boolean)
    var
        FTPResponse: JsonObject;
        FileObject: JsonObject;
        JToken: JsonToken;
        JArray: JsonArray;
        i: Integer;
        ResponseCodeText: Text;
    begin
        if IsSecureFTP then begin
            if (not SFTPClient.ListDirectory('/', JArray, SftpReq)) then
                Error(GetLastErrorText());
        end else begin
            FTPResponse := FTPClient.ListDirectory('/');
            if FTPResponse.Get('StatusCode', JToken) then
                ResponseCodeText := JToken.AsValue().AsText();
            case ResponseCodeText of
                '200':
                    begin
                        FTPResponse.Get('Files', JToken);
                        JArray := JToken.AsArray();
                    end;
                '401':
                    Error(AuthorizationFailedErrorErr);
                else begin
                    FTPResponse.Get('Error', JToken);
                    Error(JToken.AsValue().AsText());
                end;
            end;
        end;
        for i := 0 to JArray.Count - 1 do begin
            JArray.Get(i, JToken);
            FileObject := JToken.AsObject();

            FileObject.Get('IsDirectory', JToken);
            if not Jtoken.AsValue().AsBoolean() then begin
                FileObject.Get('Name', JToken);
                DirectoryList.Add(JToken.AsValue().AsText());
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Nc Endpoint Mgt.", 'OnHasInitEndpoint', '', true, true)]
    local procedure OnHasInitEndpoint(NcEndpoint: Record "NPR Nc Endpoint"; var EndpointHasInit: Boolean)
    var
        NcEndpointFTP: Record "NPR Nc Endpoint FTP";
    begin
        if NcEndpoint."Endpoint Type" <> NcEndpointFTP.GetEndpointTypeCode() then
            exit;
        if not NcEndpoint.Enabled then
            exit;
        if not NcEndpointFTP.Get(NcEndpoint.Code) then
            exit;

        EndpointHasInit := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Nc Endpoint Mgt.", 'OnInitEndpoint', '', true, true)]
    local procedure OnInitEndpoint(NcEndpoint: Record "NPR Nc Endpoint")
    var
        NcEndpointFTP: Record "NPR Nc Endpoint FTP";
    begin
        if NcEndpoint."Endpoint Type" <> NcEndpointFTP.GetEndpointTypeCode() then
            exit;
        if not NcEndpoint.Enabled then
            exit;
        if not NcEndpointFTP.Get(NcEndpoint.Code) then
            exit;

        InitEndpoint(NcEndpointFTP);
    end;

    local procedure SendAzureSFTPOutput(NcTaskOutput: Record "NPR Nc Task Output"; NcEndpointFTP: Record "NPR Nc Endpoint FTP"; var ResponseErrorDescriptionText: Text)
    var
        Sftp: Codeunit "NPR AF Sftp Client";
        SftpReqq: JsonObject;
        Istream: InStream;
        outS: OutStream;
        tmpBlob: Codeunit "Temp Blob";
        RemotePath: Text;
        OriginalFileName: Text;
    begin

        SftpReqq := SFTPClient.GetFileServerJsonRequest(NcEndpointFTP.Server, NcEndpointFTP.Port, NcEndpointFTP.Username, NcEndpointFTP.Password, '', true);

        if NcEndpointFTP."File Temporary Extension" <> '' then begin
            OriginalFileName := NcTaskOutput.Name;
#pragma warning disable AA0139
            NcTaskOutput.Name := NcTaskOutput.Name + '.' + NcEndpointFTP."File Temporary Extension";
#pragma warning restore AA0139
        end;

        if NcEndpointFTP.Directory <> '' then
            RemotePath := '/' + NcEndpointFTP.Directory.TrimStart('/').TrimEnd('/') + '/'
        else
            RemotePath := '/';
        NcTaskOutput.Data.CreateInStream(Istream);
        tmpBlob.CreateOutStream(outS);
        CopyStream(outS, Istream);
        if (Sftp.UploadFile(RemotePath + NcTaskOutput.Name, tmpBlob, SftpReqq)) then begin
            if NcEndpointFTP."File Temporary Extension" <> '' then begin
                if (not Sftp.MoveFile(RemotePath + NcTaskOutput.Name, RemotePath + OriginalFileName, SftpReqq)) then begin
                    ResponseErrorDescriptionText := StrSubstNo(UploadedFileRenameLblErr, NcTaskOutput.Name, OriginalFileName, NcEndpointFTP."File Temporary Extension");
                    Error(ResponseErrorDescriptionText);
                end;
            end;
        end else begin
            Error(GetLastErrorText());
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Nc Endpoint Type", 'OnSetupEndpointTypes', '', false, false)]
    local procedure OnSetupEndpointTypeInsertEndpointTypeCode()
    var
        NcEndpointFTP: Record "NPR Nc Endpoint FTP";
        NcEndpointType: Record "NPR Nc Endpoint Type";
    begin
        if not NcEndpointType.Get(NcEndpointFTP.GetEndpointTypeCode()) then begin
            NcEndpointType.Init();
            NcEndpointType.Code := NcEndpointFTP.GetEndpointTypeCode();
            NcEndpointType.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Nc Endpoint", 'OnOpenEndpointSetup', '', false, false)]
    local procedure OnOpenEndpointSetupOpenPage(var Sender: Record "NPR Nc Endpoint"; var Handled: Boolean)
    var
        NcEndpointFTP: Record "NPR Nc Endpoint FTP";
    begin
        if Handled then
            exit;
        if Sender."Endpoint Type" <> NcEndpointFTP.GetEndpointTypeCode() then
            exit;
        if not NcEndpointFTP.Get(Sender.Code) then begin
            NcEndpointFTP.Init();
            NcEndpointFTP.Validate(Code, Sender.Code);
            NcEndpointFTP.Description := Sender.Description;
            NcEndpointFTP.Insert();
        end else begin
            if NcEndpointFTP.Description <> Sender.Description then begin
                NcEndpointFTP.Description := Sender.Description;
                NcEndpointFTP.Modify(true);
            end;
        end;
        PAGE.Run(PAGE::"NPR Nc Endpoint FTP Card", NcEndpointFTP);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Nc Endpoint", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnDeleteEndpoint(var Rec: Record "NPR Nc Endpoint"; RunTrigger: Boolean)
    var
        NcEndpointFTP: Record "NPR Nc Endpoint FTP";
    begin
        if NcEndpointFTP.Get(Rec.Code) then
            NcEndpointFTP.Delete(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Nc Endpoint Mgt.", 'OnRunEndpoint', '', true, true)]
    local procedure OnRunEndpoint(NcTaskOutput: Record "NPR Nc Task Output"; NcEndpoint: Record "NPR Nc Endpoint"; var Response: Text)
    var
        NcEndpointFTP: Record "NPR Nc Endpoint FTP";
    begin
        if NcEndpoint."Endpoint Type" <> NcEndpointFTP.GetEndpointTypeCode() then
            exit;
        if not NcEndpointFTP.Get(NcEndpoint.Code) then
            exit;

        SendFtpOutput(NcTaskOutput, NcEndpointFTP, Response);
    end;

    local procedure InitializeFTP(ServerName: Text; Username: Text; Password: Text; FtpPort: Integer; Passive: Boolean; EncMode: Enum "NPR Nc FTP Encryption mode")
    begin
        FTPClient.Construct(ServerName, Username, Password, FtpPort, 10000, Passive, EncMode);
    end;
}

