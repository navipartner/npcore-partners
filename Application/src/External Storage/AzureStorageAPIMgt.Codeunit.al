codeunit 6184861 "NPR Azure Storage API Mgt."
{
    var
        StorageDescriptionCaption: Label 'Azure blob storage';
        UploadDescriptionCaption: Label 'Upload a file to Azure Storage from server';
        DownloadDescriptionCaption: Label 'Download a file from Azure Storage to server';
        DeleteDescriptionCaption: Label 'Remove a file from Azure Storage';
        CopyDescriptionCaption: Label 'Copy a file on Azure Storage to another location  ';
        ListDescriptionCaption: Label 'Get a full list of files and their locations on the storage';
        SearchDescriptionCaption: Label 'Find files or directories on storage';
        DropIndexDescriptionCaption: Label 'Remove index from search app on storage';
        IndexDescriptionCaption: Label 'Create index in search app';
        DataSourceDescriptionCaption: Label 'Create data source for search app';
        IndexerDescriptionCaption: Label 'Create indexer for the search app';
        MissingStorageAccNameErr: Label 'Storage account name is mandatory';
        MissingStorageAccServiceErr: Label 'Search service name is mandatory';
        MissingStorageConatainerNameErr: Label 'Call is missing the storage container name';
        MissingFileNameErr: Label 'File name is mandatory';
        MiissingToFromErr: Label 'Both source file and destination are mandatory';
        MissingMIMETypeErr: Label 'MIME type is empty and could not be resolved from the file''s name, please check file extension or provide the MIME type in the function''s call';
        MissingIndexErr: Label 'An index name is required in order to perform a search';
        MissingStorageAccDataSourceErr: Label 'A data source name is required in order to perform a search';
        DeleteIndexCaption: Label 'Warning! You are about delete index "%1", do you wish to proceed?';
        ListCaption: Label 'LIST';
        OverviewCaption: Label 'OVERVIEW';
        UploadCaption: Label 'UPLOAD';
        DownloadCaption: Label 'DOWNLOAD';
        DeleteCaption: Label 'DELETE';
        CopyCaption: Label 'COPY';
        SearchCaption: Label 'SEARCH';
        RefreshCaption: Label 'Refresh';
        ListParamDescriptionCaption: Label '(Optional) logical (1/0 or true/false or t/f) parameter to update %1, refreshing will remove entries no longer in storage, default set to false';
        UploadLocationCaption: Label 'Location on storage';
        LocationOnStorageDescCaption: Label '(Optional) input location on storage to upload the file to, example: folder1/folder11 or folder1';
        UploadFromCaption: Label 'NAV server file';
        UploadFromDescCaption: Label '(Optional) input file path [and name] on the NAV server, example: c:\folder1\folder11\  or  c:\folder1\folder11\myFile.txt';
        DownloadFileCaption: Label 'Full file path [and name]';
        FileDescCaption: Label '(Optional) input full file path [and name] on storage, example: folder1/folder11/  or  folder1/folder11/myFile.txt';
        DeleteFileCaption: Label 'Full file path [and name]';
        OverviewDescriptionCaption: Label 'Open the %1';
        ContainerNameCaption: Label 'Container name';
        ContainerParamDescriptionCaption: Label '(Optional) input the name of the container where the operation will take place, example: container1';
        UploadAllCaption: Label 'Reupload existing files ';
        UploadAllDescCaption: Label '(Optional)  logical (1/0 or true/false or t/f) case true, all files on the NAV server directory will be uploaded, else Overview table will be consulted for new files only. Default is false.';
        DataExchTypeCaption: Label 'Data exchange type';
        DataExchTypeDescCaption: Label '(Optional) Providing the Data Exchange Type (see Data Exchange Types page, Code field) will create an incoming document instead of downloading it to the server';
        IncomingDocumentCaption: Label 'Create Incoming Document';
        IncDocumentDescCaption: Label '(Optional) logical (1/0 or true/false or t/f) parameter to send file to the incoming document table instead of the physical location on server, default set to false';

    procedure StorageType(): Code[20]
    begin
        exit('AZURE');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184866, 'OnDiscoverStorage', '', false, false)]
    procedure OnDiscoverStorage(var TempStorageTypes: Record "NPR Storage Type" temporary)
    begin
        TempStorageTypes.Init;

        TempStorageTypes."Storage Type" := StorageType();
        TempStorageTypes.Description := StorageDescriptionCaption;
        TempStorageTypes.Codeunit := CODEUNIT::"NPR Azure Storage API Mgt.";

        TempStorageTypes.Insert;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184866, 'OnDiscoverStorageOperation', '', true, true)]
    procedure OnDiscoverStorageOperation(var TempStorageOperationtypes: Record "NPR Storage Operation Type" temporary)
    var
        AzureStorageOverview: Page "NPR Azure Storage Overview";
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
            Description := StrSubstNo(OverviewDescriptionCaption, AzureStorageOverview.Caption);
            "Operation Code" := OverviewCaption;
            Insert;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184866, 'OnDiscoverStorageOperationParameters', '', false, false)]
    procedure OnDiscoverStorageOperationParameters(var TempStorageOperationParameter: Record "NPR Storage Operation Param." temporary)
    var
        AzureStorageOverview: Record "NPR Azure Storage Overview";
    begin
        with TempStorageOperationParameter do begin
            Init;
            "Storage Type" := StorageType();
            "Operation Code" := ListCaption;
            "Parameter Key" := 100;
            "Parameter Name" := RefreshCaption;
            Description := StrSubstNo(ListParamDescriptionCaption, AzureStorageOverview.TableCaption);
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
            "Parameter Name" := ContainerNameCaption;
            Description := ContainerParamDescriptionCaption;
            "Mandatory For Job Queue" := true;
            if Insert then;

            Init;
            "Storage Type" := StorageType();
            "Operation Code" := UploadCaption;
            "Parameter Key" := 400;
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
            "Parameter Name" := ContainerNameCaption;
            Description := ContainerParamDescriptionCaption;
            "Mandatory For Job Queue" := true;
            if Insert then;

            Init;
            "Storage Type" := StorageType();
            "Operation Code" := DownloadCaption;
            "Parameter Key" := 300;
            "Parameter Name" := DataExchTypeCaption;
            Description := DataExchTypeDescCaption;
            if Insert then;

            Init;
            "Storage Type" := StorageType();
            "Operation Code" := DownloadCaption;
            "Parameter Key" := 400;
            "Parameter Name" := IncomingDocumentCaption;
            Description := IncDocumentDescCaption;
            if Insert then;

            Init;
            "Storage Type" := StorageType();
            "Operation Code" := DeleteCaption;
            "Parameter Key" := 100;
            "Parameter Name" := DeleteFileCaption;
            Description := FileDescCaption;
            "Mandatory For Job Queue" := true;
            if Insert then;

            Init;
            "Storage Type" := StorageType();
            "Operation Code" := DeleteCaption;
            "Parameter Key" := 200;
            "Parameter Name" := ContainerNameCaption;
            Description := ContainerParamDescriptionCaption;
            "Mandatory For Job Queue" := true;
            if Insert then;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184866, 'OnConfigureSetup', '', true, true)]
    procedure OnStorageConfiguration(var StorageSetup: Record "NPR Storage Setup")
    var
        AzureStorageAPISetup: Record "NPR Azure Storage API Setup";
    begin
        if StorageSetup."Storage Type" <> StorageType() then
            exit;

        if PAGE.RunModal(PAGE::"NPR Azure Storage Setup", AzureStorageAPISetup) <> ACTION::LookupOK then
            exit;

        StorageSetup."Storage ID" := AzureStorageAPISetup."Account Name";
        StorageSetup.Description := AzureStorageAPISetup."Account Description";
    end;

    procedure ListAzureStorage(StorageAccountName: Text; StorageConatainerName: Text; StoregeServiceVersion: Text; FullRefresh: Boolean; DBInsert: Boolean; Silent: Boolean; var ResponseXMLStack: Text): Boolean
    var
        AzureStorageAPISetup: Record "NPR Azure Storage API Setup";
        RequestManagement: Codeunit "NPR Request Management";
        XMLDOMManagement: Codeunit "XML DOM Management";
        Response: Text;
        UriParameter: Text;
        RestType: Text;
        StringToSign: Text;
        UTCNow: Text;
        LineFeed: Text;
        LF: Char;
        HMAC: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512;
        OutStr: OutStream;
        WebRequest: HttpRequestMessage;
        WebResponse: HttpResponseMessage;
        WebClient: HttpClient;
        XMLNodeList: XmlNodeList;
        XMLNode: XmlNode;
        ResponseXmlDoc: XmlDocument;
        ResponseRootNode: XmlNode;
    begin
        if StorageAccountName = '' then
            Error(MissingStorageAccNameErr);

        LF := 10;
        LineFeed := Format(LF);
        UTCNow := RequestManagement.UTCDateTimeNowText('R');

        if StorageConatainerName > '' then begin
            UriParameter := '?restype=container&comp=list';
            RestType := LineFeed + 'restype:container';
        end else
            UriParameter := '?comp=list';

        AzureStorageAPISetup.Get(StorageAccountName);
        if StoregeServiceVersion = '' then
            StoregeServiceVersion := '2019-02-02';

        WebClient.Timeout := AzureStorageAPISetup.Timeout;
        WebRequest.SetRequestUri('https://' + StorageAccountName + '.blob.core.windows.net/' + StorageConatainerName + UriParameter);
        WebRequest.Method := 'GET';
        RequestManagement.RemoveRequestHeader(WebRequest, 'Connection');
        RequestManagement.RemoveRequestHeader(WebRequest, 'Keep-Alive');

        StringToSign := WebRequest.Method +
            LineFeed + LineFeed + LineFeed +
            LineFeed + LineFeed +
            LineFeed + LineFeed + LineFeed + LineFeed + LineFeed + LineFeed + LineFeed +
            'x-ms-date:' + UTCNow +
            LineFeed +
            'x-ms-version:' + StoregeServiceVersion +
            LineFeed +
            '/' + StorageAccountName + '/' + StorageConatainerName +
            LineFeed +
            'comp:list' +
            RestType;

        RequestManagement.HMACCryptography(StringToSign, AzureStorageAPISetup.GetAccessKey(), HMAC::HMACSHA256);

        RequestManagement.AddOrReplaceRequestHeader(WebRequest, 'Authorization', StrSubstNo('%1 %2:%3', 'SharedKey', StorageAccountName, StringToSign));
        RequestManagement.AddOrReplaceRequestHeader(WebRequest, 'x-ms-date', UTCNow);
        RequestManagement.AddOrReplaceRequestHeader(WebRequest, 'x-ms-version', StoregeServiceVersion);

        if not WebClient.Send(WebRequest, WebResponse) then
            exit;

        WebResponse.Content().ReadAs(Response);
        AppendResponse(Response, ResponseXMLStack);

        if StorageConatainerName = '' then begin
            if not RequestManagement.GetNodesFromXmlText(Response, '//Containers/Container/Name', XMLNodeList) then
                exit;

            if FullRefresh then begin
                if XMLNodeList.Count() = 0 then begin
                    DeleteAzureStorageOverview(StorageAccountName, '', '');

                    exit;
                end;

                CleanResidueContainers(StorageAccountName, XMLNodeList);
            end;

            foreach XMLNode in XMLNodeList do
                ListAzureStorage(AzureStorageAPISetup."Account Name", XMLNode.AsXmlElement().InnerText,
                    '', FullRefresh, DBInsert, Silent, ResponseXMLStack);

            exit(true);
        end;

        if DBInsert then
            ImportStorageList(StorageAccountName, StorageConatainerName, Response, FullRefresh);

        exit(true);
    end;

    [Obsolete('Use native Business Central objects.')]
    procedure SearchAzureStorage(var Paths: DotNet "NPRNetXmlDocument"; StorageAccountName: Text;
        StorageServiceName: Text; StoregeApiVersion: Text; IndexName: Text;
        FolderOrFileName: Text; Silent: Boolean): Boolean
    var
        XmlDoc: XmlDocument;
        Result: Boolean;
        XmlText: Text;
    begin
        XmlDocument.ReadFrom(Paths.OuterXml, XmlDoc);
        SearchAzureStorage(XmlDoc, StorageAccountName, StorageServiceName, StoregeApiVersion,
            IndexName, FolderOrFileName, Silent);
        XmlDoc.WriteTo(XmlText);

        Paths := Paths.XmlDocument();
        Paths.LoadXml(XmlText);

        exit(Result);
    end;

    procedure SearchAzureStorage(var Paths: XmlDocument; StorageAccountName: Text; StorageServiceName: Text; StoregeApiVersion: Text; IndexName: Text; FolderOrFileName: Text; Silent: Boolean): Boolean
    var
        AzureStorageAPISetup: Record "NPR Azure Storage API Setup";
        TempBlob: Codeunit "Temp Blob";
        RequestManagement: Codeunit "NPR Request Management";
        Response: Text;
        Arguments: Text;
        OutStr: OutStream;
        ArgumentsObject: JsonObject;
        WebRequest: HttpRequestMessage;
        WebResponse: HttpResponseMessage;
        WebClient: HttpClient;
        InStrm: InStream;
        ResponseJson: JsonObject;
        ResponseText: Text;
        Base64Convert: Codeunit "Base64 Convert";
    begin
        //FolderOrFileName has to be the full name of the file or folder, not a partial string
        case '' of
            StorageServiceName:
                Error(MissingStorageAccServiceErr);
            IndexName:
                Error(MissingIndexErr);
        end;

        ArgumentsObject.Add('search', '*');
        ArgumentsObject.Add('filter', 'search.ismatch(''' + FolderOrFileName + ''')');
        ArgumentsObject.Add('select', 'path');
        ArgumentsObject.WriteTo(Arguments);

        AzureStorageAPISetup.Get(StorageAccountName);
        if StoregeApiVersion = '' then
            StoregeApiVersion := '2019-05-06';

        WebRequest.SetRequestUri('https://' + StorageServiceName + '.search.windows.net/indexes/' + IndexName + '/docs/search?api-version=' + StoregeApiVersion);
        WebRequest.Method := 'POST';

        RequestManagement.AddOrReplaceRequestHeader(WebRequest, 'api-key', AzureStorageAPISetup.GetAdminKey());

        WebRequest.Content.ReadAs(Arguments);
        RequestManagement.AddOrReplaceContentHeader(WebRequest, 'Content-Type', 'application/json');

        if not WebClient.Send(WebRequest, WebResponse) then
            exit;

        WebResponse.Content.ReadAs(ResponseText);
        ResponseJson.ReadFrom(ResponseText);

        exit(RequestManagement.GetXMLFromJsonArray(
            Base64Convert.FromBase64(ResponseText),
            Paths, 'value', '$..path', '', ''));
    end;

    procedure UploadToAzureStorage(var TempBlob: Codeunit "Temp Blob"; StorageAccountName: Text; StoregeServiceVersion: Text; StorageConatainerName: Text; FileName: Text; MIMEType: Text; Silent: Boolean): Boolean
    var
        AzureStorageOverview: Record "NPR Azure Storage Overview";
        AzureStorageAPISetup: Record "NPR Azure Storage API Setup";
        RequestManagement: Codeunit "NPR Request Management";
        StringToSign: Text;
        UTCNow: Text;
        LineFeed: Text;
        Response: Text;
        LF: Char;
        HMAC: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512;
        WebRequest: HttpRequestMessage;
        WebResponse: HttpResponseMessage;
        WebClient: HttpClient;
        InStrm: InStream;
        TypeHelper: Codeunit "Type Helper";
    begin
        if MIMEType = '' then
            if RequestManagement.TryGetMIMEType(FileName, MIMEType) then;

        case '' of
            StorageAccountName:
                Error(MissingStorageAccNameErr);
            StorageConatainerName:
                Error(MissingStorageConatainerNameErr);
            FileName:
                Error(MissingFileNameErr);
            MIMEType:
                Error(MissingMIMETypeErr);
        end;

        FileName := TypeHelper.UriEscapeDataString(FileName);

        if StoregeServiceVersion = '' then
            StoregeServiceVersion := '2019-02-02';

        AzureStorageAPISetup.Get(StorageAccountName);
        LF := 10;
        LineFeed := Format(LF);
        UTCNow := RequestManagement.UTCDateTimeNowText('R');

        WebRequest.SetRequestUri('https://' + StorageAccountName + '.blob.core.windows.net/' + StorageConatainerName + '/' + FileName);
        WebRequest.Method := 'PUT';

        StringToSign := WebRequest.Method +
            LineFeed + LineFeed + LineFeed +
            Format(RequestManagement.BlobLenght(TempBlob)) +
            LineFeed + LineFeed +
            MIMEType +
            LineFeed + LineFeed + LineFeed + LineFeed + LineFeed + LineFeed + LineFeed +
            'x-ms-blob-type:BlockBlob' +
            LineFeed +
            'x-ms-date:' + UTCNow +
            LineFeed +
            'x-ms-version:' + StoregeServiceVersion +
            LineFeed +
            '/' + StorageAccountName + '/' + StorageConatainerName + '/' + FileName;

        RequestManagement.HMACCryptography(StringToSign, AzureStorageAPISetup.GetAccessKey(), HMAC::HMACSHA256);

        RequestManagement.AddOrReplaceRequestHeader(WebRequest, 'Authorization', StrSubstNo('%1 %2:%3', 'SharedKey', StorageAccountName, StringToSign));
        RequestManagement.AddOrReplaceRequestHeader(WebRequest, 'x-ms-blob-type', 'BlockBlob');
        RequestManagement.AddOrReplaceRequestHeader(WebRequest, 'x-ms-date', UTCNow);
        RequestManagement.AddOrReplaceRequestHeader(WebRequest, 'x-ms-version', StoregeServiceVersion);

        TempBlob.CreateInStream(InStrm);
        WebRequest.Content.WriteFrom(InStrm);
        RequestManagement.AddOrReplaceContentHeader(WebRequest, 'Content-Type', MIMEType);
        RequestManagement.AddOrReplaceContentHeader(WebRequest, 'Content-Length', Format(RequestManagement.BlobLenght(TempBlob)));

        if not WebClient.Send(WebRequest, WebResponse) then
            exit;

        FileName := TypeHelper.UriEscapeDataString(FileName);
        exit(InsertAzureStorageOverview(StorageAccountName, StorageConatainerName, FileName));
    end;

    procedure CreateContainerAzureStorage(StorageAccountName: Text; StoregeServiceVersion: Text; StorageConatainerName: Text; Silent: Boolean): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        AzureStorageAPISetup: Record "NPR Azure Storage API Setup";
        RequestManagement: Codeunit "NPR Request Management";
        StringToSign: Text;
        UTCNow: Text;
        LineFeed: Text;
        Response: Text;
        LF: Char;
        HMAC: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512;
        WebRequest: HttpRequestMessage;
        WebResponse: HttpResponseMessage;
        WebClient: HttpClient;
        InStrm: InStream;
    begin
        case '' of
            StorageAccountName:
                Error(MissingStorageAccNameErr);
            StorageConatainerName:
                Error(MissingStorageConatainerNameErr);
        end;

        if StoregeServiceVersion = '' then
            StoregeServiceVersion := '2019-02-02';

        AzureStorageAPISetup.Get(StorageAccountName);
        LF := 10;
        LineFeed := Format(LF);
        UTCNow := RequestManagement.UTCDateTimeNowText('R');

        WebRequest.SetRequestUri('https://' + StorageAccountName + '.blob.core.windows.net/' +
            StorageConatainerName + '?restype=container');
        WebRequest.Method := 'PUT';
        StringToSign := WebRequest.Method +
            LineFeed + LineFeed + LineFeed +
            Format(1) +
            LineFeed + LineFeed +
            LineFeed + LineFeed + LineFeed + LineFeed + LineFeed + LineFeed + LineFeed +
            'x-ms-date:' + UTCNow +
            LineFeed +
            'x-ms-version:' + StoregeServiceVersion +
            LineFeed +
            '/' + StorageAccountName + '/' + StorageConatainerName +
            LineFeed +
            'restype:container';

        RequestManagement.HMACCryptography(StringToSign, AzureStorageAPISetup.GetAccessKey(), HMAC::HMACSHA256);

        RequestManagement.AddOrReplaceRequestHeader(WebRequest, 'Authorization', StrSubstNo('%1 %2:%3', 'SharedKey', StorageAccountName, StringToSign));
        RequestManagement.AddOrReplaceRequestHeader(WebRequest, 'x-ms-date', UTCNow);
        RequestManagement.AddOrReplaceRequestHeader(WebRequest, 'x-ms-version', StoregeServiceVersion);

        TempBlob.CreateInStream(InStrm);
        WebRequest.Content.WriteFrom(InStrm);

        exit(WebClient.Send(WebRequest, WebResponse));
    end;

    procedure DownloadFromAzureStorage(var TempBlob: Codeunit "Temp Blob"; StorageAccountName: Text; StoregeServiceVersion: Text; StorageConatainerName: Text; FileName: Text; Silent: Boolean): Boolean
    var
        AzureStorageAPISetup: Record "NPR Azure Storage API Setup";
        RequestManagement: Codeunit "NPR Request Management";
        StringToSign: Text;
        UTCNow: Text;
        LineFeed: Text;
        Response: Text;
        LF: Char;
        HMAC: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512;
        WebRequest: HttpRequestMessage;
        WebResponse: HttpResponseMessage;
        WebClient: HttpClient;
        Base64Convert: Codeunit "Base64 Convert";
        WebContent: HttpContent;
        InStrm: InStream;
        OutStrm: OutStream;
        TempBlob1: Codeunit "Temp Blob";
        TypeHelper: Codeunit "Type Helper";
    begin
        case '' of
            StorageAccountName:
                Error(MissingStorageAccNameErr);
            StorageConatainerName:
                Error(MissingStorageConatainerNameErr);
        end;

        FileName := TypeHelper.UriEscapeDataString(FileName);

        AzureStorageAPISetup.Get(StorageAccountName);
        if StoregeServiceVersion = '' then
            StoregeServiceVersion := '2019-02-02';

        LF := 10;
        LineFeed := Format(LF);
        UTCNow := RequestManagement.UTCDateTimeNowText('R');

        WebRequest.SetRequestUri('https://' + StorageAccountName + '.blob.core.windows.net/' +
            StorageConatainerName + '/' + FileName);
        WebRequest.Method := 'GET';
        WebClient.Timeout := AzureStorageAPISetup.Timeout;

        StringToSign := WebRequest.Method +
            LineFeed + LineFeed + LineFeed +
            LineFeed + LineFeed +
            LineFeed + LineFeed + LineFeed + LineFeed + LineFeed + LineFeed + LineFeed +
            'x-ms-date:' + UTCNow +
            LineFeed +
            'x-ms-version:' + StoregeServiceVersion +
            LineFeed +
            '/' + StorageAccountName + '/' + StorageConatainerName + '/' + FileName;

        RequestManagement.HMACCryptography(StringToSign, AzureStorageAPISetup.GetAccessKey(), HMAC::HMACSHA256);

        RequestManagement.AddOrReplaceRequestHeader(WebRequest, 'Authorization', StrSubstNo('%1 %2:%3', 'SharedKey', StorageAccountName, StringToSign));
        RequestManagement.AddOrReplaceRequestHeader(WebRequest, 'x-ms-date', UTCNow);
        RequestManagement.AddOrReplaceRequestHeader(WebRequest, 'x-ms-version', StoregeServiceVersion);

        WebClient.Send(WebRequest, WebResponse);
        if not WebResponse.IsSuccessStatusCode() then
            if Silent then
                exit
            else
                Error(WebResponse.ReasonPhrase);

        WebContent := WebResponse.Content();
        TempBlob1.CreateInStream(InStrm);
        WebContent.ReadAs(InStrm);
        TempBlob.CreateOutStream(OutStrm);
        CopyStream(OutStrm, InStrm);
        exit(TempBlob.HasValue);
    end;

    procedure DeleteFromAzureStorage(StorageAccountName: Text; StoregeServiceVersion: Text; StorageConatainerName: Text; FileName: Text; Silent: Boolean): Boolean
    var
        AzureStorageOverview: Record "NPR Azure Storage Overview";
        AzureStorageAPISetup: Record "NPR Azure Storage API Setup";
        RequestManagement: Codeunit "NPR Request Management";
        StringToSign: Text;
        UTCNow: Text;
        Response: Text;
        LineFeed: Text;
        LF: Char;
        HMAC: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512;
        WebRequest: HttpRequestMessage;
        WebResponse: HttpResponseMessage;
        WebClient: HttpClient;
        TypeHelper: Codeunit "Type Helper";
    begin
        case '' of
            StorageAccountName:
                Error(MissingStorageAccNameErr);
            StorageConatainerName:
                Error(MissingStorageConatainerNameErr);
        end;

        AzureStorageAPISetup.Get(StorageAccountName);
        if StoregeServiceVersion = '' then
            StoregeServiceVersion := '2019-02-02';

        FileName := TypeHelper.UriEscapeDataString(FileName);

        LF := 10;
        LineFeed := Format(LF);
        UTCNow := RequestManagement.UTCDateTimeNowText('R');

        WebRequest.SetRequestUri('https://' + StorageAccountName + '.blob.core.windows.net/' + StorageConatainerName + '/' + FileName);
        WebRequest.Method := 'DELETE';
        StringToSign := WebRequest.Method +
            LineFeed + LineFeed + LineFeed +
            LineFeed + LineFeed +
            LineFeed + LineFeed + LineFeed + LineFeed + LineFeed + LineFeed + LineFeed +
            'x-ms-date:' + UTCNow +
            LineFeed +
            'x-ms-version:' + StoregeServiceVersion +
            LineFeed +
            '/' + StorageAccountName + '/' + StorageConatainerName + '/' + FileName;

        RequestManagement.HMACCryptography(StringToSign, AzureStorageAPISetup.GetAccessKey(), HMAC::HMACSHA256);

        RequestManagement.AddOrReplaceRequestHeader(WebRequest, 'Authorization', StrSubstNo('%1 %2:%3', 'SharedKey', StorageAccountName, StringToSign));
        RequestManagement.AddOrReplaceRequestHeader(WebRequest, 'x-ms-date', UTCNow);
        RequestManagement.AddOrReplaceRequestHeader(WebRequest, 'x-ms-version', StoregeServiceVersion);

        WebClient.Send(WebRequest, WebResponse);
        if not WebResponse.IsSuccessStatusCode then
            if Silent then
                exit
            else
                Error(WebResponse.ReasonPhrase);

        FileName := FileName.Replace('+', ' ');
        DeleteAzureStorageOverview(StorageAccountName, StorageConatainerName, FileName);

        exit(true);
    end;

    procedure CopyFileOnAzureStorage(ContainerFrom: Text; ContainerTo: Text; StorageAccountName: Text; StorageApiVersion: Text; FromFileName: Text; ToFileName: Text; Silent: Boolean): Boolean
    var
        AzureStorageAPISetup: Record "NPR Azure Storage API Setup";
        TempBlob: Codeunit "Temp Blob";
        RequestManagement: Codeunit "NPR Request Management";
        StringToSign: Text;
        UTCNow: Text;
        LineFeed: Text;
        Response: Text;
        LF: Char;
        HMAC: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512;
        WebRequest: HttpRequestMessage;
        WebResponse: HttpResponseMessage;
        WebClient: HttpClient;
        TypeHelper: Codeunit "Type Helper";
    begin
        case '' of
            StorageAccountName:
                Error(MissingStorageAccNameErr);
            ContainerFrom, ContainerTo:
                Error(MissingStorageConatainerNameErr);
            FromFileName, ToFileName:
                Error(MiissingToFromErr);
        end;

        if StorageApiVersion = '' then
            StorageApiVersion := '2019-02-02';

        ToFileName := TypeHelper.UriEscapeDataString(ToFileName);
        FromFileName := TypeHelper.UriEscapeDataString(FromFileName);

        AzureStorageAPISetup.Get(StorageAccountName);
        LF := 10;
        LineFeed := Format(LF);
        UTCNow := RequestManagement.UTCDateTimeNowText('R');

        WebRequest.SetRequestUri('https://' + StorageAccountName + '.blob.core.windows.net/' + ContainerTo + '/' + ToFileName);
        WebRequest.Method := 'PUT';
        WebClient.Timeout := AzureStorageAPISetup.Timeout;

        StringToSign := WebRequest.Method +
            LineFeed + LineFeed + LineFeed +
            '1' + //Format(HttpWebRequest.ContentLength) +
            LineFeed + LineFeed +
            LineFeed + LineFeed + LineFeed + LineFeed + LineFeed + LineFeed + LineFeed +
            'x-ms-copy-source:' + 'https://' + StorageAccountName + '.blob.core.windows.net/' + ContainerFrom + '/' + FromFileName +
            LineFeed +
            'x-ms-date:' + UTCNow +
            LineFeed +
            'x-ms-version:' + StorageApiVersion +
            LineFeed +
            '/' + StorageAccountName + '/' + ContainerTo + '/' + ToFileName;

        RequestManagement.HMACCryptography(StringToSign, AzureStorageAPISetup.GetAccessKey(), HMAC::HMACSHA256);

        RequestManagement.AddOrReplaceRequestHeader(WebRequest, 'Authorization', StrSubstNo('%1 %2:%3', 'SharedKey', StorageAccountName, StringToSign));
        RequestManagement.AddOrReplaceRequestHeader(WebRequest, 'x-ms-date', UTCNow);
        RequestManagement.AddOrReplaceRequestHeader(WebRequest, 'x-ms-version', StorageApiVersion);
        RequestManagement.AddOrReplaceRequestHeader(WebRequest, 'x-ms-copy-source', 'https://' + StorageAccountName + '.blob.core.windows.net/' + ContainerFrom + '/' + FromFileName);

        WebRequest.Content.WriteFrom('');

        WebClient.Send(WebRequest, WebResponse);
        if not WebResponse.IsSuccessStatusCode then
            if Silent then
                exit
            else
                Error(WebResponse.ReasonPhrase);

        ToFileName := ToFileName.Replace('+', ' ');
        exit(InsertAzureStorageOverview(StorageAccountName, ContainerTo, ToFileName));
    end;

    procedure InitializeAzureDataSource(StorageContainerName: Text; StorageAccountName: Text; StorageServiceName: Text; StoregeApiVersion: Text; DataSourceName: Text; Silent: Boolean): Boolean
    var
        AzureStorageAPISetup: Record "NPR Azure Storage API Setup";
        TempBlob: Codeunit "Temp Blob";
        RequestManagement: Codeunit "NPR Request Management";
        Arguments: Text;
        Creds: Text;
        Response: Text;
        Container: Text;
        WebRequest: HttpRequestMessage;
        WebResponse: HttpResponseMessage;
        WebClient: HttpClient;
    begin
        case '' of
            StorageAccountName:
                Error(MissingStorageAccNameErr);
            StorageServiceName:
                Error(MissingStorageAccServiceErr);
            DataSourceName:
                Error(MissingStorageAccDataSourceErr);
            StorageContainerName:
                Error(MissingStorageConatainerNameErr);
        end;

        AzureStorageAPISetup.Get(StorageAccountName);

        if StoregeApiVersion = '' then
            StoregeApiVersion := '2019-05-06';

        with RequestManagement do begin
            JsonAdd(Arguments, 'type', 'azureblob', false);
            JsonAdd(Creds, 'connectionString', StrSubstNo('DefaultEndpointsProtocol=https;AccountName=%1;AccountKey=%2', StorageAccountName, AzureStorageAPISetup.GetAccessKey()), false);
            JsonAdd(Arguments, 'credentials', Creds, true);
            JsonAdd(Container, 'name', StorageContainerName, false);
            JsonAdd(Arguments, 'container', Container, true);
        end;

        WebRequest.SetRequestUri('https://' + StorageServiceName + '.search.windows.net/datasources/' + DataSourceName + '?api-version=' + StoregeApiVersion);
        WebRequest.Method := 'PUT';
        WebClient.Timeout := AzureStorageAPISetup.Timeout;

        RequestManagement.AddOrReplaceRequestHeader(WebRequest, 'api-key', AzureStorageAPISetup.GetAdminKey());

        WebRequest.Content.WriteFrom(Arguments);
        RequestManagement.AddOrReplaceContentHeader(WebRequest, 'Content-Type', 'application/json');

        WebClient.Send(WebRequest, WebResponse);

        exit(WebResponse.IsSuccessStatusCode());
    end;

    procedure InitializeAzureIndex(StorageAccountName: Text; StorageServiceName: Text; StoregeApiVersion: Text; StorageIndexName: Text; Reinitialize: Boolean; Silent: Boolean): Boolean
    var
        AzureStorageCognitiveSearch: Record "NPR Azure Storage Cogn. Search";
        AzureStorageAPISetup: Record "NPR Azure Storage API Setup";
        TempBlob: Codeunit "Temp Blob";
        RequestManagement: Codeunit "NPR Request Management";
        Response: Text;
        Arguments: Text;
        IndexID: Text;
        IndexContent: Text;
        WebRequest: HttpRequestMessage;
        WebResponse: HttpResponseMessage;
        WebClient: HttpClient;
    begin
        // indexer must run a reload cycle for a new index to be in effect

        case '' of
            StorageServiceName:
                Error(MissingStorageAccServiceErr);
            StorageIndexName:
                Error(MissingIndexErr);
        end;

        AzureStorageAPISetup.Get(StorageAccountName);

        if Reinitialize then
            DropAzureIndex(StorageAccountName, StorageServiceName, StoregeApiVersion, StorageIndexName, true);

        if StoregeApiVersion = '' then
            StoregeApiVersion := '2019-05-06';

        with RequestManagement do begin
            JsonAdd(IndexID, 'name', 'id', false);
            JsonAdd(IndexID, 'type', 'Edm.String', false);
            JsonAdd(IndexID, 'key', true, false);
            JsonAdd(IndexID, 'searchable', false, false);

            JsonAdd(IndexContent, 'name', 'path', false);
            JsonAdd(IndexContent, 'type', 'Edm.String', false);
            JsonAdd(IndexContent, 'searchable', true, false);
            JsonAdd(IndexContent, 'filterable', true, false);
            JsonAdd(IndexContent, 'sortable', false, false);
            JsonAdd(IndexContent, 'facetable', false, false);

            JsonAdd(Arguments, 'fields', '[' + IndexID + ',' + IndexContent + ']', true);
        end;

        WebRequest.SetRequestUri('https://' + StorageServiceName + '.search.windows.net/indexes/' + StorageIndexName + '?api-version=' + StoregeApiVersion);
        WebRequest.Method := 'PUT';
        WebClient.Timeout := AzureStorageAPISetup.Timeout;

        RequestManagement.AddOrReplaceRequestHeader(WebRequest, 'api-key', AzureStorageAPISetup.GetAdminKey());

        WebRequest.Content.WriteFrom(Arguments);
        RequestManagement.AddOrReplaceContentHeader(WebRequest, 'Content-Type', 'application/json');

        WebClient.Send(WebRequest, WebResponse);
        if not WebResponse.IsSuccessStatusCode then
            if Silent then
                exit
            else
                Error(WebResponse.ReasonPhrase);

        AzureStorageCognitiveSearch."Account Name" := StorageAccountName;
        AzureStorageCognitiveSearch."Search Service Name" := StorageServiceName;
        AzureStorageCognitiveSearch.Index := StorageIndexName;
        AzureStorageCognitiveSearch.Description := 'FIELDS - "id": Edm.String, key, nonsearchable; "path": Edm.String, searchable, filterable, nonsortable; ';
        AzureStorageCognitiveSearch.SetRecFilter;
        if AzureStorageCognitiveSearch.IsEmpty then
            AzureStorageCognitiveSearch.Insert;

        exit(true);
    end;

    procedure DropAzureIndex(StorageAccountName: Text; StorageServiceName: Text; StoregeApiVersion: Text; StorageIndexName: Text; Silent: Boolean): Boolean
    var
        AzureStorageCognitiveSearch: Record "NPR Azure Storage Cogn. Search";
        AzureStorageAPISetup: Record "NPR Azure Storage API Setup";
        RequestManagement: Codeunit "NPR Request Management";
        Response: Text;
        WebRequest: HttpRequestMessage;
        WebResponse: HttpResponseMessage;
        WebClient: HttpClient;
    begin
        case '' of
            StorageServiceName:
                Error(MissingStorageAccServiceErr);
            StorageIndexName:
                Error(MissingIndexErr);
        end;

        AzureStorageAPISetup.Get(StorageAccountName);

        if not Silent then
            if not Confirm(StrSubstNo(DeleteIndexCaption, StorageIndexName), false) then
                exit;

        if StoregeApiVersion = '' then
            StoregeApiVersion := '2019-05-06';

        WebRequest.SetRequestUri('https://' + StorageServiceName + '.search.windows.net/indexes/' + StorageIndexName + '?api-version=' + StoregeApiVersion);
        WebRequest.Method := 'DELETE';
        WebClient.Timeout := AzureStorageAPISetup.Timeout;

        RequestManagement.AddOrReplaceContentHeader(WebRequest, 'Content-Type', 'application/json');
        RequestManagement.AddOrReplaceRequestHeader(WebRequest, 'api-key', AzureStorageAPISetup.GetAdminKey());

        WebClient.Send(WebRequest, WebResponse);
        if not WebResponse.IsSuccessStatusCode then
            if Silent then
                exit
            else
                Error(WebResponse.ReasonPhrase);

        AzureStorageCognitiveSearch.SetRange("Account Name", StorageAccountName);
        AzureStorageCognitiveSearch.SetRange("Search Service Name", StorageServiceName);
        AzureStorageCognitiveSearch.SetRange(Index, StorageIndexName);
        AzureStorageCognitiveSearch.DeleteAll;

        exit(true);
    end;

    procedure InitializeAzureIndexer(StorageAccountName: Text; StorageServiceName: Text; StoregeApiVersion: Text; StorageIndexerName: Text; StorageIndexName: Text; DataSourceName: Text; RefreshInterval: Text; Silent: Boolean): Boolean
    var
        AzureStorageAPISetup: Record "NPR Azure Storage API Setup";
        TempBlob: Codeunit "Temp Blob";
        RequestManagement: Codeunit "NPR Request Management";
        Arguments: Text;
        UnsupportedContentType: Text;
        Config: Text;
        Schedule: Text;
        Mappings: Text;
        Response: Text;
        OutStrm: OutStream;
        WebRequest: HttpRequestMessage;
        WebResponse: HttpResponseMessage;
        WebClient: HttpClient;
    begin
        //API call may take a long time (timeout does not necessarily mean failure for this call)

        case '' of
            StorageServiceName:
                Error(MissingStorageAccServiceErr);
            StorageIndexName:
                Error(MissingIndexErr);
        end;

        AzureStorageAPISetup.Get(StorageAccountName);

        if StoregeApiVersion = '' then
            StoregeApiVersion := '2019-05-06';

        with RequestManagement do begin
            JsonAdd(Arguments, 'dataSourceName', DataSourceName, false);
            JsonAdd(Arguments, 'targetIndexName', StorageIndexName, false);
            JsonAdd(Schedule, 'interval', RefreshInterval, false);
            JsonAdd(Arguments, 'schedule', Schedule, true);
            JsonAdd(UnsupportedContentType, 'failOnUnsupportedContentType', false, false);
            JsonAdd(Config, 'configuration', UnsupportedContentType, true);
            JsonAdd(Arguments, 'parameters', Config, true);
            JsonAdd(Mappings, 'sourceFieldName', 'metadata_storage_path', false);
            JsonAdd(Mappings, 'targetFieldName', 'path', false);
            JsonAdd(Arguments, 'fieldMappings', '[' + Mappings + ']', true);
        end;

        WebRequest.SetRequestUri('https://' + StorageServiceName + '.search.windows.net/indexers/' +
            StorageIndexerName + '?api-version=' + StoregeApiVersion);
        WebRequest.Method := 'PUT';
        WebClient.Timeout := AzureStorageAPISetup.Timeout;

        RequestManagement.AddOrReplaceRequestHeader(WebRequest, 'api-key', AzureStorageAPISetup.GetAdminKey());

        WebRequest.Content.WriteFrom(Arguments);
        RequestManagement.AddOrReplaceContentHeader(WebRequest, 'Content-Type', 'application/json');

        WebClient.Send(WebRequest, WebResponse);
        exit(WebResponse.IsSuccessStatusCode);
    end;

    local procedure ImportStorageList(StorageAccountName: Text; StorageConatainerName: Text; ListXML: Text; FullRefresh: Boolean)
    var
        RequestManagement: Codeunit "NPR Request Management";
        XMLNodeList: XmlNodeList;
        XMLNode: XmlNode;
    begin
        RequestManagement.GetNodesFromXmlText(ListXML, '//Blobs/Blob/Name', XMLNodeList);

        if FullRefresh then
            DeleteAzureStorageOverview(StorageAccountName, StorageConatainerName, '');

        foreach XMLNode in XMLNodeList do
            InsertAzureStorageOverview(StorageAccountName, StorageConatainerName, XMLNode.AsXmlElement().InnerText);
    end;

    local procedure InsertAzureStorageOverview(StorageAccountName: Text; StorageConatainerName: Text; FileName: Text): Boolean
    var
        AzureStorageOverview: Record "NPR Azure Storage Overview";
        FileManagement: Codeunit "File Management";
    begin
        AzureStorageOverview."Account name" := StorageAccountName;
        AzureStorageOverview."Container Name" := StorageConatainerName;
        AzureStorageOverview."File Name" := ConvertStr(FileManagement.GetDirectoryName(FileName), '\', '/');
        AzureStorageOverview.Name := FileManagement.GetFileName(FileName);

        AzureStorageOverview.SetRecFilter;
        if AzureStorageOverview.IsEmpty then
            exit(AzureStorageOverview.Insert);
    end;

    local procedure DeleteAzureStorageOverview(StorageAccountName: Text; StorageConatainerName: Text; FileName: Text)
    var
        AzureStorageOverview: Record "NPR Azure Storage Overview";
        FileManagement: Codeunit "File Management";
    begin
        AzureStorageOverview.SetRange("Account name", StorageAccountName);

        if StorageConatainerName > '' then
            AzureStorageOverview.SetRange("Container Name", StorageConatainerName);

        if FileName > '' then begin
            AzureStorageOverview.SetRange("File Name", ConvertStr(FileManagement.GetDirectoryName(FileName), '\', '/'));
            AzureStorageOverview.SetRange(Name, FileManagement.GetFileName(FileName));
        end;

        AzureStorageOverview.DeleteAll;
    end;

    local procedure AppendResponse(Input: Text; var Response: Text)
    var
        RequestManagement: Codeunit "NPR Request Management";
        XMLNodeList: XmlNodeList;
        XMLNode: XmlNode;
        ResponseXMLDocument: XmlDocument;
        InputXMLDocument: XmlDocument;
        XMLNodeParent: XmlNode;
    begin
        if Response = '' then begin
            Response := Input;
            exit;
        end;

        XmlDocument.ReadFrom(Response, ResponseXMLDocument);
        ResponseXMLDocument.AsXmlNode().SelectSingleNode('EnumerationResults', XMLNodeParent);

        XmlDocument.ReadFrom(Input, InputXMLDocument);
        InputXMLDocument.AsXmlNode().SelectSingleNode('EnumerationResults', XMLNode);
        XMLNodeParent.AsXmlElement().Add(XMLNode);

        ResponseXMLDocument.WriteTo(Response);
    end;

    procedure GetAzureStorageFromXml(var TempAzureStorageOverview: Record "NPR Azure Storage Overview" temporary;
        NodeList: XmlNodeList; IsContainerList: Boolean)
    var
        RequestManagement: Codeunit "NPR Request Management";
        AzureDirectory: Text;
        ContainerName: Text;
        SlashChar: Char;
        Node: XmlNode;
        ParentNode: XmlElement;
        ParentNode1: XmlElement;
        Element: XmlElement;
        Attribute: XmlAttribute;
    begin
        SlashChar := 47;

        foreach Node in NodeList do begin
            if IsContainerList then
                ContainerName := Node.AsXmlElement().InnerXml
            else begin
                AzureDirectory := DelStr(Node.AsXmlElement().InnerText,
                    RequestManagement.FindLastOccuranceInString(Node.AsXmlElement().InnerText, SlashChar));
                Node.GetParent(ParentNode);
                ParentNode.GetParent(ParentNode1);
                ParentNode1.GetParent(Element);
                Element.Attributes().Get('ContainerName', Attribute);
                ContainerName := Attribute.Value;
            end;

            TempAzureStorageOverview.SetRange("File Name", AzureDirectory);
            TempAzureStorageOverview.SetRange("Container Name", ContainerName);
            if TempAzureStorageOverview.IsEmpty then begin
                TempAzureStorageOverview."Container Name" := ContainerName;
                TempAzureStorageOverview."File Name" := AzureDirectory;
                TempAzureStorageOverview.Insert;
            end;
        end;
    end;

    local procedure CleanResidueContainers(StorageAccountName: Text; XMLNodeList: XmlNodeList)
    var
        AzureStorageOverview: Record "NPR Azure Storage Overview";
        NodeValues: Text;
        XMLNode: XmlNode;
    begin
        AzureStorageOverview.SetRange("Account name", StorageAccountName);
        if not AzureStorageOverview.FindFirst then
            exit;

        foreach XMLNode in XMLNodeList do
            //API does not allow space characters in container names
            NodeValues += XMLNode.AsXmlElement().InnerText + ' ';

        repeat
            AzureStorageOverview.SetRange("Container Name", AzureStorageOverview."Container Name");
            AzureStorageOverview.FindLast;

            if StrPos(NodeValues, AzureStorageOverview."Container Name") = 0 then
                DeleteAzureStorageOverview(StorageAccountName, AzureStorageOverview."Container Name", '');

            AzureStorageOverview.SetRange("Container Name");
        until AzureStorageOverview.Next = 0;
    end;
}

