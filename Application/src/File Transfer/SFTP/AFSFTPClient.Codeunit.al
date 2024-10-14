codeunit 6151612 "NPR AF SFTP Client"
{
    Access = Internal;

    var
        _FunctionAppName: Label 'SftpProxy', Locked = true;
        _AzureKeyVaultNameForSubKey: Label 'AFSftpProxySub', Locked = true;
        _HttpHeaderName: Label 'NP-FileTransfer-Request', Locked = true;
        _JsonUrl: Label 'FileServerUrl', Locked = true;
        _JsonPort: Label 'FileServerPort', Locked = true;
        _JsonUser: Label 'FileServerUsername', Locked = true;
        _JsonPass: Label 'FileServerPassword', Locked = true;
        _JsonKey: Label 'FileServerPrivateKey', Locked = true;
        _JsonPath: Label 'Path', Locked = true;
        _JsonNewPath: Label 'NewPath', Locked = true;
        _JsonForce: Label 'Force', Locked = true;
        _lblRequestError: Label 'Http request error(%1): %2';

    local procedure FunctionAppVersion(): Integer;
    begin
        exit(1);
    end;

    /// <summary>
    /// Creates a JSON Object based on the Sftp Connection Record. This JsonObject is used by the other functions in this codeunit.
    /// It is used to set the Server Connection info in the HTTP Header for the Azure function that is beeing called.
    /// </summary>
    /// <param name="SftpConnection">SFTP Record to be used as connection info.</param>
    /// <returns>Return FileServer Connection info JsonObject used by File operations functions.</returns>
    internal procedure GetFileServerJsonRequest(SftpConnection: Record "NPR SFTP Connection"): JsonObject
    var
        Request: JsonObject;
        InS: InStream;
        SSHKeyB64: Text;
        Base64Convert: Codeunit "Base64 Convert";
    begin
        Request.Add(_JsonUrl, SftpConnection."Server Host");
        Request.Add(_JsonPort, SftpConnection."Server Port");
        Request.Add(_JsonUser, SftpConnection.Username);
        Request.Add(_JsonPass, SftpConnection.Password);
        SftpConnection.CalcFields("Server SSH Key");
        SftpConnection."Server SSH Key".CreateInStream(InS);
        SSHKeyB64 := Base64Convert.ToBase64(InS);
        Request.Add(_JsonKey, SSHKeyB64);
        Request.Add(_JsonForce, SftpConnection."Force Behavior");
        exit(Request);
    end;
    /// <summary>
    /// Creates a JsonObject based in the SFTP Connection parameters given. This JsonObject is used by the other functions in this codeunit.
    /// It is used to set the Server Connection info in the HTTP Header for the Azure function that is beeing called.
    /// </summary>
    /// <param name="Server">The hostname / ip-address of the file server.</param>
    /// <param name="Port">The port used fot SFTP on the file server.</param>
    /// <param name="Username">Username used to login on the file server.</param>
    /// <param name="Password">Password used to login on the file server.</param>
    /// <param name="SSHKey">(Optional) The SSH key if the file server is configured to use SSH keys instead.</param>
    /// <param name="ForceBehavior">Boolean specifying if the SFTPClient should force behavior, such as deleting non-empty directories and overwriting files.</param>
    /// <returns>Return FileServer Connection info JsonObject used by File operations functions.</returns>
    internal procedure GetFileServerJsonRequest(Server: Text; Port: Integer; Username: text; Password: Text; SSHKey: Text; ForceBehavior: Boolean): JsonObject
    var
        Request: JsonObject;
        Base64Convert: Codeunit "Base64 Convert";
    begin
        Request.Add(_JsonUrl, Server);
        Request.Add(_JsonPort, Port);
        Request.Add(_JsonUser, Username);
        Request.Add(_JsonPass, Password);
        Request.Add(_JsonKey, Base64Convert.ToBase64(SSHKey));
        Request.Add(_JsonForce, ForceBehavior);
        exit(Request);
    end;
    /// <summary>
    /// Downloads the specified file located at @RemotedPath on the file server corresponding to the @SftpConnection into the @FileStream.
    /// </summary>
    /// <param name="RemotePath">File location on server from root folder. (If just file name is five e.g. 'file.xml' then it will default to '/file.xml'
    ///  and error occours if the @RemotePath ends is a Path seperator.</param>
    /// <param name="FileStream">Temporay blob where the file contents will be written too.</param>
    /// <param name="SftpConnection">SFTP Connection record specifying File Server Connection info.</param>
    [TryFunction]
    internal procedure DownloadFile(RemotePath: Text; var FileStream: Codeunit "Temp Blob"; SftpConnection: Record "NPR SFTP Connection")
    begin
        DownloadFile(RemotePath, FileStream, GetFileServerJsonRequest(SftpConnection));
    end;

    /// <summary>
    /// Downloads the specified file located at @RemotedPath on the file server corresponding to the @FileServerRequest into the @FileStream.
    /// </summary>
    /// <param name="RemotePath">File location on server from root folder. (If just file name is five e.g. 'file.xml' then it will default to '/file.xml'
    ///  and error occours if the @RemotePath ends is a Path seperator.</param>
    /// <param name="FileStream">Temporay blob where the file contents will be written too.</param>
    /// <param name="FileServerRequest">SFTP Connection JsonObject specifying File Server Connection info. Use @GetFileServerJsonRequest() to obtain this.</param>
    [TryFunction]
    internal procedure DownloadFile(RemotePath: Text; var FileStream: Codeunit "Temp Blob"; FileServerRequest: JsonObject)
    var
        http: HttpClient;
        content: HttpContent;
        response: HttpResponseMessage;
        outS: OutStream;
        inS: InStream;
        headerJson: JsonObject;
    begin
        headerJson := FileServerRequest.Clone().AsObject();
        headerJson.Add(_JsonPath, RemotePath);
        GetAFHttpClient(_FunctionAppName, 'DownloadFile', FunctionAppVersion(), _AzureKeyVaultNameForSubKey, http);
        SendRequest(http, content, headerJson, response);
        if (not response.IsSuccessStatusCode()) then
            Error(_lblRequestError, Format(response.HttpStatusCode()), GetErrorMessage(response));
        response.Content.ReadAs(inS);
        FileStream.CreateOutStream(outS);
        CopyStream(outS, inS);
    end;
    /// <summary>
    /// Uploads the content of @FileStream into a new file @RemotePath on the server corresponding to the @SftpConnection record. If Force behavior is
    /// set to false on the SFTP Connection record and a file already exists at @RemotePath the function will fail. If @RemotePath file is located in a folder
    /// that do not yet exist the SFTP Client will attempt to create the subfolders and upload the file.
    /// </summary>
    /// <param name="RemotePath">The file path on the server the file will be uploaded to.</param>
    /// <param name="FileStream">The tempoary blob containing the filecontent to be uploaded.</param>
    /// <param name="SftpConnection">The SFTP Connection record specifying the connection info.</param>
    [TryFunction]
    internal procedure UploadFile(RemotePath: Text; var FileStream: Codeunit "Temp Blob"; SftpConnection: Record "NPR SFTP Connection")
    begin
        UploadFile(RemotePath, FileStream, GetFileServerJsonRequest(SftpConnection));
    end;
    /// <summary>
    /// Uploads the content of @FileStream into a new file @RemotePath on the server corresponding to the @FileServerRequest JsonObject. If Force behavior is
    /// set to false on the SFTP Connection record and a file already exists at @RemotePath the function will fail otherwise it will overwrite the file. If @RemotePath file is located in a folder
    /// that do not yet exist the SFTP Client will attempt to create the subfolders and upload the file.
    /// </summary>
    /// <param name="RemotePath">The file path on the server the file will be uploaded to.</param>
    /// <param name="FileStream">The tempoary blob containing the filecontent to be uploaded.</param>
    /// <param name="FileServerRequest">The FileServerRequest specifying the connection info. Use @GetFileServerJsonRequest() to obtain this.</param>
    [TryFunction]
    internal procedure UploadFile(RemotePath: Text; var FileStream: Codeunit "Temp Blob"; FileServerRequest: JsonObject)
    var
        http: HttpClient;
        content: HttpContent;
        response: HttpResponseMessage;
        headerJson: JsonObject;
        InS: InStream;
    begin
        headerJson := FileServerRequest.Clone().AsObject();
        headerJson.Add(_JsonPath, RemotePath);
        FileStream.CreateInStream(InS);
        content.WriteFrom(InS);
        GetAFHttpClient(_FunctionAppName, 'UploadFile', FunctionAppVersion(), _AzureKeyVaultNameForSubKey, http);
        SendRequest(http, content, headerJson, response);
        if (not response.IsSuccessStatusCode()) then
            Error(_lblRequestError, Format(response.HttpStatusCode()), GetErrorMessage(response));
    end;
    /// <summary>
    /// Deletes the file located at @RemotePath on the server corresponding to the @SftpConnection. If the @RemotePath does not exist or is
    /// a directory the function fails. 
    /// </summary>
    /// <param name="RemotePath">The file on the server to be deleted.</param>
    /// <param name="SftpConnection">The SFTP Connection record specifying the connection info.</param>
    [TryFunction]
    internal procedure DeleteFile(RemotePath: Text; SftpConnection: Record "NPR SFTP Connection")
    begin
        DeleteFile(RemotePath, GetFileServerJsonRequest(SftpConnection));
    end;

    /// <summary>
    /// Deletes the file located at @RemotePath on the server corresponding to the @FileServerRequest. If the @RemotePath does not exist or is
    /// a directory the function fails. 
    /// </summary>
    /// <param name="RemotePath">The file on the server to be deleted.</param>
    /// <param name="FileServerRequest">The JsonObject specifying the connection info. Use @GetFileServerJsonRequest() to obtain this.</param>
    [TryFunction]
    internal procedure DeleteFile(RemotePath: Text; FileServerRequest: JsonObject)
    var
        http: HttpClient;
        content: HttpContent;
        response: HttpResponseMessage;
        headerJson: JsonObject;
    begin
        headerJson := FileServerRequest.Clone().AsObject();
        headerJson.Add(_JsonPath, RemotePath);
        GetAFHttpClient(_FunctionAppName, 'DeleteFile', FunctionAppVersion(), _AzureKeyVaultNameForSubKey, http);
        SendRequest(http, content, headerJson, response);
        if (not response.IsSuccessStatusCode()) then
            Error(_lblRequestError, Format(response.HttpStatusCode()), GetErrorMessage(response));
    end;

    /// <summary>
    /// Moves the file located at @RemotePath to @RemoteNewPath on server corresponding to @SftpConnection. If either @RemotePath
    /// or @RemoteNewPath is a directory (i.e. ends with a folder seperator) the function fails. If the Force behavior is set to false
    /// and a file already is located at @RemoteNewPath then function fails otherwise it overwrites the file. If the @RemoteNewPath is
    /// located in a folder that do not exist, the SFTP Client will try to create these folders.
    /// </summary>
    /// <param name="RemotePath">The file on the server to be moved.</param>
    /// <param name="RemoteNewPath">The new file name and or location @RemotePath will be moved to.</param>
    /// <param name="SftpConnection">The SFTP Connection record specifying the connection info.</param>
    [TryFunction]
    internal procedure MoveFile(RemotePath: Text; RemoteNewPath: Text; SftpConnection: Record "NPR SFTP Connection")
    begin
        MoveFile(RemotePath, RemoteNewPath, GetFileServerJsonRequest(SftpConnection));
    end;

    /// <summary>
    /// Moves the file located at @RemotePath to @RemoteNewPath on server corresponding to @FileServerRequest. If either @RemotePath
    /// or @RemoteNewPath is a directory (i.e. ends with a folder seperator) the function fails. If the Force behavior is set to false
    /// and a file already is located at @RemoteNewPath then function fails otherwise it overwrites the file. If the @RemoteNewPath is
    /// located in a folder that do not exist, the SFTP Client will try to create these folders.
    /// </summary>
    /// <param name="RemotePath">The file on the server to be moved.</param>
    /// <param name="RemoteNewPath">The new file name and or location @RemotePath will be moved to.</param>
    /// <param name="FileServerRequest">The JsonObject specifying the connection info. Use @GetFileServerJsonRequest() to obtain this.</param>
    [TryFunction]
    internal procedure MoveFile(RemotePath: Text; RemoteNewPath: Text; FileServerRequest: JsonObject)
    var
        http: HttpClient;
        content: HttpContent;
        response: HttpResponseMessage;
        headerJson: JsonObject;
    begin
        headerJson := FileServerRequest.Clone().AsObject();
        headerJson.Add(_JsonPath, RemotePath);
        headerJson.Add(_JsonNewPath, RemoteNewPath);
        GetAFHttpClient(_FunctionAppName, 'MoveFile', FunctionAppVersion(), _AzureKeyVaultNameForSubKey, http);
        SendRequest(http, content, headerJson, response);
        if (not response.IsSuccessStatusCode()) then
            Error(_lblRequestError, Format(response.HttpStatusCode()), GetErrorMessage(response));
    end;
    /// <summary>
    /// Lists the content of the directoy located at @RemotePath on the server corresponding to @SftpConnection
    /// and inserts this content (files and directories).
    /// </summary>
    /// <param name="RemotePath">The directory which contents will be listed in @DirList</param>
    /// <param name="DirList">A Json Array containing objects with one string property "Name" and 
    /// a boolean property "IsDirectory".</param>
    /// <param name="SftpConnection">The SFTP Connection record specifying the connection info.</param>
    [TryFunction]
    internal procedure ListDirectory(RemotePath: Text; var DirList: JsonArray; SftpConnection: Record "NPR SFTP Connection")
    begin
        ListDirectory(RemotePath, DirList, GetFileServerJsonRequest(SftpConnection));
    end;
    /// <summary>
    /// Lists the content of the directoy located at @RemotePath on the server corresponding to @FileServerRequest
    /// and inserts this content (files and directories). The function fails if a valid directory is not found or
    /// if the @RemotePath does not end in a folder seperator.
    /// </summary>
    /// <param name="RemotePath">The directory which contents will be listed in @DirList</param>
    /// <param name="DirList">A Json Array containing objects with one string property "Name" and 
    /// a boolean property "IsDirectory".</param>
    /// <param name="FileServerRequest">The JsonObject specifying the connection info. Use @GetFileServerJsonRequest() to obtain this.</param>
    [TryFunction]
    internal procedure ListDirectory(RemotePath: Text; var DirList: JsonArray; FileServerRequest: JsonObject)
    var
        http: HttpClient;
        content: HttpContent;
        response: HttpResponseMessage;
        jsonTxt: Text;
        json: JsonObject;
        token: JsonToken;
        headerJson: JsonObject;
    begin
        headerJson := FileServerRequest.Clone().AsObject();
        headerJson.Add(_JsonPath, RemotePath);
        GetAFHttpClient(_FunctionAppName, 'ListDirectory', FunctionAppVersion(), _AzureKeyVaultNameForSubKey, http);
        SendRequest(http, content, headerJson, response);
        if (not response.IsSuccessStatusCode()) then
            Error(_lblRequestError, Format(response.HttpStatusCode()), GetErrorMessage(response));
        response.Content.ReadAs(jsonTxt);
        json.ReadFrom(jsonTxt);
        json.Get('FileList', token);
        DirList := token.AsArray();
    end;
    /// <summary>
    /// Creates a new directory @RemotePath at the server spcified by the @SftpConnection. If a directory
    /// is specified where some subfolder are not specified the SFTPClient will try ot create them. 
    /// if the @RemotePath does not end with a path seperator the function fails.
    /// </summary>
    /// <param name="RemotePath">The Directory to be created on the file server.</param>
    /// <param name="SftpConnection">The SFTP Connection record specifying the connection info.</param>
    [TryFunction]
    internal procedure CreateDirectory(RemotePath: Text; SftpConnection: Record "NPR SFTP Connection")
    begin
        CreateDirectory(RemotePath, GetFileServerJsonRequest(SftpConnection));
    end;
    /// <summary>
    /// Creates a new directory @RemotePath at the server spcified by the @FileServerRequest. If a directory
    /// is specified where some subfolder are not specified the SFTPClient will try ot create them. 
    /// if the @RemotePath does not end with a path seperator the function fails.
    /// </summary>
    /// <param name="RemotePath">The Directory to be created on the file server.</param>
    /// <param name="FileServerRequest">The JsonObject specifying the connection info. Use @GetFileServerJsonRequest() to obtain this.</param>
    [TryFunction]
    internal procedure CreateDirectory(RemotePath: Text; FileServerRequest: JsonObject)
    var
        http: HttpClient;
        content: HttpContent;
        response: HttpResponseMessage;
        headerJson: JsonObject;
    begin
        headerJson := FileServerRequest.Clone().AsObject();
        headerJson.Add(_JsonPath, RemotePath);
        GetAFHttpClient(_FunctionAppName, 'CreateDirectory', FunctionAppVersion(), _AzureKeyVaultNameForSubKey, http);
        SendRequest(http, content, headerJson, response);
        if (not response.IsSuccessStatusCode()) then
            Error(_lblRequestError, Format(response.HttpStatusCode()), GetErrorMessage(response));
    end;
    /// <summary>
    /// Deletes a te directory @RemotePath at the server spcified by the @SftpConnection.
    /// If the directory does not exist the function fails. If the directory has content and the
    /// Force behavior is set to false, then the function fails.
    /// if the @RemotePath does not end with a path seperator the function fails.
    /// </summary>
    /// <param name="RemotePath">The Directory to be deleted on the file server.</param>
    /// <param name="SftpConnection">The SFTP Connection record specifying the connection info.</param>
    [TryFunction]
    internal procedure DeleteDirectory(RemotePath: Text; SftpConnection: Record "NPR SFTP Connection")
    begin
        DeleteDirectory(RemotePath, GetFileServerJsonRequest(SftpConnection));
    end;
    /// <summary>
    /// Deletes a te directory @RemotePath at the server spcified by the @SftpConnection.
    /// If the directory does not exist the function fails. If the directory has content and the
    /// Force behavior is set to false, then the function fails.
    /// if the @RemotePath does not end with a path seperator the function fails.
    /// </summary>
    /// <param name="RemotePath">The Directory to be deleted on the file server.</param>
    /// <param name="FileServerRequest">The JsonObject specifying the connection info. Use @GetFileServerJsonRequest() to obtain this.</param>
    [TryFunction]
    internal procedure DeleteDirectory(RemotePath: Text; FileServerRequest: JsonObject)
    var
        http: HttpClient;
        content: HttpContent;
        response: HttpResponseMessage;
        headerJson: JsonObject;
    begin
        headerJson := FileServerRequest.Clone().AsObject();
        headerJson.Add(_JsonPath, RemotePath);
        GetAFHttpClient(_FunctionAppName, 'DeleteDirectory', FunctionAppVersion(), _AzureKeyVaultNameForSubKey, http);
        SendRequest(http, content, headerJson, response);
        if (not response.IsSuccessStatusCode()) then
            Error(_lblRequestError, Format(response.HttpStatusCode()), GetErrorMessage(response));
    end;

    local procedure SendRequest(Http: HttpClient; Content: HttpContent; FileServerRequest: JsonObject; var Response: HttpResponseMessage)
    var
        jsonTxt: Text;
    begin
        FileServerRequest.WriteTo(jsonTxt);
        Http.DefaultRequestHeaders().Add(_HttpHeaderName, jsonTxt);
        Http.Post('', Content, Response);
    end;

    local procedure GetErrorMessage(response: HttpResponseMessage): Text
    var
        txt: Text;
        json: JsonObject;
        tok: JsonToken;
    begin
        response.Content.ReadAs(txt);
        json.ReadFrom(txt);
        json.Get('ErrorMessage', tok);
        exit(tok.AsValue().AsText());
    end;

    [NonDebuggable]
    local procedure GetAFHttpClient(
        FunctionAppName: Text;
        AFAppAction: Text;
        AppVersion: Integer;
        AzureVaultKeyNameForSubscription: Text;
        var http: HttpClient)
    var
        AFVault: Codeunit "NPR Azure Key Vault Mgt.";
        AzureApiUrl: Label 'https://navipartner.azure-api.net', Locked = true;
        Url: Text;
    begin
        Url := AzureApiUrl + '/' + FunctionAppName + '/v' + Format(AppVersion) + '/' + AFAppAction + '/';
        http.SetBaseAddress(Url);
        http.DefaultRequestHeaders().Add('Ocp-Apim-Subscription-Key', AFVault.GetAzureKeyVaultSecret(AzureVaultKeyNameForSubscription));
    end;
}

