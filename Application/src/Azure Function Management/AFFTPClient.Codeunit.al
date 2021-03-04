codeunit 6151611 "NPR AF FTP Client"
{
    var
        //CodeUnit variables
        FtpClient: HttpClient;
        gConvert: Codeunit "Base64 Convert";
        gAzureKeyVault: Codeunit "NPR Azure Key Vault Mgt.";
        //CodeUnit Constants
        gHttpUrlConst, gHttpUsernameConst, gHttpPasswordConst, gHttpPortConst, gHttpFilePathConst : Text;
        gHttpPathConst, gHttpFileContentConst, gHttpTimeoutMsConst, gHttpHostKey : Text;
        gErrorConst, gErrMsg_Post_Fail, gErrMsg_Parse_Fail : Text;
        gResponseMsg_StatusCode, gResponseMsg_ServerJson : Text;
        //ftpParameters
        gHost, gUsername, gPassword : Text;
        gPort, gTimeoutMs : Integer;

    procedure Construct(Host: Text; Username: Text; Password: Text; Port: Integer; TimeoutMs: Integer)
    begin
        CommonConstruct(Host, Username, Password, Port, TimeoutMs);
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
        baseurl := gAzureKeyVault.GetSecret('FtpAzureFunctionUrl');
        FtpClient.SetBaseAddress(baseurl);
        gHttpUrlConst := 'url';
        gHttpUsernameConst := 'username';
        gHttpPasswordConst := 'password';
        gHttpPortConst := 'port';
        gHttpPathConst := 'path';
        gHttpFilePathConst := 'filepath';
        gHttpFileContentConst := 'filecontent';
        gHttpTimeoutMsConst := 'timeoutms';
        gErrMsg_Post_Fail := 'Post request failed';
        gErrMsg_Parse_Fail := 'Parsing of input failed';
        gResponseMsg_StatusCode := 'StatusCode';
        gResponseMsg_ServerJson := 'ServerMsg';
        gErrorConst := 'Error';
        gHttpHostKey := gAzureKeyVault.GetSecret('FtpAzureFunction');

    end;

    procedure Destruct()
    begin
        FtpClient.Clear();
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
    procedure RenameFile(CurrentRemotePath: Text; NewRemotePath: Text): JsonObject
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
            reqContent.Add('newname', NewRemotePath) and
            reqContent.WriteTo(jsonTxt)
        ) then begin
            content.WriteFrom(jsonTxt);
            exit(HandlePostRequest('RenameFile', content));
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
    ///     "Directory": boolean}, ...
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
        httpResponse: HttpResponseMessage;
        jsonTxt: Text;
        jsonResult: JsonObject;
        statusCode: Integer;
        azFuncWQuery: Text;
    begin
        azFuncWQuery := AZFunction + '?code=' + gHttpHostKey;
        if not FtpClient.Post(azFuncWQuery, Content, httpResponse) then
            jsonResult.Add(gErrorConst, gErrMsg_Post_Fail);

        if httpResponse.IsSuccessStatusCode then begin
            httpResponse.Content.ReadAs(jsonTxt);
            jsonResult.ReadFrom(jsonTxt);
            statusCode := httpResponse.HttpStatusCode;
            jsonResult.Add(gResponseMsg_StatusCode, statusCode);
        end else begin
            statusCode := httpResponse.HttpStatusCode;
            jsonResult.Add(gResponseMsg_StatusCode, statusCode);
            jsonResult.Add(gErrorConst, gErrMsg_Post_Fail);
        end;

        exit(jsonResult);
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
            returnVal := (returnVal and reqContent.Add(gHttpTimeoutMsConst, gTimeoutMs));
        end;
        exit(returnVal);
    end;
}

