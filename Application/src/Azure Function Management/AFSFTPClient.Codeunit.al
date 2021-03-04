codeunit 6151612 "NPR AF SFTP Client"
{
    var
        //CodeUnit variables
        SftpClient: HttpClient;
        gConvert: Codeunit "Base64 Convert";
        gAzureKeyVault: Codeunit "Azure Key Vault";
        //CodeUnit Constants
        gHttpUrlConst, gHttpUsernameConst, gHttpPasswordConst, gHttpPortConst, gHttpPrivateKeyConst : Text;
        gHttpPathConst, gHttpFilePathConst, gHttpFileContentConst, gHttpTimeoutMsConst, gHttpHostKey : Text;
        gErrorConst, gErrMsg_Post_Fail, gErrMsg_Parse_Fail : Text;
        gResponseMsg_StatusCode, gResponseMsg_ServerJson : Text;
        //SftpParameters
        gHost, gUsername, gPassword, gPrivateKey : Text;
        gPort, gTimeoutMs : Integer;


    procedure Construct(Host: Text; Username: Text; Password: Text; Port: Integer; TimeoutMs: Integer)
    var

    begin
        CommonConstruct(Host, Username, Password, Port, TimeoutMs);
    end;

    procedure ConstructPrivateKey(Host: Text; Username: Text; PassPhrase: Text; PrivateKeyBase64: Text; Port: Integer; TimeoutMs: Integer)
    begin
        CommonConstruct(Host, Username, PassPhrase, Port, TimeoutMs);
        gPrivateKey := PrivateKeyBase64;
    end;

    local procedure CommonConstruct(Host: Text; Username: Text; Password: Text; Port: Integer; TimeoutMs: Integer)
    var
        baseurl: Text;
    begin
        gHost := Host;
        gUsername := Username;
        gPassword := Password;
        gPort := Port;
        gTimeoutMs := TimeoutMs;
        gAzureKeyVault.GetAzureKeyVaultSecret('SftpAzureFunctionUrl', baseurl);
        SftpClient.SetBaseAddress(baseurl);
        gHttpUrlConst := 'url';
        gHttpUsernameConst := 'username';
        gHttpPasswordConst := 'password';
        gHttpPortConst := 'port';
        gHttpPrivateKeyConst := 'privatekey';
        gHttpFilePathConst := 'filepath';
        gHttpPathConst := 'path';
        gHttpFileContentConst := 'filecontent';
        gHttpTimeoutMsConst := 'timeoutms';
        gErrMsg_Post_Fail := 'Post request failed';
        gErrMsg_Parse_Fail := 'Parsing of input failed';
        gResponseMsg_StatusCode := 'StatusCode';
        gResponseMsg_ServerJson := 'ServerMsg';
        gErrorConst := 'Error';
        gAzureKeyVault.GetAzureKeyVaultSecret('SftpAzureFunction', gHttpHostKey);
    end;

    procedure Destruct()
    begin
        SftpClient.Clear();
    end;
    /// <summary>
    /// Downloads a file from te remote server with the specified path.
    /// Return a Json Object of the form:
    /// <code>
    /// {
    ///     //On Success
    ///     "File": string,
    ///     "Base64String": string,
    ///     "Size": long,   
    ///     //On Post request reached server
    ///     "StatusCode": integer,  
    ///     //Request parsing Error
    ///     "Error": string         
    /// }
    /// </code>
    /// </summary>
    /// <param name="RemotePath">
    /// The full filepath on the remote server the file is downloaded from.
    /// </param>
    procedure DownloadFile(RemotePath: Text): JsonObject
    var
        reqContent: JsonObject;
        jsonResult: JsonObject;
        content: HttpContent;
        jsonTxt: Text;
    begin
        if
        (
            PrepareCommonHttpRequest(reqContent) and
            reqContent.Add(gHttpFilePathConst, RemotePath) and
            reqContent.WriteTo(jsonTxt)
        )
        then begin
            content.WriteFrom(jsonTxt);
            exit(HandlePostRequest('DownloadFile', content));
        end else begin
            jsonResult.Add(gErrorConst, gErrMsg_Parse_Fail);
            exit(jsonResult);
        end;
    end;

    /// <summary>
    /// Uploads a file via its content in an inputstream to a specified location
    /// on the remote server.
    /// Return a Json Object of the form:
    /// <code>
    /// {
    ///     //On Success
    ///     "Decription": string,   
    ///     //On Post request reached server
    ///     "StatusCode": integer,  
    ///     //Request parsing Error
    ///     "Error": string         
    /// }
    /// </code>
    /// </summary>
    /// <param name="FileContent">
    /// Input stream containing the contents of a file
    /// </param>
    /// <param name="RemotePath">
    /// The full filepath on the remote server where the file will be stored
    /// </param>
    procedure UploadFile(FileContent: InStream; RemotePath: Text): JsonObject
    var
        jsonTxt: Text;
        base64: Text;
        jsonResult: JsonObject;
        reqContent: JsonObject;
        content: HttpContent;
    begin
        base64 := gConvert.ToBase64(FileContent);
        if
        (
            PrepareCommonHttpRequest(reqContent) and
            reqContent.Add(gHttpFilePathConst, RemotePath) and
            reqContent.Add(gHttpFileContentConst, base64) and
            reqContent.WriteTo(jsonTxt)
        )
            then begin
            content.WriteFrom(jsonTxt);
            exit(HandlePostRequest('UploadFile', content));
        end else begin
            jsonResult.Add(gErrorConst, gErrMsg_Parse_Fail);
            exit(reqContent);
        end;
    end;
    /// <summary>
    /// Move a file from the old specified path to the new specified path on the server.
    /// Return a Json Object of the form:
    /// <code>
    /// {
    ///     //On Success
    ///     "Description": string,  
    ///     //On Post request reached server
    ///     "StatusCode": integer,  
    ///     //Request parsing Error
    ///     "Error": string         
    /// }
    /// </code>
    /// </summary>
    /// <param name="RemotePath">
    /// The full filepath on the remote server the file is moved from.
    /// </param>
    /// <param name="NewRemotePath">
    /// The full filepath on the remote server the file is moved to.
    /// </param>
    procedure MoveFile(CurrentRemotePath: Text; NewRemotePath: Text): JsonObject
    var
        reqContent: JsonObject;
        jsonTxt: Text;
        jsonResult: JsonObject;
        content: HttpContent;
    begin
        if
        (
            PrepareCommonHttpRequest(reqContent) and
            reqContent.Add(gHttpFilePathConst, CurrentRemotePath) and
            reqContent.Add('toPath', NewRemotePath) and
            reqContent.WriteTo(jsonTxt)
        ) then begin
            content.WriteFrom(jsonTxt);
            exit(HandlePostRequest('MoveFile', content));
        end else begin
            jsonResult.Add(gErrorConst, gErrMsg_Parse_Fail);
            exit(jsonResult);
        end;
    end;

    /// <summary>
    /// Deletes a file from the remote server with the specified path.
    /// Return a Json Object of the form:
    /// <code>
    /// {
    ///     //On Success
    ///     "Description": string, 
    ///     //On Post request reached server
    ///     "StatusCode": integer,  
    ///     //Request parsing Error
    ///     "Error": string         
    /// }
    /// </code>
    /// </summary>
    /// <param name="RemotePath">
    /// The full filepath on the remote server the file is deleted from.
    /// </param>
    procedure DeleteFile(RemotePath: Text): JsonObject
    var
        reqContent: JsonObject;
        jsonTxt: Text;
        jsonResult: JsonObject;
        content: HttpContent;

    begin
        if
        (
            PrepareCommonHttpRequest(reqContent) and
            reqContent.Add(gHttpFilePathConst, RemotePath) and
            reqContent.WriteTo(jsonTxt)
        )
        then begin
            content.WriteFrom(jsonTxt);
            exit(HandlePostRequest('DeleteFile', content));
        end else begin
            jsonResult.Add(gErrorConst, gErrMsg_Parse_Fail);
            exit(jsonResult);
        end;
    end;
    /// <summary>
    /// Downloads the files from the specified directory on the rmeote server
    /// with or without the recursive option.
    /// Return a Json Object of the form:
    /// <code>
    /// {
    ///     //On Success
    ///     "Files": 
    ///     [
    ///     {"File": string,
    ///     "Base64String": string,
    ///     "Size": long}, ...
    ///     ],
    ///     //On Post request reached server
    ///     "StatusCode": integer,  
    ///     //Request parsing Error
    ///     "Error": string         
    /// }
    /// </code>
    /// </summary>
    /// <param name="RemotePath">
    /// The full path where the files will be downloaded from.
    /// </param>
    /// <param name="IncludeSubFolders">
    /// The option that declares wether subfolder should be included.
    /// </param>
    procedure DownloadDirectory(RemotePath: Text; IncludeSubFolders: Boolean): JsonObject
    var
        reqContent: JsonObject;
        jsonResult: JsonObject;
        jsonTxt: Text;
        content: HttpContent;

    begin
        if CopyStr(RemotePath, StrLen(RemotePath), 1) <> '/' then
            RemotePath += '/';
        if
        (
            PrepareCommonHttpRequest(reqContent) and
            reqContent.Add(gHttpPathConst, RemotePath) and
            reqContent.Add('recursive', IncludeSubFolders) and
            reqContent.WriteTo(jsonTxt)
        )
        then begin
            content.WriteFrom(jsonTxt);
            exit(HandlePostRequest('DownloadDirectory', content));
        end else begin
            jsonResult.Add(gErrorConst, gErrMsg_Parse_Fail);
            exit(jsonResult);
        end;
    end;
    /// <summary>
    /// Deletes the specified diretory.
    /// Return a Json Object of the form:
    /// <code>
    /// {
    ///     //On Success
    ///     "Description": string,
    ///     //On Post request reached server
    ///     "StatusCode": integer,  
    ///     //Request parsing Error
    ///     "Error": string         
    /// }
    /// </code>
    /// </summary>
    /// <param name="RemotePath">
    /// The full path where the files will be downloaded from.
    /// </param>
    procedure DeleteDirectory(RemotePath: Text): JsonObject
    var
        reqContent: JsonObject;
        jsonTxt: Text;
        jsonResult: JsonObject;
        content: HttpContent;
    begin
        if
        (
            PrepareCommonHttpRequest(reqContent) and
            reqContent.Add(gHttpPathConst, RemotePath) and
            reqContent.WriteTo(jsonTxt)
        )
        then begin
            content.WriteFrom(jsonTxt);
            exit(HandlePostRequest('DeleteDirectory', content));
        end else begin
            jsonResult.Add(gErrorConst, gErrMsg_Parse_Fail);
            exit(jsonResult);
        end;
    end;
    /// <summary>
    /// Searches for a partial filename in a specified location on the remote
    /// server and returns a list of files. This list can be empty.
    /// Return a Json Object of the form:
    /// <code>
    /// {
    ///     //On Success
    ///     "Files": 
    ///     [
    ///     {"File": string,
    ///     "Base64String": string,
    ///     "Size": long}, ...
    ///     ],
    ///     //On Post request reached server
    ///     "StatusCode": integer,  
    ///     //Request parsing Error
    ///     "Error": string         
    /// }
    /// </code>
    /// </summary>
    /// <param name="RemotePath">
    /// The full path where the files will be downloaded from.
    /// </param>
    /// <param name="PartialFileName">
    /// A comma seperated string of search terms.
    /// </param>
    procedure SearchFileAndDownload(RemotePath: Text; PartialFileName: Text): JsonObject
    var
        reqContent: JsonObject;
        jsonResult: JsonObject;
        jsonTxt: Text;
        content: HttpContent;
    begin
        if CopyStr(RemotePath, StrLen(RemotePath), 1) <> '/' then
            RemotePath += '/';
        if
        (
            PrepareCommonHttpRequest(reqContent) and
            reqContent.Add(gHttpPathConst, RemotePath) and
            //Can include recursive search and download, works in azure function
            //reqContent.Add('recursive', IncludeSubFolders) and
            reqContent.WriteTo(jsonTxt)
        )
        then begin
            content.WriteFrom(jsonTxt);
            exit(HandlePostRequest('SearchFileAndDownload', content));
        end else begin
            jsonResult.Add(gErrorConst, gErrMsg_Parse_Fail);
            exit(jsonResult);
        end;
    end;
    /// <summary>
    /// Searches for a partial filename in a specified location on the remote
    /// server and returns a list of files. This list can be empty.
    /// Return a Json Object of the form:
    /// <code>
    /// {
    ///     //On Success
    ///     "Files": 
    ///     [
    ///     {"File": string,
    ///     "Directory": boolean,
    ///     "Size": long}, ...
    ///     ],
    ///     //On Post request reached server
    ///     "StatusCode": integer,  
    ///     //Request parsing Error
    ///     "Error": string         
    /// }
    /// </code>
    /// </summary>
    /// <param name="RemotePath">
    /// The full path where the files will be downloaded from.
    /// </param>
    procedure ListDirectory(RemotePath: Text): JsonObject
    var
        reqContent: JsonObject;
        jsonTxt: Text;
        jsonResult: JsonObject;
        content: HttpContent;
    begin
        if
        (
            PrepareCommonHttpRequest(reqContent) and
            reqContent.Add(gHttpPathConst, RemotePath) and
            reqContent.WriteTo(jsonTxt)
        )
        then begin
            content.WriteFrom(jsonTxt);
            exit(HandlePostRequest('ListDirectory', content));
        end else begin
            jsonResult.Add(gErrorConst, gErrMsg_Parse_Fail);
            exit(jsonResult);
        end;
    end;
    /// <summary>
    /// Creates the sppecified directory and if some part of the filepath
    /// does not exist it will create those folders as well.
    /// Return a Json Object of the form:
    /// <code>
    /// {
    ///     //On Success
    ///     "Description":string,
    ///     //On Post request reached server
    ///     "StatusCode": integer,  
    ///     //Request parsing Error
    ///     "Error": string         
    /// }
    /// </code>
    /// </summary>
    /// <param name="RemotePath">
    /// The full path where the files will be downloaded from.
    /// </param>
    procedure CreateDirectory(RemotePath: Text): JsonObject
    var
        reqContent: JsonObject;
        jsonTxt: Text;
        jsonResult: JsonObject;
        content: HttpContent;
    begin
        if
        (
            PrepareCommonHttpRequest(reqContent) and
            reqContent.Add(gHttpPathConst, RemotePath) and
            reqContent.WriteTo(jsonTxt)
        )
        then begin
            content.WriteFrom(jsonTxt);
            exit(HandlePostRequest('CreateDirectory', content));
        end else begin
            jsonResult.Add(gErrorConst, gErrMsg_Parse_Fail);
            exit(jsonResult);
        end;
    end;

    local procedure HandlePostRequest(AZFunction: Text; Content: HttpContent): JsonObject
    var
        //TODO Insert keyvault unit code
        //keyVault: Codeunit "INSERT"
        httpResponse: HttpResponseMessage;
        jsonTxt: Text;
        jsonResult: JsonObject;
        statusCode: Integer;
        azFuncWQuery: Text;
    begin
        // TODO Insert correct code
        //azFuncWQuery := AZFunction + '?code='+ keyVault.get();
        azFuncWQuery := AZFunction + '?code=' + gHttpHostKey;
        if (SftpClient.Post(azFuncWQuery, Content, httpResponse))
            then begin
            httpResponse.Content.ReadAs(jsonTxt);
            jsonResult.ReadFrom(jsonTxt);
            statusCode := httpResponse.HttpStatusCode;
            jsonResult.Add(gResponseMsg_StatusCode, statusCode);
            exit(jsonResult);
        end else begin
            jsonResult.Add(gErrorConst, gErrMsg_Post_Fail);
            exit(jsonResult);
        end;
    end;

    local procedure PrepareCommonHttpRequest(var reqContent: JsonObject): Boolean
    var
        returnVal: Boolean;
    begin
        returnVal :=
        (
            reqContent.Add(gHttpUrlConst, gHost) and
            reqContent.Add(gHttpUsernameConst, gUsername) and
            reqContent.Add(gHttpPasswordConst, gPassword) and
            reqContent.Add(gHttpPortConst, gPort)
        );
        if (gTimeoutMs <> -1)
        then begin
            returnVal := (returnVal and reqContent.Add(gHttpTimeoutMsConst, gHost));
        end;
        if (gPrivateKey <> '')
        then begin
            returnVal := (returnVal and reqContent.Add(gHttpPrivateKeyConst, gPrivateKey));
        end;
        exit(returnVal);
    end;
}

