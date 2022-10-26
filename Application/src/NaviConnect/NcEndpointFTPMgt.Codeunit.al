codeunit 6151524 "NPR Nc Endpoint FTP Mgt."
{
    Access = Internal;

    var
        FTPClient: Codeunit "NPR AF FTP Client";
        SFTPClient: Codeunit "NPR AF SFTP Client";
        AuthorizationFailedErrorErr: Label 'Authorization failed. Wrong FTP username/password.';
        UploadedFileRenameLblErr: Label 'File %1 could not be renamed back to original file name %2 after it was uploaded with temporrary extension .%3.';

    local procedure ProcessNcEndpoints(NcTriggerCode: Code[20]; Output: Text; Filename: Text; var NcTask: Record "NPR Nc Task")
    var
        NcEndpoint: Record "NPR Nc Endpoint";
        NcEndpointFTP: Record "NPR Nc Endpoint FTP";
        NcEndpointTriggerLink: Record "NPR Nc Endpoint Trigger Link";
    begin
        case NcTask."Table No." of
            DATABASE::"NPR Nc Trigger":
                begin
                    NcEndpointTriggerLink.Reset();
                    NcEndpointTriggerLink.SetRange("Trigger Code", NcTriggerCode);
                    if NcEndpointTriggerLink.FindSet() then
                        repeat
                            if NcEndpoint.Get(NcEndpointTriggerLink."Endpoint Code") then begin
                                if NcEndpoint."Endpoint Type" = NcEndpointFTP.GetEndpointTypeCode() then begin
                                    if NcEndpointFTP.Get(NcEndpointTriggerLink."Endpoint Code") then begin
                                        ProcessNcEndpointTrigger(NcTriggerCode, Output, Filename, NcTask, NcEndpointFTP);
                                    end;
                                end;
                            end;
                        until NcEndpointTriggerLink.Next() = 0;
                end;
            DATABASE::"NPR Nc Endpoint FTP":
                begin
                    //Process Endpoint Task
                    NcEndpointFTP.SetPosition(NcTask."Record Position");
                    NcEndpointFTP.SetRange(Code, NcEndpointFTP.Code);
                    NcEndpointFTP.SetRange(Enabled, true);
                    if NcEndpointFTP.FindFirst() then begin
                        ProcessEndPointTask(NcEndpointFTP, NcTask, Output, Filename);
                        NcTask.Modify();
                    end;
                end;
        end;
    end;

    local procedure ProcessNcEndpointTrigger(NcTriggerCode: Code[20]; Output: Text; Filename: Text; var NcTask: Record "NPR Nc Task"; NcEndpointFTP: Record "NPR Nc Endpoint FTP")
    var
        NcTrigger: Record "NPR Nc Trigger";
    begin
        if not NcEndpointFTP.Enabled then
            exit;
        NcTrigger.Get(NcTriggerCode);
        if not NcTrigger."Split Trigger and Endpoint" then begin
            //Process Trigger Task Directly
            FtpProcess(NcTask, NcEndpointFTP, Output, Filename);
            NcTask.Modify();
        end else begin
            //Insert New Task per Endpoint
            InsertEndpointTask(NcEndpointFTP, NcTask, Filename);
            NcTask.Modify();
        end;
    end;

    local procedure InsertEndpointTask(var NcEndpointFTP: Record "NPR Nc Endpoint FTP"; var NcTask: Record "NPR Nc Task"; Filename: Text)
    var
        NcTriggerSyncMgt: Codeunit "NPR Nc Trigger Sync. Mgt.";
        NewTask: Record "NPR Nc Task";
        TempNcEndPointFTP: Record "NPR Nc Endpoint FTP" temporary;
        RecRef: RecordRef;
        TextTaskInsertedLbl: Label 'FTP Task inserted for Nc Endpoint FTP %1 %2, server: %3. Nc Task Entry No. %4.', Comment = '%1=NcEndpointFTP.Code;%2=NcEndpointFTP.Description;%3=NcEndpointFTP.Server;%4=NewTask."Entry No."';
        TaskEntryNo: BigInteger;
    begin
        RecRef.Get(NcEndpointFTP.RecordId);
        NcTriggerSyncMgt.InsertTask(RecRef, TaskEntryNo);
        NewTask.Get(TaskEntryNo);
        TempNcEndPointFTP.Init();
        TempNcEndPointFTP.Copy(NcEndpointFTP);
        TempNcEndPointFTP."Output Nc Task Entry No." := NcTask."Entry No.";
#pragma warning disable AA0139
        TempNcEndPointFTP.Filename := Filename;
#pragma warning restore AA0139
        NcTriggerSyncMgt.FillFields(NewTask, TempNcEndPointFTP);
        NcTriggerSyncMgt.AddResponse(NcTask, StrSubstNo(TextTaskInsertedLbl, NcEndpointFTP.Code, NcEndpointFTP.Description, NcEndpointFTP.Server, NewTask."Entry No."));
    end;

    local procedure ProcessEndPointTask(var NcEndpointFTP: Record "NPR Nc Endpoint FTP"; var NcTask: Record "NPR Nc Task"; Output: Text; Filename: Text)
    var
        NcTaskMgt: Codeunit "NPR Nc Task Mgt.";
        RecRef: RecordRef;
        FldRef: FieldRef;
        TextNoOutputErr: Label 'FTP Task not executed because there was no output to send.';
    begin
        NcTaskMgt.RestoreRecord(NcTask."Entry No.", RecRef);
        if Output = '' then
            Error(TextNoOutputErr);
        FldRef := RecRef.Field(NcEndpointFTP.FieldNo(Filename));
        if Format(FldRef.Value) <> '' then
            Filename := Format(FldRef.Value);
        FtpProcess(NcTask, NcEndpointFTP, Output, Filename);
    end;

    local procedure FtpProcess(var NcTask: Record "NPR Nc Task"; NcEndpointFTP: Record "NPR Nc Endpoint FTP"; OutputText: Text; Filename: Text)
    var
        ResponseDescriptionText: Text;
        ResponseCodeText: Text;
        TextFTPServerResponseFailErr: Label 'File could not be uploaded. FTP server %1 returned error status %2 %3.', Comment = '%1=NcEndpointFTP.Server;%2=ResponseCodeText;%3=ResponseDescriptionText';
        TextFTPServerResponseSuccessLbl: Label 'The file %1 (%2 bytes) was successfully uploaded to the FTP server %3. Server returned status %4 %5.', Comment = '%1=ConnectionString;%2=StrLen(OutputText);%3=NcEndpointFTP.Server;%4=ResponseCodeText;%5=ResponseDescriptionText';
        NcTaskMgt: Codeunit "NPR Nc Task Mgt.";
        TextCouldnotFTPErr: Label 'File could not be uploaded. No error received from server.';
    begin
        if SendFtp(NcEndpointFTP, OutputText, Filename, ResponseDescriptionText, ResponseCodeText) then begin
            case (CopyStr(ResponseCodeText, 1, 1)) of
                '1', '2', '3':
                    begin
                        //Positive Response
                        NcTaskMgt.AddResponse(NcTask, StrSubstNo(TextFTPServerResponseSuccessLbl, NcEndpointFTP.Directory + '/' + Filename, StrLen(OutputText), NcEndpointFTP.Server, ResponseCodeText, ResponseDescriptionText));
                        NcTaskMgt.AddOutputToTask(NcTask, OutputText);
                    end;
                else begin
                    //Negative Response
                    Error(TextFTPServerResponseFailErr, NcEndpointFTP.Server, ResponseCodeText, ResponseDescriptionText);
                end;
            end;
        end else
            Error(TextCouldnotFTPErr);
    end;

    local procedure SendFtp(NcEndpointFTP: Record "NPR Nc Endpoint FTP"; OutputText: Text; Filename: Text; var ResponseDescriptionText: Text; var ResponseCodeText: Text): Boolean
    begin
        if not NcEndpointFTP.Enabled then
            exit(false);
        if NcEndpointFTP.Server = '' then
            exit(false);
        if Filename = '' then
            Filename := NcEndpointFTP.Filename;

        case NcEndpointFTP."Protocol Type" of
            NcEndpointFTP."Protocol Type"::FTP:
                begin
                    if not SendAzureFtp(NcEndpointFTP, OutputText, Filename, ResponseDescriptionText, ResponseCodeText) then
                        exit(false);
                end;
            NcEndpointFTP."Protocol Type"::SFTP:
                begin
                    if not SendAzureSFTP(NcEndpointFTP, OutputText, Filename, ResponseDescriptionText, ResponseCodeText) then
                        exit(false);
                end;
        end;
        exit(true);
    end;

    local procedure SendAzureFtp(NcEndpointFTP: Record "NPR Nc Endpoint FTP"; OutputText: Text; Filename: Text; var ResponseDescriptionText: Text; var ResponseCodeText: Text): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        Servername: Text;
        RemotePath: Text;
        OriginalFileName: Text;
        FTPResponse: JsonObject;
        JToken: JsonToken;
        InStr: InStream;
        OutStr: OutStream;
        FtpPort: Integer;
        Encoding: TextEncoding;
        UseDefaultEncoding: Boolean;
    begin
        Servername := BuildFTPServerName(NcEndpointFTP.Server);

        if NcEndpointFTP.Directory <> '' then
            RemotePath := '/' + NcEndpointFTP.Directory.TrimStart('/').TrimEnd('/') + '/'
        else
            RemotePath := '/';

        if NcEndpointFTP."File Temporary Extension" <> '' then begin
            OriginalFileName := Filename;
            Filename := Filename + '.' + NcEndpointFTP."File Temporary Extension";
        end;

        UseDefaultEncoding := false;
        case NcEndpointFTP."File Encoding" of
            NcEndpointFTP."File Encoding"::ANSI:
                Encoding := TextEncoding::Windows;
            NcEndpointFTP."File Encoding"::UTF8:
                Encoding := TextEncoding::UTF8;
            else
                UseDefaultEncoding := true;
        end;
        if UseDefaultEncoding then
            TempBlob.CreateOutStream(OutStr)
        else
            TempBlob.CreateOutStream(OutStr, Encoding);

        OutStr.Write(OutputText);

        if UseDefaultEncoding then
            TempBlob.CreateInStream(InStr)
        else
            TempBlob.CreateInStream(InStr, Encoding);

        FtpPort := NcEndpointFTP.Port;
        If FtpPort = 0 then
            FtpPort := 21;

        InitializeFTP(Servername, NcEndpointFTP.Username, NcEndpointFTP.Password, FtpPort, NcEndpointFTP.Passive, NcEndpointFTP.EncMode);
        FTPResponse := FTPClient.UploadFile(InStr, RemotePath + Filename);

        FTPResponse.Get('StatusCode', JToken);
        ResponseCodeText := JToken.AsValue().AsText();

        case ResponseCodeText of
            '200':
                begin
                    FTPResponse.Get('Decription', JToken);
                    ResponseDescriptionText := JToken.AsValue().AsText();

                    if NcEndpointFTP."File Temporary Extension" <> '' then begin
                        FTPResponse := FTPClient.RenameFile(RemotePath + Filename, RemotePath + OriginalFileName);

                        FTPResponse.Get('StatusCode', JToken);
                        ResponseCodeText := JToken.AsValue().AsText();

                        if ResponseCodeText <> '200' then begin
                            FTPClient.Destruct();
                            ResponseDescriptionText := StrSubstNo(UploadedFileRenameLblErr, Filename, OriginalFileName, NcEndpointFTP."File Temporary Extension");
                            exit(false);
                        end;
                    end;

                    FTPClient.Destruct();
                    exit(true);
                end;
            '401':
                ResponseDescriptionText := AuthorizationFailedErrorErr;
            else begin
                FTPResponse.Get('Error', JToken);
                ResponseDescriptionText := JToken.AsValue().AsText();
            end;
        end;

        FTPClient.Destruct();
        exit(false);
    end;

    local procedure SendAzureSFTP(NcEndpointFTP: Record "NPR Nc Endpoint FTP"; OutputText: Text; Filename: Text; var ResponseDescriptionText: Text; var ResponseCodeText: Text): Boolean
    var
        RemotePath: Text;
        OriginalFileName: Text;
        TempBlob: Codeunit "Temp Blob";
        FTPResponse: JsonObject;
        JToken: JsonToken;
        InStr: InStream;
        OutStr: OutStream;
        FtpPort: Integer;
        Encoding: TextEncoding;
        UseDefaultEncoding: Boolean;
    begin
        if NcEndpointFTP.Directory <> '' then
            RemotePath := '/' + NcEndpointFTP.Directory.TrimStart('/').TrimEnd('/') + '/'
        else
            RemotePath := '/';

        if NcEndpointFTP."File Temporary Extension" <> '' then begin
            OriginalFileName := Filename;
            Filename := Filename + '.' + NcEndpointFTP."File Temporary Extension";
        end;

        UseDefaultEncoding := false;
        case NcEndpointFTP."File Encoding" of
            NcEndpointFTP."File Encoding"::ANSI:
                Encoding := TextEncoding::Windows;
            NcEndpointFTP."File Encoding"::UTF8:
                Encoding := TextEncoding::UTF8;
            else
                UseDefaultEncoding := true;
        end;
        if UseDefaultEncoding then
            TempBlob.CreateOutStream(OutStr)
        else
            TempBlob.CreateOutStream(OutStr, Encoding);

        OutStr.Write(OutputText);

        if UseDefaultEncoding then
            TempBlob.CreateInStream(InStr)
        else
            TempBlob.CreateInStream(InStr, Encoding);

        FtpPort := NcEndpointFTP.Port;
        If FtpPort = 0 then
            FtpPort := 22;

        InitializeSFTP(NcEndpointFTP.Server, NcEndpointFTP.Username, NcEndpointFTP.Password, FtpPort);
        FTPResponse := SFTPClient.UploadFile(InStr, RemotePath + Filename);

        FTPResponse.Get('StatusCode', JToken);
        ResponseCodeText := JToken.AsValue().AsText();

        case ResponseCodeText of
            '200':
                begin
                    ResponseDescriptionText := '200 The requested action has been successfully completed';

                    if NcEndpointFTP."File Temporary Extension" <> '' then begin
                        FTPResponse := SFTPClient.MoveFile(RemotePath + Filename, RemotePath + OriginalFileName);

                        FTPResponse.Get('StatusCode', JToken);
                        ResponseCodeText := JToken.AsValue().AsText();

                        if ResponseCodeText <> '200' then begin
                            SFTPClient.Destruct();
                            ResponseDescriptionText := StrSubstNo(UploadedFileRenameLblErr, Filename, OriginalFileName, NcEndpointFTP."File Temporary Extension");
                            exit(false);
                        end;
                    end;

                    SFTPClient.Destruct();
                    exit(true);
                end;
            '401':
                ResponseDescriptionText := AuthorizationFailedErrorErr;
            else begin
                FTPResponse.Get('Error', JToken);
                ResponseDescriptionText := JToken.AsValue().AsText();
            end;
        end;

        SFTPClient.Destruct();
        exit(false);
    end;

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

        FTPResponse.Get('StatusCode', JToken);
        ResponseCodeText := JToken.AsValue().AsText();

        case ResponseCodeText of
            '200':
                begin
                    if NcEndpointFTP."File Temporary Extension" <> '' then begin
                        FTPResponse := FTPClient.RenameFile(FilePath + NcTaskOutput.Name, FilePath + OriginalFileName);

                        FTPResponse.Get('StatusCode', JToken);
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

        FtpPort := NcEndpointFTP.Port;
        If FtpPort = 0 then begin
            if IsSecureFTP then
                FtpPort := 22
            else
                FtpPort := 21;
        end;

        if IsSecureFTP then
            InitializeSFTP(NcEndpointFTP.Server, NcEndpointFTP.Username, NcEndpointFTP.Password, FtpPort)
        else
            InitializeFTP(NcEndpointFTP.Server, NcEndpointFTP.Username, NcEndpointFTP.Password, FtpPort, NcEndpointFTP.Passive, NcEndpointFTP.EncMode);

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
        if IsSecureFTP then
            FTPResponse := SFTPClient.CreateDirectory(FtpPath)
        else
            FTPResponse := FTPClient.CreateDirectory(FtpPath);

        FTPResponse.Get('StatusCode', JToken);
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
        if IsSecureFTP then
            FTPResponse := SFTPClient.ListDirectory('/')
        else
            FTPResponse := FTPClient.ListDirectory('/');

        FTPResponse.Get('StatusCode', JToken);
        ResponseCodeText := JToken.AsValue().AsText();

        case ResponseCodeText of
            '200':
                begin
                    FTPResponse.Get('Files', JToken);
                    JArray := JToken.AsArray();

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
            '401':
                Error(AuthorizationFailedErrorErr);
            else begin
                FTPResponse.Get('Error', JToken);
                Error(JToken.AsValue().AsText());
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
        AFSFTPClient: Codeunit "NPR AF SFTP Client";
        Istream: InStream;
        FTPResponse: JsonObject;
        JToken: JsonToken;
        RemotePath: Text;
        OriginalFileName: Text;
        ResponseCodeText: Text;
    begin
        AFSFTPClient.Construct(NcEndpointFTP.Server, NcEndpointFTP.Username, NcEndpointFTP.Password, NcEndpointFTP.Port, 10000);
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
        FTPResponse := AFSFTPClient.UploadFile(Istream, RemotePath + NcTaskOutput.Name);

        FTPResponse.Get('StatusCode', JToken);
        ResponseCodeText := JToken.AsValue().AsText();

        case ResponseCodeText of
            '200':
                begin
                    if NcEndpointFTP."File Temporary Extension" <> '' then begin
                        FTPResponse := AFSFTPClient.MoveFile(RemotePath + NcTaskOutput.Name, RemotePath + OriginalFileName);

                        FTPResponse.Get('StatusCode', JToken);
                        ResponseCodeText := JToken.AsValue().AsText();

                        if ResponseCodeText <> '200' then begin
                            AFSFTPClient.Destruct();
                            ResponseErrorDescriptionText := StrSubstNo(UploadedFileRenameLblErr, NcTaskOutput.Name, OriginalFileName, NcEndpointFTP."File Temporary Extension");
                            Error(ResponseErrorDescriptionText);
                        end;
                    end;

                    AFSFTPClient.Destruct();
                    exit;
                end;
            '401':
                ResponseErrorDescriptionText := AuthorizationFailedErrorErr;
            else begin
                FTPResponse.Get('Error', JToken);
                ResponseErrorDescriptionText := JToken.AsValue().AsText();
            end;
        end;
        AFSFTPClient.Destruct();
        Error(ResponseErrorDescriptionText);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Nc Trigger Task Mgt.", 'OnAfterGetOutputTriggerTask', '', false, false)]
    local procedure OnAfterGetOutputTriggerTaskFTPOutput(NcTriggerCode: Code[20]; Output: Text; var NcTask: Record "NPR Nc Task"; Filename: Text; Subject: Text; Body: Text)
    begin
        ProcessNcEndpoints(NcTriggerCode, Output, Filename, NcTask);
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

    local procedure InitializeSFTP(ServerName: Text; Username: Text; Password: Text; FtpPort: Integer)
    begin
        SFTPClient.Construct(ServerName, Username, Password, FtpPort, 10000);
    end;
}

