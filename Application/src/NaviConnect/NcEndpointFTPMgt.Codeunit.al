codeunit 6151524 "NPR Nc Endpoint FTP Mgt."
{
    var
        FTPClient: Codeunit "NPR AF FTP Client";
        SFTPClient: Codeunit "NPR AF SFTP Client";
        AuthorizationFailedErrorErr: Label 'Authorization failed. Wrong FTP username/password.';

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
        TempNcEndPointFTP.Filename := Filename;
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
        ConnectionString: Text;
        TextFTPServerResponseFailErr: Label 'File could not be uploaded. FTP server %1 returned error status %2 %3.', Comment = '%1=NcEndpointFTP.Server;%2=ResponseCodeText;%3=ResponseDescriptionText';
        TextFTPServerResponseSuccessLbl: Label 'The file %1 (%2 bytes) was successfully uploaded to the FTP server %3. Server returned status %4 %5.', Comment = '%1=ConnectionString;%2=StrLen(OutputText);%3=NcEndpointFTP.Server;%4=ResponseCodeText;%5=ResponseDescriptionText';
        NcTriggerSyncMgt: Codeunit "NPR Nc Trigger Sync. Mgt.";
        TextCouldnotFTPErr: Label 'File could not be uploaded. No error received from server.';
    begin
        if SendFtp(NcEndpointFTP, OutputText, Filename, ResponseDescriptionText, ResponseCodeText, ConnectionString) then begin
            case (CopyStr(ResponseDescriptionText, 1, 1)) of
                '1', '2', '3':
                    begin
                        //Positive Response
                        NcTriggerSyncMgt.AddResponse(NcTask, StrSubstNo(TextFTPServerResponseSuccessLbl, ConnectionString, StrLen(OutputText), NcEndpointFTP.Server, ResponseCodeText, ResponseDescriptionText));
                    end;
                else begin
                        //Negative Response
                        Error(TextFTPServerResponseFailErr, NcEndpointFTP.Server, ResponseCodeText, ResponseDescriptionText);
                    end;
            end;
        end else
            Error(TextCouldnotFTPErr);
    end;

    local procedure SendFtp(NcEndpointFTP: Record "NPR Nc Endpoint FTP"; OutputText: Text; Filename: Text; var ResponseDescriptionText: Text; var ResponseCodeText: Text; var ConnectionString: Text): Boolean
    begin
        if not NcEndpointFTP.Enabled then
            exit(false);
        if NcEndpointFTP.Server = '' then
            exit(false);
        if Filename = '' then
            Filename := NcEndpointFTP.Filename;

        case NcEndpointFTP.Type of
            NcEndpointFTP.Type::DotNet:
                SendDotNetFtp(NcEndpointFTP, OutputText, Filename, ResponseDescriptionText, ResponseCodeText, ConnectionString);
            NcEndpointFTP.Type::SharpSFTP:
                SendSharpSFTP(NcEndpointFTP, OutputText, Filename, ResponseDescriptionText, ResponseCodeText);
        end;
        exit(true);
    end;

    local procedure SendDotNetFtp(NcEndpointFTP: Record "NPR Nc Endpoint FTP"; OutputText: Text; Filename: Text; var ResponseDescriptionText: Text; var ResponseCodeText: Text; var ConnectionString: Text): Boolean
    var
        Servername: Text;
        TempBlob: Codeunit "Temp Blob";
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
            ConnectionString := (NcEndpointFTP.Directory + '/' + Filename)
        else
            ConnectionString := (Filename);

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

        InitializeFTP(Servername, NcEndpointFTP.Username, NcEndpointFTP.Password, FtpPort, NcEndpointFTP.Passive);
        FTPResponse := FTPClient.UploadFile(InStr, ConnectionString);

        FTPResponse.Get('StatusCode', JToken);
        ResponseCodeText := JToken.AsValue().AsText();

        case ResponseCodeText of
            '200':
                begin
                    FTPResponse.Get('Decription', JToken);
                    ResponseDescriptionText := JToken.AsValue().AsText();
                    exit(true);
                end;
            '401':
                ResponseDescriptionText := AuthorizationFailedErrorErr;
            else begin
                    FTPResponse.Get('Error', JToken);
                    ResponseDescriptionText := JToken.AsValue().AsText();
                end;
        end;

        exit(false);
    end;

    local procedure SendSharpSFTP(NcEndpointFTP: Record "NPR Nc Endpoint FTP"; OutputText: Text; Filename: Text; var ResponseDescriptionText: Text; var ResponseCodeText: Text): Boolean
    var
        RemotePath: Text;
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
            RemotePath := '/' + NcEndpointFTP.Directory + '/'
        else
            RemotePath := '/';

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

        InitializeSFTP(NcEndpointFTP.Server, NcEndpointFTP.Username, NcEndpointFTP.Password, FtpPort);
        FTPResponse := SFTPClient.UploadFile(InStr, RemotePath + Filename);

        FTPResponse.Get('StatusCode', JToken);
        ResponseCodeText := JToken.AsValue().AsText();

        case ResponseCodeText of
            '200':
                begin
                    ResponseDescriptionText := '200 The requested action has been successfully completed';
                    exit(true);
                end;
            '401':
                ResponseDescriptionText := AuthorizationFailedErrorErr;
            else begin
                    FTPResponse.Get('Error', JToken);
                    ResponseDescriptionText := JToken.AsValue().AsText();
                end;
        end;

        exit(false);
    end;

    local procedure SendFtpOutput(NcTaskOutput: Record "NPR Nc Task Output"; NcEndpointFTP: Record "NPR Nc Endpoint FTP")
    begin
        if not NcEndpointFTP.Enabled then
            exit;
        if NcEndpointFTP.Server = '' then
            exit;

        case NcEndpointFTP.Type of
            NcEndpointFTP.Type::DotNet:
                SendDotNetFtpOutput(NcTaskOutput, NcEndpointFTP);
            NcEndpointFTP.Type::SharpSFTP:
                SendSFTPOutput(NcTaskOutput, NcEndpointFTP);
        end;
    end;

    local procedure SendDotNetFtpOutput(NcTaskOutput: Record "NPR Nc Task Output"; NcEndpointFTP: Record "NPR Nc Endpoint FTP"): Boolean
    var
        FtpPort: Integer;
        InStr: InStream;
        ServerName: Text;
        FilePath: Text;
    begin
        ServerName := BuildFTPServerName(NcEndpointFTP.Server);

        FilePath := (NcTaskOutput.Name);
        if NcEndpointFTP.Directory <> '' then
            FilePath := (NcEndpointFTP.Directory + '/' + NcTaskOutput.Name);

        NcTaskOutput.Data.CreateInStream(InStr);

        FtpPort := NcEndpointFTP.Port;
        If FtpPort = 0 then
            FtpPort := 21;

        InitializeFTP(ServerName, NcEndpointFTP.Username, NcEndpointFTP.Password, FtpPort, NcEndpointFTP.Passive);
        FTPClient.UploadFile(InStr, FilePath);
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
    begin
        FtpPath := '/';

        FtpPort := NcEndpointFTP.Port;
        If FtpPort = 0 then
            FtpPort := 21;

        InitializeFTP(NcEndpointFTP.Server, NcEndpointFTP.Username, NcEndpointFTP.Password, FtpPort, NcEndpointFTP.Passive);
        TryListFtpDirectory(DirectoryList);

        if NcEndpointFTP.Directory = '' then
            exit;

        FtpFolders := NcEndpointFTP.Directory;
        CreateFtpFolders(NcEndpointFTP.Server, FtpFolders);
    end;

    local procedure CreateFtpFolders(FtpServer: Text; FtpFolders: Text)
    var
        FtpFolder: Text;
        FtpPath: Text;
        DirectoryList: List of [Text];
    begin
        FtpPath := FtpServer;
        while CutNextFtpFolder(FtpFolders, FtpFolder) do begin
            FtpPath += '/' + FtpFolder;
            if (not TryListFtpDirectory(DirectoryList)) or (DirectoryList.Count = 0) then
                TryCreateFtpFolder(FtpPath);
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
    local procedure TryCreateFtpFolder(FtpPath: Text)
    var
        FTPResponse: JsonObject;
        ResponseCodeText: Text;
        JToken: JsonToken;
    begin
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
    local procedure TryListFtpDirectory(var DirectoryList: List of [Text])
    var
        FTPResponse: JsonObject;
        FileObject: JsonObject;
        JToken: JsonToken;
        JArray: JsonArray;
        i: Integer;
        ResponseCodeText: Text;
    begin
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

                        FileObject.Get('Directory', JToken);
                        if Jtoken.AsValue().AsBoolean() then begin
                            FileObject.Get('File', JToken);
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

    local procedure SendSFTPOutput(NcTaskOutput: Record "NPR Nc Task Output"; NcEndpointFTP: Record "NPR Nc Endpoint FTP")
    var
        AFSFTPClient: Codeunit "NPR AF SFTP Client";
        Istream: InStream;
        RemotePath: Text;
    begin
        AFSFTPClient.Construct(NcEndpointFTP.Server, NcEndpointFTP.Username, NcEndpointFTP.Password, NcEndpointFTP.Port, 10000);
        if NcEndpointFTP.Directory <> '' then
            RemotePath := '/' + NcEndpointFTP.Directory.TrimStart('/').TrimEnd('/') + '/'
        else
            RemotePath := '/';
        NcTaskOutput.Data.CreateInStream(Istream);
        AFSFTPClient.UploadFile(Istream, RemotePath + NcTaskOutput.Name);
        AFSFTPClient.Destruct();
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
    local procedure OnRunEndpoint(NcTaskOutput: Record "NPR Nc Task Output"; NcEndpoint: Record "NPR Nc Endpoint")
    var
        NcEndpointFTP: Record "NPR Nc Endpoint FTP";
    begin
        if NcEndpoint."Endpoint Type" <> NcEndpointFTP.GetEndpointTypeCode() then
            exit;
        if not NcEndpointFTP.Get(NcEndpoint.Code) then
            exit;

        SendFtpOutput(NcTaskOutput, NcEndpointFTP);
    end;

    local procedure InitializeFTP(ServerName: Text; Username: Text; Password: Text; FtpPort: Integer; Passive: Boolean)
    begin
        FTPClient.Construct(ServerName, Username, Password, FtpPort, 10000, Passive);
    end;

    local procedure InitializeSFTP(ServerName: Text; Username: Text; Password: Text; FtpPort: Integer)
    begin
        SFTPClient.Construct(ServerName, Username, Password, FtpPort, 10000);
    end;
}

