codeunit 6184862 "FTP Management"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created
    // NPR5.54/JAKUBV/20200408  CASE 394895 Transport NPR5.54 - 8 April 2020


    trigger OnRun()
    begin
    end;

    var
        StorageDescriptionCaption: Label 'FTP server storage';
        UploadDescriptionCaption: Label 'Upload file to FTP server from NAV server';
        DownloadDescriptionCaption: Label 'Download file from FTP Server to NAV server';
        DeleteDescriptionCaption: Label 'Delete file from FTP Server';
        ListDescriptionCaption: Label 'Get list of all files and their locations on the FTP Server';
        EmptyResponsListErr: Label 'This is a programing error: listing FTP server failed to complete for an unknown reason. FTP response should not be empty for a LIST command';
        CannotParseResponseErr: Label 'This is a programing error: could not discern starting position of file name in the FTP response, please provide as parameter in function before call';
        EmptyResponsSearchErr: Label 'This is a programing error: searching FTP server failed to complete for an unknown reason. FTP response should not be empty for a LIST command';
        ListCaption: Label 'LIST';
        OverviewCaption: Label 'OVERVIEW';
        UploadCaption: Label 'UPLOAD';
        DownloadCaption: Label 'DOWNLOAD';
        DeleteCaption: Label 'DELETE';
        RefreshCaption: Label 'Refresh';
        ListParamDescriptionCaption: Label '(Optional) logical (1/0 or true/false or t/f) parameter to update %1, refreshing will remove entries no longer in storage, default set to false';
        UploadLocationCaption: Label 'Location on storage';
        LocationOnStorageDescCaption: Label '(Optional) input location on storage to upload the file, example: /folder1/folder11/ or /folder1/';
        UploadFromCaption: Label 'NAV server file';
        UploadFromDescCaption: Label '(Optional) input file path [and name] on the NAV server, example: c:\folder1\folder11\  or  c:\folder1\folder11\myFile.txt';
        DownloadFileCaption: Label 'Full file path [and name]';
        FileDescCaption: Label '(Optional) input full file path [and name] on storage, example: /folder1/folder11/  or  /folder1/folder11/myFile.txt';
        DeleteFileCaption: Label 'Full file path [and name]';
        OverviewDescriptionCaption: Label 'Open the %1';
        UploadAllCaption: Label 'Reupload existing files ';
        UploadAllDescCaption: Label '(Optional)  logical (1/0 or true/false or t/f) case true, all files on the NAV server directory will be uploaded, else Overview table will be consulted for new files only. Default is false.';
        DataExchTypeCaption: Label 'Data exchange type';
        DataExchTypeDescCaption: Label '(Optional) Providing the Data Exchange Type (see Data Exchange Types page, Code field) will create an incoming document instead of downloading it to the server';

    procedure StorageType(): Code[20]
    begin
        exit('FTP');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184866, 'OnDiscoverStorage', '', false, false)]
    procedure OnDiscoverStorageType(var TempStorageTypes: Record "Storage Type" temporary)
    begin
        TempStorageTypes.Init;

        TempStorageTypes."Storage Type" := StorageType();
        TempStorageTypes.Description := StorageDescriptionCaption;
        TempStorageTypes.Codeunit := CODEUNIT::"FTP Management";

        TempStorageTypes.Insert;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184866, 'OnDiscoverStorageOperation', '', true, true)]
    procedure OnDiscoverStorageOperation(var TempStorageOperationtypes: Record "Storage Operation Type" temporary)
    var
        FTPOverview: Record "FTP Overview";
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
          Description := StrSubstNo(OverviewDescriptionCaption, FTPOverview.TableCaption);
          "Operation Code" := OverviewCaption;
          Insert;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184866, 'OnDiscoverStorageOperationParameters', '', false, false)]
    procedure OnDiscoverStorageOperationParameters(var TempStorageOperationParameter: Record "Storage Operation Parameter" temporary)
    var
        FTPOverview: Record "FTP Overview";
    begin
        with TempStorageOperationParameter do begin
          Init;
          "Storage Type" := StorageType();
          "Operation Code" := ListCaption;
          "Parameter Key" := 100;
          "Parameter Name" := RefreshCaption;
          Description := StrSubstNo(ListParamDescriptionCaption, FTPOverview.TableCaption);
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

    [EventSubscriber(ObjectType::Codeunit, 6184866, 'OnConfigureSetup', '', true, true)]
    procedure OnStorageConfiguration(var StorageSetup: Record "Storage Setup")
    var
        FTPSetup: Record "FTP Setup";
    begin
        if StorageSetup."Storage Type" <> StorageType() then
          exit;

        if PAGE.RunModal(PAGE::"FTP Setup", FTPSetup) <> ACTION::LookupOK then
          exit;

        StorageSetup."Storage ID" := FTPSetup.Code;
        StorageSetup.Description := FTPSetup.Description;
    end;

    procedure FindOnFTP(var XMLDocument: DotNet npNetXmlDocument;FTPCode: Code[10];StartParsingPosition: Integer;var CurrentPathDepth: Text;StartingDirectory: Text;FileName: Text;RecursiveSearch: Boolean;Secure: Boolean;Silent: Boolean): Boolean
    var
        TempBlob: Record TempBlob;
        FTPSetup: Record "FTP Setup";
        RequestManagement: Codeunit "Request Management";
        ValidName: Boolean;
        CR: Char;
        LF: Char;
        InStr: InStream;
        OutStr: OutStream;
        Line: Text;
        Name: Text;
        Method: Text;
        Response: Text;
        CRLF: Text;
        Path: DotNet npNetPath;
        XMLElement: DotNet npNetXmlElement;
        XMLRoot: DotNet npNetXmlElement;
        FTPWebRequest: DotNet npNetFtpWebRequest;
    begin
        //caution, recursive searching taxes FTP server resources, please try to pinpoint the directory as much as possible

        FTPSetup.Get(FTPCode);

        if StartingDirectory > '' then begin
          if CopyStr(StartingDirectory, StrLen(StartingDirectory)) <> '/' then
            StartingDirectory += '/';
        end else
          StartingDirectory += '/';

        if RecursiveSearch then
          Method := 'LIST'
        else
          Method := 'NLST';

        RequestManagement.CreateFTPRequest(FTPWebRequest, FTPSetup."FTP Host" + StartingDirectory + CurrentPathDepth, FTPCode, Method, Secure);

        if not RequestManagement.HandleFTPRequest(FTPWebRequest, Response, true) then
          if not Silent then
            RequestManagement.HandleURLWebException()
          else
            exit;

        if IsNull(XMLDocument) then begin
          XMLDocument := XMLDocument.XmlDocument();
          XMLRoot := XMLDocument.CreateElement('root');
          XMLDocument.AppendChild(XMLRoot);
        end;

        if not RecursiveSearch then begin
          CR := 11;
          LF := 10;
          CRLF := Format(CR) + Format(LF);

          exit(StrPos(DelChr(Response, '=', CRLF), FileName) > 0);
        end;

        if Response = '' then
          Error(EmptyResponsSearchErr);

        TempBlob.Blob.CreateOutStream(OutStr);
        OutStr.Write(Response);

        TempBlob.Blob.CreateInStream(InStr);

        while (StartParsingPosition = 0) and not InStr.EOS do begin
          InStr.ReadText(Line);
          StartParsingPosition := StrPos(Line, '..');
        end;

        if StartParsingPosition = 0 then
          Error(CannotParseResponseErr);

        while not InStr.EOS do begin
          InStr.ReadText(Line);
          Name := CopyStr(Line, StartParsingPosition);
          ValidName := not (DelChr(Name,'=',' ') in ['.', '..', '']);

          if Path.HasExtension(Name) then begin
            if Name = FileName then begin
              XMLRoot := XMLDocument.FirstChild();

              XMLElement := XMLDocument.CreateElement(Format(DelChr(CreateGuid,'=','{-}')));
              XMLElement.InnerText := CurrentPathDepth + FileName;
              XMLRoot.AppendChild(XMLElement);
            end;
          end else
            if ValidName then begin
              CurrentPathDepth += Name + '/';

              FindOnFTP(XMLDocument, FTPCode, StartParsingPosition, CurrentPathDepth, StartingDirectory, FileName, true, Secure, Silent);
            end;
        end;

        if CurrentPathDepth > '' then
          CurrentPathDepth := CopyStr(CurrentPathDepth, 1, RequestManagement.FindLastOccuranceInString(CopyStr(CurrentPathDepth, 1, StrLen(CurrentPathDepth) - 1), '/'));

        if IsNull(XMLRoot) then
          exit(false);

        exit(XMLRoot.ChildNodes.Count() > 0);
    end;

    procedure UploadToFTP(var TempBlob: Record TempBlob;FTPCode: Code[10];PathInDirectory: Text;FileName: Text;Secure: Boolean;Silent: Boolean): Boolean
    var
        FTPSetup: Record "FTP Setup";
        RequestManagement: Codeunit "Request Management";
        Response: Text;
        FTPWebRequest: DotNet npNetFtpWebRequest;
        NetworkCredentials: DotNet npNetNetworkCredential;
    begin
        FTPSetup.Get(FTPCode);

        RequestManagement.CreateFTPRequest(FTPWebRequest, FTPSetup."FTP Host" + PathInDirectory + FileName, FTPCode, 'STOR', Secure);

        RequestManagement.StreamToFTPRequest(FTPWebRequest, TempBlob, RequestManagement.BlobLenght(TempBlob));

        if not RequestManagement.HandleFTPRequest(FTPWebRequest, Response, true) then
          if not Silent then
            RequestManagement.HandleURLWebException()
          else
            exit;

        InsertFTPOverview(FTPCode, PathInDirectory, FileName);

        exit(true);
    end;

    procedure DownloadFromFTP(var TempBlob: Record TempBlob;FTPCode: Code[10];PathInDirectory: Text;FileName: Text;Secure: Boolean;Silent: Boolean): Boolean
    var
        FTPSetup: Record "FTP Setup";
        RequestManagement: Codeunit "Request Management";
        Response: Text;
        OutStr: OutStream;
        FTPWebRequest: DotNet npNetFtpWebRequest;
        NetworkCredentials: DotNet npNetNetworkCredential;
        MemoryStream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
    begin
        FTPSetup.Get(FTPCode);

        RequestManagement.CreateFTPRequest(FTPWebRequest, FTPSetup."FTP Host" + PathInDirectory + FileName, FTPCode, 'RETR', Secure);

        if not RequestManagement.HandleFTPRequest(FTPWebRequest, Response, true) then
          if not Silent then
            RequestManagement.HandleURLWebException()
          else
            exit;

        MemoryStream := MemoryStream.MemoryStream(Convert.FromBase64String(Response));

        TempBlob.Blob.CreateOutStream(OutStr);
        MemoryStream.CopyTo(OutStr);

        exit(true);
    end;

    procedure DeleteFromFTP(FTPCode: Code[10];PathInDirectory: Text;FileName: Text;Secure: Boolean;Silent: Boolean): Boolean
    var
        FTPSetup: Record "FTP Setup";
        RequestManagement: Codeunit "Request Management";
        Response: Text;
        Method: Text;
        FTPWebRequest: DotNet npNetFtpWebRequest;
        NetworkCredentials: DotNet npNetNetworkCredential;
    begin
        FTPSetup.Get(FTPCode);

        if FileName = '' then
          Method := 'RMD'
        else
          Method := 'DELE';

        RequestManagement.CreateFTPRequest(FTPWebRequest, FTPSetup."FTP Host" + PathInDirectory + FileName, FTPCode, Method, Secure);

        if not RequestManagement.HandleFTPRequest(FTPWebRequest, Response, true) then
          if not Silent then
            RequestManagement.HandleURLWebException()
          else
            exit;

        DeleteFromFTPOverview(FTPCode, PathInDirectory, FileName, false);

        exit(true);
    end;

    procedure CreateDirectoryInFTP(FTPCode: Code[10];DirectoryPath: Text;Secure: Boolean;Silent: Boolean): Boolean
    var
        FTPSetup: Record "FTP Setup";
        RequestManagement: Codeunit "Request Management";
        Response: Text;
        FTPWebRequest: DotNet npNetFtpWebRequest;
        NetworkCredentials: DotNet npNetNetworkCredential;
    begin
        FTPSetup.Get(FTPCode);

        RequestManagement.CreateFTPRequest(FTPWebRequest, FTPSetup."FTP Host" + DirectoryPath, FTPCode, 'MKD', Secure);

        if not RequestManagement.HandleFTPRequest(FTPWebRequest, Response, true) then
          if not Silent then
            RequestManagement.HandleURLWebException()
          else
            exit;

        exit(true);
    end;

    procedure ListFTP(FTPCode: Code[10];StartParsingPosition: Integer;var CurrentPathDepth: Text;StartingDirectory: Text;SingleDirectory: Boolean;Refresh: Boolean;DBInsert: Boolean;Secure: Boolean;var Directories: DotNet npNetXmlDocument;Silent: Boolean): Boolean
    var
        FTPSetup: Record "FTP Setup";
        TempBlob: Record TempBlob;
        RequestManagement: Codeunit "Request Management";
        ValidName: Boolean;
        Name: Text;
        Line: Text;
        Response: Text;
        InStr: InStream;
        OutStr: OutStream;
        FTPWebRequest: DotNet npNetFtpWebRequest;
        Path: DotNet npNetPath;
        Root: DotNet npNetXmlNode;
        Directory: DotNet npNetXmlNode;
    begin
        //caution, function is taxing on FTP server, do not perform lightly, check if single directory update is sufficient

        FTPSetup.Get(FTPCode);

        if IsNull(Directories) then begin
          Directories := Directories.XmlDocument();
          Root := Directories.CreateElement('root');
          Directories.AppendChild(Root);
        end;

        if StartingDirectory > '' then begin
          if CopyStr(StartingDirectory, 1, 1) <> '/' then
            StartingDirectory := '/' + StartingDirectory;

          if CopyStr(StartingDirectory, StrLen(StartingDirectory)) <> '/' then
            StartingDirectory += '/';
        end else
          StartingDirectory += '/';

        if Refresh then
          DeleteFromFTPOverview(FTPCode, StartingDirectory, '', SingleDirectory);

        RequestManagement.CreateFTPRequest(FTPWebRequest, FTPSetup."FTP Host" + StartingDirectory + CurrentPathDepth, FTPCode, 'LIST', Secure);

        if not RequestManagement.HandleFTPRequest(FTPWebRequest, Response, true) then
          if not Silent then
            RequestManagement.HandleURLWebException()
          else
            exit;

        if Response = '' then
          Error(EmptyResponsListErr);

        TempBlob.Blob.CreateOutStream(OutStr);
        OutStr.Write(Response);

        TempBlob.Blob.CreateInStream(InStr);

        while (StartParsingPosition = 0) and not InStr.EOS do begin
          InStr.ReadText(Line);
          StartParsingPosition := StrPos(Line, '..');
        end;

        if StartParsingPosition = 0 then
          Error(CannotParseResponseErr);

        while not InStr.EOS do begin
          InStr.ReadText(Line);
          Name := CopyStr(Line, StartParsingPosition);
          ValidName := not (DelChr(Name,'=',' ') in ['.', '..', '']);

          if Path.HasExtension(Name) then begin
            if DBInsert then
              InsertFTPOverview(FTPCode, StartingDirectory + CurrentPathDepth, Name)
          end else
            if not SingleDirectory and ValidName then begin
              CurrentPathDepth += Name + '/';

              Directory := Directories.CreateElement(Format(DelChr(CreateGuid,'=','{-}')));
              Directory.InnerText := CurrentPathDepth;
              Directories.FirstChild.AppendChild(Directory);

              ListFTP(FTPCode, StartParsingPosition, CurrentPathDepth, StartingDirectory, false, false, DBInsert, Secure, Directories, Silent);
            end;
        end;

        if CurrentPathDepth > '' then
          CurrentPathDepth := CopyStr(CurrentPathDepth, 1, RequestManagement.FindLastOccuranceInString(CopyStr(CurrentPathDepth, 1, StrLen(CurrentPathDepth) - 1), '/'));

        exit(true);
    end;

    local procedure InsertFTPOverview(FTPCode: Code[10];FilePath: Text;FileName: Text)
    var
        FTPOverview: Record "FTP Overview";
    begin
        FTPOverview."Host Code" := FTPCode;
        FTPOverview."File Name" := FilePath;
        FTPOverview.Name := FileName;

        FTPOverview.SetRecFilter;
        if FTPOverview.IsEmpty then begin
          FTPOverview.Insert;

          Commit;
        end;
    end;

    local procedure DeleteFromFTPOverview(FTPCode: Code[10];DirectoryName: Text;Name: Text;IsSingleDirectory: Boolean)
    var
        FTPOverview: Record "FTP Overview";
    begin
        FTPOverview.SetRange("Host Code", FTPCode);

        if Name > '' then begin
          FTPOverview.SetRange("File Name", DirectoryName);
          FTPOverview.SetRange(Name, Name);

          if FTPOverview.FindFirst then
            FTPOverview.Delete;
        end else begin
          if IsSingleDirectory then begin
            FTPOverview.SetRange("File Name", DirectoryName);
            FTPOverview.DeleteAll;

            exit;
          end;

          FTPOverview.FindSet;
          repeat
            if StrPos(FTPOverview."File Name", DirectoryName) > 0 then
              FTPOverview.Delete;
          until FTPOverview.Next = 0;
        end;
    end;
}

