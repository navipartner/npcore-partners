codeunit 6184862 "NPR FTP Management"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created
    // NPR5.54/JAKUBV/20200408  CASE 394895 Transport NPR5.54 - 8 April 2020
    // NPR5.55/ALST/20200603    CASE 402502 integrated SFTP download
    // NPR5.55/ALST/20200609    CASE 387570 added incoming document boolean parameter
    // NPR5.55/ALST/20200626    CASE 408285 added SSH protocol handling


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
        SecuredConnectionCaption: Label 'Secured connection';
        SecuredConnDescCaption: Label '(Optional) Used when accessing information VIA a secured connection. Valid values are: SSH, SSL, and left blank (for SFTP, FTPS, and FTP connections respectively).';
        StartingDirectoryCaption: Label 'Look in directory';
        StartingDirDescCaption: Label '(Optional) focus command to directory, example: /folder1/folder11/';
        IncomingDocumentCaption: Label 'Create Incoming Document';
        IncDocumentDescCaption: Label '(Optional) logical (1/0 or true/false or t/f) parameter to send file to the incoming document table instead of the physical location on server, default set to false';

    procedure StorageType(): Code[20]
    begin
        exit('FTP');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184866, 'OnDiscoverStorage', '', false, false)]
    procedure OnDiscoverStorageType(var TempStorageTypes: Record "NPR Storage Type" temporary)
    begin
        TempStorageTypes.Init;

        TempStorageTypes."Storage Type" := StorageType();
        TempStorageTypes.Description := StorageDescriptionCaption;
        TempStorageTypes.Codeunit := CODEUNIT::"NPR FTP Management";

        TempStorageTypes.Insert;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184866, 'OnDiscoverStorageOperation', '', true, true)]
    procedure OnDiscoverStorageOperation(var TempStorageOperationtypes: Record "NPR Storage Operation Type" temporary)
    var
        FTPOverview: Record "NPR FTP Overview";
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
    procedure OnDiscoverStorageOperationParameters(var TempStorageOperationParameter: Record "NPR Storage Operation Param." temporary)
    var
        FTPOverview: Record "NPR FTP Overview";
    begin
        with TempStorageOperationParameter do begin
            Init;
            "Storage Type" := StorageType();
            "Operation Code" := ListCaption;
            "Parameter Key" := 100;
            "Parameter Name" := RefreshCaption;
            Description := StrSubstNo(ListParamDescriptionCaption, FTPOverview.TableCaption);
            if Insert then;

            //-NPR5.55 [402502]
            Init;
            "Storage Type" := StorageType();
            "Operation Code" := ListCaption;
            "Parameter Key" := 200;
            "Parameter Name" := SecuredConnectionCaption;
            Description := SecuredConnDescCaption;
            if Insert then;

            Init;
            "Storage Type" := StorageType();
            "Operation Code" := ListCaption;
            "Parameter Key" := 300;
            "Parameter Name" := StartingDirectoryCaption;
            Description := StartingDirDescCaption;
            if Insert then;
            //+NPR5.55 [402502]

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

            //-NPR5.55 [402502]
            Init;
            "Storage Type" := StorageType();
            "Operation Code" := UploadCaption;
            "Parameter Key" := 400;
            "Parameter Name" := SecuredConnectionCaption;
            Description := SecuredConnDescCaption;
            if Insert then;
            //+NPR5.55 [402502]

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

            //-NPR5.55 [402502]
            Init;
            "Storage Type" := StorageType();
            "Operation Code" := DownloadCaption;
            "Parameter Key" := 300;
            "Parameter Name" := SecuredConnectionCaption;
            Description := SecuredConnDescCaption;
            if Insert then;
            //+NPR5.55 [402502]

            //-NPR5.55 [387570]
            Init;
            "Storage Type" := StorageType();
            "Operation Code" := DownloadCaption;
            "Parameter Key" := 400;
            "Parameter Name" := IncomingDocumentCaption;
            Description := IncDocumentDescCaption;
            if Insert then;
            //+NPR5.55 [387570]

            Init;
            "Storage Type" := StorageType();
            "Operation Code" := DeleteCaption;
            "Parameter Key" := 100;
            "Parameter Name" := DeleteFileCaption;
            Description := FileDescCaption;
            "Mandatory For Job Queue" := true;
            if Insert then;

            //-NPR5.55 [402502]
            Init;
            "Storage Type" := StorageType();
            "Operation Code" := DeleteCaption;
            "Parameter Key" := 200;
            "Parameter Name" := SecuredConnectionCaption;
            Description := SecuredConnDescCaption;
            if Insert then;
            //+NPR5.55 [402502]
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184866, 'OnConfigureSetup', '', true, true)]
    procedure OnStorageConfiguration(var StorageSetup: Record "NPR Storage Setup")
    var
        FTPSetup: Record "NPR FTP Setup";
    begin
        if StorageSetup."Storage Type" <> StorageType() then
            exit;

        if PAGE.RunModal(PAGE::"NPR FTP Setup", FTPSetup) <> ACTION::LookupOK then
            exit;

        StorageSetup."Storage ID" := FTPSetup.Code;
        StorageSetup.Description := FTPSetup.Description;
    end;

    procedure FindOnFTP(var XMLDocument: DotNet "NPRNetXmlDocument"; FTPCode: Code[10]; StartParsingPosition: Integer; var CurrentPathDepth: Text; StartingDirectory: Text; FileName: Text; RecursiveSearch: Boolean; Secure: Code[3]; Silent: Boolean): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        FTPSetup: Record "NPR FTP Setup";
        RequestManagement: Codeunit "NPR Request Management";
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
        Path: DotNet NPRNetPath;
        XMLElement: DotNet NPRNetXmlElement;
        XMLRoot: DotNet NPRNetXmlElement;
        FTPWebRequest: DotNet NPRNetFtpWebRequest;
    begin
        //caution, recursive searching taxes FTP server resources, please try to pinpoint the directory as much as possible
        //-NPR5.55 [408285]
        //XML document contains search results

        FTPSetup.Get(FTPCode);

        if StartingDirectory > '' then begin
            if CopyStr(StartingDirectory, StrLen(StartingDirectory)) <> '/' then
                StartingDirectory += '/';
        end else
            StartingDirectory += '/';

        if IsNull(XMLDocument) then begin
            XMLDocument := XMLDocument.XmlDocument();
            XMLRoot := XMLDocument.CreateElement('root');
            XMLDocument.AppendChild(XMLRoot);
        end;

        if Secure = 'SSH' then
            exit(FindOnSFTP(XMLDocument, FTPSetup, CurrentPathDepth, StartingDirectory, FileName, RecursiveSearch));

        // IF StartingDirectory > '' THEN BEGIN
        //  IF COPYSTR(StartingDirectory, STRLEN(StartingDirectory)) <> '/' THEN
        //    StartingDirectory += '/';
        // END ELSE
        //  StartingDirectory += '/';
        //+NPR5.55 [402502]

        if RecursiveSearch then
            Method := 'LIST'
        else
            Method := 'NLST';

        //-NPR5.55 [402502]
        //RequestManagement.CreateFTPRequest(FTPWebRequest, FTPSetup."FTP Host" + StartingDirectory + CurrentPathDepth, FTPCode, Method, Secure);
        RequestManagement.CreateFTPRequest(FTPWebRequest, FTPSetup."FTP Host" + StartingDirectory + CurrentPathDepth, FTPCode, Method, Secure = 'SSL');
        //+NPR5.55 [402502]

        if not RequestManagement.HandleFTPRequest(FTPWebRequest, Response, true) then
            if not Silent then
                RequestManagement.HandleURLWebException()
            else
                exit;

        //-NPR5.55 [408285]
        // IF ISNULL(XMLDocument) THEN BEGIN
        //  XMLDocument := XMLDocument.XmlDocument();
        //  XMLRoot := XMLDocument.CreateElement('root');
        //  XMLDocument.AppendChild(XMLRoot);
        // END;
        //+NPR5.55 [408285]

        if not RecursiveSearch then begin
            CR := 11;
            LF := 10;
            CRLF := Format(CR) + Format(LF);

            exit(StrPos(DelChr(Response, '=', CRLF), FileName) > 0);
        end;

        if Response = '' then
            Error(EmptyResponsSearchErr);

        TempBlob.CreateOutStream(OutStr);
        OutStr.Write(Response);

        TempBlob.CreateInStream(InStr);

        while (StartParsingPosition = 0) and not InStr.EOS do begin
            InStr.ReadText(Line);
            StartParsingPosition := StrPos(Line, '..');
        end;

        if StartParsingPosition = 0 then
            Error(CannotParseResponseErr);

        while not InStr.EOS do begin
            InStr.ReadText(Line);
            Name := CopyStr(Line, StartParsingPosition);
            ValidName := not (DelChr(Name, '=', ' ') in ['.', '..', '']);

            if Path.HasExtension(Name) then begin
                if Name = FileName then begin
                    XMLRoot := XMLDocument.FirstChild();

                    XMLElement := XMLDocument.CreateElement(Format(DelChr(CreateGuid, '=', '{-}')));
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

    procedure UploadToFTP(var TempBlob: Codeunit "Temp Blob"; FTPCode: Code[10]; PathInDirectory: Text; FileName: Text; Secure: Code[3]; Silent: Boolean): Boolean
    var
        FTPSetup: Record "NPR FTP Setup";
        RequestManagement: Codeunit "NPR Request Management";
        Response: Text;
        FTPWebRequest: DotNet NPRNetFtpWebRequest;
        NetworkCredentials: DotNet NPRNetNetworkCredential;
    begin
        FTPSetup.Get(FTPCode);

        //-NPR5.55 [402502]
        if Secure = 'SSH' then begin
            //-NPR5.55 [408285]
            //UploadToSFTP();
            UploadToSFTP(TempBlob, FTPSetup, PathInDirectory, FileName);
            //+NPR5.55 [408285]

            exit(true);
        end;

        //RequestManagement.CreateFTPRequest(FTPWebRequest, FTPSetup."FTP Host" + PathInDirectory + FileName, FTPCode, 'STOR', Secure);
        RequestManagement.CreateFTPRequest(FTPWebRequest, FTPSetup."FTP Host" + PathInDirectory + FileName, FTPCode, 'STOR', Secure = 'SSL');
        //+NPR5.55 [402502]

        RequestManagement.StreamToFTPRequest(FTPWebRequest, TempBlob, RequestManagement.BlobLenght(TempBlob));

        if not RequestManagement.HandleFTPRequest(FTPWebRequest, Response, true) then
            if not Silent then
                RequestManagement.HandleURLWebException()
            else
                exit;

        InsertFTPOverview(FTPCode, PathInDirectory, FileName);

        exit(true);
    end;

    procedure DownloadFromFTP(var TempBlob: Codeunit "Temp Blob"; FTPCode: Code[10]; PathInDirectory: Text; FileName: Text; Secure: Code[3]; Silent: Boolean): Boolean
    var
        FTPSetup: Record "NPR FTP Setup";
        RequestManagement: Codeunit "NPR Request Management";
        Response: Text;
        OutStr: OutStream;
        FTPWebRequest: DotNet NPRNetFtpWebRequest;
        NetworkCredentials: DotNet NPRNetNetworkCredential;
        MemoryStream: DotNet NPRNetMemoryStream;
        Convert: DotNet NPRNetConvert;
    begin
        FTPSetup.Get(FTPCode);

        //-NPR5.55 [402502]
        if Secure = 'SSH' then begin
            DownloadFromSFTP(TempBlob, FTPSetup, PathInDirectory, FileName);

            exit(true);
        end;

        //RequestManagement.CreateFTPRequest(FTPWebRequest, FTPSetup."FTP Host" + PathInDirectory + FileName, FTPCode, 'RETR', Secure);
        RequestManagement.CreateFTPRequest(FTPWebRequest, FTPSetup."FTP Host" + PathInDirectory + FileName, FTPCode, 'RETR', Secure = 'SSL');
        //+NPR5.55 [402502]

        if not RequestManagement.HandleFTPRequest(FTPWebRequest, Response, true) then
            if not Silent then
                RequestManagement.HandleURLWebException()
            else
                exit;

        MemoryStream := MemoryStream.MemoryStream(Convert.FromBase64String(Response));

        TempBlob.CreateOutStream(OutStr);
        MemoryStream.CopyTo(OutStr);

        exit(true);
    end;

    procedure DeleteFromFTP(FTPCode: Code[10]; PathInDirectory: Text; FileName: Text; Secure: Code[3]; Silent: Boolean): Boolean
    var
        FTPSetup: Record "NPR FTP Setup";
        RequestManagement: Codeunit "NPR Request Management";
        Response: Text;
        Method: Text;
        FTPWebRequest: DotNet NPRNetFtpWebRequest;
        NetworkCredentials: DotNet NPRNetNetworkCredential;
    begin
        FTPSetup.Get(FTPCode);

        //-NPR5.55 [402502]
        if Secure = 'SSH' then begin
            //-NPR5.55 [408285]
            //DeleteFromSFTP();
            DeleteFromSFTP(FTPSetup, PathInDirectory, FileName);
            //+NPR5.55 [408285]

            exit(true);
        end;
        //+NPR5.55 [402502]

        if FileName = '' then
            Method := 'RMD'
        else
            Method := 'DELE';

        //-NPR5.55 [402502]
        //RequestManagement.CreateFTPRequest(FTPWebRequest, FTPSetup."FTP Host" + PathInDirectory + FileName, FTPCode, Method, Secure);
        RequestManagement.CreateFTPRequest(FTPWebRequest, FTPSetup."FTP Host" + PathInDirectory + FileName, FTPCode, Method, Secure = 'SSL');
        //+NPR5.55 [402502]

        if not RequestManagement.HandleFTPRequest(FTPWebRequest, Response, true) then
            if not Silent then
                RequestManagement.HandleURLWebException()
            else
                exit;

        DeleteFromFTPOverview(FTPCode, PathInDirectory, FileName, false);

        exit(true);
    end;

    procedure CreateDirectoryInFTP(FTPCode: Code[10]; DirectoryPath: Text; Secure: Code[3]; Silent: Boolean): Boolean
    var
        FTPSetup: Record "NPR FTP Setup";
        RequestManagement: Codeunit "NPR Request Management";
        Response: Text;
        FTPWebRequest: DotNet NPRNetFtpWebRequest;
        NetworkCredentials: DotNet NPRNetNetworkCredential;
    begin
        FTPSetup.Get(FTPCode);

        //-NPR5.55 [408285]
        if Secure = 'SSH' then begin
            CreateDirectoryInSFTP(FTPSetup, DirectoryPath);

            exit(true);
        end;

        //RequestManagement.CreateFTPRequest(FTPWebRequest, FTPSetup."FTP Host" + DirectoryPath, FTPCode, 'MKD', Secure);
        RequestManagement.CreateFTPRequest(FTPWebRequest, FTPSetup."FTP Host" + DirectoryPath, FTPCode, 'MKD', Secure = 'SSL');
        //+NPR5.55 [408285]

        if not RequestManagement.HandleFTPRequest(FTPWebRequest, Response, true) then
            if not Silent then
                RequestManagement.HandleURLWebException()
            else
                exit;

        exit(true);
    end;

    procedure ListFTP(FTPCode: Code[10]; StartParsingPosition: Integer; var CurrentPathDepth: Text; StartingDirectory: Text; SingleDirectory: Boolean; Refresh: Boolean; DBInsert: Boolean; Secure: Code[3]; var Directories: DotNet "NPRNetXmlDocument"; Silent: Boolean): Boolean
    var
        FTPSetup: Record "NPR FTP Setup";
        TempBlob: Codeunit "Temp Blob";
        RequestManagement: Codeunit "NPR Request Management";
        ValidName: Boolean;
        Name: Text;
        Line: Text;
        Response: Text;
        InStr: InStream;
        OutStr: OutStream;
        FTPWebRequest: DotNet NPRNetFtpWebRequest;
        Path: DotNet NPRNetPath;
        Root: DotNet NPRNetXmlNode;
        Directory: DotNet NPRNetXmlNode;
    begin
        //caution, function is taxing on FTP server, do not perform lightly, check if single directory update is sufficient

        FTPSetup.Get(FTPCode);

        //-NPR5.55 [402502]
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

        if Secure = 'SSH' then begin
            //-NPR5.55 [408285]
            //ListSFTP(FTPSetup, StartingDirectory);
            ListSFTP(FTPSetup, StartingDirectory, CurrentPathDepth, Directories);
            //+NPR5.55 [408285]

            exit(true);
        end;

        // IF ISNULL(Directories) THEN BEGIN
        //  Directories := Directories.XmlDocument();
        //  Root := Directories.CreateElement('root');
        //  Directories.AppendChild(Root);
        // END;
        //
        // IF StartingDirectory > '' THEN BEGIN
        //  IF COPYSTR(StartingDirectory, 1, 1) <> '/' THEN
        //    StartingDirectory := '/' + StartingDirectory;
        //
        //  IF COPYSTR(StartingDirectory, STRLEN(StartingDirectory)) <> '/' THEN
        //    StartingDirectory += '/';
        // END ELSE
        //  StartingDirectory += '/';
        //
        // IF Refresh THEN
        //  DeleteFromFTPOverview(FTPCode, StartingDirectory, '', SingleDirectory);

        //RequestManagement.CreateFTPRequest(FTPWebRequest, FTPSetup."FTP Host" + StartingDirectory + CurrentPathDepth, FTPCode, 'LIST', Secure);
        RequestManagement.CreateFTPRequest(FTPWebRequest, FTPSetup."FTP Host" + StartingDirectory + CurrentPathDepth, FTPCode, 'LIST', Secure = 'SSL');
        //+NPR5.55 [402502]

        if not RequestManagement.HandleFTPRequest(FTPWebRequest, Response, true) then
            if not Silent then
                RequestManagement.HandleURLWebException()
            else
                exit;

        if Response = '' then
            Error(EmptyResponsListErr);

        TempBlob.CreateOutStream(OutStr);
        OutStr.Write(Response);

        TempBlob.CreateInStream(InStr);

        while (StartParsingPosition = 0) and not InStr.EOS do begin
            InStr.ReadText(Line);
            StartParsingPosition := StrPos(Line, '..');
        end;

        if StartParsingPosition = 0 then
            Error(CannotParseResponseErr);

        while not InStr.EOS do begin
            InStr.ReadText(Line);
            Name := CopyStr(Line, StartParsingPosition);
            ValidName := not (DelChr(Name, '=', ' ') in ['.', '..', '']);

            if Path.HasExtension(Name) then begin
                if DBInsert then
                    InsertFTPOverview(FTPCode, StartingDirectory + CurrentPathDepth, Name)
            end else
                if not SingleDirectory and ValidName then begin
                    CurrentPathDepth += Name + '/';

                    Directory := Directories.CreateElement(Format(DelChr(CreateGuid, '=', '{-}')));
                    Directory.InnerText := CurrentPathDepth;
                    Directories.FirstChild.AppendChild(Directory);

                    ListFTP(FTPCode, StartParsingPosition, CurrentPathDepth, StartingDirectory, false, false, DBInsert, Secure, Directories, Silent);
                end;
        end;

        if CurrentPathDepth > '' then
            CurrentPathDepth := CopyStr(CurrentPathDepth, 1, RequestManagement.FindLastOccuranceInString(CopyStr(CurrentPathDepth, 1, StrLen(CurrentPathDepth) - 1), '/'));

        exit(true);
    end;

    local procedure FindOnSFTP(var XMLDocument: DotNet "NPRNetXmlDocument"; FTPSetup: Record "NPR FTP Setup"; var CurrentPathDepth: Text; StartingDirectory: Text; FileName: Text; RecursiveSearch: Boolean): Boolean
    var
        SSHNETSFTPClient: Codeunit "NPR SSH.NET SFTP Client";
        RequestManagement: Codeunit "NPR Request Management";
        XMLRoot: DotNet NPRNetXmlElement;
        XMLElement: DotNet NPRNetXmlElement;
        IEnumerableSFTPFileList: DotNet NPRNetIEnumerable;
        SftpFile: DotNet NPRNetSftpFile;
        Path: DotNet NPRNetPath;
        Found: Boolean;
    begin
        //-NPR5.55 [408285]
        SSHNETSFTPClient.Construct(FTPSetup."FTP Host", FTPSetup.User, FTPSetup.GetPassword(), FTPSetup."Port Number", FTPSetup.Timeout);
        SSHNETSFTPClient.SetKeepAliveInterval(0, 0, 0);
        SSHNETSFTPClient.ListDirectory(StartingDirectory + CurrentPathDepth, IEnumerableSFTPFileList);

        foreach SftpFile in IEnumerableSFTPFileList do
            if not (DelChr(SftpFile.Name, '=', ' ') in ['.', '..', '']) then
                if Path.HasExtension(SftpFile.Name) then begin
                    if StrPos(SftpFile.Name, FileName) > 0 then begin
                        XMLRoot := XMLDocument.FirstChild();

                        XMLElement := XMLDocument.CreateElement(Format(DelChr(CreateGuid, '=', '{-}')));
                        XMLElement.InnerText := CurrentPathDepth + SftpFile.Name;
                        XMLRoot.AppendChild(XMLElement);
                    end;
                end else begin
                    CurrentPathDepth += SftpFile.Name + '/';

                    Found := FindOnSFTP(XMLDocument, FTPSetup, CurrentPathDepth, StartingDirectory, FileName, true) or Found;
                end;

        if CurrentPathDepth > '' then
            CurrentPathDepth := CopyStr(CurrentPathDepth, 1, RequestManagement.FindLastOccuranceInString(CopyStr(CurrentPathDepth, 1, StrLen(CurrentPathDepth) - 1), '/'));

        if IsNull(XMLRoot) then
            exit(Found);

        exit((XMLRoot.ChildNodes.Count() > 0) or Found);
        //+NPR5.55 [408285]
    end;

    local procedure UploadToSFTP(var TempBlob: Codeunit "Temp Blob"; FTPSetup: Record "NPR FTP Setup"; PathInDirectory: Text; FileName: Text)
    var
        SSHNETSFTPClient: Codeunit "NPR SSH.NET SFTP Client";
    begin
        //-NPR5.55 [408285]
        SSHNETSFTPClient.Construct(FTPSetup."FTP Host", FTPSetup.User, FTPSetup.GetPassword(), FTPSetup."Port Number", FTPSetup.Timeout);
        SSHNETSFTPClient.SetKeepAliveInterval(0, 0, 0);

        SSHNETSFTPClient.UploadFileFromBlob(TempBlob, PathInDirectory + FileName);

        InsertFTPOverview(FTPSetup.Code, PathInDirectory, FileName);
        //+NPR5.55 [408285]
    end;

    local procedure DownloadFromSFTP(var TempBlob: Codeunit "Temp Blob"; FTPSetup: Record "NPR FTP Setup"; FilePath: Text; FileName: Text)
    var
        SSHNETSFTPClient: Codeunit "NPR SSH.NET SFTP Client";
        FileMgt: Codeunit "File Management";
    begin
        //-NPR5.55 [402502]
        SSHNETSFTPClient.Construct(FTPSetup."FTP Host", FTPSetup.User, FTPSetup.GetPassword(), FTPSetup."Port Number", FTPSetup.Timeout);
        //-NPR5.55 [408285]
        SSHNETSFTPClient.SetKeepAliveInterval(0, 0, 0);
        //+NPR5.55 [408285]
        SSHNETSFTPClient.DownloadFile(FTPSetup."Storage On Server" + FileName, FilePath + FileName);

        FileMgt.BLOBImportFromServerFile(TempBlob, FTPSetup."Storage On Server" + FileName);
        //+NPR5.55 [402502]
    end;

    local procedure DeleteFromSFTP(FTPSetup: Record "NPR FTP Setup"; PathInDirectory: Text; FileName: Text)
    var
        SSHNETSFTPClient: Codeunit "NPR SSH.NET SFTP Client";
    begin
        //-NPR5.55 [408285]
        SSHNETSFTPClient.Construct(FTPSetup."FTP Host", FTPSetup.User, FTPSetup.GetPassword(), FTPSetup."Port Number", FTPSetup.Timeout);
        SSHNETSFTPClient.SetKeepAliveInterval(0, 0, 0);

        if FileName = '' then
            SSHNETSFTPClient.DeleteDirectory(PathInDirectory)
        else
            SSHNETSFTPClient.DeleteFile(PathInDirectory + FileName);

        DeleteFromFTPOverview(FTPSetup.Code, PathInDirectory, FileName, false);
        //+NPR5.55 [408285]
    end;

    local procedure ListSFTP(FTPSetup: Record "NPR FTP Setup"; StartingDirectory: Text; var CurrentPathDepth: Text; var Directories: DotNet "NPRNetXmlDocument")
    var
        SSHNETSFTPClient: Codeunit "NPR SSH.NET SFTP Client";
        FileManagement: Codeunit "File Management";
        RequestManagement: Codeunit "NPR Request Management";
        IEnumerableSFTPFileList: DotNet NPRNetIEnumerable;
        SftpFile: DotNet NPRNetSftpFile;
        Path: DotNet NPRNetPath;
        Directory: DotNet NPRNetXmlNode;
    begin
        //-NPR5.55 [402502]
        SSHNETSFTPClient.Construct(FTPSetup."FTP Host", FTPSetup.User, FTPSetup.GetPassword(), FTPSetup."Port Number", FTPSetup.Timeout);
        SSHNETSFTPClient.SetKeepAliveInterval(0, 0, 0);
        SSHNETSFTPClient.ListDirectory(StartingDirectory + CurrentPathDepth, IEnumerableSFTPFileList);

        foreach SftpFile in IEnumerableSFTPFileList do
            //-NPR5.55 [408285]
            //InsertFTPOverview(FTPSetup.Code, StartingDirectory, SftpFile.Name);
            if not (DelChr(SftpFile.Name, '=', ' ') in ['.', '..', '']) then
                if Path.HasExtension(SftpFile.Name) then begin
                    InsertFTPOverview(FTPSetup.Code, StartingDirectory + CurrentPathDepth, SftpFile.Name);
                end else begin
                    CurrentPathDepth += SftpFile.Name + '/';

                    Directory := Directories.CreateElement(Format(DelChr(CreateGuid, '=', '{-}')));
                    Directory.InnerText := CurrentPathDepth;
                    Directories.FirstChild.AppendChild(Directory);

                    ListSFTP(FTPSetup, StartingDirectory, CurrentPathDepth, Directories);
                end;

        if CurrentPathDepth > '' then
            CurrentPathDepth := CopyStr(CurrentPathDepth, 1, RequestManagement.FindLastOccuranceInString(CopyStr(CurrentPathDepth, 1, StrLen(CurrentPathDepth) - 1), '/'));
        //+NPR5.55 [408285]
        //+NPR5.55 [402502]
    end;

    procedure CreateDirectoryInSFTP(FTPSetup: Record "NPR FTP Setup"; DirectoryPath: Text): Boolean
    var
        SSHNETSFTPClient: Codeunit "NPR SSH.NET SFTP Client";
    begin
        //-NPR5.55 [408285]
        SSHNETSFTPClient.Construct(FTPSetup."FTP Host", FTPSetup.User, FTPSetup.GetPassword(), FTPSetup."Port Number", FTPSetup.Timeout);
        SSHNETSFTPClient.SetKeepAliveInterval(0, 0, 0);

        SSHNETSFTPClient.CreateDirectory(DirectoryPath);
        //+NPR5.55 [408285]
    end;

    local procedure InsertFTPOverview(FTPCode: Code[10]; FilePath: Text; FileName: Text)
    var
        FTPOverview: Record "NPR FTP Overview";
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

    local procedure DeleteFromFTPOverview(FTPCode: Code[10]; DirectoryName: Text; Name: Text; IsSingleDirectory: Boolean)
    var
        FTPOverview: Record "NPR FTP Overview";
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

            //-NPR5.55 [408285]
            //FTPOverview.FINDSET;
            if FTPOverview.FindSet then
                //+NPR5.55 [408285]
                repeat
                    if StrPos(FTPOverview."File Name", DirectoryName) > 0 then
                        FTPOverview.Delete;
                until FTPOverview.Next = 0;
        end;
    end;
}

