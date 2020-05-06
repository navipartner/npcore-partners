codeunit 6184860 "Dropbox API Mgt."
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created


    trigger OnRun()
    begin
    end;

    var
        StorageDescriptionCaption: Label 'DropBox storage';
        UploadDescriptionCaption: Label 'Upload file to DropBox from server';
        DownloadDescriptionCaption: Label 'Download file from DropBox to server';
        DeleteDescriptionCaption: Label 'Delete file from DropBox';
        ListDescriptionCaption: Label 'Get list of all files and their locations on DropBox';
        ListCaption: Label 'LIST';
        OverviewCaption: Label 'OVERVIEW';
        UploadCaption: Label 'UPLOAD';
        DownloadCaption: Label 'DOWNLOAD';
        DeleteCaption: Label 'DELETE';
        RefreshCaption: Label 'Refresh';
        ListParamDescriptionCaption: Label '(Optional) logical (1/0 or true/false or t/f) parameter to update %1, refreshing will remove entries no longer in storage, default set to false';
        UploadLocationCaption: Label 'Location on storage';
        LocationOnStorageDescCaption: Label '(Optional) input location on storage to upload the file, example: /folder1/folder11  or /folder1';
        UploadFromCaption: Label 'NAV server file';
        UploadFromDescCaption: Label '(Optional) input file path [and name] on the NAV server, example: c:\folder1\folder11\  or c:\folder1\folder11\myFile.txt';
        DownloadFileCaption: Label 'Full file path [and name]';
        FileDescCaption: Label '(Optional) input full file path [and name] on storage, example: /folder1/  or /folder1/myFile.txt';
        DeleteFileCaption: Label 'Full file path [and name]';
        OverviewDescriptionCaption: Label 'Open the %1';
        UploadAllCaption: Label 'Reupload existing files';
        UploadAllDescCaption: Label '(Optional)  logical (1/0 or true/false or t/f) case true, all files on the NAV server directory will be uploaded, else Overview table will be consulted for new files only. Default is false.';
        DataExchTypeCaption: Label 'Data exchange type';
        DataExchTypeDescCaption: Label '(Optional) Providing the Data Exchange Type (see Data Exchange Types page, Code field) will create an incoming document instead of downloading it to the server';

    procedure StorageType(): Code[20]
    begin
        exit('DROPBOX');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184866, 'OnDiscoverStorage', '', false, false)]
    procedure OnDiscoverStorage(var TempStorageTypes: Record "Storage Type" temporary)
    begin
        TempStorageTypes."Storage Type" := StorageType();
        TempStorageTypes.Description := StorageDescriptionCaption;
        TempStorageTypes.Codeunit := CODEUNIT::"Dropbox API Mgt.";

        TempStorageTypes.Insert;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184866, 'OnDiscoverStorageOperation', '', false, false)]
    procedure OnDiscoverStorageOperation(var TempStorageOperationtypes: Record "Storage Operation Type" temporary)
    var
        DropBoxOverview: Record "DropBox Overview";
    begin
        with TempStorageOperationtypes do begin
          Init;
          "Storage Type" := StorageType();
          Description := UploadDescriptionCaption;
          "Operation Code" := UploadCaption;
          Insert;

          Init;
          "Storage Type" := StorageType();
          Description := DownloadDescriptionCaption;
          "Operation Code" := DownloadCaption;
          Insert;

          Init;
          "Storage Type" := StorageType();
          Description := DeleteDescriptionCaption;
          "Operation Code" := DeleteCaption;
          Insert;

          Init;
          "Storage Type" := StorageType();
          Description := ListDescriptionCaption;
          "Operation Code" := ListCaption;
          Insert;

          Init;
          "Storage Type" := StorageType();
          Description := StrSubstNo(OverviewDescriptionCaption, DropBoxOverview.TableCaption);
          "Operation Code" := OverviewCaption;
          Insert;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184866, 'OnDiscoverStorageOperationParameters', '', false, false)]
    procedure OnDiscoverStorageOperationParameters(var TempStorageOperationParameter: Record "Storage Operation Parameter" temporary)
    var
        DropBoxOverview: Page "DropBox Overview";
    begin
        with TempStorageOperationParameter do begin
          Init;
          "Storage Type" := StorageType();
          "Operation Code" := ListCaption;
          "Parameter Key" := 100;
          "Parameter Name" := RefreshCaption;
          Description := StrSubstNo(ListParamDescriptionCaption, DropBoxOverview.Caption);
          if Insert then;

          Init;
          "Storage Type" := StorageType();
          "Operation Code" := UploadCaption;
          "Parameter Key" := 100;
          "Parameter Name" := UploadFromCaption;
          Description := UploadFromDescCaption;
          "Mandatory For Job Queue" := true;
          if Insert then;

          Init;
          "Storage Type" := StorageType();
          "Operation Code" := UploadCaption;
          "Parameter Key" := 200;
          "Parameter Name" := UploadLocationCaption;
          Description := LocationOnStorageDescCaption;
          "Mandatory For Job Queue" := true;
          if Insert then;

          Init;
          "Storage Type" := StorageType();
          "Operation Code" := UploadCaption;
          "Parameter Key" := 300;
          "Parameter Name" := UploadAllCaption;
          Description := UploadAllDescCaption;
          if Insert then;

          Init;
          "Storage Type" := StorageType();
          "Operation Code" := DownloadCaption;
          "Parameter Key" := 100;
          "Parameter Name" := DownloadFileCaption;
          Description := FileDescCaption;
          "Mandatory For Job Queue" := true;
          if Insert then;

          Init;
          "Storage Type" := StorageType();
          "Operation Code" := DownloadCaption;
          "Parameter Key" := 200;
          "Parameter Name" := DataExchTypeCaption;
          Description := DataExchTypeDescCaption;
          if Insert then;

          Init;
          "Storage Type" := StorageType();
          "Operation Code" := DeleteCaption;
          "Parameter Key" := 100;
          "Parameter Name" := DeleteFileCaption;
          Description := FileDescCaption;
          "Mandatory For Job Queue" := true;
          if Insert then;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184866, 'OnConfigureSetup', '', false, false)]
    procedure OnStorageConfiguration(var StorageSetup: Record "Storage Setup")
    var
        DropBoxAPISetup: Record "DropBox API Setup";
    begin
        if StorageSetup."Storage Type" <> StorageType() then
          exit;

        if PAGE.RunModal(PAGE::"DropBox Setup", DropBoxAPISetup) <> ACTION::LookupOK then
          exit;

        StorageSetup."Storage ID" :=  DropBoxAPISetup."Account Code";
        StorageSetup.Description := DropBoxAPISetup.Description;
    end;

    procedure ListFolderFilesContinueDropBox(AccountCode: Code[10];var Cursor: Text;var Paths: DotNet npNetXmlDocument;File: Boolean;Silent: Boolean)
    var
        DropBoxSetup: Record "DropBox API Setup";
        TempBlob: Record TempBlob;
        RequestManagement: Codeunit "Request Management";
        Arguments: Text;
        CustomResponse: Text;
        Response: Text;
        HasMore: Text;
        PropertyValue: Text;
        OutStr: OutStream;
        HttpWebRequest: DotNet npNetHttpWebRequest;
        NewPaths: DotNet npNetXmlDocument;
        Path: DotNet npNetXmlElement;
        Convert: DotNet npNetConvert;
    begin
        DropBoxSetup.Get(AccountCode);

        RequestManagement.JsonAdd(Arguments, 'cursor', Cursor, false);

        HttpWebRequest := HttpWebRequest.Create('https://api.dropboxapi.com/2/files/list_folder/continue');
        HttpWebRequest.Timeout := DropBoxSetup.Timeout;
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType('application/json');
        HttpWebRequest.Headers.Add('Authorization', 'Bearer ' + DropBoxSetup.GetToken());

        TempBlob.Blob.CreateOutStream(OutStr);
        OutStr.Write(Arguments);

        RequestManagement.StreamToHttpRequest(HttpWebRequest, TempBlob, StrLen(Arguments));

        if not RequestManagement.HandleHttpRequest(HttpWebRequest, Response, Silent) then
          exit;

        if File then
          PropertyValue := 'file'
        else
          PropertyValue := 'folder';

        RequestManagement.ReplaceSubstringAnyLength(Response, CustomResponse, '".tag"', '"tag"');
        RequestManagement.GetXMLFromJsonArray(Response, NewPaths, 'entries', 'path_display', 'tag', PropertyValue);

        if File then
          foreach Path in NewPaths.SelectNodes('/root/*') do
            InsertDropBoxOverview(AccountCode, Path.InnerText);

        HasMore := RequestManagement.GetJsonValueByPropertyNameSingleNode(Response, 'has_more');
        RequestManagement.AppendXML(NewPaths, '', Paths);

        if HasMore > '' then
          if Convert.ToBoolean(HasMore) then begin
            Cursor := RequestManagement.GetJsonValueByPropertyNameSingleNode(Response, 'cursor');

            ListFolderFilesContinueDropBox(AccountCode, Cursor, Paths, File, Silent);
          end;
    end;

    procedure ListFolderFilesDropBox(AccountCode: Code[10];DirectoryPath: Text;var Cursor: Text;var Paths: DotNet npNetXmlDocument;FullRefresh: Boolean;File: Boolean;Silent: Boolean): Boolean
    var
        DropBoxSetup: Record "DropBox API Setup";
        TempBlob: Record TempBlob;
        RequestManagement: Codeunit "Request Management";
        Response: Text;
        CustomResponse: Text;
        Arguments: Text;
        HasMore: Text;
        PropertyValue: Text;
        OutStr: OutStream;
        HttpWebRequest: DotNet npNetHttpWebRequest;
        Path: DotNet npNetXmlNode;
        Convert: DotNet npNetConvert;
    begin
        DropBoxSetup.Get(AccountCode);
        if FullRefresh then
          RemoveDropBoxOverview(AccountCode, '');

        RequestManagement.JsonAdd(Arguments, 'path' , DirectoryPath, false);
        RequestManagement.JsonAdd(Arguments, 'recursive' , true, false);
        RequestManagement.JsonAdd(Arguments, 'include_deleted' , false, false);
        RequestManagement.JsonAdd(Arguments, 'include_has_explicit_shared_members' , false, false);
        RequestManagement.JsonAdd(Arguments, 'include_mounted_folders' , true, false);
        RequestManagement.JsonAdd(Arguments, 'include_non_downloadable_files' , true, false);

        HttpWebRequest := HttpWebRequest.Create('https://api.dropboxapi.com/2/files/list_folder');
        HttpWebRequest.Timeout := DropBoxSetup.Timeout;
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType('application/json');
        HttpWebRequest.Headers.Add('Authorization', 'Bearer ' + DropBoxSetup.GetToken());

        TempBlob.Blob.CreateOutStream(OutStr);
        OutStr.Write(Arguments);

        RequestManagement.StreamToHttpRequest(HttpWebRequest, TempBlob, StrLen(Arguments));

        if not RequestManagement.HandleHttpRequest(HttpWebRequest, Response, Silent) then
          exit;

        if File then
          PropertyValue := 'file'
        else
          PropertyValue := 'folder';

        RequestManagement.ReplaceSubstringAnyLength(Response, CustomResponse, '".tag"', '"tag"');
        RequestManagement.GetXMLFromJsonArray(CustomResponse, Paths, 'entries', 'path_display', 'tag', PropertyValue);

        if File then
          foreach Path in Paths.SelectNodes('/root/*') do
            InsertDropBoxOverview(AccountCode, Path.InnerText);

        HasMore := RequestManagement.GetJsonValueByPropertyNameSingleNode(Response, 'has_more');

        if HasMore > '' then
          if Convert.ToBoolean(HasMore) then begin
            Cursor := RequestManagement.GetJsonValueByPropertyNameSingleNode(Response, 'cursor');

            ListFolderFilesContinueDropBox(AccountCode, Cursor, Paths, File, Silent);
          end;

        exit(Paths.FirstChild.ChildNodes.Count() > 0);
    end;

    procedure FindOnDropbox(var Paths: DotNet npNetXmlDocument;AccountCode: Code[10];SearchText: Text;Silent: Boolean): Boolean
    var
        DropBoxSetup: Record "DropBox API Setup";
        TempBlob: Record TempBlob;
        RequestManagement: Codeunit "Request Management";
        Arguments: Text;
        Response: Text;
        Value: Text;
        OutStr: OutStream;
        HttpWebRequest: DotNet npNetHttpWebRequest;
    begin
        DropBoxSetup.Get(AccountCode);

        RequestManagement.JsonAdd(Arguments, 'query', SearchText, false);
        RequestManagement.JsonAdd(Arguments, 'include_highlights', false, false);

        HttpWebRequest := HttpWebRequest.Create('https://api.dropboxapi.com/2/files/search_v2');
        HttpWebRequest.Timeout := DropBoxSetup.Timeout;
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType('application/json');
        HttpWebRequest.UserAgent := 'api-explorer-client';
        HttpWebRequest.Headers.Add('Authorization', 'Bearer ' + DropBoxSetup.GetToken());

        TempBlob.Blob.CreateOutStream(OutStr);
        OutStr.Write(Arguments);

        RequestManagement.StreamToHttpRequest(HttpWebRequest, TempBlob, StrLen(Arguments));

        if not RequestManagement.HandleHttpRequest(HttpWebRequest, Response, Silent) then
          exit;

        RequestManagement.GetXMLFromJsonArray(Response, Paths, 'matches', '$..path_display', '', '');

        exit(Paths.FirstChild.ChildNodes.Count() > 0);
    end;

    procedure UploadToDropbox(var TempBlob: Record TempBlob;AccountCode: Code[10];FileName: Text;Replace: Boolean;Silent: Boolean): Boolean
    var
        DropBoxSetup: Record "DropBox API Setup";
        RequestManagement: Codeunit "Request Management";
        Mode: Option add,overwrite;
        Arguments: Text;
        Response: Text;
        Success: Boolean;
        CR: Char;
        LF: Char;
        HttpWebRequest: DotNet npNetHttpWebRequest;
    begin
        DropBoxSetup.Get(AccountCode);

        //avoid non suggestive error
        if CopyStr(FileName, 1, 1) <> '/' then
          FileName := '/' + FileName;

        if Replace then
          Mode := Mode::overwrite;

        with RequestManagement do begin
          JsonAdd(Arguments, 'path', FileName, false);
          JsonAdd(Arguments, 'mode', Format(Mode), false);
          JsonAdd(Arguments, 'autorename', true, false);
          JsonAdd(Arguments, 'mute', false, false);
          JsonAdd(Arguments, 'strict_conflict', false, false);
        end;

        HttpWebRequest := HttpWebRequest.Create('https://content.dropboxapi.com/2/files/upload');
        HttpWebRequest.Timeout := DropBoxSetup.Timeout;
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentLength := RequestManagement.BlobLenght(TempBlob);
        HttpWebRequest.ContentType('application/octet-stream');
        HttpWebRequest.Headers.Add('Authorization', 'Bearer ' + DropBoxSetup.GetToken());
        HttpWebRequest.UserAgent := 'api-explorer-client';
        HttpWebRequest.Headers.Add('Dropbox-API-Arg', Arguments);

        RequestManagement.StreamToHttpRequest(HttpWebRequest, TempBlob, HttpWebRequest.ContentLength);

        if not RequestManagement.HandleHttpRequest(HttpWebRequest, Response, Silent) then
          exit;

        InsertDropBoxOverview(AccountCode, FileName);

        exit(true);
    end;

    procedure DownloadFromDropbox(var TempBlob: Record TempBlob;AccountCode: Code[10];FileName: Text;Silent: Boolean): Boolean
    var
        DropBoxSetup: Record "DropBox API Setup";
        RequestManagement: Codeunit "Request Management";
        Arguments: Text;
        Response: Text;
        OutStr: OutStream;
        HttpWebRequest: DotNet npNetHttpWebRequest;
        Convert: DotNet npNetConvert;
        MemoryStream: DotNet npNetMemoryStream;
    begin
        DropBoxSetup.Get(AccountCode);

        //avoid non suggestive error
        if CopyStr(FileName, 1, 1) <> '/' then
          FileName := '/' + FileName;

        RequestManagement.JsonAdd(Arguments, 'path', FileName, false);

        HttpWebRequest := HttpWebRequest.Create('https://content.dropboxapi.com/2/files/download');
        HttpWebRequest.Timeout := DropBoxSetup.Timeout;
        HttpWebRequest.Method := 'GET';
        HttpWebRequest.UserAgent := 'api-explorer-client';
        HttpWebRequest.Headers.Add('Authorization', 'Bearer ' + DropBoxSetup.GetToken());
        HttpWebRequest.Headers.Add('Dropbox-API-Arg', Arguments);

        if not RequestManagement.HandleHttpRequest(HttpWebRequest, Response, Silent) then
          exit;

        MemoryStream := MemoryStream.MemoryStream(Convert.FromBase64String(Response));

        TempBlob.Blob.CreateOutStream(OutStr);
        MemoryStream.CopyTo(OutStr);

        exit(TempBlob.Blob.HasValue);
    end;

    procedure DeleteFromDropbox(AccountCode: Code[10];FileName: Text;Silent: Boolean): Boolean
    var
        DropBoxSetup: Record "DropBox API Setup";
        TempBlob: Record TempBlob;
        RequestManagement: Codeunit "Request Management";
        Arguments: Text;
        Response: Text;
        OutStr: OutStream;
        HttpWebRequest: DotNet npNetHttpWebRequest;
    begin
        DropBoxSetup.Get(AccountCode);

        //avoid non suggestive error
        if CopyStr(FileName, 1, 1) <> '/' then
          FileName := '/' + FileName;

        RequestManagement.JsonAdd(Arguments, 'path', FileName, false);

        HttpWebRequest := HttpWebRequest.Create('https://api.dropboxapi.com/2/files/delete_v2');
        HttpWebRequest.Timeout := DropBoxSetup.Timeout;
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'application/json';
        HttpWebRequest.Headers.Add('Authorization', 'Bearer ' + DropBoxSetup.GetToken());

        TempBlob.Blob.CreateOutStream(OutStr);
        OutStr.Write(Arguments);

        RequestManagement.StreamToHttpRequest(HttpWebRequest, TempBlob, StrLen(Arguments));

        if not RequestManagement.HandleHttpRequest(HttpWebRequest, Response, Silent) then
          exit;

        RemoveDropBoxOverview(AccountCode, FileName);

        exit(true);
    end;

    procedure CopyFileOnDropbox(AccountCode: Code[10];FileFrom: Text;FileTo: Text;Silent: Boolean): Boolean
    var
        DropBoxSetup: Record "DropBox API Setup";
        TempBlob: Record TempBlob;
        RequestManagement: Codeunit "Request Management";
        Arguments: Text;
        Response: Text;
        OutStr: OutStream;
        HttpWebRequest: DotNet npNetHttpWebRequest;
    begin
        DropBoxSetup.Get(AccountCode);

        //avoid non suggestive error
        if CopyStr(FileFrom, 1, 1) <> '/' then
          FileFrom := '/' + FileFrom;

        if CopyStr(FileTo, 1, 1) <> '/' then
          FileTo := '/' + FileTo;

        with RequestManagement do begin
          JsonAdd(Arguments, 'from_path', FileFrom, false);
          JsonAdd(Arguments, 'to_path', FileTo, false);
          JsonAdd(Arguments, 'allow_shared_folder', false, false);
          JsonAdd(Arguments, 'autorename', false, false);
          JsonAdd(Arguments, 'allow_ownership_transfer', false, false);
        end;

        HttpWebRequest := HttpWebRequest.Create('https://api.dropboxapi.com/2/files/copy_v2');
        HttpWebRequest.Timeout := DropBoxSetup.Timeout;
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'application/json';
        HttpWebRequest.Headers.Add('Authorization', 'Bearer ' + DropBoxSetup.GetToken());

        TempBlob.Blob.CreateOutStream(OutStr);
        OutStr.Write(Arguments);

        RequestManagement.StreamToHttpRequest(HttpWebRequest, TempBlob, StrLen(Arguments));

        if not RequestManagement.HandleHttpRequest(HttpWebRequest, Response, Silent) then
          exit;

        InsertDropBoxOverview(AccountCode, FileTo);

        exit(true);
    end;

    local procedure InsertDropBoxOverview(Account: Code[10];Path: Text)
    var
        DropBoxOverview: Record "DropBox Overview";
        FileManagement: Codeunit "File Management";
    begin
        DropBoxOverview."Account Code" := Account;
        DropBoxOverview."File Name" := ConvertStr(FileManagement.GetDirectoryName(Path), '\', '/');
        DropBoxOverview.Name := FileManagement.GetFileName(Path);

        DropBoxOverview.SetRecFilter;
        if DropBoxOverview.IsEmpty and (DropBoxOverview."File Name" > '') then
          DropBoxOverview.Insert;
    end;

    local procedure RemoveDropBoxOverview(Account: Code[10];Path: Text)
    var
        DropBoxOverview: Record "DropBox Overview";
        FileManagement: Codeunit "File Management";
    begin
        DropBoxOverview.SetRange("Account Code", Account);

        if Path > '' then begin
          DropBoxOverview.SetRange("File Name", ConvertStr(FileManagement.GetDirectoryName(Path), '\', '/'));
          DropBoxOverview.SetRange(Name, FileManagement.GetFileName(Path));
        end;

        DropBoxOverview.DeleteAll;
    end;
}

