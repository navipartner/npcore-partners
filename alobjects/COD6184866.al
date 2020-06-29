codeunit 6184866 "External Storage Interface"
{
    // NPR5.54/ALST/20200311 CASE 394895 Object created


    trigger OnRun()
    begin
    end;

    var
        ProcessingCaption: Label 'Processing...';
        DirectoryListCaption: Label 'Fetching directory list...';
        DownloadingCaption: Label 'Downloading...@1@@@@@@@@@@';
        DeletingCaption: Label 'Deleting from server...@1@@@@@@@@@@';
        UploadMsgCaption: Label 'Uploading...@1@@@@@@@@@@';
        CreatingAzureContainerCaption: Label 'Creating new container...';
        BadDirErr: Label 'Directory "%1" does not exist on the server, please check %2';
        NotYetImplementedErr: Label 'Operation type %1 not yet implemented for storage type %2';
        UnhandledStorageErr: Label 'Storage of type %1 has not yet been handled';
        DirectoryNotAllowedErr: Label 'Only files from directory "%1" may be uploaded';
        ListCaption: Label 'LIST';
        OverviewCaption: Label 'OVERVIEW';
        UploadCaption: Label 'UPLOAD';
        DownloadCaption: Label 'DOWNLOAD';
        DeleteCaption: Label 'DELETE';

    [IntegrationEvent(false, false)]
    procedure OnDiscoverStorage(var TempStorageTypes: Record "Storage Type" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnDiscoverStorageOperation(var TempStorageOperationtypes: Record "Storage Operation Type" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnDiscoverStorageOperationParameters(var TempStorageOperationParameter: Record "Storage Operation Parameter" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnConfigureSetup(var StorageSetup: Record "Storage Setup")
    begin
    end;

    procedure HandleOperation(StorageID: Text[24]; var TempStorageOperationType: Record "Storage Operation Type" temporary; var TempStorageOperationParameter: Record "Storage Operation Parameter" temporary)
    var
        StorageType: Record "Storage Type";
        AzureStorageAPIMgt: Codeunit "Azure Storage API Mgt.";
        DropboxAPIMgt: Codeunit "Dropbox API Mgt.";
        FTPManagement: Codeunit "FTP Management";
    begin
        case TempStorageOperationType."Storage Type" of
            DropboxAPIMgt.StorageType():
                HandleDropBoxOperation(StorageID, TempStorageOperationType, TempStorageOperationParameter);
            AzureStorageAPIMgt.StorageType():
                HandleAzureStorageOperation(StorageID, TempStorageOperationType, TempStorageOperationParameter);
            FTPManagement.StorageType():
                HandleFTPOperation(StorageID, TempStorageOperationType, TempStorageOperationParameter);
            else
                Error(UnhandledStorageErr);
        end;
    end;

    local procedure HandleDropBoxOperation(StorageID: Text[24]; var TempStorageOperationType: Record "Storage Operation Type" temporary; var TempStorageOperationParameter: Record "Storage Operation Parameter" temporary)
    var
        DropBoxOverview: Record "DropBox Overview";
    begin
        case TempStorageOperationType."Operation Code" of
            UploadCaption:
                DropBoxUpload(StorageID, TempStorageOperationParameter);
            DownloadCaption:
                DropBoxDownload(StorageID, TempStorageOperationParameter);
            DeleteCaption:
                DropBoxDelete(StorageID, TempStorageOperationParameter);
            ListCaption:
                DropBoxUpdateRefresh(StorageID, TempStorageOperationParameter);
            OverviewCaption:
                DropBoxOverviewRun(StorageID, DropBoxOverview);
            else
                Error(NotYetImplementedErr, TempStorageOperationType."Operation Code", TempStorageOperationType."Storage Type");
        end;
    end;

    local procedure HandleAzureStorageOperation(StorageID: Text[24]; var TempStorageOperationType: Record "Storage Operation Type" temporary; var TempStorageOperationParameter: Record "Storage Operation Parameter" temporary)
    var
        AzureStorageOverview: Record "Azure Storage Overview";
    begin
        case TempStorageOperationType."Operation Code" of
            UploadCaption:
                AzureStorageUpload(StorageID, TempStorageOperationParameter);
            DownloadCaption:
                AzureStorageDownload(StorageID, TempStorageOperationParameter);
            DeleteCaption:
                AzureStorageDelete(StorageID, TempStorageOperationParameter);
            ListCaption:
                AzureStorageUpdateRefresh(StorageID, TempStorageOperationParameter);
            OverviewCaption:
                AzureStorageOverviewRun(StorageID, AzureStorageOverview);
            else
                Error(NotYetImplementedErr, TempStorageOperationType."Operation Code", TempStorageOperationType."Storage Type");
        end;
    end;

    local procedure HandleFTPOperation(StorageID: Text[24]; var TempStorageOperationType: Record "Storage Operation Type" temporary; var TempStorageOperationParameter: Record "Storage Operation Parameter" temporary)
    var
        FTPOverview: Record "FTP Overview";
    begin
        case TempStorageOperationType."Operation Code" of
            UploadCaption:
                FTPUpload(StorageID, TempStorageOperationParameter);
            DownloadCaption:
                FTPDownload(StorageID, TempStorageOperationParameter);
            DeleteCaption:
                FTPDelete(StorageID, TempStorageOperationParameter);
            ListCaption:
                FTPUpdateRefresh(StorageID, TempStorageOperationParameter);
            OverviewCaption:
                FTPOverviewRun(StorageID, FTPOverview);
            else
                Error(NotYetImplementedErr, TempStorageOperationType."Operation Code", TempStorageOperationType."Storage Type");
        end;
    end;

    procedure DropBoxUpdateRefresh(AccountCode: Text; var TempStorageOperationParameter: Record "Storage Operation Parameter" temporary)
    var
        DropboxAPIMgt: Codeunit "Dropbox API Mgt.";
        Dialog: Dialog;
        Refresh: Boolean;
        Cursor: Text;
        Paths: DotNet npNetXmlDocument;
    begin
        //TempStorageOperationParameter: boolean used to call refresh or simply to update

        if TempStorageOperationParameter."Parameter Value" > '' then
            Evaluate(Refresh, TempStorageOperationParameter."Parameter Value");

        if GuiAllowed then
            Dialog.Open(ProcessingCaption);

        DropboxAPIMgt.ListFolderFilesDropBox(AccountCode, '', Cursor, Paths, Refresh, true, false);

        if GuiAllowed then
            Dialog.Close;
    end;

    procedure DropBoxUpload(AccountCode: Text; var TempStorageOperationParameter: Record "Storage Operation Parameter" temporary)
    var
        DropBoxOverview: Record "DropBox Overview";
        TempDropBoxOverview: Record "DropBox Overview" temporary;
        DropBoxAPISetup: Record "DropBox API Setup";
        TempBlob: Codeunit "Temp Blob";
        File: Record File;
        ServerOverview: Page "Server Overview";
        FileManagement: Codeunit "File Management";
        RequestManagement: Codeunit "Request Management";
        DropboxAPIMgt: Codeunit "Dropbox API Mgt.";
        Reupload: Boolean;
        DirectoryName: Text;
        ServerFileName: Text;
        Cursor: Text;
        Dialog: Dialog;
        Paths: DotNet npNetXmlDocument;
        Path: DotNet npNetXmlNode;
        i: Integer;
    begin
        //TempStorageOperationParameter[first]:   file path and name on NAV server
        //TempStorageOperationParameter[second]:  directory path on DropBox server
        //TempStorageOperationParameter[third]:   files found in the Overview table will not be reuploaded unless parameter is true

        DropBoxAPISetup.Get(AccountCode);

        ServerFileName := TempStorageOperationParameter."Parameter Value";

        if not (TempStorageOperationParameter.Next = 0) then
            DirectoryName := TempStorageOperationParameter."Parameter Value";

        if not (TempStorageOperationParameter.Next = 0) then
            if TempStorageOperationParameter."Parameter Value" > '' then
                Evaluate(Reupload, TempStorageOperationParameter."Parameter Value");

        if ServerFileName = '' then begin
            if not FileManagement.ServerDirectoryExists(DropBoxAPISetup."Storage On Server") then
                Error(BadDirErr, DropBoxAPISetup."Storage On Server", DropBoxAPISetup.TableCaption);

            File.SetRange(Path, DropBoxAPISetup."Storage On Server");
            File.SetRange("Is a file", true);
            ServerOverview.SetTableView(File);
            ServerOverview.Editable := false;
            ServerOverview.LookupMode := true;
            if ServerOverview.RunModal <> ACTION::LookupOK then
                exit;

            ServerOverview.GetRecord(File);

            File.SetRecFilter;
        end else begin
            File.SetRange(Path, FileManagement.GetDirectoryName(ServerFileName));

            File.Name := FileManagement.GetFileName(ServerFileName);
            if File.Name > '' then
                File.SetRange(Name, File.Name);

            File.SetRange("Is a file", true);
        end;

        if not File.FindSet then
            exit;

        if StrPos(UpperCase(File.Path), UpperCase(FileManagement.GetDirectoryName(DropBoxAPISetup."Storage On Server"))) <> 1 then
            Error(DirectoryNotAllowedErr, DropBoxAPISetup."Storage On Server");

        if DirectoryName = '' then begin
            if GuiAllowed then
                Dialog.Open(DirectoryListCaption);

            DropboxAPIMgt.ListFolderFilesDropBox(DropBoxAPISetup."Account Code", '', Cursor, Paths, false, false, false);

            foreach Path in Paths.SelectNodes('/root/*') do begin
                TempDropBoxOverview.SetRange("File Name", Path.InnerText);
                if TempDropBoxOverview.IsEmpty then begin
                    TempDropBoxOverview."Account Code" := DropBoxAPISetup."Account Code";
                    TempDropBoxOverview."File Name" := Path.InnerText;

                    TempDropBoxOverview.Insert;
                end;
            end;

            TempDropBoxOverview.Reset;

            Commit;

            if GuiAllowed then
                Dialog.Close;

            if not (PAGE.RunModal(PAGE::"DropBox Dir. Select", TempDropBoxOverview) = ACTION::LookupOK) then
                exit;

            DirectoryName := TempDropBoxOverview."File Name";
        end;

        if GuiAllowed then
            Dialog.Open(UploadMsgCaption);

        repeat
            DropBoxOverview.SetRange("Account Code", AccountCode);
            DropBoxOverview.SetRange("File Name", DirectoryName);
            DropBoxOverview.SetRange(Name, File.Name);
            if DropBoxOverview.IsEmpty or Reupload then begin
                TempBlob.Import(File.Path + '\' + File.Name);

                DropboxAPIMgt.UploadToDropbox(TempBlob, DropBoxAPISetup."Account Code", DirectoryName + '/' + File.Name, true, false);

                Commit;
            end;

            if GuiAllowed then begin
                Dialog.Update(1, (i / File.Count * 10000) div 1);
                i += 1;
            end;
        until File.Next = 0;

        if GuiAllowed then
            Dialog.Close;
    end;

    procedure DropBoxDownload(AccountCode: Text; var TempStorageOperationParameter: Record "Storage Operation Parameter" temporary)
    var
        DropBoxOverview: Record "DropBox Overview";
        TempBlob: Codeunit "Temp Blob";
        DropBoxAPISetup: Record "DropBox API Setup";
        DropboxAPIMgt: Codeunit "Dropbox API Mgt.";
        FileManagement: Codeunit "File Management";
        DataExchangeType: Code[20];
        StorageServerFilePath: Text;
        StorageServerFileName: Text;
        Dialog: Dialog;
        i: Integer;
    begin
        //TempStorageOperationParameter[first]: file path [and name] on the DropBox storage server
        //TempStorageOperationParameter[second]: data exchange type used to import incoming document

        if TempStorageOperationParameter."Parameter Value" = '' then begin
            if not DropBoxOverviewRun(AccountCode, DropBoxOverview) then
                exit;

            DropBoxOverview.SetRecFilter;
        end else begin
            StorageServerFileName := FileManagement.GetFileName(TempStorageOperationParameter."Parameter Value");
            StorageServerFilePath := CopyStr(TempStorageOperationParameter."Parameter Value", 1, StrLen(TempStorageOperationParameter."Parameter Value") - StrLen(StorageServerFileName) - 1);

            DropBoxOverview.SetRange("Account Code", AccountCode);
            DropBoxOverview.SetRange("File Name", StorageServerFilePath);

            if StorageServerFileName > '' then
                DropBoxOverview.SetRange(Name, StorageServerFileName);
        end;

        if not (TempStorageOperationParameter.Next = 0) then
            DataExchangeType := TempStorageOperationParameter."Parameter Value";

        if not DropBoxOverview.FindSet then
            exit;

        DropBoxAPISetup.Get(AccountCode);

        if DataExchangeType = '' then
            if not FileManagement.ServerDirectoryExists(DropBoxAPISetup."Storage On Server") then
                Error(BadDirErr, DropBoxAPISetup."Storage On Server", DropBoxAPISetup.TableCaption);

        if GuiAllowed then
            Dialog.Open(DownloadingCaption);

        repeat
            DropboxAPIMgt.DownloadFromDropbox(TempBlob, AccountCode, DropBoxOverview."File Name" + '/' + DropBoxOverview.Name, false);

            if DataExchangeType > '' then
                CreateIncomingDocument(TempBlob, DropBoxOverview.Name, DataExchangeType)
            else
                TempBlob.Export(DropBoxAPISetup."Storage On Server" + DropBoxOverview.Name);

            if GuiAllowed then begin
                Dialog.Update(1, (i / DropBoxOverview.Count * 10000) div 1);
                i += 1;
            end;
        until DropBoxOverview.Next = 0;

        if GuiAllowed then
            Dialog.Close;
    end;

    procedure DropBoxDelete(AccountCode: Text; var TempStorageOperationParameter: Record "Storage Operation Parameter" temporary)
    var
        DropBoxOverview: Record "DropBox Overview";
        DropboxAPIMgt: Codeunit "Dropbox API Mgt.";
        FileManagement: Codeunit "File Management";
        Dialog: Dialog;
        StorageServerFilePath: Text;
        StorageServerFileName: Text;
        i: Integer;
        OverviewCount: Integer;
    begin
        //TempStorageOperationParameter: file path [and name] on the DropBox storage server

        if TempStorageOperationParameter."Parameter Value" = '' then begin
            if not DropBoxOverviewRun(AccountCode, DropBoxOverview) then
                exit;

            DropBoxOverview.SetRecFilter;
        end else begin
            StorageServerFileName := FileManagement.GetFileName(TempStorageOperationParameter."Parameter Value");
            StorageServerFilePath := CopyStr(TempStorageOperationParameter."Parameter Value", 1, StrLen(TempStorageOperationParameter."Parameter Value") - StrLen(StorageServerFileName) - 1);

            DropBoxOverview.SetRange("Account Code", AccountCode);
            DropBoxOverview.SetRange("File Name", StorageServerFilePath);

            if StorageServerFileName > '' then
                DropBoxOverview.SetRange(Name, StorageServerFileName);
        end;

        if not DropBoxOverview.FindSet then
            exit;

        if GuiAllowed then
            Dialog.Open(DeletingCaption);

        repeat
            OverviewCount := DropBoxOverview.Count;

            DropboxAPIMgt.DeleteFromDropbox(AccountCode, DropBoxOverview."File Name" + '/' + DropBoxOverview.Name, false);

            if GuiAllowed then begin
                Dialog.Update(1, (i / OverviewCount * 10000) div 1);
                i += 1;
            end;
        until DropBoxOverview.Next = 0;

        if GuiAllowed then
            Dialog.Close;
    end;

    procedure DropBoxOverviewRun(AccountCode: Text; var DropBoxOverview: Record "DropBox Overview"): Boolean
    begin
        DropBoxOverview.SetRange("Account Code", AccountCode);

        exit(PAGE.RunModal(PAGE::"DropBox Overview", DropBoxOverview) = ACTION::LookupOK);
    end;

    procedure AzureStorageUpdateRefresh(AccountName: Text; var TempStorageOperationParameter: Record "Storage Operation Parameter" temporary)
    var
        AzureStoageAPIMgt: Codeunit "Azure Storage API Mgt.";
        Refresh: Boolean;
        ResponseXMLString: Text;
        Dialog: Dialog;
    begin
        //TempStorageOperationParameter: boolean used to call refresh or simply to update

        if TempStorageOperationParameter."Parameter Value" > '' then
            Evaluate(Refresh, TempStorageOperationParameter."Parameter Value");

        if GuiAllowed then
            Dialog.Open(ProcessingCaption);

        AzureStoageAPIMgt.ListAzureStorage(AccountName, '', '', Refresh, true, false, ResponseXMLString);

        if GuiAllowed then
            Dialog.Close;
    end;

    procedure AzureStorageUpload(AccountCode: Text; var TempStorageOperationParameter: Record "Storage Operation Parameter" temporary)
    var
        AzureStorageAPISetup: Record "Azure Storage API Setup";
        AzureStorageOverview: Record "Azure Storage Overview";
        TempAzureStorageOverview: Record "Azure Storage Overview" temporary;
        TempBlob: Codeunit "Temp Blob";
        File: Record File;
        ServerOverview: Page "Server Overview";
        FileManagement: Codeunit "File Management";
        AzureStoageAPIMgt: Codeunit "Azure Storage API Mgt.";
        RequestManagement: Codeunit "Request Management";
        Reupload: Boolean;
        ContainerName: Text;
        DirectoryName: Text;
        ServerFileName: Text;
        StorageMappingXML: Text;
        XMLFolderList: DotNet npNetXmlNodeList;
        XMLContainerList: DotNet npNetXmlNodeList;
        Dialog: Dialog;
        i: Integer;
    begin
        //TempStorageOperationParameter[first]:   file path and name on NAV server
        //TempStorageOperationParameter[second]:  directory path on Azure Storage
        //TempStorageOperationParameter[third]:   container name on Azure Storage
        //TempStorageOperationParameter[fourth]:  files found in the Overview table will not be reuploaded unless parameter is true

        AzureStorageAPISetup.Get(AccountCode);
        ServerFileName := TempStorageOperationParameter."Parameter Value";

        if not (TempStorageOperationParameter.Next = 0) then
            DirectoryName := TempStorageOperationParameter."Parameter Value";

        if not (TempStorageOperationParameter.Next = 0) then
            ContainerName := TempStorageOperationParameter."Parameter Value";

        if not (TempStorageOperationParameter.Next = 0) then
            if TempStorageOperationParameter."Parameter Value" > '' then
                Evaluate(Reupload, TempStorageOperationParameter."Parameter Value");

        if not FileManagement.ServerDirectoryExists(AzureStorageAPISetup."Storage On Server") then
            Error(BadDirErr, AzureStorageAPISetup."Storage On Server", AzureStorageAPISetup.TableCaption);

        if ServerFileName = '' then begin
            File.SetRange(Path, AzureStorageAPISetup."Storage On Server");
            File.SetRange("Is a file", true);
            ServerOverview.SetTableView(File);
            ServerOverview.Editable := false;
            ServerOverview.LookupMode := true;
            if ServerOverview.RunModal <> ACTION::LookupOK then
                exit;

            ServerOverview.GetRecord(File);

            File.SetRecFilter;
        end else begin
            File.SetRange(Path, FileManagement.GetDirectoryName(ServerFileName));

            File.Name := FileManagement.GetFileName(ServerFileName);
            if File.Name > '' then
                File.SetRange(Name, File.Name);

            File.SetRange("Is a file", true);
        end;

        if not File.FindSet then
            exit;

        if StrPos(UpperCase(File.Path), UpperCase(FileManagement.GetDirectoryName(AzureStorageAPISetup."Storage On Server"))) = 0 then
            Error(DirectoryNotAllowedErr, AzureStorageAPISetup."Storage On Server");

        if (DirectoryName = '') or (ContainerName = '') then begin
            if GuiAllowed then
                Dialog.Open(DirectoryListCaption);

            AzureStoageAPIMgt.ListAzureStorage(AzureStorageAPISetup."Account Name", '', '', false, false, false, StorageMappingXML);

            TempAzureStorageOverview."Account name" := AzureStorageAPISetup."Account Name";
            RequestManagement.GetNodesFromXmlText(StorageMappingXML, '//Blob/Name', XMLFolderList);
            AzureStoageAPIMgt.GetAzureStorageFromXml(TempAzureStorageOverview, XMLFolderList, false);

            RequestManagement.GetNodesFromXmlText(StorageMappingXML, '//Container/Name', XMLContainerList);
            AzureStoageAPIMgt.GetAzureStorageFromXml(TempAzureStorageOverview, XMLContainerList, true);

            TempAzureStorageOverview.Reset;

            Commit;

            if GuiAllowed then
                Dialog.Close;

            if not (PAGE.RunModal(PAGE::"Azure Storage Dir. Select", TempAzureStorageOverview) = ACTION::LookupOK) then
                exit;

            DirectoryName := TempAzureStorageOverview."File Name";
            ContainerName := TempAzureStorageOverview."Container Name";
        end;

        AzureStorageOverview.SetRange("Account name", AzureStorageAPISetup."Account Name");
        AzureStorageOverview.SetRange("Container Name", ContainerName);
        if AzureStorageOverview.IsEmpty then begin
            if GuiAllowed then
                Dialog.Open(CreatingAzureContainerCaption);

            if AzureStoageAPIMgt.CreateContainerAzureStorage(AzureStorageAPISetup."Account Name", '', ContainerName, true) then;

            if GuiAllowed then
                Dialog.Close;
        end;

        if GuiAllowed then
            Dialog.Open(UploadMsgCaption);

        repeat
            AzureStorageOverview.SetRange("File Name", DirectoryName);
            AzureStorageOverview.SetRange(Name, File.Name);
            if AzureStorageOverview.IsEmpty or Reupload then begin
                TempBlob.Import(File.Path + '/' + File.Name);

                AzureStoageAPIMgt.UploadToAzureStorage(TempBlob, AzureStorageAPISetup."Account Name", '', ContainerName,
                                                      DirectoryName + '/' + File.Name, '', false);

                Commit;
            end;

            if GuiAllowed then begin
                Dialog.Update(1, (i / File.Count * 10000) div 1);
                i += 1;
            end;
        until File.Next = 0;

        if GuiAllowed then
            Dialog.Close;
    end;

    procedure AzureStorageDownload(AccountCode: Text; var TempStorageOperationParameter: Record "Storage Operation Parameter" temporary)
    var
        AzureStorageOverview: Record "Azure Storage Overview";
        TempBlob: Codeunit "Temp Blob";
        AzureStorageAPISetup: Record "Azure Storage API Setup";
        FileManagement: Codeunit "File Management";
        AzureStoageAPIMgt: Codeunit "Azure Storage API Mgt.";
        Dialog: Dialog;
        DataExchangeType: Code[20];
        StorageServerFilePath: Text;
        StorageServerFileName: Text;
        ContainerName: Text;
        DirectoryFileName: Text;
        i: Integer;
    begin
        //TempStorageOperationParameter[first]:   directory [and file name] on the Azure storage server
        //TempStorageOperationParameter[second]:  container name on the Azure storage server
        //TempStorageOperationParameter[third]:   data exchange type used to import incoming document

        DirectoryFileName := TempStorageOperationParameter."Parameter Value";

        if not (TempStorageOperationParameter.Next = 0) then
            ContainerName := TempStorageOperationParameter."Parameter Value";

        if not (TempStorageOperationParameter.Next = 0) then
            DataExchangeType := TempStorageOperationParameter."Parameter Value";

        if (DirectoryFileName = '') or
          (ContainerName = '')
        then begin
            if not AzureStorageOverviewRun(AccountCode, AzureStorageOverview) then
                exit;

            AzureStorageOverview.SetRecFilter;
        end else begin
            StorageServerFileName := FileManagement.GetFileName(DirectoryFileName);
            StorageServerFilePath := CopyStr(DirectoryFileName, 1, StrLen(DirectoryFileName) - StrLen(StorageServerFileName) - 1);

            AzureStorageOverview.SetRange("Account name", AccountCode);
            AzureStorageOverview.SetRange("Container Name", ContainerName);
            AzureStorageOverview.SetRange("File Name", StorageServerFilePath);
            if StorageServerFileName > '' then
                AzureStorageOverview.SetRange(Name, StorageServerFileName);
        end;

        if not AzureStorageOverview.FindSet then
            exit;

        AzureStorageAPISetup.Get(AccountCode);

        if DataExchangeType = '' then
            if not FileManagement.ServerDirectoryExists(AzureStorageAPISetup."Storage On Server") then
                Error(BadDirErr, AzureStorageAPISetup."Storage On Server", AzureStorageAPISetup.TableCaption);

        if GuiAllowed then
            Dialog.Open(DownloadingCaption);

        repeat
            AzureStoageAPIMgt.DownloadFromAzureStorage(TempBlob, AccountCode, '', AzureStorageOverview."Container Name", AzureStorageOverview."File Name" + '/' + AzureStorageOverview.Name, false);

            if DataExchangeType > '' then
                CreateIncomingDocument(TempBlob, AzureStorageOverview.Name, DataExchangeType)
            else
                TempBlob.Export(AzureStorageAPISetup."Storage On Server" + AzureStorageOverview.Name);

            if GuiAllowed then begin
                Dialog.Update(1, (i / AzureStorageOverview.Count * 10000) div 1);
                i += 1;
            end;
        until AzureStorageOverview.Next = 0;

        if GuiAllowed then
            Dialog.Close;
    end;

    procedure AzureStorageDelete(AccountCode: Text; var TempStorageOperationParameter: Record "Storage Operation Parameter" temporary)
    var
        AzureStorageOverview: Record "Azure Storage Overview";
        AzureStoageAPIMgt: Codeunit "Azure Storage API Mgt.";
        FileManagement: Codeunit "File Management";
        Dialog: Dialog;
        ContainerName: Text;
        StorageServerFilePath: Text;
        StorageServerFileName: Text;
        DirectoryFileName: Text;
        i: Integer;
        OverviewCount: Integer;
    begin
        //TempStorageOperationParameter[first]:   directory [and name] on the Azure storage server
        //TempStorageOperationParameter[second]:  container name on the Azure storage server

        DirectoryFileName := TempStorageOperationParameter."Parameter Value";

        if not (TempStorageOperationParameter.Next = 0) then
            ContainerName := TempStorageOperationParameter."Parameter Value";

        if (DirectoryFileName = '') or
          (ContainerName = '')
        then begin
            if not AzureStorageOverviewRun(AccountCode, AzureStorageOverview) then
                exit;

            AzureStorageOverview.SetRecFilter;
        end else begin
            StorageServerFileName := FileManagement.GetFileName(DirectoryFileName);
            StorageServerFilePath := CopyStr(DirectoryFileName, 1, StrLen(DirectoryFileName) - StrLen(StorageServerFileName) - 1);

            AzureStorageOverview.SetRange("Account name", AccountCode);
            AzureStorageOverview.SetRange("Container Name", ContainerName);
            AzureStorageOverview.SetRange("File Name", StorageServerFilePath);
            if StorageServerFileName > '' then
                AzureStorageOverview.SetRange(Name, StorageServerFileName);
        end;

        if not AzureStorageOverview.FindSet then
            exit;

        if GuiAllowed then
            Dialog.Open(DeletingCaption);

        repeat
            OverviewCount := AzureStorageOverview.Count;

            AzureStoageAPIMgt.DeleteFromAzureStorage(AccountCode, '', AzureStorageOverview."Container Name", AzureStorageOverview."File Name" + '/' + AzureStorageOverview.Name, false);

            if GuiAllowed then begin
                Dialog.Update(1, (i / OverviewCount * 10000) div 1);
                i += 1;
            end;
        until AzureStorageOverview.Next = 0;

        if GuiAllowed then
            Dialog.Close;
    end;

    procedure AzureStorageOverviewRun(AccountName: Text; var AzureStorageOverview: Record "Azure Storage Overview"): Boolean
    begin
        AzureStorageOverview.SetRange("Account name", AccountName);

        exit(PAGE.RunModal(PAGE::"Azure Storage Overview", AzureStorageOverview) = ACTION::LookupOK);
    end;

    procedure FTPUpdateRefresh(AccountCode: Text; var TempStorageOperationParameter: Record "Storage Operation Parameter" temporary)
    var
        FTPManagement: Codeunit "FTP Management";
        Dialog: Dialog;
        Refresh: Boolean;
        CurrentPathDepth: Text;
        Directories: DotNet npNetXmlDocument;
    begin
        //TempStorageOperationParameter: boolean used to call refresh or simply to update

        if TempStorageOperationParameter."Parameter Value" > '' then
            Evaluate(Refresh, TempStorageOperationParameter."Parameter Value");

        if GuiAllowed then
            Dialog.Open(ProcessingCaption);

        FTPManagement.ListFTP(AccountCode, 0, CurrentPathDepth, '', false, Refresh, true, false, Directories, false);

        if GuiAllowed then
            Dialog.Close;
    end;

    procedure FTPUpload(HostCode: Text; var TempStorageOperationParameter: Record "Storage Operation Parameter" temporary)
    var
        TempBlob: Codeunit "Temp Blob";
        FTPSetup: Record "FTP Setup";
        FTPOverview: Record "FTP Overview";
        TempFTPOverview: Record "FTP Overview" temporary;
        File: Record File;
        ServerOverview: Page "Server Overview";
        FTPManagement: Codeunit "FTP Management";
        FileManagement: Codeunit "File Management";
        Reupload: Boolean;
        DirectoryName: Text;
        ServerFileName: Text;
        CurrentPathDepth: Text;
        Dialog: Dialog;
        Directories: DotNet npNetXmlDocument;
        Directory: DotNet npNetXmlNode;
        i: Integer;
    begin
        //TempStorageOperationParameter[first]:   file path and name on NAV server
        //TempStorageOperationParameter[second]:  directory path on FTP server
        //TempStorageOperationParameter[third]:   files found in the Overview table will not be reuploaded unless parameter is true

        FTPSetup.Get(HostCode);

        if not FileManagement.ServerDirectoryExists(FTPSetup."Storage On Server") then
            Error(BadDirErr, FTPSetup."Storage On Server", FTPSetup.TableCaption);

        ServerFileName := TempStorageOperationParameter."Parameter Value";

        if not (TempStorageOperationParameter.Next = 0) then
            DirectoryName := TempStorageOperationParameter."Parameter Value";

        if not (TempStorageOperationParameter.Next = 0) then
            if TempStorageOperationParameter."Parameter Value" > '' then
                Evaluate(Reupload, TempStorageOperationParameter."Parameter Value");

        if ServerFileName = '' then begin
            File.SetRange(Path, FTPSetup."Storage On Server");
            File.SetRange("Is a file", true);
            ServerOverview.SetTableView(File);
            ServerOverview.Editable := false;
            ServerOverview.LookupMode := true;
            if ServerOverview.RunModal <> ACTION::LookupOK then
                exit;

            ServerOverview.GetRecord(File);

            File.SetRecFilter;
        end else begin
            File.SetRange(Path, FileManagement.GetDirectoryName(ServerFileName));

            File.Name := FileManagement.GetFileName(ServerFileName);
            if File.Name > '' then
                File.SetRange(Name, File.Name);

            File.SetRange("Is a file", true);
        end;

        if not File.FindSet then
            exit;

        if StrPos(UpperCase(File.Path), UpperCase(FileManagement.GetDirectoryName(FTPSetup."Storage On Server"))) = 0 then
            Error(DirectoryNotAllowedErr, FTPSetup."Storage On Server");

        if DirectoryName = '' then begin
            if GuiAllowed then
                Dialog.Open(DirectoryListCaption);

            FTPManagement.ListFTP(FTPSetup.Code, 0, CurrentPathDepth, '', false, false, false, false, Directories, false);

            foreach Directory in Directories.SelectNodes('/root/*') do begin
                TempFTPOverview.SetRange("File Name", Directory.InnerText);
                if TempFTPOverview.IsEmpty then begin
                    TempFTPOverview."Host Code" := FTPSetup.Code;
                    TempFTPOverview."File Name" := Directory.InnerText;

                    TempFTPOverview.Insert;
                end;
            end;

            TempFTPOverview.Reset;

            Commit;

            if GuiAllowed then
                Dialog.Close;

            if not (PAGE.RunModal(PAGE::"FTP Dir. Select", TempFTPOverview) = ACTION::LookupOK) then
                exit;

            DirectoryName := '/' + TempFTPOverview."File Name";
        end;

        if GuiAllowed then
            Dialog.Open(UploadCaption);

        repeat
            FTPOverview.SetRange("Host Code", HostCode);
            FTPOverview.SetRange("File Name", DirectoryName);
            FTPOverview.SetRange(Name, File.Name);
            if FTPOverview.IsEmpty or Reupload then begin
                TempBlob.Import(File.Path + '\' + File.Name);

                FTPManagement.UploadToFTP(TempBlob, FTPSetup.Code, DirectoryName, File.Name, false, false);

                Commit;
            end;

            if GuiAllowed then begin
                Dialog.Update(1, (i / File.Count * 10000) div 1);
                i += 1;
            end;
        until File.Next = 0;

        if GuiAllowed then
            Dialog.Close;
    end;

    procedure FTPDownload(HostCode: Text; var TempStorageOperationParameter: Record "Storage Operation Parameter" temporary)
    var
        TempBlob: Codeunit "Temp Blob";
        FTPSetup: Record "FTP Setup";
        FTPOverview: Record "FTP Overview";
        FTPManagement: Codeunit "FTP Management";
        FileManagement: Codeunit "File Management";
        Dialog: Dialog;
        DataExchangeType: Code[20];
        StorageServerFilePath: Text;
        StorageServerFileName: Text;
        i: Integer;
    begin
        //TempStorageOperationParameter[first]: file path [and name] on the FTP storage server
        //TempStorageOperationParameter[second]: data exchange type used to import incoming document

        if TempStorageOperationParameter."Parameter Value" = '' then begin
            if not FTPOverviewRun(HostCode, FTPOverview) then
                exit;

            FTPOverview.SetRecFilter;
        end else begin
            StorageServerFileName := FileManagement.GetFileName(TempStorageOperationParameter."Parameter Value");
            StorageServerFilePath := CopyStr(TempStorageOperationParameter."Parameter Value", 1, StrLen(TempStorageOperationParameter."Parameter Value") - StrLen(StorageServerFileName));

            FTPOverview.SetRange("Host Code", HostCode);
            FTPOverview.SetRange("File Name", StorageServerFilePath);

            if StorageServerFileName > '' then
                FTPOverview.SetRange(Name, StorageServerFileName);
        end;

        if not (TempStorageOperationParameter.Next = 0) then
            DataExchangeType := TempStorageOperationParameter."Parameter Value";

        if not FTPOverview.FindSet then
            exit;

        FTPSetup.Get(HostCode);

        if DataExchangeType = '' then
            if not FileManagement.ServerDirectoryExists(FTPSetup."Storage On Server") then
                Error(BadDirErr, FTPSetup."Storage On Server", FTPSetup.TableCaption);

        if GuiAllowed then
            Dialog.Open(DownloadingCaption);

        repeat
            FTPManagement.DownloadFromFTP(TempBlob, HostCode, FTPOverview."File Name", FTPOverview.Name, false, false);

            if DataExchangeType > '' then
                CreateIncomingDocument(TempBlob, FTPOverview.Name, DataExchangeType)
            else
                TempBlob.Export(FTPSetup."Storage On Server" + FTPOverview.Name);

            if GuiAllowed then begin
                Dialog.Update(1, (i / FTPOverview.Count * 10000) div 1);
                i += 1;
            end;
        until FTPOverview.Next = 0;

        if GuiAllowed then
            Dialog.Close;
    end;

    procedure FTPDelete(HostCode: Text; var TempStorageOperationParameter: Record "Storage Operation Parameter" temporary)
    var
        FTPOverview: Record "FTP Overview";
        FTPManagement: Codeunit "FTP Management";
        FileManagement: Codeunit "File Management";
        Dialog: Dialog;
        FileName: Text;
        StorageServerFilePath: Text;
        StorageServerFileName: Text;
        i: Integer;
        OverviewCount: Integer;
    begin
        //TempStorageOperationParameter: file path + name on the FTP storage server

        if TempStorageOperationParameter."Parameter Value" = '' then begin
            if not FTPOverviewRun(HostCode, FTPOverview) then
                exit;

            FTPOverview.SetRecFilter;
        end else begin
            StorageServerFileName := FileManagement.GetFileName(TempStorageOperationParameter."Parameter Value");
            StorageServerFilePath := CopyStr(TempStorageOperationParameter."Parameter Value", 1, StrLen(TempStorageOperationParameter."Parameter Value") - StrLen(StorageServerFileName));

            FTPOverview.SetRange("Host Code", HostCode);
            FTPOverview.SetRange("File Name", StorageServerFilePath);

            if StorageServerFileName > '' then
                FTPOverview.SetRange(Name, StorageServerFileName);
        end;

        if not FTPOverview.FindSet then
            exit;

        if GuiAllowed then
            Dialog.Open(DeletingCaption);

        repeat
            OverviewCount := FTPOverview.Count;

            FTPManagement.DeleteFromFTP(HostCode, FTPOverview."File Name", FTPOverview.Name, false, false);

            if GuiAllowed then begin
                Dialog.Update(1, (i / OverviewCount * 10000) div 1);
                i += 1;
            end;
        until FTPOverview.Next = 0;

        if GuiAllowed then
            Dialog.Close;
    end;

    procedure FTPOverviewRun(HostCode: Text; var FTPOverview: Record "FTP Overview"): Boolean
    begin
        FTPOverview.SetRange("Host Code", HostCode);

        exit(PAGE.RunModal(PAGE::"FTP Overview", FTPOverview) = ACTION::LookupOK);
    end;

    procedure CreateIncomingDocument(var TempBlob: Codeunit "Temp Blob"; FileName: Text; DataExhangeType: Code[20])
    var
        IncomingDocument: Record "Incoming Document";
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        FileManagement: Codeunit "File Management";
        RecRef: RecordRef;
    begin
        IncomingDocument.Init;
        IncomingDocument.CreateIncomingDocument(FileName, '');

        IncomingDocument."Data Exchange Type" := DataExhangeType;

        IncomingDocument.Modify(true);

        with IncomingDocumentAttachment do begin
            Init;

            "Incoming Document Entry No." := IncomingDocument."Entry No.";
            "Line No." := 10000;


            RecRef.GetTable(IncomingDocumentAttachment);
            TempBlob.ToRecordRef(RecRef, IncomingDocumentAttachment.FieldNo(Content));
            RecRef.SetTable(IncomingDocumentAttachment);

            Validate("File Extension", LowerCase(CopyStr(FileManagement.GetExtension(FileName), 1, MaxStrLen("File Extension"))));
            Name := CopyStr(FileManagement.GetFileNameWithoutExtension(FileName), 1, MaxStrLen(Name));
            "Document No." := IncomingDocument."Document No.";
            "Posting Date" := IncomingDocument."Posting Date";

            Insert(true);

            if Type in [Type::Image, Type::PDF] then
                OnAttachBinaryFile;
        end;
    end;
}

