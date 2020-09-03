codeunit 6151524 "NPR Nc Endpoint FTP Mgt."
{
    // NC2.01/BR /20160818  CASE 248630 NaviConnect
    // NC2.01/BR /20161110 CASE 261431 SFTP function SendSharpSFTP()
    // NC2.12/MHA /20180418  CASE 308107 Added functions EmailProcessOutput(),OnRunEndpoint()
    // NC2.13/MHA /20180613  CASE 318934 Implemented Init framework


    trigger OnRun()
    begin
    end;

    local procedure ProcessNcEndpoints(NcTriggerCode: Code[20]; Output: Text; Filename: Text; var NcTask: Record "NPR Nc Task")
    var
        NcTrigger: Record "NPR Nc Trigger";
        NcEndpoint: Record "NPR Nc Endpoint";
        NcEndpointFTP: Record "NPR Nc Endpoint FTP";
        NcEndpointTriggerLink: Record "NPR Nc Endpoint Trigger Link";
    begin
        case NcTask."Table No." of
            DATABASE::"NPR Nc Trigger":
                begin
                    NcEndpointTriggerLink.Reset;
                    NcEndpointTriggerLink.SetRange("Trigger Code", NcTriggerCode);
                    if NcEndpointTriggerLink.FindSet then
                        repeat
                            if NcEndpoint.Get(NcEndpointTriggerLink."Endpoint Code") then begin
                                if NcEndpoint."Endpoint Type" = NcEndpointFTP.GetEndpointTypeCode then begin
                                    if NcEndpointFTP.Get(NcEndpointTriggerLink."Endpoint Code") then begin
                                        ProcessNcEndpointTrigger(NcTriggerCode, Output, Filename, NcTask, NcEndpointFTP);
                                    end;
                                end;
                            end;
                        until NcEndpointTriggerLink.Next = 0;
                end;
            DATABASE::"NPR Nc Endpoint FTP":
                begin
                    //Process Endpoint Task
                    NcEndpointFTP.SetPosition(NcTask."Record Position");
                    NcEndpointFTP.SetRange(Code, NcEndpointFTP.Code);
                    NcEndpointFTP.SetRange(Enabled, true);
                    if NcEndpointFTP.FindFirst then begin
                        ProcessEndPointTask(NcEndpointFTP, NcTask, Output, Filename);
                        NcTask.Modify;
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
            NcTask.Modify;
        end else begin
            //Insert New Task per Endpoint
            InsertEndpointTask(NcEndpointFTP, NcTask, Filename);
            NcTask.Modify;
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
        TempNcEndPointFTP.Init;
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
    var
        "Field": Record "Field";
        Credential: DotNet NPRNetNetworkCredential;
        FtpWebRequest: DotNet NPRNetFtpWebRequest;
        FtpWebResponse: DotNet NPRNetFtpWebResponse;
        UTF8Encoding: DotNet NPRNetUTF8Encoding;
        IoStream: DotNet NPRNetStream;
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
            //-NC2.01 [261431]
            //NcEndpointFTP.Type::ChilkatFTP2 :
            //  SendChilKatFTP(NcEndpointFTP,OutputText,Filename,ResponseDescriptionText,ResponseCodeText,ConnectionString);
            //NcEndpointFTP.Type::ChilkatSFTP :
            //  SendChilKatSFTP(NcEndpointFTP,OutputText,Filename,ResponseDescriptionText,ResponseCodeText,ConnectionString);
            NcEndpointFTP.Type::SharpSFTP:
                SendSharpSFTP(NcEndpointFTP, OutputText, Filename, ResponseDescriptionText, ResponseCodeText, ConnectionString);
        //+NC2.01 [261431]
        end;
        exit(true);
    end;

    local procedure SendDotNetFtp(NcEndpointFTP: Record "NPR Nc Endpoint FTP"; OutputText: Text; Filename: Text; var ResponseDescriptionText: Text; var ResponseCodeText: Text; var ConnectionString: Text): Boolean
    var
        "Field": Record "Field";
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

        FtpWebRequest.Method := 'STOR'; //WebRequestMethods.Ftp.UploadFile
        FtpWebRequest.Credentials := Credential.NetworkCredential(NcEndpointFTP.Username, NcEndpointFTP.Password);
        //-NC2.01 [261431]
        // UTF8Encoding := UTF8Encoding.UTF8Encoding;
        //
        // FtpWebRequest.ContentLength := UTF8Encoding.GetBytes(OutputText).Length;
        // IoStream := FtpWebRequest.GetRequestStream;
        // IoStream.Write(UTF8Encoding.GetBytes(OutputText),0,FtpWebRequest.ContentLength);
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
        //+NC2.01 [261431]
        IoStream.Flush;
        IoStream.Close;
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
        //-NC2.01 [261431]
        LocalPath := TemporaryPath;
        UploadFile.Create(LocalPath + Filename);
        UploadFile.Close;

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
        StreamWriter.Close;

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
        //+NC2.01 [261431]
    end;

    local procedure SendFtpOutput(NcTaskOutput: Record "NPR Nc Task Output"; NcEndpointFTP: Record "NPR Nc Endpoint FTP")
    begin
        //-308107 [308107]
        if not NcEndpointFTP.Enabled then
            exit;
        if NcEndpointFTP.Server = '' then
            exit;

        case NcEndpointFTP.Type of
            NcEndpointFTP.Type::DotNet:
                SendDotNetFtpOutput(NcTaskOutput, NcEndpointFTP);
        //  NcEndpointFTP.Type::SharpSFTP :
        //    SendSharpSFTP(NcEndpointFTP,OutputText,Filename,ResponseDescriptionText,ResponseCodeText,ConnectionString);
        end;
        //+308107 [308107]
    end;

    local procedure SendDotNetFtpOutput(NcTaskOutput: Record "NPR Nc Task Output"; NcEndpointFTP: Record "NPR Nc Endpoint FTP"): Boolean
    var
        "Field": Record "Field";
        Credential: DotNet NPRNetNetworkCredential;
        FtpWebRequest: DotNet NPRNetFtpWebRequest;
        FtpWebResponse: DotNet NPRNetFtpWebResponse;
        Stream: DotNet NPRNetStream;
        Uri: DotNet NPRNetUri;
        InStream: InStream;
        ServerName: Text;
        Url: Text;
    begin
        //-NC2.12 [308107]
        ServerName := BuildFTPServerName(NcEndpointFTP.Server);

        Url := (ServerName + '/' + NcTaskOutput.Name);
        if NcEndpointFTP.Directory <> '' then
            Url := (ServerName + '/' + NcEndpointFTP.Directory + '/' + NcTaskOutput.Name);

        FtpWebRequest := FtpWebRequest.Create(Uri.Uri(Url));
        FtpWebRequest.KeepAlive := true;
        FtpWebRequest.UseBinary := true;
        FtpWebRequest.UsePassive := NcEndpointFTP.Passive;

        FtpWebRequest.Method := 'STOR'; //WebRequestMethods.Ftp.UploadFile
        FtpWebRequest.Credentials := Credential.NetworkCredential(NcEndpointFTP.Username, NcEndpointFTP.Password);
        NcTaskOutput.Data.CreateInStream(InStream);
        Stream := FtpWebRequest.GetRequestStream;
        CopyStream(Stream, InStream);
        Stream.Flush;
        Stream.Close;
        Clear(Stream);

        FtpWebResponse := FtpWebRequest.GetResponse;
        //+NC2.12 [308107]
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

    local procedure "--- Init"()
    begin
    end;

    local procedure InitEndpoint(NcEndpointFTP: Record "NPR Nc Endpoint FTP")
    var
        Credential: DotNet NPRNetNetworkCredential;
        FtpFolder: Text;
        FtpFolders: Text;
        FtpPath: Text;
        List: Text;
    begin
        //-NC2.13 [318934]
        Credential := Credential.NetworkCredential(NcEndpointFTP.Username, NcEndpointFTP.Password);
        FtpPath := NcEndpointFTP.Server;
        TryListFtpDirectory(FtpPath, Credential, List);

        if NcEndpointFTP.Directory = '' then
            exit;

        FtpFolders := NcEndpointFTP.Directory;
        CreateFtpFolders(NcEndpointFTP.Server, Credential, FtpFolders);
        //+NC2.13 [318934]
    end;

    local procedure CreateFtpFolders(FtpServer: Text; var Credential: DotNet NPRNetNetworkCredential; FtpFolders: Text)
    var
        FtpFolder: Text;
        FtpPath: Text;
        List: Text;
    begin
        //-NC2.13 [318934]
        FtpPath := FtpServer;
        while CutNextFtpFolder(FtpFolders, FtpFolder) do begin
            FtpPath += '/' + FtpFolder;
            if (not TryListFtpDirectory(FtpPath, Credential, List)) or (List = '') then
                TryCreateFtpFolder(FtpPath, Credential);
        end;
        //+NC2.13 [318934]
    end;

    local procedure CutNextFtpFolder(var FtpFolders: Text; var FtpFolder: Text): Boolean
    var
        Position: Integer;
    begin
        //-NC2.13 [318934]
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
        //+NC2.13 [318934]
    end;

    [TryFunction]
    local procedure TryCreateFtpFolder(FtpPath: Text; var Credential: DotNet NPRNetNetworkCredential)
    var
        FtpWebRequest: DotNet NPRNetFtpWebRequest;
        FtpWebResponse: DotNet NPRNetFtpWebResponse;
        MemoryStream: DotNet NPRNetMemoryStream;
    begin
        //-NC2.13 [318934]
        FtpWebRequest := FtpWebRequest.Create(FtpPath);
        FtpWebRequest.Method := 'MKD'; //WebRequestMethods.Ftp.UploadFile
        FtpWebRequest.Credentials := Credential;
        FtpWebResponse := FtpWebRequest.GetResponse;
        MemoryStream := FtpWebResponse.GetResponseStream();
        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);
        FtpWebRequest.Abort();
        Clear(FtpWebRequest);
        //+NC2.13 [318934]
    end;

    [TryFunction]
    local procedure TryListFtpDirectory(FtpPath: Text; var Credential: DotNet NPRNetNetworkCredential; var List: Text)
    var
        FtpWebRequest: DotNet NPRNetFtpWebRequest;
        FtpWebResponse: DotNet NPRNetFtpWebResponse;
        MemoryStream: DotNet NPRNetMemoryStream;
        StreamReader: DotNet NPRNetStreamReader;
    begin
        //-NC2.13 [318934]
        FtpWebRequest := FtpWebRequest.Create(FtpPath);
        FtpWebRequest.Method := 'LIST'; //WebRequestMethods.Ftp.ListDirectory
        FtpWebRequest.Credentials := Credential;
        FtpWebResponse := FtpWebRequest.GetResponse;
        MemoryStream := FtpWebResponse.GetResponseStream();

        StreamReader := StreamReader.StreamReader(MemoryStream);
        List := StreamReader.ReadToEnd;

        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);
        FtpWebRequest.Abort();
        Clear(FtpWebRequest);
        //+NC2.13 [318934]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151519, 'OnHasInitEndpoint', '', true, true)]
    local procedure OnHasInitEndpoint(NcEndpoint: Record "NPR Nc Endpoint"; var EndpointHasInit: Boolean)
    var
        NcEndpointFTP: Record "NPR Nc Endpoint FTP";
    begin
        //-NC2.13 [318934]
        if NcEndpoint."Endpoint Type" <> NcEndpointFTP.GetEndpointTypeCode() then
            exit;
        if not NcEndpoint.Enabled then
            exit;
        if not NcEndpointFTP.Get(NcEndpoint.Code) then
            exit;

        EndpointHasInit := true;

        //+NC2.13 [318934]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151519, 'OnInitEndpoint', '', true, true)]
    local procedure OnInitEndpoint(NcEndpoint: Record "NPR Nc Endpoint")
    var
        NcEndpointFTP: Record "NPR Nc Endpoint FTP";
    begin
        //-NC2.13 [318934]
        if NcEndpoint."Endpoint Type" <> NcEndpointFTP.GetEndpointTypeCode() then
            exit;
        if not NcEndpoint.Enabled then
            exit;
        if not NcEndpointFTP.Get(NcEndpoint.Code) then
            exit;

        InitEndpoint(NcEndpointFTP);
        //+NC2.13 [318934]
    end;

    local procedure "---Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151522, 'OnAfterGetOutputTriggerTask', '', false, false)]
    local procedure OnAfterGetOutputTriggerTaskFTPOutput(NcTriggerCode: Code[20]; Output: Text; var NcTask: Record "NPR Nc Task"; Filename: Text; Subject: Text; Body: Text)
    begin
        ProcessNcEndpoints(NcTriggerCode, Output, Filename, NcTask);
    end;

    [EventSubscriber(ObjectType::Table, 6151531, 'OnSetupEndpointTypes', '', false, false)]
    local procedure OnSetupEndpointTypeInsertEndpointTypeCode()
    var
        NcEndpointFTP: Record "NPR Nc Endpoint FTP";
        NcEndpointType: Record "NPR Nc Endpoint Type";
    begin
        if not NcEndpointType.Get(NcEndpointFTP.GetEndpointTypeCode) then begin
            NcEndpointType.Init;
            NcEndpointType.Code := NcEndpointFTP.GetEndpointTypeCode;
            NcEndpointType.Insert;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6151533, 'OnOpenEndpointSetup', '', false, false)]
    local procedure OnOpenEndpointSetupOpenPage(var Sender: Record "NPR Nc Endpoint"; var Handled: Boolean)
    var
        NcEndpointFTP: Record "NPR Nc Endpoint FTP";
    begin
        if Handled then
            exit;
        if Sender."Endpoint Type" <> NcEndpointFTP.GetEndpointTypeCode then
            exit;
        if not NcEndpointFTP.Get(Sender.Code) then begin
            NcEndpointFTP.Init;
            NcEndpointFTP.Validate(Code, Sender.Code);
            NcEndpointFTP.Description := Sender.Description;
            NcEndpointFTP.Insert;
        end else begin
            if NcEndpointFTP.Description <> Sender.Description then begin
                NcEndpointFTP.Description := Sender.Description;
                NcEndpointFTP.Modify(true);
            end;
        end;
        PAGE.Run(PAGE::"NPR Nc Endpoint FTP Card", NcEndpointFTP);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Table, 6151533, 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnDeleteEndpoint(var Rec: Record "NPR Nc Endpoint"; RunTrigger: Boolean)
    var
        NcEndpointFTP: Record "NPR Nc Endpoint FTP";
    begin
        if NcEndpointFTP.Get(Rec.Code) then
            NcEndpointFTP.Delete(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151519, 'OnRunEndpoint', '', true, true)]
    local procedure OnRunEndpoint(NcTaskOutput: Record "NPR Nc Task Output"; NcEndpoint: Record "NPR Nc Endpoint")
    var
        NcEndpointFTP: Record "NPR Nc Endpoint FTP";
    begin
        //-NC2.12 [308107]
        if NcEndpoint."Endpoint Type" <> NcEndpointFTP.GetEndpointTypeCode() then
            exit;
        if not NcEndpointFTP.Get(NcEndpoint.Code) then
            exit;

        SendFtpOutput(NcTaskOutput, NcEndpointFTP);
        //+NC2.12 [308107]
    end;
}

