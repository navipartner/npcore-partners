codeunit 6151394 "NPR Sftp Api"
{
    Access = Public;

    var
        _SftpClient: Codeunit "NPR AF SFTP Client";

    /// <summary>
    /// Downloads the specified file located at @RemotedPath on the file server corresponding to the @SftpConnection into the @FileStream.
    /// </summary>
    /// <param name="RemotePath">File location on server from root folder. (If just file name is five e.g. 'file.xml' then it will default to '/file.xml'
    ///  and error occours if the @RemotePath ends is a Path seperator.</param>
    /// <param name="FileStream">Temporay blob where the file contents will be written too.</param>
    /// <param name="SftpConnection">SFTP Connection record specifying File Server Connection info.</param>
    [TryFunction]
    procedure DownloadFile(RemotePath: Text; var FileStream: Codeunit "Temp Blob"; SftpConnection: Record "NPR SFTP Connection")
    begin
        _SftpClient.DownloadFile(RemotePath, FileStream, SftpConnection);
    end;

    /// <summary>
    /// Downloads the specified file located at @RemotedPath on the file server corresponding to the parameters into the @FileStream.
    /// </summary>
    /// <param name="RemotePath">File location on server from root folder. (If just file name is five e.g. 'file.xml' then it will default to '/file.xml'
    ///  and error occours if the @RemotePath ends is a Path seperator.</param>
    /// <param name="FileStream">Temporay blob where the file contents will be written too.</param>
    /// <param name="Server">The hostname / ip-address of the file server.</param>
    /// <param name="Port">The port used fot SFTP on the file server.</param>
    /// <param name="Username">Username used to login on the file server.</param>
    /// <param name="Password">Password used to login on the file server.</param>
    /// <param name="SSHKey">(Optional) The SSH key if the file server is configured to use SSH keys instead.</param>
    [TryFunction]
    procedure DownloadFile(RemotePath: Text; var FileStream: Codeunit "Temp Blob"; Server: Text; Port: Integer; Username: Text; Password: Text; SSHKey: Text)
    var
        json: JsonObject;
    begin
        json := _SftpClient.GetFileServerJsonRequest(Server, Port, Username, Password, SSHKey, False);
        _SftpClient.DownloadFile(RemotePath, FileStream, json);
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
    procedure UploadFile(RemotePath: Text; var FileStream: Codeunit "Temp Blob"; SftpConnection: Record "NPR SFTP Connection")
    begin
        _SftpClient.UploadFile(RemotePath, FileStream, SftpConnection);
    end;
    /// <summary>
    /// Uploads the content of @FileStream into a new file @RemotePath on the server corresponding to the parameters. If Force behavior is
    /// set to false on the SFTP Connection record and a file already exists at @RemotePath the function will fail. If @RemotePath file is located in a folder
    /// that do not yet exist the SFTP Client will attempt to create the subfolders and upload the file.
    /// </summary>
    /// <param name="RemotePath">The file path on the server the file will be uploaded to.</param>
    /// <param name="FileStream">The tempoary blob containing the filecontent to be uploaded.</param>
    /// <param name="Server">The hostname / ip-address of the file server.</param>
    /// <param name="Port">The port used fot SFTP on the file server.</param>
    /// <param name="Username">Username used to login on the file server.</param>
    /// <param name="Password">Password used to login on the file server.</param>
    /// <param name="SSHKey">(Optional) The SSH key if the file server is configured to use SSH keys instead.</param>
    /// <param name="ForceBehavior">Boolean specifying if the SFTPClient should force behavior, such as deleting non-empty directories and overwriting files.</param>
    [TryFunction]
    procedure UploadFile(RemotePath: Text; var FileStream: Codeunit "Temp Blob"; Server: Text; Port: Integer; Username: Text; Password: Text; SSHKey: Text; ForceBehavior: Boolean)
    var
        json: JsonObject;
    begin
        json := _SftpClient.GetFileServerJsonRequest(Server, Port, Username, Password, SSHKey, ForceBehavior);
        _SftpClient.UploadFile(RemotePath, FileStream, json);
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
    procedure MoveFile(RemotePath: Text; RemoteNewPath: Text; SftpConnection: Record "NPR SFTP Connection")
    begin
        _SftpClient.MoveFile(RemotePath, RemoteNewPath, SftpConnection);
    end;

    /// <summary>
    /// Moves the file located at @RemotePath to @RemoteNewPath on server corresponding to parameters. If either @RemotePath
    /// or @RemoteNewPath is a directory (i.e. ends with a folder seperator) the function fails. If the Force behavior is set to false
    /// and a file already is located at @RemoteNewPath then function fails otherwise it overwrites the file. If the @RemoteNewPath is
    /// located in a folder that do not exist, the SFTP Client will try to create these folders.
    /// </summary>
    /// <param name="RemotePath">The file on the server to be moved.</param>
    /// <param name="RemoteNewPath">The new file name and or location @RemotePath will be moved to.</param>
    /// <param name="Server">The hostname / ip-address of the file server.</param>
    /// <param name="Port">The port used fot SFTP on the file server.</param>
    /// <param name="Username">Username used to login on the file server.</param>
    /// <param name="Password">Password used to login on the file server.</param>
    /// <param name="SSHKey">(Optional) The SSH key if the file server is configured to use SSH keys instead.</param>
    /// <param name="ForceBehavior">Boolean specifying if the SFTPClient should force behavior, such as deleting non-empty directories and overwriting files.</param>
    [TryFunction]
    procedure MoveFile(RemotePath: Text; RemoteNewPath: Text; Server: Text; Port: Integer; Username: Text; Password: Text; SSHKey: Text; ForceBehavior: Boolean)
    var
        json: JsonObject;
    begin
        json := _SftpClient.GetFileServerJsonRequest(Server, Port, Username, Password, SSHKey, ForceBehavior);
        _SftpClient.MoveFile(RemotePath, RemoteNewPath, json);
    end;

    /// <summary>
    /// Deletes the file located at @RemotePath on the server corresponding to the @SftpConnection. If the @RemotePath does not exist or is
    /// a directory the function fails. 
    /// </summary>
    /// <param name="RemotePath">The file on the server to be deleted.</param>
    /// <param name="SftpConnection">The SFTP Connection record specifying the connection info.</param>
    [TryFunction]
    procedure DeleteFile(Path: Text; SftpConnection: Record "NPR SFTP Connection")
    begin
        _SftpClient.DeleteFile(Path, SftpConnection);
    end;

    /// <summary>
    /// Deletes the file located at @RemotePath on the server corresponding to the parameters. If the @RemotePath does not exist or is
    /// a directory the function fails. 
    /// </summary>
    /// <param name="RemotePath">The file on the server to be deleted.</param>
    /// <param name="Server">The hostname / ip-address of the file server.</param>
    /// <param name="Port">The port used fot SFTP on the file server.</param>
    /// <param name="Username">Username used to login on the file server.</param>
    /// <param name="Password">Password used to login on the file server.</param>
    /// <param name="SSHKey">(Optional) The SSH key if the file server is configured to use SSH keys instead.</param>
    [TryFunction]
    procedure DeleteFile(RemotePath: Text; Server: Text; Port: Integer; Username: Text; Password: Text; SSHKey: Text)
    var
        json: JsonObject;
    begin
        json := _SftpClient.GetFileServerJsonRequest(Server, Port, Username, Password, SSHKey, False);
        _SftpClient.DeleteFile(RemotePath, json);
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
    procedure ListDirectory(RemotePath: Text; var DirList: JsonArray; SftpConnection: Record "NPR SFTP Connection")
    begin
        _SftpClient.ListDirectory(RemotePath, DirList, SftpConnection);
    end;

    /// <summary>
    /// Lists the content of the directoy located at @RemotePath on the server corresponding to parameters
    /// and inserts this content (files and directories).
    /// </summary>
    /// <param name="RemotePath">The directory which contents will be listed in @DirList</param>
    /// <param name="DirList">A Json Array containing objects with one string property "Name" and 
    /// a boolean property "IsDirectory".</param>
    /// <param name="Server">The hostname / ip-address of the file server.</param>
    /// <param name="Port">The port used fot SFTP on the file server.</param>
    /// <param name="Username">Username used to login on the file server.</param>
    /// <param name="Password">Password used to login on the file server.</param>
    /// <param name="SSHKey">(Optional) The SSH key if the file server is configured to use SSH keys instead.</param>
    [TryFunction]
    procedure ListDirectory(RemotePath: Text; var DirList: JsonArray; Server: Text; Port: Integer; Username: Text; Password: Text; SSHKey: Text)
    var
        json: JsonObject;
    begin
        json := _SftpClient.GetFileServerJsonRequest(Server, Port, Username, Password, SSHKey, False);
        _SftpClient.ListDirectory(RemotePath, DirList, json);
    end;

    /// <summary>
    /// Creates a new directory @RemotePath at the server spcified by the @SftpConnection. If a directory
    /// is specified where some subfolder are not specified the SFTPClient will try ot create them. 
    /// if the @RemotePath does not end with a path seperator the function fails.
    /// </summary>
    /// <param name="RemotePath">The Directory to be created on the file server.</param>
    /// <param name="SftpConnection">The SFTP Connection record specifying the connection info.</param>
    [TryFunction]
    procedure CreateDirectory(RemotePath: Text; SftpConnection: Record "NPR SFTP Connection")
    begin
        _SftpClient.CreateDirectory(RemotePath, SftpConnection);
    end;

    /// <summary>
    /// Creates a new directory @RemotePath at the server spcified by the parameters. If a directory
    /// is specified where some subfolder are not specified the SFTPClient will try ot create them. 
    /// if the @RemotePath does not end with a path seperator the function fails.
    /// </summary>
    /// <param name="RemotePath">The Directory to be created on the file server.</param>
    /// <param name="Server">The hostname / ip-address of the file server.</param>
    /// <param name="Port">The port used fot SFTP on the file server.</param>
    /// <param name="Username">Username used to login on the file server.</param>
    /// <param name="Password">Password used to login on the file server.</param>
    /// <param name="SSHKey">(Optional) The SSH key if the file server is configured to use SSH keys instead.</param>
    [TryFunction]
    procedure CreateDirectory(RemotePath: Text; Server: Text; Port: Integer; Username: Text; Password: Text; SSHKey: Text)
    var
        json: JsonObject;
    begin
        json := _SftpClient.GetFileServerJsonRequest(Server, Port, Username, Password, SSHKey, False);
        _SftpClient.CreateDirectory(RemotePath, json);
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
    procedure DeleteDirectory(RemotePath: Text; SftpConnection: Record "NPR SFTP Connection")
    begin
        _SftpClient.DeleteDirectory(RemotePath, SftpConnection);
    end;

    /// <summary>
    /// Deletes a te directory @RemotePath at the server spcified by the parameters.
    /// If the directory does not exist the function fails. If the directory has content and the
    /// Force behavior is set to false, then the function fails.
    /// if the @RemotePath does not end with a path seperator the function fails.
    /// </summary>
    /// <param name="RemotePath">The Directory to be deleted on the file server.</param>
    /// <param name="Server">The hostname / ip-address of the file server.</param>
    /// <param name="Port">The port used fot SFTP on the file server.</param>
    /// <param name="Username">Username used to login on the file server.</param>
    /// <param name="Password">Password used to login on the file server.</param>
    /// <param name="SSHKey">(Optional) The SSH key if the file server is configured to use SSH keys instead.</param>
    /// <param name="ForceBehavior">Boolean specifying if the SFTPClient should force behavior, such as deleting non-empty directories and overwriting files.</param>
    [TryFunction]
    procedure DeleteDirectory(RemotePath: Text; Server: Text; Port: Integer; Username: Text; Password: Text; SSHKey: Text; ForceBehavior: Boolean)
    var
        json: JsonObject;
    begin
        json := _SftpClient.GetFileServerJsonRequest(Server, Port, Username, Password, SSHKey, ForceBehavior);
        _SftpClient.DeleteDirectory(RemotePath, json);
    end;

}