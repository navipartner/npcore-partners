codeunit 6151524 "NPR Nc Endpoint FTP Mgt."
{
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
                                if NcEndpoint."Endpoint Type" = NcEndpointFTP.GetEndpointTypeCode then begin
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
        TextTaskInserted: Label 'FTP Task inserted for Nc Endpoint FTP %1 %2, server: %3. Nc Task Entry No. %4.';
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
        NcTriggerSyncMgt.AddResponse(NcTask, StrSubstNo(TextTaskInserted, NcEndpointFTP.Code, NcEndpointFTP.Description, NcEndpointFTP.Server, NewTask."Entry No."));
    end;

    local procedure ProcessEndPointTask(var NcEndpointFTP: Record "NPR Nc Endpoint FTP"; var NcTask: Record "NPR Nc Task"; Output: Text; Filename: Text)
    var
        NcTaskMgt: Codeunit "NPR Nc Task Mgt.";
        RecRef: RecordRef;
        FldRef: FieldRef;
        TextNoOutput: Label 'FTP Task not executed because there was no output to send.';
    begin
        NcTaskMgt.RestoreRecord(NcTask."Entry No.", RecRef);
        if Output = '' then
            Error(TextNoOutput);
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
        TextFTPServerResponseFail: Label 'File could not be uploaded. FTP server %1 returned error status %2 %3.';
        TextFTPServerResponseSuccess: Label 'The file %1 (%2 bytes) was successfully uploaded to the FTP server %3. Server returned status %4 %5.';
        NcTriggerSyncMgt: Codeunit "NPR Nc Trigger Sync. Mgt.";
        TextCouldnotFTP: Label 'File could not be uploaded. No error received from server.';
    begin
        if SendFtp(NcEndpointFTP, OutputText, Filename, ResponseDescriptionText, ResponseCodeText, ConnectionString) then begin
            case (CopyStr(ResponseDescriptionText, 1, 1)) of
                '1', '2', '3':
                    begin
                        //Positive Response
                        NcTriggerSyncMgt.AddResponse(NcTask, StrSubstNo(TextFTPServerResponseSuccess, ConnectionString, StrLen(OutputText), NcEndpointFTP.Server, ResponseCodeText, ResponseDescriptionText));
                    end;
                else begin
                        //Negative Response
                        Error(TextFTPServerResponseFail, NcEndpointFTP.Server, ResponseCodeText, ResponseDescriptionText);
                    end;
            end;
        end else
            Error(TextCouldnotFTP);
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
                SendSharpSFTP(NcEndpointFTP, OutputText, Filename, ResponseDescriptionText, ResponseCodeText, ConnectionString);
        end;
        exit(true);
    end;

    local procedure SendDotNetFtp(NcEndpointFTP: Record "NPR Nc Endpoint FTP"; OutputText: Text; Filename: Text; var ResponseDescriptionText: Text; var ResponseCodeText: Text; var ConnectionString: Text): Boolean
    var
        Credential: DotNet NPRNetNetworkCredential;
        Encoding: DotNet NPRNetUTF8Encoding;
        FtpWebRequest: DotNet NPRNetFtpWebRequest;
        FtpWebResponse: DotNet NPRNetFtpWebResponse;
        IoStream: DotNet NPRNetStream;
        Servername: Text;
    begin
        Servername := BuildFTPServerName(NcEndpointFTP.Server);

        if NcEndpointFTP.Directory <> '' then
            ConnectionString := (Servername + '/' + NcEndpointFTP.Directory + '/' + Filename)
        else
            ConnectionString := (Servername + '/' + Filename);
        FtpWebRequest := FtpWebRequest.Create(ConnectionString);

        FtpWebRequest.KeepAlive := true;
        FtpWebRequest.UseBinary := true;
        FtpWebRequest.UsePassive := NcEndpointFTP.Passive;

        FtpWebRequest.Method := 'STOR';
        FtpWebRequest.Credentials := Credential.NetworkCredential(NcEndpointFTP.Username, NcEndpointFTP.Password);
        case NcEndpointFTP."File Encoding" of
            NcEndpointFTP."File Encoding"::ANSI:
                Encoding := Encoding.GetEncoding('windows-1252');
            NcEndpointFTP."File Encoding"::Unicode:
                Encoding := Encoding.Unicode;
            NcEndpointFTP."File Encoding"::UTF8:
                Encoding := Encoding.UTF8;
        end;

        FtpWebRequest.ContentLength := Encoding.GetBytes(OutputText).Length;
        IoStream := FtpWebRequest.GetRequestStream;
        IoStream.Write(Encoding.GetBytes(OutputText), 0, FtpWebRequest.ContentLength);
        IoStream.Flush;
        IoStream.Close();
        Clear(IoStream);
        FtpWebResponse := FtpWebRequest.GetResponse;
        ResponseDescriptionText := FtpWebResponse.StatusDescription;
        ResponseCodeText := Format(FtpWebResponse.StatusCode);
        exit(true);
    end;

    local procedure SendSharpSFTP(NcEndpointFTP: Record "NPR Nc Endpoint FTP"; OutputText: Text; Filename: Text; var ResponseDescriptionText: Text; var ResponseCodeText: Text; var ConnectionString: Text): Boolean
    var
        Encoding: DotNet NPRNetUTF8Encoding;
        SharpSFtp: DotNet NPRNetSftp0;
        StreamWriter: DotNet NPRNetStreamWriter;
        UploadFile: File;
        LocalPath: Text;
        RemotePath: Text;
    begin
        LocalPath := TemporaryPath;
        UploadFile.Create(LocalPath + Filename);
        UploadFile.Close();

        case NcEndpointFTP."File Encoding" of
            NcEndpointFTP."File Encoding"::ANSI:
                Encoding := Encoding.GetEncoding('windows-1252');
            NcEndpointFTP."File Encoding"::Unicode:
                Encoding := Encoding.Unicode;
            NcEndpointFTP."File Encoding"::UTF8:
                Encoding := Encoding.UTF8;
        end;
        StreamWriter := StreamWriter.StreamWriter(LocalPath + Filename, true, Encoding);
        StreamWriter.Write(OutputText);
        StreamWriter.Flush;
        StreamWriter.Close();

        SharpSFtp := SharpSFtp.Sftp(NcEndpointFTP.Server, NcEndpointFTP.Username, NcEndpointFTP.Password);
        SharpSFtp.Connect(NcEndpointFTP.Port);

        if NcEndpointFTP.Directory <> '' then
            RemotePath := '/' + NcEndpointFTP.Directory + '/'
        else
            RemotePath := '/';
        SharpSFtp.Put(LocalPath + Filename, RemotePath + Filename);

        ResponseDescriptionText := '200 The requested action has been successfully completed';
        ResponseCodeText := '200';
        exit(true);
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
        Credential: DotNet NPRNetNetworkCredential;
        FtpWebRequest: DotNet NPRNetFtpWebRequest;
        FtpWebResponse: DotNet NPRNetFtpWebResponse;
        Stream: DotNet NPRNetStream;
        Uri: DotNet NPRNetUri;
        InStream: InStream;
        ServerName: Text;
        Url: Text;
    begin
        ServerName := BuildFTPServerName(NcEndpointFTP.Server);

        Url := (ServerName + '/' + NcTaskOutput.Name);
        if NcEndpointFTP.Directory <> '' then
            Url := (ServerName + '/' + NcEndpointFTP.Directory + '/' + NcTaskOutput.Name);

        FtpWebRequest := FtpWebRequest.Create(Uri.Uri(Url));
        FtpWebRequest.KeepAlive := true;
        FtpWebRequest.UseBinary := true;
        FtpWebRequest.UsePassive := NcEndpointFTP.Passive;

        FtpWebRequest.Method := 'STOR';
        FtpWebRequest.Credentials := Credential.NetworkCredential(NcEndpointFTP.Username, NcEndpointFTP.Password);
        NcTaskOutput.Data.CreateInStream(InStream);
        Stream := FtpWebRequest.GetRequestStream;
        CopyStream(Stream, InStream);
        Stream.Flush;
        Stream.Close();
        Clear(Stream);

        FtpWebResponse := FtpWebRequest.GetResponse;
    end;

    local procedure SetupNCTaskLine()
    begin
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
        Credential: DotNet NPRNetNetworkCredential;
        FtpFolders: Text;
        FtpPath: Text;
        List: Text;
    begin
        Credential := Credential.NetworkCredential(NcEndpointFTP.Username, NcEndpointFTP.Password);
        FtpPath := NcEndpointFTP.Server;
        TryListFtpDirectory(FtpPath, Credential, List);

        if NcEndpointFTP.Directory = '' then
            exit;

        FtpFolders := NcEndpointFTP.Directory;
        CreateFtpFolders(NcEndpointFTP.Server, Credential, FtpFolders);
    end;

    local procedure CreateFtpFolders(FtpServer: Text; var Credential: DotNet NPRNetNetworkCredential; FtpFolders: Text)
    var
        FtpFolder: Text;
        FtpPath: Text;
        List: Text;
    begin
        FtpPath := FtpServer;
        while CutNextFtpFolder(FtpFolders, FtpFolder) do begin
            FtpPath += '/' + FtpFolder;
            if (not TryListFtpDirectory(FtpPath, Credential, List)) or (List = '') then
                TryCreateFtpFolder(FtpPath, Credential);
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
    local procedure TryCreateFtpFolder(FtpPath: Text; var Credential: DotNet NPRNetNetworkCredential)
    var
        FtpWebRequest: DotNet NPRNetFtpWebRequest;
        FtpWebResponse: DotNet NPRNetFtpWebResponse;
        MemoryStream: DotNet NPRNetMemoryStream;
    begin
        FtpWebRequest := FtpWebRequest.Create(FtpPath);
        FtpWebRequest.Method := 'MKD';
        FtpWebRequest.Credentials := Credential;
        FtpWebResponse := FtpWebRequest.GetResponse;
        MemoryStream := FtpWebResponse.GetResponseStream();
        MemoryStream.Flush;
        MemoryStream.Close();
        Clear(MemoryStream);
        FtpWebRequest.Abort();
        Clear(FtpWebRequest);
    end;

    [TryFunction]
    local procedure TryListFtpDirectory(FtpPath: Text; var Credential: DotNet NPRNetNetworkCredential; var List: Text)
    var
        FtpWebRequest: DotNet NPRNetFtpWebRequest;
        FtpWebResponse: DotNet NPRNetFtpWebResponse;
        MemoryStream: DotNet NPRNetMemoryStream;
        StreamReader: DotNet NPRNetStreamReader;
    begin
        FtpWebRequest := FtpWebRequest.Create(FtpPath);
        FtpWebRequest.Method := 'LIST';
        FtpWebRequest.Credentials := Credential;
        FtpWebResponse := FtpWebRequest.GetResponse;
        MemoryStream := FtpWebResponse.GetResponseStream();

        StreamReader := StreamReader.StreamReader(MemoryStream);
        List := StreamReader.ReadToEnd;

        MemoryStream.Flush;
        MemoryStream.Close();
        Clear(MemoryStream);
        FtpWebRequest.Abort();
        Clear(FtpWebRequest);
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
        if not NcEndpointType.Get(NcEndpointFTP.GetEndpointTypeCode) then begin
            NcEndpointType.Init();
            NcEndpointType.Code := NcEndpointFTP.GetEndpointTypeCode;
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
        if Sender."Endpoint Type" <> NcEndpointFTP.GetEndpointTypeCode then
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
}

